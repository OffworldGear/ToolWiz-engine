"""
ToolWiz AI Machinist - Context-Aware CAM & Machining Intelligence Module
Integrates Google Gemini with real-time ToolWiz physics telemetry.
"""

import os
import json
import httpx


SYSTEM_INSTRUCTION = """You are the ToolWiz AI Machinist & Senior CAM Applications Engineer (Fusion 360, Mastercam, Siemens NX).
You have deep, first-principles expertise in cutting tool mechanics, metallurgy (work-hardening in austenitic stainless like 316 and Nitronic 60, titanium, nickel superalloys), machine tool stiffness, spindle thrust compliance, cantilever beam deflection, surface finish, chip thinning, entry dynamics, and CAM compensation strategies.

You are provided with the live ToolWiz session state (material alloy, cutter geometry, cut depths, speeds, feeds, calculated deflection, and active physics advisor alerts).

CRITICAL MACHINING PRINCIPLES TO APPLY:
1. Deflection vs. Springback on Flat / Floor Finishing:
   - On flat floors, lateral/radial cutter deflection (Fradial) is negligible because cutting occurs with the bottom end-teeth (wiper/dish geometry) rather than side flutes.
   - However, axial cutting force (Fz thrust) pushes vertically into the machine spindle bearings and Z-axis ballscrew.
   - In high-yield, work-hardening alloys like Nitronic 60, austenitic stainless, or thin-walled pocket floors, cutting edge hone/micro-radii and tool pressure push the material elastically downward. When the tool passes, the material springs back up, leaving the finished floor proud (thick by +0.0005" to +0.0015" / +0.012 to +0.038 mm).
   - CAM Compensation Solutions:
     * Standard Best Practice: Run a dedicated semi-finishing pass leaving uniform +0.005" (0.125 mm), followed by a Spring Pass (repeating the flat finish toolpath at nominal 0.0000" stock).
     * Controlled Negative Axial Stock: If elastic springback persists after a spring pass, applying a small negative axial stock to leave in CAM (-0.0005" to -0.0010" / -0.012 to -0.025 mm) while strictly keeping radial stock at 0.0000" is an established master-machinist technique to bring the floor to nominal tolerance.
     * Safeguards: Never apply negative radial stock (which gouges adjacent vertical walls), and ensure a semi-finishing pass was run so cutting forces are uniform across the entire floor.

2. Tone and Style:
   - Provide concrete, nuanced, shop-floor proven advice. Avoid simplistic "never do this" rules; explain the underlying physics, when advanced techniques are used, and the necessary safeguards.
   - Always quote specific numbers and units (both Imperial and Metric).
   - Reference the active cutter and material telemetry provided in the prompt.
   - Format cleanly in GitHub Flavored Markdown with bold headers, bullet points, and code/parameter callouts.
"""


