"""T-slot / keyseat cutter comparison for ``strategy_planner.compare`` (feature type ``tslot``).

Lengths in inches, feeds IPM, times minutes. Speeds, feeds, radial depth per pass, axial step and neck deflection
come from ``tslot_model`` (the T-slot model); this module sequences them into passes and a cycle time.

Job: a T-slot of height H (Z extent), radial depth R (into the wall) and length L, cut with a cutter of kerf k
(head thickness), head diameter D, neck and reach from the shop tool file or a geometry given in the request.
  * Z cuts = ``axial_plan.cuts`` of the model: 1 when H <= k; else H is covered in steps of 0.8 k when both faces
    cut (the cutter can move up and down, Z moves at the model's face feed), or one full kerf level at a time when
    only the periphery cuts (retract, move Z, re-enter).
  * Radial passes per Z cut = ceil(R / radial depth per pass) from the model, each a lateral pass of length L at
    the model's lateral feed (zig-zag, no return); radial steps between passes at lateral feed.
"""
from __future__ import annotations

import math
from typing import Any, Dict, List, Optional

MM = 1.0 / 25.4


def _geom(c: Dict[str, Any], idx: int, shop: Dict[str, Dict[str, Any]]) -> Dict[str, Any]:
    """Cutter geometry in inches from a shop tool id or an explicit geometry dict (inch keys or *_mm keys)."""
    from strategy_planner import _num
    w = f"candidate_tools[{idx}]."
    if c.get("id"):
        tid = str(c["id"])
        if tid not in shop:
            raise ValueError(f"unknown T-slot tool id {tid!r}; known: {', '.join(sorted(shop))}")
        t = shop[tid]
        g = dict(diameter=t["diameter_mm"] * MM, kerf=t["kerf_mm"] * MM, neck_diameter=t["neck_diameter_mm"] * MM,
                 reach=t["reach_mm"] * MM, shank_diameter=t["shank_diameter_mm"] * MM, teeth=t["teeth"],
                 tooth_form=t.get("tooth_form"), coating=t.get("coating", "Uncoated"),
                 teeth_per_face=t.get("teeth_per_face"), cutting_faces=t.get("cutting_faces"),
                 provisional=list(t.get("provisional") or []), name=t.get("name", tid), id=tid,
                 planned=bool(t.get("planned")), source_url=t.get("source_url"),
                 vendor_data=str(tid).startswith("harvey"))
        return g
    src = c.get("geometry") if isinstance(c.get("geometry"), dict) else c

    def dim(name: str) -> Optional[float]:
        v = _num(src, name, positive=True, where=w)
        if v is not None:
            return v
        v = _num(src, name + "_mm", positive=True, where=w)
        return None if v is None else v * MM
    D, k, neck, reach = dim("diameter"), dim("kerf"), dim("neck_diameter"), dim("reach")
    for nm, v in (("diameter", D), ("kerf", k), ("neck_diameter", neck), ("reach", reach)):
        if v is None:
            raise ValueError(f"'{w}{nm}' (or '{nm}_mm') is required for a T-slot cutter without 'id'")
    shank = dim("shank_diameter") or D
    teeth = int(_num(src, "teeth", default=4, positive=True, where=w))
    prov = list(src.get("provisional") or [])
    return dict(diameter=D, kerf=k, neck_diameter=neck, reach=reach, shank_diameter=shank, teeth=teeth,
                tooth_form=src.get("tooth_form"), coating=str(src.get("coating") or "Uncoated"),
                teeth_per_face=src.get("teeth_per_face"), cutting_faces=src.get("cutting_faces"), provisional=prov,
                name=str(src.get("name") or f"{D:.3f}in x {k:.4f}in T-slot"), id=None, planned=False, source_url=None,
                vendor_data=False)


def _hrc(physics, family: str, alloy: str) -> Optional[float]:
    """HRC of the alloy from its Brinell hardness (as tslot_model.run_for_request does); None when unknown."""
    try:
        hb = physics.resolve_alloy_hardness(family, alloy) if alloy else None
        if hb:
            from gwizard_physics import ASTMHardnessConverter
            hrc = ASTMHardnessConverter.brinell_to_hrc(float(hb))
            return max(0.0, hrc) if hrc is not None else None
    except Exception:
        return None
    return None


