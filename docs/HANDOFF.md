# ToolWiz handoff (written 2026-11-13)

For a new Claude session picking up this project. Read this first, then the documents it points to.

## Where things are

- **Branch to work on:** `toolwiz/v4-advisor`. `master` is NOT updated: the owner merges only after their own testing.
  `toolwiz/v3-advisor` is the previous stable state. Side branches `v4/*` are merged and can be ignored.
- **Feature freeze (owner decision, 2026-11-12):** no new features. Fix only what the owner's testing finds. Flag any request
  that would add a new subsystem and suggest doing it as a separate project.
- **Two sessions push to this branch:** a cloud session (code changes, full test suite) and a local session on the owner's
  shop PC (only what needs Windows or live Fusion; it writes test reports to `docs/`). Always `git pull` before pushing.
- **Owner preferences:** heavy jobs run in the cloud, not on the shop PC. Keep token use economical (cheaper subagents for
  data and UI work). No pull request unless asked. Plain-language reports; say what was and was not verified.

## What ToolWiz is

A speeds-and-feeds engine, CAM advisor and tool-library manager for a Brother Speedio S500X2 (BT30, 16,000 rpm), as a
local Flask web app plus a Fusion 360 add-in. Start with `README.md`.

- "v2" is the CURRENT physics engine (`physics_v2/`); "v1" is the older table engine (`gwizard_physics.py`), still used
  for facing, drilling, tapping and a few tool types. "v3" / "v4" are project phases, not engines.
- Vendor charts (`tests/benchmarks/v2/*.json`) guard the physics: brand first, then a Harvey + Helical default, then a
  cross-vendor consensus. 0 / 50 / 100 % aggressiveness = bottom / middle / top of the vendor range.
- Engine history and numbers: `docs/V4_ENGINE_NOTES.md`. Owner decisions: `docs/V3_IMPLEMENTATION_PLAN.md`.
- Studies live as a script plus a document (`docs/SLOT_ROUGHING_STUDY.md`, `tools/slot_roughing_study.py`).

## Tests

```
timeout 1800 python3 -m pytest -q -p no:cacheprovider -k "not conformance and not stability"   # fast, about 4 min
timeout 3000 python3 -m pytest -q -p no:cacheprovider                                         # full, about 10 min
```

Never loosen a conformance tolerance or add an expected-failure mark to get green. Missed gates stay as strict xfails with
the measured number. Check the exit status directly; a pipe into `tail` hides failures.

## Open items

1. **Owner is testing in Fusion.** Checklist: AI chat with a live key; chat proposing a change and the Fusion confirm;
   tool-field write-back; probing ops show "does not cut"; Face1 stepover about 0.156 in; brand from the Fusion vendor
   field; blank runout = automatic; alternative-tools card; a high-feed tool's ramp and wall notes.
2. **Local session re-checks** of the 2026-11-13 bridge fixes (`docs/FUSION_BRIDGE_LOCAL_TEST_2026-11-13.md`,
   `tests/test_local_bridge_report_2026_11_13.py`): second server refusal on Windows, `addin_polling`, operation labels,
   a real MCP client on `/api/mcp`.
3. **Asked of the owner, not yet answered:**
   - Rate SK / SX collet holders at 0.0001 in throughout? (The holder advice lists SK under "avoid" for ultra-precision
     cuts, but the runout defaults already use 0.0001 in for Lyndex SK and Pioneer SX.)
   - Rewrite the two jargon notes ("v2 ramp: R1 ...", "Cutting model: v2") in plain words?
   - Look into the ramp-angle rule (18.2 degrees came out for a 1/4 in tool in 7075; vendor guidance is nearer 3 to 10)?
   - Confirm the controller name "CNC-C00" in `machines/speedio_s500x2.json`.
4. **Three AI entry points exist** (AI Machinist co-pilot panel, AI Setup Advisor Chat tab, local Claude session over
   MCP). Recommendation given: use the local session; remove the other two later if it proves itself. Owner's call.
5. **Known gaps:** micro-tool conformance (about 80 % on the cross-vendor run); unbranded high-feed slots (about 69 %);
   adaptive chip load in aluminium is conservative (flute-count correction not applied to HEM: one vendor per flute
   count); no axial-load check for high-feed tools; ball and bull-nose tools have no per-brand charts.
6. **After the freeze, owner chooses one:** retire v1 (move facing, drilling, tapping to the physics engine; this also
   removes the G-Wizard-derived code that blocks open-sourcing), or a separate project (part-number web lookup with an
   approval queue; whole-setup optimizer; spindle-speeder study).

## Added 2026-11-13 (later)

- **Ramp angle fixed** (`docs/V4_ENGINE_NOTES.md`, ramp section): the angle follows the brand-first rule and the
  bottom / middle / top range like speeds; flute count and reach decide which vendor rows a tool may use; a tool no chart
  covers gets the bottom of the range. Generic 4-flute in 7075: 6.4 deg at 50% (was 18.2). Not yet run in Fusion.
- **Study in progress / done:** `docs/PHYSICS_VS_CHARTS_STUDY.md` (how often the vendor chart decides versus physics;
  whether a "generic / import carbide" grade is worth adding). Owner's steer: unnamed tools should run somewhat more
  conservatively, but "not too much lower": cheap carbide has been better than expected.
- **Owner's tools:** T1 and the 1/16 in end mill are Haas-branded, which the owner says are made by YG-1; the 1/16 in ball
  is a cheap import. Haas is not mapped to any vendor chart today (owner to decide: label those tools YG-1, or add an alias).
- **Separate project the owner wants next (new chat):** clean up the tool libraries. Make the cloud / hub library the
  master, then replace the document tools from it, and log every large change to axial depth, radial depth and ramp angle
  with the reason. Existing pieces to build on: `master_library.py`, `library_audit.py`, `tool_library_curator.py`,
  `docs/TOOL_LIBRARY_NOTES.md`, `docs/SHOP_LIBRARY_AUDIT.md`, the add-in's `update_tool_fields` bridge action (not yet
  proven against live Fusion), and the description convention for coating / HSS in `docs/ADDIN_USER_GUIDE.md`.

## Things that bit us

- The result cache key once lacked the flute count: every flute count got the first tool's answer. Any new engine input
  must go into `v2_bridge._cache_key`.
- On Windows two servers can bind port 5000; `app.py` now refuses a second start.
- A stdio `python mcp_server.py` has its own bridge queue that Fusion never polls. Agents must use `POST /api/mcp` on
  the running server (`.mcp.json`).
- The add-in's result dialog must keep its question on the first line; long reports push text off the screen.
