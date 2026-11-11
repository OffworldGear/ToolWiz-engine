/* ToolWiz web: v3 additions to the Speeds & Feeds results (engagement source, limit in plain words, runout regime,
 * stock to leave, holder and tool advice, T-slot block) and the tool-size-scaled DOC / WOC sliders.
 * renderV3Result(res) is called by calculate() in the main script; every field may be missing (older server). */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const set = (id, html) => { const el = $(id); if (!el) return; if (html) { el.innerHTML = html; el.style.display = ''; } else { el.innerHTML = ''; el.style.display = 'none'; } };

    // Plain-words names of the physics constraints (physics_v2 check ids). Unknown ids fall back to the check's own name.
    const CHECK_WORDS = {
        C1: 'minimum chip thickness (a thinner chip would rub instead of cut)',
        C2: 'chip thickness (the chip load this tool and material tolerate)',
        C3: 'tool deflection (part accuracy)',
        C4: 'tool bending stress',
        C5: 'spindle power or torque',
        C6: 'tool geometry (reach and clearance)',
        C7: 'spindle speed (the rpm cap or tool life)',
        C8: 'depth-of-cut cap from vendor engagement limits',
        C9: 'speed reduction for long stickout (chatter)',
        C10: 'the work-hardened layer',
        C11: 'machine feed-rate limit',
        C12: 'every flute must reach the stock',
        C13: 'program size',
        C14v: 'the vendor-consensus speed ceiling',
        C14f: 'the vendor-consensus chip-load ceiling',
        C14m: 'the vendor-consensus removal-rate ceiling',
        C14lo: 'the minimum chip-load floor for small tools',
        holder_clearance: 'holder clearance',
        neck_clearance: 'neck clearance of the cutter'
    };
    function limitedWords(res) {
        const raw = res && res.limited_by;
        if (!raw) return '';
        const checks = (res.v2 && res.v2.checks) || {};
        const ids = String(raw).replace(/^v2:\s*/, '').split(/[,\s]+/).filter(Boolean);
        const words = ids.map(id => CHECK_WORDS[id] || (checks[id] && checks[id].name) || id);
        return words.join('; ');
    }

    const isRoughing = () => /rough|adaptive|slot|high feed|pocket/i.test((($('operation') || {}).value) || '');
    function engagementCard(res) {
        const src = res.engagement_source;
        if (!src || res.tslot) return '';   // the T-slot model sets its own radial depth per pass (see the T-slot plan card)
        const recD = res.rec_doc, recW = res.rec_woc;
        const sd = $('cutDepth_val'), sw = $('cutWidth_val');
        const userD = sd ? parseFloat(sd.value) : NaN, userW = sw ? parseFloat(sw.value) : NaN;
        const fmt = v => T.len(v, { unit: false });
        const recTxt = `${fmt(recD)} &times; ${fmt(recW)} ${T.unitName()}`;
        const userTxt = (Number.isFinite(userD) && Number.isFinite(userW)) ? `${userD} &times; ${userW} ${T.unitName()}` : '';
        const near = (a, b) => Math.abs(a - b) <= 0.02 * Math.max(Math.abs(b), 1e-6);
        const same = Number.isFinite(userD) && Number.isFinite(userW) && near(T.toIn(userD), recD) && near(T.toIn(userW), recW);
        if (src === 'user') {
            return `<div class="v3-row"><div>
                <div class="v3-title">Feeds are computed for your sliders</div>
                <div class="v3-sub">Speed and feed above are for <strong>${userTxt}</strong> (axial &times; radial). ${same ? (isRoughing() ? 'That is the maximum-MRR cut at this aggressiveness.' : 'That matches the ToolWiz recommendation.') : `ToolWiz recommends <strong>${recTxt}</strong> for this tool and material.`}</div></div>
                ${same ? '' : '<button type="button" class="btn-ratio v3-btn" id="applyRecBtn" onclick="applyRecommendations()" title="Set the DOC and WOC sliders to the recommendation; speed and feed are recalculated for it">Apply recommendation</button>'}</div>`;
        }
        return `<div class="v3-row"><div>
            <div class="v3-title">Feeds are computed for the ToolWiz recommendation</div>
            <div class="v3-sub">Speed and feed above are for <strong>${recTxt}</strong>${isRoughing() ? ' (max MRR at this aggressiveness)' : ''}. Your sliders do not drive the result in this case.</div></div>
            <button type="button" class="btn-ratio v3-btn" onclick="applyRecommendations()">Show it on the sliders</button></div>`;
    }

    function runoutCard(res) {
        if (!res.runout_regime && res.flutes_cutting == null && res.tir_all_flutes_in == null) return '';
        const nf = parseInt(($('flutes') && $('flutes').value) || ($('flutes_val') && $('flutes_val').value)) || null;
        const cutting = res.flutes_cutting;
        const all = res.runout_regime === 'all_flutes' || (nf && cutting != null && cutting >= nf);
        const runout = (typeof runoutInches !== 'undefined') ? runoutInches : null;
        const head = cutting != null
            ? `${cutting}${nf ? ' of ' + nf : ''} flute${(nf || cutting) > 1 ? 's' : ''} cutting`
            : (all ? 'All flutes cutting' : 'Reduced flutes cutting');
        const parts = [];
        if (runout != null) parts.push(all ? `At your runout of <strong>${T.len(runout)}</strong> every flute forms a chip.`
            : `At your runout of <strong>${T.len(runout)}</strong> only ${cutting != null ? cutting : 'some'}${nf ? ' of ' + nf : ''} flute${cutting === 1 ? '' : 's'} form a chip; the rest rub.`);
        if (T.finite(res.tir_all_flutes_in)) parts.push(all ? `All flutes would still cut up to <strong>${T.len(res.tir_all_flutes_in)}</strong> runout.` : `All flutes cut at runout of <strong>${T.len(res.tir_all_flutes_in)}</strong> or less.`);
        if (T.finite(res.runout_ratio)) parts.push(`Tooth-to-tooth offset is ${T.pct(res.runout_ratio)} of the chip load${res.runout_ratio > 0.25 ? ' (above the 25 % an all-flute cut tolerates)' : ''}.`);
        const dia = res.diameter || null;
        return `<div class="v3-row"><div>
            <div class="v3-title"><span class="v3-pill ${all ? 'ok' : 'warn'}">${T.esc(head)}</span> Runout effect</div>
            <div class="v3-sub">${parts.join(' ')}</div></div></div>`;
    }

    function stockCard(res) {
        const r = res.recommended_radial_stock_in, a = res.recommended_axial_stock_in;
        if (!T.finite(r) && !T.finite(a)) return '';
        const fin = res.is_finishing;
        return `<div class="v3-title">Stock to leave for a true-to-size part</div>
            <div class="v3-kv"><div><span>Radial (walls)</span><strong>${T.len(r)}</strong></div><div><span>Axial (floors)</span><strong>${T.len(a)}</strong></div></div>
            <div class="v3-sub">${fin ? 'This operation is the finishing pass. These are the amounts the roughing pass before it should leave.'
                : 'Leave this on the roughing pass, then take one finishing pass to size. It is 1.5 &times; the predicted wall deflection plus springback, never under 0.05 mm (0.002 in).'}</div>`;
    }

    const CLASS_WORDS = { standard: 'standard runout is enough', precision: 'needs a precision holder', ultra: 'needs an ultra-precision holder' };
    function holderCard(res) {
        const h = res.holder_advice;
        if (!h || typeof h !== 'object') return '';
        const cls = String(h.class || '');
        const reason = String(h.reason || '');
        const firstSentence = reason.split(/(?<=[a-z0-9\)])\.\s/)[0];
        const rest = reason.length > firstSentence.length ? reason.slice(firstSentence.length + 1).trim() : '';
        const src = Array.isArray(h.sources) ? h.sources : [];
        return `<div class="v3-title">Tool holder advice <span class="v3-pill ${cls === 'ultra' ? 'bad' : cls === 'precision' ? 'warn' : 'ok'}">${T.esc(cls || 'n/a')}</span></div>
            <div class="v3-sub">${CLASS_WORDS[cls] ? T.esc(CLASS_WORDS[cls]) + '. ' : ''}${T.finite(h.required_tir_in) ? `Required runout at the tool tip: <strong>${T.len(h.required_tir_in)}</strong> or better.` : ''}</div>
            ${(h.recommended || []).length ? `<div class="v3-chiprow"><span class="v3-chiplabel">Recommended</span>${T.chips(h.recommended, 'good')}</div>` : ''}
            ${(h.acceptable || []).length ? `<div class="v3-chiprow"><span class="v3-chiplabel">Acceptable</span>${T.chips(h.acceptable, 'ok')}</div>` : ''}
            ${(h.avoid || []).length ? `<div class="v3-chiprow"><span class="v3-chiplabel">Avoid</span>${T.chips(h.avoid, 'bad')}</div>` : ''}
            <div class="v3-sub">${T.esc(firstSentence)}.</div>
            ${h.high_speed_spindle ? `<div class="v3-callout v3-info"><div class="v3-callout-title">Spindle speeder</div><div class="v3-callout-body">${T.esc(h.high_speed_spindle)}</div></div>` : ''}
            ${(rest || src.length) ? `<details class="v3-more"><summary>Details and sources</summary>${rest ? `<p>${T.esc(rest)}</p>` : ''}${src.length ? `<ul>${src.map(s => `<li>${T.esc(s)}</li>`).join('')}</ul>` : ''}</details>` : ''}`;
    }

    function toolAdviceCard(res) {
        const list = Array.isArray(res.tool_advice) ? res.tool_advice : [];
        if (!list.length) return '';
        return `<div class="v3-title">Tool recommendations</div>` + list.map(t => {
            const ev = Array.isArray(t.evidence) ? t.evidence.length : 0;
            return `<div class="v3-advice">
                <div class="v3-advice-head"><strong>${T.esc(t.vendor)}</strong> ${T.esc(t.series)}</div>
                ${t.applies_to ? `<div class="v3-sub">${T.esc(t.applies_to)}</div>` : ''}
                <div class="v3-sub">${T.esc(t.why)}</div>
                <div class="v3-chiprow">${t.expected_gain ? `<span class="v3-chip good">${T.esc(t.expected_gain)}</span>` : ''}<span class="v3-chip" title="${T.esc((t.evidence || []).join(', '))}">${ev} benchmark row${ev === 1 ? '' : 's'}</span></div></div>`;
        }).join('');
    }

    function tslotCard(res) {
        const t = res.tslot;
        if (!t) return '';
        const plan = t.axial_plan || {};
        const kv = (k, v) => `<div><span>${k}</span><strong>${v}</strong></div>`;
        const defl = T.finite(t.deflection_in) ? `${T.len(t.deflection_in)} <small>of ${T.len(t.deflection_limit_in)} limit</small>` : '—';
        const clr = T.finite(t.neck_clearance_in) ? T.len(t.neck_clearance_in) : '—';
        const prov = (t.provisional || []).length ? T.callout('warn', 'Provisional geometry', `Assumed, not measured: ${T.esc(t.provisional.join(', '))}. Measure neck diameter, reach and tooth form before trusting the neck deflection and pass count.`) : '';
        const formWord = !t.tooth_form ? 'unknown (treated as staggered)' : { staggered: 'staggered', straight: 'straight', unknown: 'unknown (treated as staggered)' }[t.tooth_form] || t.tooth_form || '—';
        return `<div class="v3-title">T-slot / keyseat plan <span class="v3-pill">${T.esc(String(t.operation || '').replace('_', ' '))}</span></div>
            ${prov}
            <div class="v3-kv">
                ${kv('Radial passes', `${t.radial_passes} &times; ${T.len(t.radial_depth_per_pass_in)}`)}
                ${kv('Total radial depth', T.len(t.radial_depth_total_in))}
                ${kv('Max per pass', T.len(t.radial_depth_limit_per_pass_in))}
                ${kv('Z cuts', `${plan.cuts != null ? plan.cuts : '—'}${plan.z_step_in ? ` (step ${T.len(plan.z_step_in)})` : ''}`)}
                ${kv('Slot height', T.len(plan.slot_height_in))}
                ${kv('Lateral feed', T.feed(t.lateral_feed_ipm))}
                ${kv('Axial (Z) feed', t.axial_feed_ipm != null ? T.feed(t.axial_feed_ipm) : 'no face cutting')}
                ${kv('Face chip load', t.axial_feed_ipm != null ? T.ipt(t.face_chip_load_ipt) : '—')}
                ${kv('Tooth form', T.esc(formWord))}
                ${kv('Teeth per face', t.teeth_per_face != null ? t.teeth_per_face : '—')}
                ${kv('Neck clearance', clr)}
                ${kv('Neck deflection', defl)}
            </div>
            ${plan.method ? `<div class="v3-sub">${T.esc(plan.method)}.</div>` : ''}
            ${t.limited_by ? `<div class="v3-sub">Limited by: ${T.esc(String(t.limited_by).replace(/_/g, ' '))}.</div>` : ''}`;
    }

    window.renderV3Result = function (res) {
        if (!res) return;
        set('engagementCard', engagementCard(res));
        const lw = limitedWords(res);
        set('limitedByLine', lw ? `<span class="v3-limited-label">Limited by</span> ${T.esc(lw)}` : '');
        set('runoutCard', runoutCard(res));
        set('finishCard', typeof finishCardHtml === 'function' ? finishCardHtml(res) : '');
        set('stockCard', stockCard(res));
        set('tslotCard', tslotCard(res));
        set('holderCard', holderCard(res));
        set('toolAdviceCard', toolAdviceCard(res));
    };

    /* --- DOC / WOC sliders scaled to the tool diameter: 0 to 4 x D, step about D/500 --------------------- */
    function niceStep(x) {
        if (!(x > 0)) return 0.0001;
        const p = Math.pow(10, Math.floor(Math.log10(x)));
        const m = x / p;
        return (m >= 5 ? 5 : m >= 2 ? 2 : 1) * p;
    }
    let lastScaleKey = '';
    window.scaleEngagementSliders = function () {
        const dEl = $('diameter');
        const d = dEl ? parseFloat(dEl.value) : NaN;       // display unit
        if (!(d > 0)) return;
        const key = d + '|' + T.metric();
        const step = niceStep(d / 500);
        const dec = Math.max(3, Math.min(6, Math.ceil(-Math.log10(step)) + 1));
        ['cutDepth', 'cutWidth'].forEach(p => {
            const r = $(p + '_range'), v = $(p + '_val');
            if (!r) return;
            const cur = v ? parseFloat(v.value) : NaN;
            const max = Math.max(4 * d, Number.isFinite(cur) ? cur * 1.05 : 0);
            if (key !== lastScaleKey || parseFloat(r.max) < max) {
                r.min = step; r.step = step; r.max = +max.toPrecision(4);
                if (v) v.step = 'any';
            }
        });
        lastScaleKey = key;
        const note = $('engagementRangeNote');
        if (note) note.textContent = `Slider range 0 to ${+(4 * d).toPrecision(3)} ${T.unitName()} (4 × tool diameter), step ${+step.toPrecision(2)}`;
    };

    /* --- Runout prominence: tools under 1/8 in --------------------------------------------------------------- */
    window.updateRunoutProminence = function () {
        const dEl = $('diameter'), g = $('runoutGroup'), hint = $('runoutHint');
        if (!dEl || !g) return;
        const dIn = T.toIn(dEl.value);
        const micro = Number.isFinite(dIn) && dIn < 0.125 - 1e-9;
        g.classList.toggle('runout-prominent', micro);
        if (hint) hint.style.display = micro ? '' : 'none';
    };
    window.setRunoutPreset = function (inches) {
        const inp = $('runout');
        if (!inp) return;
        inp.value = T.metric() ? (inches * 25.4).toFixed(5) : String(inches);
        if (typeof onRunoutInput === 'function') onRunoutInput();
    };
})();