def format_context_for_prompt(context: dict) -> str:
    """Format the active machining context dictionary into a readable markdown block with explicit dual units."""
    if not context:
        return "No live tool/material context available."

    material = context.get("material", "Unknown")
    family = context.get("materialFamily", "General")
    tool = context.get("tool", "End Mill")
    geo = context.get("geometry", "Standard")
    flutes = context.get("flutes", "4")
    coating = context.get("coating", "None")
    carbide = context.get("isCarbide", True)
    op = context.get("operation", "Roughing")

    is_metric = bool(context.get("isMetric", False) or "metric" in str(context.get("unitSystem", "")).lower())

    # Safely parse numeric parameters supporting dual-unit keys and legacy keys
    try:
        dia_in = float(context.get("diameter_in", context.get("diameter", 0.5)))
    except (ValueError, TypeError):
        dia_in = 0.5
    try:
        dia_mm = float(context.get("diameter_mm", dia_in * 25.4))
    except (ValueError, TypeError):
        dia_mm = dia_in * 25.4

    try:
        flute_in = float(context.get("fluteLength_in", context.get("fluteLength", 1.0)))
    except (ValueError, TypeError):
        flute_in = 1.0
    try:
        flute_mm = float(context.get("fluteLength_mm", flute_in * 25.4))
    except (ValueError, TypeError):
        flute_mm = flute_in * 25.4

    try:
        stick_in = float(context.get("stickout_in", context.get("stickout", 1.5)))
    except (ValueError, TypeError):
        stick_in = 1.5
    try:
        stick_mm = float(context.get("stickout_mm", stick_in * 25.4))
    except (ValueError, TypeError):
        stick_mm = stick_in * 25.4

    try:
        doc_in = float(context.get("cutDepth_in", context.get("cutDepth", 0.25)))
    except (ValueError, TypeError):
        doc_in = 0.25
    try:
        doc_mm = float(context.get("cutDepth_mm", doc_in * 25.4))
    except (ValueError, TypeError):
        doc_mm = doc_in * 25.4

    try:
        woc_in = float(context.get("cutWidth_in", context.get("cutWidth", 0.10)))
    except (ValueError, TypeError):
        woc_in = 0.10
    try:
        woc_mm = float(context.get("cutWidth_mm", woc_in * 25.4))
    except (ValueError, TypeError):
        woc_mm = woc_in * 25.4

    try:
        rpm = int(float(context.get("rpm", 0)))
    except (ValueError, TypeError):
        rpm = 0

    try:
        feed_ipm = float(context.get("feedrate_ipm", context.get("feedrate", 0)))
    except (ValueError, TypeError):
        feed_ipm = 0.0
    try:
        feed_mmpm = float(context.get("feedrate_mmpm", feed_ipm * 25.4))
    except (ValueError, TypeError):
        feed_mmpm = feed_ipm * 25.4

    try:
        sfm = float(context.get("sfm", 0))
    except (ValueError, TypeError):
        sfm = 0.0
    try:
        smm = float(context.get("smm", sfm * 0.3048))
    except (ValueError, TypeError):
        smm = sfm * 0.3048

    try:
        ipt_in = float(context.get("ipt_in", context.get("ipt", 0)))
    except (ValueError, TypeError):
        ipt_in = 0.0
    try:
        ipt_mm = float(context.get("ipt_mm", ipt_in * 25.4))
    except (ValueError, TypeError):
        ipt_mm = ipt_in * 25.4

    try:
        plunge_ipm = float(context.get("plungeFeed_ipm", context.get("plungeFeed", 0)))
    except (ValueError, TypeError):
        plunge_ipm = 0.0
    try:
        plunge_mmpm = float(context.get("plungeFeed_mmpm", plunge_ipm * 25.4))
    except (ValueError, TypeError):
        plunge_mmpm = plunge_ipm * 25.4

    try:
        ramp_ipm = float(context.get("rampFeed_ipm", context.get("rampFeed", 0)))
    except (ValueError, TypeError):
        ramp_ipm = 0.0
    try:
        ramp_mmpm = float(context.get("rampFeed_mmpm", ramp_ipm * 25.4))
    except (ValueError, TypeError):
        ramp_mmpm = ramp_ipm * 25.4

    try:
        ramp_angle = float(context.get("rampAngle", 0))
    except (ValueError, TypeError):
        ramp_angle = 0.0

    try:
        def_in = float(context.get("deflection_in", context.get("deflection", 0)))
    except (ValueError, TypeError):
        def_in = 0.0
    try:
        def_mm = float(context.get("deflection_mm", def_in * 25.4))
    except (ValueError, TypeError):
        def_mm = def_in * 25.4
    try:
        def_um = float(context.get("deflection_um", def_mm * 1000.0))
    except (ValueError, TypeError):
        def_um = def_mm * 1000.0

    try:
        spring_in = float(context.get("springback_in", 0))
    except (ValueError, TypeError):
        spring_in = 0.0
    try:
        spring_mm = float(context.get("springback_mm", spring_in * 25.4))
    except (ValueError, TypeError):
        spring_mm = spring_in * 25.4

    try:
        rad_comp_in = float(context.get("radialComp_in", 0))
    except (ValueError, TypeError):
        rad_comp_in = 0.0
    try:
        rad_comp_mm = float(context.get("radialComp_mm", rad_comp_in * 25.4))
    except (ValueError, TypeError):
        rad_comp_mm = rad_comp_in * 25.4

    try:
        ax_comp_in = float(context.get("axialComp_in", 0))
    except (ValueError, TypeError):
        ax_comp_in = 0.0
    try:
        ax_comp_mm = float(context.get("axialComp_mm", ax_comp_in * 25.4))
    except (ValueError, TypeError):
        ax_comp_mm = ax_comp_in * 25.4

    try:
        spindle_load = float(context.get("spindleLoadPct", 0))
    except (ValueError, TypeError):
        spindle_load = 0.0

    try:
        mrr_in3 = float(context.get("mrr_in3", context.get("mrr", 0)))
    except (ValueError, TypeError):
        mrr_in3 = 0.0
    try:
        mrr_cm3 = float(context.get("mrr_cm3", mrr_in3 * 16.387))
    except (ValueError, TypeError):
        mrr_cm3 = mrr_in3 * 16.387

    tips = context.get("tips", [])
    tips_str = ", ".join(tips) if tips else "None active"
    carbide_str = "Solid Carbide" if carbide else "HSS"

    if is_metric:
        unit_system_desc = "Metric (UI in mm & mm/min)"
        dia_display = f"{dia_mm:.3f} mm ({dia_in:g}\" dia)"
        flute_display = f"{flute_mm:.2f} mm ({flute_in:.3f}\")"
        stick_display = f"{stick_mm:.2f} mm ({stick_in:.3f}\")"
        doc_display = f"{doc_mm:.3f} mm ({doc_in:.4f}\")"
        woc_display = f"{woc_mm:.3f} mm ({woc_in:.4f}\")"
        feed_display = f"{feed_mmpm:.1f} mm/min ({feed_ipm:.2f} IPM)"
        speed_display = f"{smm:.1f} m/min ({sfm:.1f} SFM)"
        chip_display = f"{ipt_mm:.4f} mm/tooth ({ipt_in:.5f} IPT)"
        plunge_display = f"{plunge_mmpm:.1f} mm/min ({plunge_ipm:.2f} IPM)"
        ramp_display = f"{ramp_mmpm:.1f} mm/min ({ramp_ipm:.2f} IPM)"
        def_display = f"{def_mm:.4f} mm / {def_um:.1f} µm ({def_in:.5f}\")"
        spring_display = f"{spring_mm:.4f} mm ({spring_in:.5f}\")"
        mrr_display = f"{mrr_cm3:.2f} cm³/min ({mrr_in3:.3f} in³/min)"
        comp_display = f"Negative Radial Stock: {rad_comp_mm:.4f} mm ({rad_comp_in:.5f}\"), Negative Axial Stock: {ax_comp_mm:.4f} mm ({ax_comp_in:.5f}\")"
    else:
        unit_system_desc = "Imperial (UI in inches & IPM)"
        dia_display = f"{dia_in:g}\" dia ({dia_mm:.3f} mm)"
        flute_display = f"{flute_in:.3f}\" ({flute_mm:.2f} mm)"
        stick_display = f"{stick_in:.3f}\" ({stick_mm:.2f} mm)"
        doc_display = f"{doc_in:.4f}\" ({doc_mm:.3f} mm)"
        woc_display = f"{woc_in:.4f}\" ({woc_mm:.3f} mm)"
        feed_display = f"{feed_ipm:.2f} IPM ({feed_mmpm:.1f} mm/min)"
        speed_display = f"{sfm:.1f} SFM ({smm:.1f} m/min)"
        chip_display = f"{ipt_in:.5f} IPT ({ipt_mm:.4f} mm/tooth)"
        plunge_display = f"{plunge_ipm:.2f} IPM ({plunge_mmpm:.1f} mm/min)"
        ramp_display = f"{ramp_ipm:.2f} IPM ({ramp_mmpm:.1f} mm/min)"
        def_display = f"{def_in:.5f}\" ({def_mm:.4f} mm / {def_um:.1f} µm)"
        spring_display = f"{spring_in:.5f}\" ({spring_mm:.4f} mm)"
        mrr_display = f"{mrr_in3:.3f} in³/min ({mrr_cm3:.2f} cm³/min)"
        comp_display = f"Negative Radial Stock: {rad_comp_in:.5f}\" ({rad_comp_mm:.4f} mm), Negative Axial Stock: {ax_comp_in:.5f}\" ({ax_comp_mm:.4f} mm)"

    lines = [
        "### Active Machining Telemetry:",
        f"- **Active Unit System**: {unit_system_desc}",
        f"- **Workpiece Material**: {material} (Family: {family})",
        f"- **Cutter Setup**: {tool} ({geo}), {dia_display}, {flutes}-flute, Flute Length: {flute_display}, Stickout: {stick_display}, Coating: {coating} ({carbide_str})",
        f"- **Operation**: {op}",
        f"- **Programmed Engagement**: Axial DOC: {doc_display}, Radial WOC: {woc_display}",
        f"- **Kinematics**: {rpm} RPM, Cutting Feed: {feed_display}, Surface Speed: {speed_display}, Chip Load: {chip_display}, Plunge: {plunge_display}, Ramp: {ramp_display} @ {ramp_angle:g}°",
        f"- **Calculated Physics**: Lateral Deflection: {def_display}, Material Springback: {spring_display}, Spindle Load: {spindle_load:.1f}%, MRR: {mrr_display}",
        f"- **Suggested Stock to Leave (Comp)**: {comp_display}",
        f"- **Physics Advisor Alerts**: {tips_str}"
    ]
    return "\n".join(lines) + "\n"