def compare_tslot(req: Dict[str, Any], physics: Any, machine: Dict[str, Any], m: Any) -> Dict[str, Any]:
    """Compare T-slot cutters on one job. ``req`` is the validated request (see strategy_planner._validate)."""
    import tslot_model
    from strategy_planner import (_num, _material, _life, _rank, _reasoning, _common_assumptions, MM_PER_IN)
    feat = req["feature"]
    H = _num(feat, "slot_height", positive=True, where="feature.") or _num(feat, "height", positive=True, where="feature.")
    R = _num(feat, "radial_depth", positive=True, where="feature.")
    L = _num(feat, "length", positive=True, where="feature.")
    for nm, v in (("slot_height", H), ("radial_depth", R), ("length", L)):
        if v is None:
            raise ValueError(f"'feature.{nm}' is required for a tslot job (inches)")
    shop = tslot_model.load_shop_tools()
    material = _material(physics, req)
    hrc = _hrc(physics, req["family"], req["alloy"])
    options: List[Dict[str, Any]] = []
    for i, c in enumerate(req["candidates"]):
        if not isinstance(c, dict):
            raise ValueError(f"candidate_tools[{i}] must be an object")
        g = _geom(c, i, shop)
        common = dict(diameter=g["diameter"], kerf=g["kerf"], neck_diameter=g["neck_diameter"], reach=g["reach"],
                      shank_diameter=g["shank_diameter"], teeth=g["teeth"], tooth_form=g["tooth_form"],
                      cutting_faces=g["cutting_faces"], teeth_per_face=g["teeth_per_face"], coating=g["coating"],
                      hardness=hrc, aggressiveness=req["aggressiveness"], runout=req["runout"],
                      max_rpm=machine["max_rpm"], max_hp=machine["max_hp"], slot_height=H, radial_depth_total=R,
                      provisional=g["provisional"], name=g["name"])
        full = tslot_model.compute_tslot(physics, req["family"], operation="full_slot", **common)
        axial = tslot_model.compute_tslot(physics, req["family"], operation="axial_step", **common)
        plan = full["axial_plan"]
        cuts = int(plan["cuts"])
        z_step = float(plan.get("z_step_in") or 0.0)
        passes = int(full["radial_passes"])
        ae = full["radial_depth_per_pass_in"]
        lat = full["lateral_feed_ipm"]
        ax = axial.get("axial_feed_ipm")
        both = bool(ax) and "top" in full["cutting_faces"] and "bottom" in full["cutting_faces"]
        t_cut = cuts * passes * L / lat
        t_radial = cuts * max(0, passes - 1) * ae / lat
        z_moves = max(0, cuts - 1)
        if both and z_moves:
            t_z = z_moves * z_step / ax
            z_note = f"{z_moves} Z steps of {z_step:.4f} in with the cutter faces cutting at {ax:.2f} ipm"
        else:
            t_z = z_moves * ((2.0 * R + g["kerf"]) / m.rapid)
            z_note = (f"{z_moves} Z level changes: retract, move, re-enter (straight-tooth or one-face cutter)"
                      if z_moves else "single Z level")
        t_pos = 2.0 * m.retract / m.rapid
        cycle = t_cut + t_radial + t_z + t_pos
        life = _life(material, full["sfm"], g["diameter"], ae)
        wear = (cycle - t_pos) / life["life"] if life.get("life") else None
        crit = [w["message"] for w in full["warnings"] if w["type"] == "critical"]
        warn = [w["message"] if w["title"] == "Provisional geometry" else f"{w['title']}: {w['message']}"
                for w in full["warnings"] if w["type"] in ("warning", "critical")]
        risks = list(warn)
        if H < g["kerf"] * 0.999:
            crit.append(f"slot height {H:.4f} in is smaller than the cutter kerf {g['kerf']:.4f} in")
            risks.append(crit[-1])
        if g["planned"]:
            risks.append("planned tool (not owned yet)")
        basis = ("vendor data: the T-slot model is calibrated on Harvey keyseat speed/feed sheets and this is a Harvey part "
                 "(tests/benchmarks/tslot/harvey.json)" if g["vendor_data"] else
                 "physics only: no vendor cutting data exists for this cutter; numbers are the T-slot model's extrapolation")
        options.append({
            "name": g["name"] if not g["id"] else f"{g['id']}: {g['name']}",
            "strategy": "tslot",
            "tool": {"id": g["id"], "diameter": round(g["diameter"], 5), "kerf": round(g["kerf"], 5),
                     "neck_diameter": round(g["neck_diameter"], 5), "reach": round(g["reach"], 5),
                     "shank_diameter": round(g["shank_diameter"], 5), "teeth": g["teeth"],
                     "tooth_form": full.get("tooth_form"), "teeth_per_face": full["teeth_per_face"],
                     "cutting_faces": full["cutting_faces"], "coating": g["coating"]},
            "levels": cuts, "ap": round(g["kerf"], 5), "ae": round(ae, 5), "rpm": round(full["rpm"]),
            "feed_ipm": round(lat, 3), "sfm": round(full["sfm"], 1), "fz_in": round(full["chip_load_ipt"], 6),
            "radial_passes": passes, "z_steps": z_moves, "z_step_in": round(z_step, 5),
            "axial_feed_ipm": None if ax is None else round(ax, 3),
            "path_length_in": round(cuts * passes * L, 3), "link_length_in": 0.0,
            "cycle_time_min": cycle, "cutting_minutes": cycle - t_pos,
            "time_breakdown_min": {"cutting": t_cut, "ramp_entries": 0.0,
                                   "links_and_retracts": t_radial + t_z + t_pos},
            "wear_raw": wear, "relative_tool_life": ((cycle - t_pos) / wear) if wear else None,
            "neck_deflection_in": round(full["deflection_in"], 6), "neck_deflection_limit_in": round(full["deflection_limit_in"], 6),
            "neck_stress_ksi": round(full["neck_stress_ksi"], 1), "limited_by": full["limited_by"],
            "feasible": not crit, "risks": risks, "critical": list(crit),
            "provisional_geometry": list(g["provisional"]), "data_basis": basis,
            "notes": [f"{cuts} Z cut(s) x {passes} radial pass(es) of {ae:.4f} in (radial {R:.4f} in); {z_note}",
                      f"engagement angle {life['phi_deg']:.0f} deg per radial pass",
                      f"teeth {g['teeth']} ({full.get('tooth_form') or 'unknown form: staggered assumed'}), "
                      f"{full['teeth_per_face']} per face"],
            "fusion_hints": {"fusion_strategy": "2D Contour with a T-slot / slot mill (Slot tool), or a 3D radial-passes toolpath",
                             "tool_diameter_in": round(g["diameter"], 5), "kerf_in": round(g["kerf"], 5),
                             "multiple_depths": {"useStepdown": z_moves > 0, "maximumStepdown_in": round(z_step, 5) if z_moves else None,
                                                 "levels": cuts},
                             "optimal_load_in": None, "stepover": f"radial depth per pass {ae:.4f} in ({passes} passes)",
                             "ramp": {"type": "radial entry", "note": "enter radially from the open groove; no ramp for a T-slot cutter"},
                             "tabs": None, "stock_to_leave": {"radial_in": 0.0, "axial_in": 0.0},
                             "finishing_pass": "Optional light finishing pass on the slot back wall at ToolWiz numbers.",
                             "feed_rpm_source": "tslot_model.compute_tslot (T-slot model)"},
            "stock_to_leave_in": {"radial": None, "axial": None},
            "phases": [{"name": "T-slot passes", "operation": "T-slot full slot", "rpm": round(full["rpm"]),
                        "sfm": round(full["sfm"], 1), "feed_ipm": round(lat, 3), "fz_in": round(full["chip_load_ipt"], 6),
                        "ap": round(g["kerf"], 5), "ae": round(ae, 5), "in_cut_min": cycle - t_pos,
                        "engagement_angle_deg": round(life["phi_deg"], 1),
                        "edge_fraction": round(life["edge_fraction"], 4),
                        "taylor_life_ratio": None if life["taylor"] is None else round(life["taylor"], 3),
                        "taylor_life_ratio_uncapped": None if life["taylor"] is None else round(life["taylor_raw"], 3),
                        "relative_life": None if life["life"] is None else round(life["life"], 3), "note": ""}],
        })
    best, _, allowed, _ = _rank(options, req["aggressiveness"])
    for o in options:
        o["cycle_time_min"] = round(o["cycle_time_min"], 4)
        o["cutting_minutes"] = round(o["cutting_minutes"], 4)
        o["time_breakdown_min"] = {k: round(v, 4) for k, v in o["time_breakdown_min"].items()}
    reasoning = _reasoning(options, best, allowed, req["aggressiveness"], "tslot")
    prem = [o for o in options if o["tool"].get("id") and str(o["tool"]["id"]).startswith("harvey")]
    if prem and best is not None:
        for p in prem:
            others = [o for o in options if o is not p and o["feasible"]]
            if others and p["feasible"]:
                ref = min(others, key=lambda o: o["cycle_time_min"])
                gain = (1.0 - p["cycle_time_min"] / ref["cycle_time_min"]) * 100.0
                word = f"{abs(gain):.0f}% {'shorter' if gain >= 0 else 'longer'}"
                reasoning.append(f"{p['name']} vs the fastest feasible alternative ({ref['name']}): cycle time {word}, "
                                 f"wear {p['tool_wear_per_part']:.2f}x vs {ref['tool_wear_per_part']:.2f}x. Basis: {p['data_basis']}.")
    for o in options:
        if o["provisional_geometry"]:
            reasoning.append(f"{o['name']}: provisional geometry ({', '.join(o['provisional_geometry'])}) - measure neck diameter, "
                             f"reach and tooth form before trusting the neck deflection and pass count.")
    assumptions = _common_assumptions(m, req, "tslot")
    assumptions = [a for a in assumptions if not a.startswith("Cycle time per part")] + [
        "T-slot cycle: Z cuts x radial passes x length / lateral feed (zig-zag, no return), radial steps at lateral feed, Z steps at the "
        "model's face feed when both faces cut (else retract and re-enter at rapid), one approach and retract. The slot's entry groove, "
        "tool change and chip clearing are not included.",
        "T-slot speeds come from tslot_model (database carbide SFM x saw reduction x family fit x hardness x aggressiveness; chip load fit on "
        "Harvey keyseat sheets); relative tool life applies the v2 Taylor law at that SFM and the radial engagement, an extrapolation "
        "for these cutters.",
    ]
    return {"options": options, "recommended": best["name"] if best else None, "reasoning": reasoning,
            "assumptions": assumptions, "skipped": [], "tab_advice": [], "wear_ratio_limit": allowed}
