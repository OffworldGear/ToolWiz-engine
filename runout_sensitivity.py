"""Runout sensitivity: how the recommended cut (and its material removal rate) changes with holder runout.

``analyze(run, body, ...)`` takes a function ``run(body) -> dict`` that answers one ``/api/calculate``-style
request (``routes_runout`` passes the app's own calculate view, so the tool / material / operation fields and
the engine are exactly those of the Speeds & Feeds page, ``pipeline.run_cut`` underneath), calls it once per
runout and returns the table plus a plain-words summary: MRR at the typical TIR of each holder class in
``data/holders.json`` and the MRR gained by moving from the shop's current class to each better one.

Runouts are TIR at the cutting edge in inches. Nothing here changes the physics; it only sweeps one input.
"""
from __future__ import annotations

import json
import math
import os
from typing import Any, Callable, Dict, List, Optional

DEFAULT_RUNOUTS_IN = [0.0, 0.00005, 0.0001, 0.00015, 0.0002, 0.0003, 0.0005]
MAX_RUNOUTS = 16
MAX_RUNOUT_IN = 0.005
_HOLDERS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "holders.json")

# Holder classes of the owner's question and the holders.json ids that make each one.
HOLDER_CLASSES = (
    ("er_standard", "standard ER collet", ("er_standard",)),
    ("er_up", "ER-UP collet", ("er_ultra_precision",)),
    ("sk", "SK/SKC precision collet", ("sk_collet_chuck",)),
    ("hydraulic_shrink_powrgrip", "hydraulic / shrink-fit / powRgrip", ("hydraulic", "shrink_fit", "powrgrip")),
    ("micro_chuck", "micro collet chuck", ("micro_collet_chuck",)),
)


# Plain words for the physics constraint ids in ``limited_by`` (same wording as the results panel).
CHECK_WORDS = {
    "C1": "minimum chip thickness", "C2": "chip thickness (chip load limit)", "C3": "tool deflection",
    "C4": "tool bending stress", "C5": "spindle power or torque", "C6": "tool geometry (reach and clearance)",
    "C7": "spindle speed (rpm cap or tool life)", "C8": "depth-of-cut cap from vendor limits",
    "C9": "long-stickout chatter speed reduction", "C10": "work-hardened layer", "C11": "machine feed limit",
    "C12": "every flute must reach the stock", "C14v": "vendor speed ceiling", "C14f": "vendor chip-load ceiling",
    "C14m": "vendor removal-rate ceiling", "C14lo": "minimum chip-load floor for small tools",
    "C2o": "chip thickness with runout", "holder_clearance": "holder clearance", "neck_clearance": "neck clearance",
}


def limited_words(limited_by: Optional[str]) -> str:
    ids = [i for i in str(limited_by or "").replace("v2:", " ").replace(",", " ").split() if i]
    return "; ".join(CHECK_WORDS.get(i, i) for i in ids)


def fmt_in(v: float) -> str:
    """0.0002 -> '0.0002"', 0.00012 -> '0.00012"', 0 -> '0"'."""
    if v == 0:
        return '0"'
    return f'{v:.5f}'.rstrip("0").rstrip(".") + '"'


def holder_classes() -> List[Dict[str, Any]]:
    """[{id, label, tir_in, clamp_mm, sources}] from data/holders.json; the TIR of a class is the largest
    published TIR of its members (worst case, as the advisor uses it)."""
    with open(_HOLDERS, encoding="utf-8") as fh:
        by_id = {h["id"]: h for h in json.load(fh)["holders"]}
    out = []
    for cid, label, members in HOLDER_CLASSES:
        hs = [by_id[m] for m in members if m in by_id]
        if not hs:
            continue
        clamp = [min(h["clamp_mm"][0] for h in hs), max(h["clamp_mm"][1] for h in hs)] if all(h.get("clamp_mm") for h in hs) else None
        out.append({"id": cid, "label": label, "tir_in": max(float(h["tir_in"]) for h in hs),
                    "clamp_mm": clamp, "members": [h["id"] for h in hs]})
    return out


def _row(res: Dict[str, Any], runout: float) -> Dict[str, Any]:
    def num(k, nd=None):
        v = res.get(k)
        if isinstance(v, (int, float)) and math.isfinite(v):
            return round(v, nd) if nd is not None else v
        return None
    rpm, feed = num("rpm"), num("feedrate")
    return {"runout_in": runout, "rpm": rpm, "feed_ipm": feed, "fz_in": num("adj_ipt", 6),
            "ap_in": num("rec_doc", 5), "ae_in": num("rec_woc", 5), "mrr_in3_min": num("mrr", 5),
            "flutes_cutting": res.get("flutes_cutting"), "runout_regime": res.get("runout_regime"),
            "limited_by": res.get("limited_by"), "limited_by_words": limited_words(res.get("limited_by")),
            "feasible": res.get("feasible")}