def get_offline_expert_response(prompt: str, context: dict) -> str:
    """Provides high-quality, physics-based fallback answers when no API key is set."""
    p_lower = prompt.lower()
    mat = context.get("material", "Nitronic 60 / Stainless Steel") if context else "tough alloy"
    op = context.get("operation", "Finishing") if context else "Finishing"
    is_metric = bool(context.get("isMetric", False) or "metric" in str(context.get("unitSystem", "")).lower()) if context else False
    
    try:
        dia_in = float(context.get("diameter_in", context.get("diameter", 0.5)))
    except (ValueError, TypeError):
        dia_in = 0.5
    dia_mm = dia_in * 25.4
    dia_label = f"{dia_mm:.3f} mm ({dia_in:g}\")" if is_metric else f"{dia_in:g}\" ({dia_mm:.2f} mm)"
    
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
   - If the floor still measures $+0.0006"$ thick due to springback, set **Axial Stock to Leave = -0.0005" to -0.0008" (-0.012 mm to -0.020 mm)**.
   - **Floor-Only Cuts**: Set **Positive Radial Stock to Leave = +0.0050" to +0.0100" (+0.13 to +0.25 mm)**. This keeps the perimeter flutes completely off pocket walls, preventing tool rubbing, corner chatter, and chip drag marks.
   - **Combined Floor + Wall Cuts** (e.g. Fusion 360 *Flat* with finishing passes enabled): Enter **BOTH** values—Axial Stock (`-0.0005"`) for floor springback, and Radial Stock (`-0.0008"`) for wall deflection.
   - **Wall Finishing Cuts** (e.g. *2D Contour*): Apply Negative Radial Stock (`-0.0008"`), and also enter Negative Axial Stock (`-0.0005"`) if finishing down to an uncut floor (keep Axial at `0.0000"` if the floor was already cut).

