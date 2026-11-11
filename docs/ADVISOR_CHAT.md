# Advisor Chat

A conversational assistant next to Fusion 360 ("another set of eyes on my Fusion screen"). It works through the Setup Advisor's
recommendations with you, using a model and API keys you choose. **ToolWiz stays the source of every number.** Web tab: *Advisor Chat*
(`/#chat`); keep the browser window beside Fusion.

## Setup

1. `pip install -r requirements.txt` (adds the official `anthropic` SDK).
2. Open the tab, then *API keys and settings*: paste a Claude (Anthropic) and/or Gemini (Google AI Studio) key and press Save. Keys are
   stored only in `data/ai_settings.json` (git-ignored, file mode 600), never returned to the browser (it shows "set" and the last four
   characters), and never logged. Alternatively set `ANTHROPIC_API_KEY` / `GEMINI_API_KEY` (or `GOOGLE_API_KEY`); a saved key wins.
3. Pick provider, model and effort. Conversations are saved under `data/advisor_chats/` (git-ignored).

### Models and cost

* **Claude Opus 5.5 (`claude-opus-5-5`) is the default**: the most capable, and the most expensive. **Sonnet 5.5** and **Haiku 5.5** are cheaper
  and faster (Haiku cheapest); Sonnet is a good day-to-day choice. The picker lists the models your key can use (`client.models.list()`),
  falling back to `claude-opus-5-5`, `claude-sonnet-5-5`, `claude-haiku-5-5`, `claude-fable-5-2`. Exact IDs are used, never dated ones.
* *Effort* (low / medium / high) sets the reasoning depth (`output_config.effort`); thinking is always on for Opus / Sonnet / Fable 5.x, so the
  `thinking` parameter is never sent. Higher effort costs more and is slower. Medium is the default.
* The system prompt and tool list are kept stable and automatic prompt caching is on, which lowers the cost of long chats.
* **Gemini**: any model your key lists that supports `generateContent` (the first is the default). Function calling is used; effort is ignored.
  Gemini is the cheaper option; it follows the numbers rule less reliably, so keep the numeric guard on *strict* with it.
* **Server-side refusal fallback is on** for Opus 5.5 / Sonnet 5.5 / Fable 5.2 (`betas=["server-side-fallback-2026-07-01"]`, `fallbacks="default"`).
  If the requested model declines, a fallback model answers and the chat says so ("Another model answered").

## The numeric guard

The system prompt requires that every speed, feed, chip load, rpm, depth, width, stock, time or ratio comes from a tool result in the conversation.
After each assistant reply `toolwiz_common.numeric_guard` checks every number in it against **all tool results of the conversation, your own
messages, session notes and your assumptions** (same rules as the Setup Advisor narrative: unit conversions, 0.5 % rounding, a chip load is not a
length, ...). The result is stored per message (`guard`).

* Default: the reply is shown, each unverified number is marked **unverified** and a banner lists them.
* *Strict numbers*: such a reply is withheld (you can reveal it), the model is told which numbers were rejected and answers once more; if that fails too
  it stays withheld. The guard can also flag harmless numbers that no result contains (a count such as "three operations"); that is by design.

## What the assistant can and cannot do

Can: read the live setup the add-in pushed (and say when it is stale or Fusion is disconnected); run the Setup Advisor, ToolWiz calculations,
strategy comparison, holder and tool advice, and runout sensitivity (when `POST /api/runout_sensitivity` exists; otherwise it says "not available");
keep **assumptions** (coating, tool material / grade, material, runout per tool or diameter, aggressiveness, finish mode, holder type; scoped to all
tools, tool numbers, a diameter or operations) that apply to every run in the chat without touching Fusion: "all my tools are AlTiN" removes the
"coating unknown" findings (it fills gaps only; a coating Fusion already states is kept unless the assumption has `override`); propose changes; optionally look at a screenshot.

Proposed changes: *operation values* must equal ToolWiz's `apply_plan` values of the last advisor run (the validated `/api/setup_advisor/apply` path);
*tool fields* (coating, BMC, GRADE, comment, description or description keywords such as "staggered") go through the new bridge action
`update_tool_fields`. **Approve** in the chat only queues the change; the add-in then shows old -> new in a Fusion dialog and writes only after you confirm
(audited, Undo reverts, `revert_<time>.json` is saved). Results come back as `{ok, applied, skipped, error}` and are reported to the model.

Cannot: invent numbers, change anything without both confirmations, write fields outside the allow-list, edit toolpaths, or know anything Fusion
has not sent. The tool-library write uses `Tool.createFromJson` + `DocumentToolLibrary.update(tool, False)` (a tool edit applies to every operation using that
tool; speeds and feeds are untouched) and must be checked once in Fusion (see "To verify in Fusion").

### Bridge actions (add-in)

`update_tool_fields {tool_number | tool_guid, fields, reason}` and `get_viewport_image {width, height}` (read-only; `Viewport.saveAsImageFile`, a temporary
PNG returned base64 and deleted). The server validates (`fusion_bridge.check_tool_fields`), the add-in validates again (`twlogic.validate_tool_fields`).

## Built-in chat or an external assistant (MCP)?

Use the **built-in chat for day-to-day work**: it shows unverified numbers, keeps assumptions as chips, queues approvals with buttons, and keeps history.
Use **MCP for power use** (Claude Desktop / Claude Code / Antigravity with your own subscription): `toolwiz_set_assumption`, `toolwiz_apply_recommendation`
(same validated apply path), `fusion_update_tool_fields`, `fusion_bridge_result`, and the MCP prompt **`review_setup`** that walks the assistant through the same review.
An external assistant is not checked by the numeric guard; its server instructions forbid invented numbers. MCP assumptions live for the server process.

## Privacy

Sent to the provider you chose: your messages, the system prompt, the live setup snapshot (document name, operations, tools, parameters), and ToolWiz tool results.
If enabled in settings and the model asks, a screenshot of the Fusion viewport. Nothing is sent when you do not chat. No keys are in the repository; they are only in
`data/ai_settings.json` or the environment. Saved chats (`data/advisor_chats/`, screenshots stripped) stay on this computer.

## To verify in Fusion

1. `update_tool_fields`: `DocumentToolLibrary.update` with a tool rebuilt by `Tool.createFromJson` keeps one copy of the tool (tool count unchanged) and the new description / BMC / GRADE show in the library.
2. `get_viewport_image` returns a PNG on the main thread.
3. The confirmation dialogs show old and new values.