/** Decimal places for a DOC / WOC slider value so micro-tool steps are not rounded away. */
function fmtEngagement(rangeEl) {
    const v = parseFloat(rangeEl.value);
    const step = parseFloat(rangeEl.step) || 0.0001;
    const dec = Math.max(3, Math.min(6, Math.ceil(-Math.log10(step))));
    return v.toFixed(dec);
}

/* --- Finish modes (finishing operations only): cleanup | surface | accuracy ------------------------------------- */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const finish = { mode: 'cleanup', raUin: 32, tolIn: 0.0002 };   // canonical units: micro-inches, inches
    const isFinishOp = () => /finish|contour|scallop/i.test((($('operation') || {}).value) || '');

    function showTargets() {
        const m = finish.mode;
        $('targetRaGroup').style.display = m === 'surface' ? '' : 'none';
        $('wallTolGroup').style.display = m === 'accuracy' ? '' : 'none';
        const metric = T.metric();
        $('targetRaUnit').textContent = metric ? 'µm' : 'µin';
        $('wallTolUnit').textContent = metric ? 'µm' : 'in';
        $('targetRa').value = metric ? +(finish.raUin * 0.0254).toFixed(2) : finish.raUin;
        $('wallTolerance').value = metric ? +(finish.tolIn * 25400).toFixed(1) : finish.tolIn;
    }
    window.updateFinishModeVisibility = function () {
        const box = $('finishModeBox'); if (!box) return;
        box.style.display = isFinishOp() ? '' : 'none';
        showTargets();
    };
    window.onFinishModeChange = function () {
        const r = document.querySelector('input[name="finishMode"]:checked');
        finish.mode = r ? r.value : 'cleanup';
        showTargets();
        if (typeof calculate === 'function') calculate();
    };
    window.onFinishTargetInput = function () {
        const metric = T.metric();
        const ra = parseFloat($('targetRa').value), tol = parseFloat($('wallTolerance').value);
        if (ra > 0) finish.raUin = metric ? ra / 0.0254 : ra;
        if (tol > 0) finish.tolIn = metric ? tol / 25400 : tol;
        if (typeof calculate === 'function') calculate();
    };
    window.finishUnitChanged = function () { showTargets(); };
    /** Request fields: finishMode, targetRa (micro-inches), wallTolerance (inches). Only sent for finishing operations. */
    window.finishPayload = function () {
        if (!isFinishOp()) return {};
        const out = { finishMode: finish.mode };
        if (finish.mode === 'surface') out.targetRa = +finish.raUin.toFixed(3);
        if (finish.mode === 'accuracy') out.wallTolerance = finish.tolIn;
        return out;
    };
    const fmtRa = uin => !T.finite(uin) ? '—' : (T.metric() ? (uin * 0.0254).toFixed(2) + ' µm' : Number(uin).toFixed(1) + ' µin');
    const fmtErr = inch => !T.finite(inch) ? '—' : (T.metric() ? (inch * 25400).toFixed(1) + ' µm' : Number(inch).toFixed(5) + ' in');
    const NAMES = { cleanup: 'Clean-up', surface: 'Surface finish', accuracy: 'Accuracy' };
    /** HTML for the response `finish` block (empty when the server did not send one). */
    window.finishCardHtml = function (res) {
        const f = res && res.finish;
        if (!f || typeof f !== 'object') return '';
        const okRa = T.finite(f.predicted_ra_uin) && T.finite(f.target_ra_uin) ? f.predicted_ra_uin <= f.target_ra_uin * 1.001 : null;
        const okWall = T.finite(f.predicted_wall_error_in) && T.finite(f.wall_tolerance_in) ? f.predicted_wall_error_in <= f.wall_tolerance_in * 1.001 : null;
        const mark = ok => ok === null ? '' : `<span class="v3-pill ${ok ? 'ok' : 'bad'}">${ok ? 'meets target' : 'misses target'}</span>`;
        const kv = (k, v, extra) => `<div><span>${k}</span><strong>${v}</strong>${extra || ''}</div>`;
        const adv = Array.isArray(f.advice) ? f.advice : (f.advice ? [f.advice] : []);
        const lim = f.limited_by ? String(f.limited_by).replace(/_/g, ' ') : '';
        return `<div class="v3-title">Finish: ${T.esc(NAMES[f.mode] || f.mode || '')}</div>
            <div class="v3-kv">
                ${kv('Predicted Ra', fmtRa(f.predicted_ra_uin), `<small>target ${fmtRa(f.target_ra_uin)} ${mark(okRa)}</small>`)}
                ${kv('Cusp height', T.len(f.predicted_cusp_in))}
                ${kv('Predicted wall error', fmtErr(f.predicted_wall_error_in), `<small>tolerance ${fmtErr(f.wall_tolerance_in)} ${mark(okWall)}</small>`)}
            </div>
            ${lim ? `<div class="v3-sub">Limited by: ${T.esc(lim)}.</div>` : ''}
            ${adv.length ? `<ul class="v2-list">${adv.map(a => `<li>${T.esc(a)}</li>`).join('')}</ul>` : ''}
            <div class="v3-sub">Ra is estimated as cusp height / 4, an approximation; measure the first part.</div>`;
    };
})();
