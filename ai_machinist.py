"""
ToolWiz AI Machinist - Context-Aware CAM & Machining Intelligence Module
Integrates Google Gemini with real-time ToolWiz physics telemetry.
"""

import os
import json
import httpx


SYSTEM_INSTRUCTION = """You are the ToolWiz AI Machinist & Senior CAM Applications Engineer (Fusion 360, Mastercam, Siemens NX).
You have deep, first-principles expertise in cutting tool mechanics, metallurgy (work-hardening, austenitic stainless, superalloys, titanium), machine rigidity, cantilever beam deflection, surface finish, chip thinning, entry dynamics, and CAM toolpath strategies.

You are provided with the live ToolWiz session state (material alloy, cutter geometry, cut depths, speeds, feeds, calculated deflection, and active physics advisor alerts).

When answering:
1. Directly and thoroughly answer the user's specific question with actionable, shop-floor proven recommendations.
2. Directly reference the active machining context provided (e.g. active material alloy, cutter diameter, stickout, calculated deflection, and operation).
3. If asked about CAM parameters (like Stock to Leave, Negative Stock to Leave, Stepover, Ramping Angle, Spring Passes, Lead-in/Lead-out):
   - Provide concrete, numeric values with units (both Imperial and Metric).
   - Explain the physical and metallurgical mechanics (e.g. radial tool deflection vs axial spindle compliance vs elastic workpiece springback).
   - Detail the exact CAM software workflow (e.g., in Fusion 360 2D/3D Contour or Flat Finishing).
4. Warn the machinist of potential failure modes (e.g. accidental floor gouging, work hardening from rubbing, thermal shock in wet milling, chatter due to stickout) and provide mitigation steps.
5. Format your output clearly in clean GitHub Flavored Markdown with bold headers, bullet points, and code/parameter callouts.
"""


def format_context_for_prompt(context: dict) -> str:
    """Format the active machining context dictionary into a readable markdown block."""
    if not context:
        return "No live tool/material context available."

    material = context.get("material", "Unknown")
    family = context.get("materialFamily", "General")
    tool = context.get("tool", "End Mill")
    geo = context.get("geometry", "Standard")
    dia = context.get("diameter", "0.5")
    flutes = context.get("flutes", "4")
    flute_len = context.get("fluteLength", "1.0")
    stickout = context.get("stickout", "1.5")
    coating = context.get("coating", "None")
    carbide = context.get("isCarbide", True)
    op = context.get("operation", "Roughing")
    
    doc = context.get("cutDepth", "0.25")
    woc = context.get("cutWidth", "0.10")
    rpm = context.get("rpm", "0")
    feed = context.get("feedrate", "0")
    sfm = context.get("sfm", "0")
    ipt = context.get("ipt", "0")
    plunge = context.get("plungeFeed", "0")
    ramp_feed = context.get("rampFeed", "0")
    ramp_angle = context.get("rampAngle", "0")
    
    deflection = context.get("deflection", "0")
    spindle_load = context.get("spindleLoadPct", "0")
    mrr = context.get("mrr", "0")
    tips = context.get("tips", [])
    
    tips_str = ", ".join(tips) if tips else "None active"

    return f"""### Active Machining Telemetry:
- **Workpiece Material**: {material} (Family: {family})
- **Cutter Setup**: {tool} ({geo}), {dia}\" dia, {flutes}-flute, Flute Length: {flute_len}\", Stickout: {stickout}\", Coating: {coating} ({'Carbide' if carbide else 'HSS'})
- **Operation**: {op}
- **Programmed Engagement**: Axial DOC: {doc}\", Radial WOC: {woc}\"
- **Kinematics**: {rpm} RPM, {feed} IPM ({sfm} SFM, {ipt} IPT), Plunge: {plunge} IPM, Ramp: {ramp_feed} IPM @ {ramp_angle}°
- **Calculated Physics**: Lateral Deflection: {deflection}\", Spindle Load: {spindle_load}%, MRR: {mrr} in³/min
- **Physics Advisor Alerts**: {tips_str}
"""