def _nearest_class(runout: float, classes: List[Dict[str, Any]]) -> Dict[str, Any]:
    if runout <= 0:
        return classes[-1]
    return min(classes, key=lambda c: abs(math.log(c["tir_in"] / runout)))


def _gain_sentence(cur: Dict[str, Any], new: Dict[str, Any], label: Optional[str]) -> str:
    a, b = cur["mrr_in3_min"], new["mrr_in3_min"]
    c, n = fmt_in(cur["runout_in"]), fmt_in(new["runout_in"])
    where = f" ({label})" if label else ""
    if not a or not b or not cur.get("feasible") and not new.get("feasible"):
        return f"Going from {c} to {n}{where}: no usable MRR on this cut."
    pct = (b / a - 1.0) * 100.0
    if abs(pct) < 0.5:
        why = new.get("limited_by_words") or "another limit"
        return (f"Going from {c} to {n}{where} changes MRR by less than 1% on this cut: it is limited by "
                f"{why}, not by runout.")
    verb = "raises" if pct > 0 else "lowers"
    return f"Going from {c} to {n}{where} {verb} MRR by {abs(pct):.0f}% on this cut."


def analyze(run: Callable[[Dict[str, Any]], Dict[str, Any]], body: Dict[str, Any],
            runouts: Optional[List[float]] = None, current_runout: Optional[float] = None) -> Dict[str, Any]:
    """Sweep runout. ``run`` must raise on a failed calculation; ``current_runout`` (in) is the shop's present
    holder TIR (default: the body's own ``runout``)."""
    runouts = sorted({round(float(r), 7) for r in (runouts or DEFAULT_RUNOUTS_IN)})
    if not runouts or len(runouts) > MAX_RUNOUTS:
        raise ValueError(f"give 1 to {MAX_RUNOUTS} runout values")
    if any(r < 0 or r > MAX_RUNOUT_IN for r in runouts):
        raise ValueError(f"runouts must be between 0 and {MAX_RUNOUT_IN} in")
    classes = holder_classes()
    if current_runout is None:
        current_runout = body.get("runout")
    current = float(current_runout) if current_runout not in (None, "") else None
    if current is None or current < 0:
        raise ValueError("current runout is required")
    cur_class = _nearest_class(current, classes)

    cache: Dict[float, Dict[str, Any]] = {}
    shank_in = [None]

    def at(r: float) -> Dict[str, Any]:
        r = round(r, 7)
        if r not in cache:
            res = run(dict(body, runout=r))
            if shank_in[0] is None and isinstance(res.get("shank_diameter"), (int, float)):
                shank_in[0] = float(res["shank_diameter"])
            cache[r] = _row(res, r)
        return cache[r]

    rows = [at(r) for r in runouts]
    cur_row = at(current)
    class_rows = []
    for c in classes:
        row = at(c["tir_in"])
        fits = None
        if c["clamp_mm"] and shank_in[0]:
            fits = c["clamp_mm"][0] - 1e-6 <= shank_in[0] * 25.4 <= c["clamp_mm"][1] + 1e-6
        class_rows.append({**{k: c[k] for k in ("id", "label", "tir_in", "clamp_mm")}, "fits_shank": fits,
                           "is_current": c["id"] == cur_class["id"], **{k: row[k] for k in (
                               "rpm", "feed_ipm", "fz_in", "ap_in", "ae_in", "mrr_in3_min", "flutes_cutting",
                               "runout_regime", "limited_by", "limited_by_words", "feasible")}})
    summary = []
    for cr in class_rows:
        if cr["tir_in"] < current * 0.99 and cr["fits_shank"] is not False:
            gain = (cr["mrr_in3_min"] / cur_row["mrr_in3_min"] - 1.0) * 100.0 if cur_row["mrr_in3_min"] else None
            cr["mrr_gain_vs_current_pct"] = None if gain is None else round(gain, 1)
            summary.append(_gain_sentence(cur_row, at(cr["tir_in"]), cr["label"]))
        elif cr["fits_shank"] is False:
            cr["mrr_gain_vs_current_pct"] = None
    if not summary:
        summary.append(f"The current runout {fmt_in(current)} is already at or better than every holder class here; "
                       "there is no holder upgrade to gain from.")
    best = rows[0]
    if best["runout_in"] == 0 and cur_row["mrr_in3_min"]:
        summary.append("Upper bound: " + _gain_sentence(cur_row, best, "zero runout, not achievable"))
    return {"rows": rows, "current": {"runout_in": current, "class_id": cur_class["id"],
                                      "class_label": cur_class["label"], **cur_row},
            "holder_classes": class_rows, "summary": summary, "shank_diameter_in": shank_in[0]}
