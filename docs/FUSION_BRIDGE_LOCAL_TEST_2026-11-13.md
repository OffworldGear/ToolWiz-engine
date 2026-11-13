# Fusion bridge: local test report (2026-11-13)

From the local Claude Code session on the shop PC (Windows 11, Python 3.14.2), branch `toolwiz/v4-advisor` at `9cf54bc`.
For the cloud session: findings to triage and fix. Nothing below has been fixed yet except where it says so.

## Summary

- **The bridge works end to end.** With the add-in running, `POST /api/fusion_bridge/command {"action": "get_setup_summary"}`
  on 127.0.0.1:5000 returned the open document within seconds: "EndCapOnlyManufacture (~recovered)", 3 setups,
  45 operations, 22 tools in the document library.
- **Already fixed (`9cf54bc`):** MCP over HTTP. `.mcp.json` used to start a separate stdio `python mcp_server.py`,
  whose Fusion bridge queue nothing polls (the add-in polls only the queue of the server on port 5000). The
  `/api/mcp` route mentioned in `mcp_server.py`'s docstring didn't exist. Now `python app.py` serves
  `POST /api/mcp`, and `.mcp.json` points at it with the `X-ToolWiz-Client` header.
  **Not yet tested:** a real Claude Code client connecting to it (needs a new local session).
- **Five issues found** (below), ordered by how much they get in the way.

## 1. Two ToolWiz servers can share port 5000 silently (likely cause of "it isn't connected")

Werkzeug's `BaseWSGIServer.allow_reuse_address = True` sets `SO_REUSEADDR` before `bind()`. On Windows that
does **not** stop a second process from binding the same address: I tested it on this PC, and a second socket with
`SO_REUSEADDR` bound and listened on an occupied 127.0.0.1 port without error. So a second `python app.py` /
`py app.py` starts "fine," and Windows then hands each new connection to either process.

Each process has its own in-memory bridge (`fusion_bridge._pending_queue`, live state, results). When two are
running:
- a command queued through one (web UI, MCP, Advisor Chat) may never be seen by the add-in, which is polling the other.
  The command then times out;
- `/api/fusion_bridge/state` reports `connected: false` from the process the add-in isn't posting to;
- results posted by the add-in can land on the wrong process.

Today there was only one listener (checked with `netstat` / `Get-NetTCPConnection`). But the server was
started twice within minutes: once by me (`python app.py`) and once by something else through `py.exe app.py`.
Mine then disappeared. That's exactly how a double server happens. 5000 isn't in a Windows-reserved port range.

**Suggested fix (app.py `__main__`):** before `app.run`, refuse to start if a ToolWiz server already answers.
For example, GET `http://127.0.0.1:5000/api/version` with a 1 s timeout: if it answers, print "ToolWiz is
already running (branch/commit …)" and exit non-zero. Also (or instead), on Windows bind with
`SO_EXCLUSIVEADDRUSE`, e.g. a `BaseWSGIServer` subclass with `allow_reuse_address = False` passed via
`app.run(..., request_handler/…)`, or run through `werkzeug.serving.make_server` with a pre-bound socket.
Add a test that a second start exits with the message.

## 2. `connected` means "a snapshot was posted," not "the add-in is polling"

`fusion_bridge` sets `connected: True` only in `update_live_state()`, which runs when the add-in calls
`push_live_state()`. That only happens from the Setup Advisor command and the `get_setup_summary` bridge action.
The poller (`_bridge_poll_loop`, GET `/api/fusion_bridge/next` every 1 s) leaves no trace. So with the add-in
running and polling, `/api/fusion_bridge/state` says `connected: false`, `updated_at: null` until something asks
for a summary. A server restart wipes it again. This misled both me and the owner today.

**Suggested fix:** record `addin_last_poll` (time) in `pop_next_command()` / the `/next` route, and expose
`addin_polling: true` when the last poll is under ~5 s old. Keep `connected` for the snapshot, or rename it
`snapshot_present`.