def get_offline_expert_response(prompt: str, context: dict) -> str:
    """Provides high-quality, physics-based fallback answers when no API key is set."""
    p_lower = prompt.lower()
    mat = context.get("material", "Nitronic 60 / Stainless Steel") if context else "tough alloy"
    dia = context.get("diameter", "0.5") if context else "0.5"
    op = context.get("operation", "Finishing") if context else "Finishing"
    
    if any(k in p_lower for k in ["negative stock", "stock to leave", "flat", "spring back", "springback", "floor"]):
        return f"""### 🎯 Recommendation: Negative Stock to Leave & Floor Finishing in {mat}

Yes! Utilizing **negative stock to leave on flats/floors** is an established shop technique, but understanding the difference between **deflection** and **springback** is crucial:

---

### 1. The Physics: Tool Deflection vs. Springback
- **Tool Deflection ($F_\\text{{radial}}$ is Near Zero)**:
  On bottom floor finishing, cutting occurs on the tool's end teeth (wiper/dish geometry). Because radial engagement against a wall is minimal or decoupled, lateral cantilever beam deflection is virtually non-existent.
- **Axial Spindle Compliance ($F_z$ Thrust)**:
  Axial cutting force pushes vertically **up** into the spindle bearings, toolholder taper, and machine Z-axis ballscrew.
- **Workpiece Elastic Springback ($E_\\text{{elastic}}$)**:
  In high-yield, work-hardening alloys like **{mat}** (or thin-walled pocket floors), cutting edge hone and tool pressure compress the workpiece material elastically downward. As the cutter passes, the material **springs back up**, leaving the finished floor **thick by +0.0005" to +0.0015" (+0.012 to +0.038 mm)**.

---

### 2. Recommended CAM Workflow (Fusion 360 / Mastercam)

1. **Step 1: Uniform Semi-Finishing Pass**:
   - Never finish directly from roughing! Leave **+0.005" (0.125 mm)** axial floor stock and finish with a dedicated semi-finisher so chip load is perfectly uniform.
2. **Step 2: Try a Spring Pass First**:
   - In Fusion 360 (e.g. *Flat Machining* or *2D Pocket*), enable **Spring Passes: 1** at nominal `0.0000"` stock at $100\\%$ programmed feed. A clean spring pass frequently removes the $+0.0008"$ push-off without any risk of gouging.
3. **Step 3: Program Negative Axial Stock to Leave**:
   - If the floor still measures $+0.0006"$ thick due to springback, set **Radial Stock to Leave = 0.0000"** and **Axial Stock to Leave = -0.0005" to -0.0008" (-0.012 mm to -0.020 mm)**.
   - ⚠️ **Caution**: Keep Radial Stock at `0.0000"` (do not make radial stock negative, or the side flutes will gouge adjacent vertical walls).

---

### 3. Cutting Parameters for This Pass
- **Tool**: {dia}\" Diameter Carbide End Mill
- **Chip Load**: Maintain at least $0.0010"\\text{{ IPT}}$ ($0.025\\text{{ mm/tooth}}$) so the wiper edges cleanly shear the chip rather than burnishing and work-hardening the floor.
- **Coolant**: Copious high-pressure coolant or high-lubricity mist to prevent microscopic chip welding on the bottom face.

> [!NOTE]
> *This response was generated using ToolWiz's built-in machining knowledge engine. To enable open-ended, real-time Gemini AI chat for any CAM question, configure your Google Gemini API Key in the settings.*"""

    elif any(k in p_lower for k in ["chatter", "vibration", "stickout", "harmonic"]):
        return f"""### 🛡️ Mitigating Chatter & Harmonics for {dia}\" Cutter in {mat}

When operating at extended stickout, chatter is dominated by regenerative tool deflection and natural frequency resonance:

1. **Optimize Radial WOC vs Axial DOC**:
   - Switch from deep radial cuts to high-efficiency milling (**HEM / Adaptive**): light radial engagement ($5\\% - 10\\%\\text{{ WOC}}$) paired with deeper axial engagement.
   - Low radial engagement reduces the arc of contact, preventing continuous chatter excitation.
2. **Variable Helix & Unequal Flute Spacing**:
   - Standard uniform-helix end mills resonate easily. Ensure your cutter uses variable pitch ($35°/38°$) to disrupt harmonics.
3. **Speed Tuning (Stability Lobes)**:
   - Increasing RPM by $10\\% - 15\\%$ can move you into a stable harmonic valley without increasing tool wear.
4. **Toolholder Rigidity**:
   - Minimize gauge length. Dual-contact (Big Plus / HSK) or hydraulic chucks have significantly higher damping capacity than standard ER collets.

> [!NOTE]
> *Generated via ToolWiz machining knowledge engine. Connect your Gemini API Key in settings to enable full conversational LLM chat.*"""

    else:
        return f"""### 🤖 ToolWiz AI Machinist Consultation

**Active Context Analyzed**:
- **Material**: {mat}
- **Tool**: {dia}\" End Mill
- **Operation**: {op}

For your inquiry: *"{(prompt[:120] + '...') if len(prompt) > 120 else prompt}"*

**Key Machining Principles**:
1. **Kinematics & Chip Load**: Ensure chip thickness never falls below the cutter's edge preparation threshold (~$0.0005" / 0.012\\text{{ mm}}$) to avoid tool rubbing, rapid flank wear, and localized work hardening in {mat}.
2. **Rigidity & Deflection Control**: With programmed parameters, tool deflection should be audited against tolerance limits.
3. **CAM Toolpath Dynamics**: Prefer continuous climb milling with smooth tangential lead-ins/lead-outs and helical entry ramping ($1.5° - 2.5°$) to prevent shock loading on tool entry.

> [!NOTE]
> **API Key Setup**: To converse interactively with full conversational intelligence powered by Google Gemini, enter your `GEMINI_API_KEY` in the AI Machinist settings or set it in your environment variables. Free API keys are available from [Google AI Studio](https://aistudio.google.com/)."""