---

### 3. Cutting Parameters for This Pass
- **Tool**: {dia_label} Diameter Carbide End Mill
- **Chip Load**: Maintain at least $0.0010"\\text{{ IPT}}$ ($0.025\\text{{ mm/tooth}}$) so the wiper edges cleanly shear the chip rather than burnishing and work-hardening the floor.
- **Coolant**: Copious high-pressure coolant or high-lubricity mist to prevent microscopic chip welding on the bottom face.

> [!NOTE]
> *This response was generated using ToolWiz's built-in machining knowledge engine. To enable open-ended, real-time Gemini AI chat for any CAM question, configure your Google Gemini API Key in the settings.*"""

    elif any(k in p_lower for k in ["chatter", "vibration", "stickout", "harmonic"]):
        return f"""### 🛡️ Mitigating Chatter & Harmonics for {dia_label} Cutter in {mat}

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
- **Tool**: {dia_label} End Mill
- **Operation**: {op}

For your inquiry: *"{(prompt[:120] + '...') if len(prompt) > 120 else prompt}"*

**Key Machining Principles**:
1. **Kinematics & Chip Load**: Ensure chip thickness never falls below the cutter's edge preparation threshold (~$0.0005" / 0.012\\text{{ mm}}$) to avoid tool rubbing, rapid flank wear, and localized work hardening in {mat}.
2. **Rigidity & Deflection Control**: With programmed parameters, tool deflection should be audited against tolerance limits.
3. **CAM Toolpath Dynamics**: Prefer continuous climb milling with smooth tangential lead-ins/lead-outs and helical entry ramping ($1.5° - 2.5°$) to prevent shock loading on tool entry.

> [!NOTE]
> **API Key Setup**: To converse interactively with full conversational intelligence powered by Google Gemini, enter your `GEMINI_API_KEY` in the AI Machinist settings or set it in your environment variables. Free API keys are available from [Google AI Studio](https://aistudio.google.com/)."""


