# Kickoff prompt: ToolWiz cutting model v2

Paste the block below into a new Claude Code chat whose working folder is `C:\Users\matti\.gemini\antigravity\scratch`.

---

I'm continuing work on ToolWiz, my speeds-and-feeds engine and Fusion 360 add-in. The repo is `C:\Users\matti\.gemini\antigravity\scratch` (GitHub `OffworldGear/ToolWiz-engine`, private). The working branch is `toolwiz/hardening`; master is not merged.

**Read first:**
- `docs/PHYSICS_MODEL_DESIGN.md`: the approved direction, a physics-based cutting model ("v2").
- `docs/research/harvey_micro_data.md`: vendor data showing v1 is 2–7× too aggressive for small tools in steel.
- `docs/OPEN_ITEMS.md`: everything else still open.

**Today's task:** step 1 of §6 in the design, data first.
1. Build the v2 benchmark dataset at `tests/benchmarks/v2/` following §4.2:
   - every row cites vendor, document, table and exact cells, with a URL;
   - include the full tool geometry, with the real shank and neck;
   - at least two independent vendors per diameter/material/operation cell where data exists;
   - start with Harvey, Helical, OSG, Sandvik and Kennametal published charts.
2. Source the Sandvik Coromant kc1.1/mc values by material group. Propose the mapping from ToolWiz's 31 GWizard material families to those groups.
3. Source carbide properties: E, transverse rupture strength (TRS) and fatigue fraction. Source edge radius by coating and size for micro tools (§3.5, C1/C2).
4. Write what you found and what is missing to `docs/research/`. Don't change the v1 engine.

**Rules:**
- Physics first. Vendor data calibrates and validates the model; it is never copied in as a lookup table.
- Never loosen a benchmark target to make a test pass.
- Cite every number.
- Run the full tests with `PYTHONPATH=. python -m unittest discover -s tests` (451 pass today, plus 25/25 vendor benchmarks). Commit only when the output shows `OK`.
- Use Windows paths with backslashes in anything you tell me to run.
- Use cheaper models for lookups and research and keep the main model for design and review.
- Ask me before decisions in §7 of the design.

**Machine:** Brother Speedio S500X2, 16k non-dual-contact spindle, max HP 6.84 (user-editable), 16,000 RPM.

**My tools for side-by-side checks:**
- T1: 1/8" 4-flute, flute length 0.5", stickout 0.6".
- T12: 1/16" 4-flute rougher. Its Fusion definition still has a 1/16" shank, which I'm correcting to 1/8".
- I mostly cut 17-4 / 17-7 PH stainless.

**Server:** the desktop "Tool Wizard" shortcut restarts a stale server automatically. Use "Restart Tool Wizard" to force a restart. Install the Fusion add-in with `python install_addin.py`, then stop and start it in Fusion (Shift+S).