def query_ai_machinist(prompt: str, context: dict = None, api_key: str = None) -> dict:
    """
    Sends the user prompt along with live ToolWiz telemetry to Google Gemini.
    Falls back gracefully to the built-in offline machining knowledge engine if no key is configured.
    """
    key = api_key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    context_str = format_context_for_prompt(context or {})

    if not key:
        reply = get_offline_expert_response(prompt, context or {})
        return {
            "success": True,
            "reply": reply,
            "mode": "offline_expert",
            "model": "toolwiz-machining-expert",
            "apiKeyConfigured": False
        }

    full_prompt = f"{context_str}\n\n### Machinist Question:\n{prompt}"

    # Try Gemini 2.5 Flash, fallback to Gemini 1.5 Flash
    models = ["gemini-2.5-flash", "gemini-1.5-flash"]
    last_err = None

    for model in models:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
        payload = {
            "system_instruction": {
                "parts": [{"text": SYSTEM_INSTRUCTION}]
            },
            "contents": [
                {
                    "role": "user",
                    "parts": [{"text": full_prompt}]
                }
            ],
            "generationConfig": {
                "temperature": 0.4,
                "maxOutputTokens": 2048,
            }
        }

        try:
            with httpx.Client(timeout=25.0) as client:
                resp = client.post(url, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    candidates = data.get("candidates", [])
                    if candidates:
                        parts = candidates[0].get("content", {}).get("parts", [])
                        if parts:
                            text = parts[0].get("text", "")
                            return {
                                "success": True,
                                "reply": text,
                                "mode": "gemini_live",
                                "model": model,
                                "apiKeyConfigured": True
                            }
                else:
                    last_err = f"HTTP {resp.status_code}: {resp.text[:200]}"
        except Exception as e:
            last_err = str(e)

    # If network/API error occurred with provided key, fall back cleanly
    offline_reply = get_offline_expert_response(prompt, context or {})
    return {
        "success": True,
        "reply": f"{offline_reply}\n\n*(Note: Gemini live API returned: {last_err}. Displaying knowledge engine response.)*",
        "mode": "fallback_offline",
        "model": "toolwiz-machining-expert",
        "apiKeyConfigured": True,
        "warning": last_err
    }