# Cache available models in memory per API key to prevent redundant network lookups
_MODEL_CACHE = {}


def get_available_gemini_models(api_key: str) -> tuple[list[str], str | None]:
    """
    Queries Google Gemini ModelService.ListModels to discover active models supporting generateContent.
    Returns (models_list, error_message).
    """
    if api_key in _MODEL_CACHE:
        return _MODEL_CACHE[api_key], None

    url = f"https://generativelanguage.googleapis.com/v1beta/models?key={api_key}"
    try:
        with httpx.Client(timeout=10.0) as client:
            resp = client.get(url)
            if resp.status_code == 200:
                data = resp.json()
                models_data = data.get("models", [])
                
                valid_models = []
                for m in models_data:
                    name = m.get("name", "")  # e.g. "models/gemini-2.0-flash"
                    methods = m.get("supportedGenerationMethods", [])
                    if "generateContent" in methods:
                        clean_name = name.replace("models/", "").strip()
                        valid_models.append(clean_name)

                if valid_models:
                    # Sort to prioritize fast flash models, then pro models, preferring newest versions
                    def model_priority(m):
                        score = 0
                        m_low = m.lower()
                        if "flash" in m_low:
                            score += 100
                        elif "pro" in m_low:
                            score += 50
                        
                        # Newer generation priorities
                        if "3" in m_low: score += 40
                        elif "2.5" in m_low: score += 30
                        elif "2.0" in m_low or "2-" in m_low: score += 20
                        elif "1.5" in m_low: score += 10
                        
                        # Prefer non-experimental / non-preview
                        if "preview" in m_low or "exp" in m_low:
                            score -= 5
                        return score

                    valid_models.sort(key=model_priority, reverse=True)
                    _MODEL_CACHE[api_key] = valid_models
                    return valid_models, None
                else:
                    return [], "No models with generateContent capability found for this API key."
            elif resp.status_code in (400, 403):
                try:
                    err_data = resp.json().get("error", {})
                    err_msg = err_data.get("message", f"HTTP {resp.status_code}")
                except Exception:
                    err_msg = f"HTTP {resp.status_code}"
                return [], f"API Key Authentication Error: {err_msg}"
            else:
                return [], f"Model discovery HTTP {resp.status_code}: {resp.text[:200]}"
    except Exception as e:
        return [], f"Model discovery network error: {str(e)}"