## 3. Probe, chamfer, engrave and deburr ops are labeled "Adaptive Roughing" (`is_roughing: true`)

`infer_strategy_for_op()` (ToolWizFusionAddin.py ~3388–3436) has no case for these Fusion strategies, so they fall
through to the default `'Adaptive Roughing'`. Live examples from the snapshot:

| op | Fusion strategy | tool | label given |
|---|---|---|---|
| PrepEndCapStock > Probe WCS1 | probe | T99 Blum probe, NOF 0 | Adaptive Roughing |
| PrepEndCapStock > 2D Chamfer1 | chamfer2d | 1/4 chamfer mill | Adaptive Roughing |
| Op1EndCap7075 > Engrave17 (2) | engrave | 1/8 chamfer mill, 1 flute | Adaptive Roughing |
| Op1EndCap7075 > Deburr8 (2) | deburr | 1/16 ball | Adaptive Roughing |

(6 probe ops, 1 chamfer, 2 engrave, 2 deburr in this document.) The Setup Advisor and any `toolwiz_setup_advisor`
run would then check roughing chip load and engagement on probe moves and deburr passes.

**Suggested fix:** map `probe` (and other non-cutting strategies, e.g. inspection/manual NC) to a skip label
that the advisor ignores. Map `chamfer2d`/`deburr`/`engrave` to a chamfer/finishing label. Make the final
fallback something that doesn't claim roughing (e.g. `'Unknown'`, which the advisor reports as INFO). Add a test
per strategy.

## 4. A drill is labeled a tap because of words in its description

`Op1EndCap7075 > Drill4 (5)` and `Op2EndCap7075 > Drill33 (2)` use T7. T7 is a Fusion `drill` (unit mm, DC 1.45), and
its description is "1.45mm carbide drill for M1.6 form tap". The add-in reports tool_type "Form Tap" and
strategy "Tapping (Form / Roll)". The description keywords ("tap", "form") override Fusion's own tool type.
`kind` correctly says `drill`.

**Suggested fix:** in the tap test inside `infer_strategy_for_op()` and wherever `tool_type` "Form Tap" is
derived, use Fusion's tool `type` first. Treat description keywords as a hint only when the type is
ambiguous. Add a test with this description.

## 5. `inspect_operation` with no `operation` silently inspects the first op

`_find_cam_operation(query)` returns `ops[0]` when the query is empty (ToolWizFusionAddin.py ~7179). The
`inspect_operation` handler (~7214) passes `params.get("operation")` straight through, and
`fusion_bridge._check_params` doesn't require it. A call with a misspelled key (I sent `operation_name` by
mistake) returned `success: true` for "Probe WCS1". A caller would believe it inspected the op it asked for.

**Suggested fix:** require a non-empty `operation` for `inspect_operation` in `fusion_bridge._check_params`
(and in the add-in), and return an error naming the valid key.

## Minor

- `tests/test_advisor_chat.py` does `import pytest` at module level. This PC's Python 3.14 has no pytest, so
  `python -m unittest` can't load it (the rest of the suite runs under unittest). Either drop the import or
  list pytest as a dev requirement.
- `/api/version` reports the commit at server start and doesn't say when the working tree had uncommitted
  changes. Consider a `dirty: true` flag.

## How I tested (all read-only against Fusion)

```
curl -s http://127.0.0.1:5000/api/fusion_bridge/state
curl -s -X POST http://127.0.0.1:5000/api/fusion_bridge/command -H "X-ToolWiz-Client: claude-code" \
     -H "Content-Type: application/json" -d '{"action":"get_setup_summary","params":{},"timeout":15}'
curl -s -X POST http://127.0.0.1:5000/api/fusion_bridge/command -H "X-ToolWiz-Client: claude-code" \
     -H "Content-Type: application/json" -d '{"action":"inspect_operation","params":{"operation":"Op1EndCap7075 > Drill4 (5)"},"timeout":15}'
netstat -ano | findstr :5000
```

No changes were made in Fusion.