def query_ai_machinist(prompt: str, context: dict = None, api_key: str = None, preferred_model: str = None) -> dict:
    """
    Sends the user prompt along with live ToolWiz telemetry to Google Gemini.
    Dynamically resolves supported models via ModelService.ListModels.
    Concatenates all response parts to prevent truncation.
    Falls back gracefully to the built-in offline machining knowledge engine if no key is configured or API errors occur.
    """
    key = (api_key or os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY") or "").strip()
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

    # 1. Dynamically discover models supported by this specific API key
    discovered_models, discovery_err = get_available_gemini_models(key)
    
    # If the key was rejected by Google as invalid (400/403), warn immediately
    if discovery_err and "Authentication Error" in discovery_err:
        offline_reply = get_offline_expert_response(prompt, context or {})
        return {
            "success": True,
            "reply": f"{offline_reply}\n\n> [!WARNING]\n> **Google API Key Error**: {discovery_err}. Please verify your API key in the settings (⚙️).",
            "mode": "fallback_offline",
            "model": "toolwiz-machining-expert",
            "apiKeyConfigured": True,
            "warning": discovery_err
        }

    # If user selected a specific model (e.g. gemini-2.5-pro), prioritize it first
    pref = (preferred_model or "").strip()
    candidates = []
    if pref and pref.lower() != "auto":
        candidates.append(pref)

    # Add discovered models
    if discovered_models:
        for m in discovered_models:
            if m not in candidates:
                candidates.append(m)
    else:
        for m in ["gemini-2.5-pro", "gemini-2.5-flash", "gemini-2.0-flash", "gemini-pro"]:
            if m not in candidates:
                candidates.append(m)

    candidate_models = candidates[:6]
    last_err = discovery_err or "No response"

    # 2. Query Gemini with the candidate models
    for model in candidate_models:
        clean_model = model.replace("models/", "").strip()
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{clean_model}:generateContent?key={key}"
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
                "temperature": 0.35,
                "maxOutputTokens": 4096,
            }
        }

        try:
            with httpx.Client(timeout=30.0) as client:
                resp = client.post(url, json=payload)
                if resp.status_code == 200:
                    data = resp.json()
                    candidates_list = data.get("candidates", [])
                    if candidates_list:
                        candidate = candidates_list[0]
                        content = candidate.get("content", {})
                        parts = content.get("parts", [])
                        # Concatenate all text parts to guarantee complete, untruncated answers
                        text_chunks = [p.get("text", "") for p in parts if "text" in p]
                        text = "".join(text_chunks).strip()
                        if text:
                            return {
                                "success": True,
                                "reply": text,
                                "mode": "gemini_live",
                                "model": clean_model,
                                "apiKeyConfigured": True
                            }
                else:
                    try:
                        err_msg = resp.json().get("error", {}).get("message", resp.text[:150])
                    except Exception:
                        err_msg = resp.text[:150]
                    last_err = f"HTTP {resp.status_code} ({clean_model}): {err_msg}"
        except Exception as e:
            last_err = f"Network exception ({clean_model}): {str(e)}"

    # If all live attempts failed, fall back cleanly to knowledge engine with diagnostic message
    offline_reply = get_offline_expert_response(prompt, context or {})
    return {
        "success": True,
        "reply": f"{offline_reply}\n\n> [!NOTE]\n> *Gemini Live API status: {last_err}. Displaying ToolWiz physics knowledge engine response.*",
        "mode": "fallback_offline",
        "model": "toolwiz-machining-expert",
        "apiKeyConfigured": True,
        "warning": last_err
    }

