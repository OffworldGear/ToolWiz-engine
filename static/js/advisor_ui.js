/* ToolWiz web: Setup Advisor tab. Reads GET /api/setup_advisor/last (pushed from the Fusion add-in).
 * Response shape (plan contract): operations[{op_id,name,strategy,current,toolwiz,findings[{severity,title,detail,recommendation}]}],
 * setup_findings[], strategy_suggestions[], narrative, narrative_check{ok,rejected_numbers}. Everything optional. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const E = T.esc;
    let timer = null, data = null;
    const hidden = new Set();      // severities hidden by the filter chips
    const RANK = { STOP: 0, CAUTION: 1, INFO: 2 };
    const sevOf = f => String(f && f.severity || 'INFO').toUpperCase();

    window.initSetupAdvisor = function () { loadSetupAdvisor(); };
    window.advisorUnitChanged = function () { if (data) render(); };
    window.advisorAutoToggle = function () {
        clearInterval(timer); timer = null;
        if ($('advAuto').checked) timer = setInterval(() => { if ($('advisorView').style.display !== 'none') loadSetupAdvisor(true); }, 10000);
    };

    window.loadSetupAdvisor = async function (quiet) {
        const meta = $('advMeta');
        if (!quiet) meta.textContent = 'Loading…';
        const r = await T.api('/api/setup_advisor/last', undefined, 'GET');
        if (r.status === 404 || (r.data && (r.data.has_data === false || r.data.empty === true))) { data = null; renderEmpty(); return; }
        if (!r.ok) {
            data = null; $('advBody').innerHTML = '';
            meta.innerHTML = r.status === 0 || r.status >= 500 ? `<span class="err-text">Could not reach the advisor: ${E(r.data.error || ('HTTP ' + r.status))}</span>` : '';
            if (r.status !== 0 && r.status < 500) renderEmpty();
            return;
        }
        data = r.data.result && typeof r.data.result === 'object' ? Object.assign({}, r.data, r.data.result) : r.data;
        if (!Array.isArray(data.operations)) { renderEmpty(); return; }
        render();
    };
    function renderEmpty() {
        $('advMeta').textContent = '';
        $('advBody').innerHTML = `<div class="glass-panel"><div class="v3-empty"><strong>No setup received yet.</strong><br>In Fusion, run the ToolWiz Setup Advisor command on a setup. The add-in sends it here and it appears on this page.</div></div>`;
    }

    function counts(d) {
        const c = { STOP: 0, CAUTION: 0, INFO: 0 };
        const add = f => { const s = sevOf(f); c[s in c ? s : 'INFO']++; };
        (d.operations || []).forEach(o => (o.findings || []).forEach(add));
        (d.setup_findings || []).forEach(f => typeof f === 'object' && add(f));
        return c;
    }
    function findingHtml(f) {
        if (typeof f === 'string') f = { severity: 'INFO', title: f };
        const sev = sevOf(f);
        if (hidden.has(sev)) return '';
        return `<div class="adv-finding adv-${sev.toLowerCase()}"><div class="adv-ftitle">${T.sevBadge(sev)} <strong>${E(f.title || '')}</strong></div>
            ${f.detail ? `<div class="v3-sub">${E(f.detail)}</div>` : ''}${f.recommendation ? `<div class="adv-rec"><span>Do this</span> ${E(f.recommendation)}</div>` : ''}</div>`;
    }
    const sortF = list => (list || []).slice().sort((a, b) => (RANK[sevOf(a)] ?? 2) - (RANK[sevOf(b)] ?? 2));

    // Values come in inches, IPM, SFM, in^3/min; keys with those suffixes are converted for display.
    function fmtVal(k, v) {
        if (v == null || typeof v === 'object') return v == null ? '—' : JSON.stringify(v);
        if (typeof v !== 'number') return String(v);
        if (/_in$/i.test(k)) return T.len(v);
        if (/_ipm$|^feed(rate)?$/i.test(k)) return T.feed(v);
        if (/_sfm$|^sfm$/i.test(k)) return T.sfm(v);
        if (/_ipt$|^ipt$/i.test(k)) return T.ipt(v);
        if (/in3_min$/i.test(k)) return T.metric() ? (v * 16.387).toFixed(2) + ' cm³/min' : v.toFixed(3) + ' in³/min';
        return Number.isInteger(v) ? String(v) : String(+v.toPrecision(4));
    }
    const LABELS = { rpm: 'spindle speed', ap_in: 'axial depth', ae_in: 'radial width', stepdown_in: 'stepdown', stepover_in: 'stepover', chip_load_ipt: 'chip load', mrr_in3_min: 'MRR',
        stock_radial_in: 'radial stock', stock_axial_in: 'axial stock', deflection_in: 'deflection', flutes_cutting: 'flutes cutting', feed_ipm: 'feed' };
    const label = k => LABELS[k] || String(k).replace(/_(in|ipm|sfm|ipt)$/i, '').replace(/_/g, ' ');
    function kvTable(obj, keys) {
        const ks = (keys || Object.keys(obj || {})).filter(k => obj && obj[k] != null && typeof obj[k] !== 'object');
        return ks.length ? `<div class="v3-kv">${ks.map(k => `<div><span>${E(label(k))}</span><strong>${E(fmtVal(k, obj[k]))}</strong></div>`).join('')}</div>` : '<div class="v3-sub">—</div>';
    }
    const TW_KEYS = ['rpm', 'sfm', 'feed_ipm', 'ap_in', 'ae_in', 'chip_load_ipt', 'mrr_in3_min', 'deflection_in', 'flutes_cutting'];

    function planTable(plan) {
        return `<div class="v3-kv adv-plan">${Object.keys(plan).map(k => `<div><span>${E(k)}</span><strong>${E(plan[k])}</strong></div>`).join('')}</div>`;
    }
    function applyBlock(o, idx) {
        const ap = o.apply_plan;
        if (!ap || (!ap.recommended && !ap.keep_engagement)) return '';
        const btn = (kind, text, title) => `<button type="button" class="btn-ratio v3-btn" id="advApply_${idx}_${kind}" onclick="advisorApply(${idx}, '${kind}')" title="${E(title)}">${E(text)}</button>`;
        return `<div class="adv-apply"><h5 class="v3-h5">Apply ToolWiz's values to this operation</h5>
            ${ap.recommended ? `<div class="v3-sub">ToolWiz recommended engagement and speeds:</div>${planTable(ap.recommended)}${btn('recommended', 'Apply recommended values', 'Send exactly these parameters to the Fusion add-in')}` : ''}
            ${ap.keep_engagement ? `<div class="v3-sub" style="margin-top:0.6rem;">Or keep your own depth and width and change only speed and feed:</div>${planTable(ap.keep_engagement)}${btn('keep_engagement', 'Apply speed and feed only', 'Send exactly these parameters to the Fusion add-in')}` : ''}
            <div class="v3-sub">Fusion asks you to confirm every change before anything is written.</div>
            <div id="advApplyMsg_${idx}" class="v3-status" role="status" aria-live="polite"></div></div>`;
    }
    window.advisorApply = async function (idx, kind) {
        const o = data && data.operations && data.operations[idx];
        const msg = $('advApplyMsg_' + idx);
        if (!o || !o.apply_plan || !o.apply_plan[kind]) return;
        const btns = document.querySelectorAll(`[id^="advApply_${idx}_"]`); btns.forEach(b => { b.disabled = true; });
        msg.className = 'v3-status'; msg.textContent = 'Sending to the Fusion add-in…';
        const r = await T.api('/api/setup_advisor/apply', { op_id: o.op_id, params: o.apply_plan[kind], reason: 'ToolWiz setup advisor' });
        btns.forEach(b => { b.disabled = false; });
        if (r.ok) {
            const n = Object.keys(r.data.accepted || o.apply_plan[kind]).length;
            msg.className = 'v3-status ok-text';
            msg.textContent = `Sent ${n} parameter${n === 1 ? '' : 's'} to the Fusion add-in${r.data.request_id ? ' (request ' + r.data.request_id + ')' : ''}. Fusion will ask you to confirm before anything is changed.`;
            return;
        }
        const rej = r.data && r.data.rejected;
        msg.className = 'v3-status err';
        msg.innerHTML = rej && Object.keys(rej).length
            ? `ToolWiz refused to send these parameters:<ul class="v2-list">${Object.keys(rej).map(k => `<li><strong>${E(k)}</strong>: ${E(rej[k])}</li>`).join('')}</ul>`
            : E('Could not apply: ' + ((r.data && r.data.error) || ('HTTP ' + r.status)));
    };

    function strategyHtml(sg) {
        if (typeof sg === 'string') return `<li>${E(sg)}</li>`;
        const cur = sg.current_option && sg.current_option.name, rec = sg.recommended_option && sg.recommended_option.name || sg.recommended;
        const saved = T.finite(sg.time_saved_min) && sg.time_saved_min >= 0.05 ? `saves <strong>${T.num(sg.time_saved_min, 1)} min</strong>${T.finite(sg.time_saved_pct) ? ` (${T.num(sg.time_saved_pct, 0)} %)` : ''} per part` : '';
        const reasons = Array.isArray(sg.reasoning) ? sg.reasoning : (sg.reasoning ? [sg.reasoning] : []);
        const tabs = Array.isArray(sg.tab_advice) ? sg.tab_advice : [];
        return `<div class="adv-sugg-item"><div class="v3-title">${E(sg.name || sg.op_id || '')} ${sg.same_as_current ? '<span class="v3-pill ok">your approach is already the best</span>' : ''}</div>
            <div class="v3-sub">Recommended: <strong>${E(rec || '')}</strong>${cur && !sg.same_as_current ? `; your current approach: ${E(cur)}` : ''}${saved ? '; ' + saved : ''}.</div>
            ${(reasons.length || tabs.length) ? `<details class="v3-more"><summary>Why</summary><ul>${reasons.concat(tabs).map(t => `<li>${E(t)}</li>`).join('')}</ul></details>` : ''}</div>`;
    }

    function render() {
        const d = data, c = counts(d), sm = d.summary || {}, st = d.settings || {};
        const when = d.generated_at || d.received_at || d.pushed_at || d.timestamp;
        $('advMeta').textContent = [d.document || d.setup, st.family ? st.family + (st.alloy ? ' / ' + st.alloy : '') : '',
            T.finite(st.aggressiveness) ? 'aggressiveness ' + Math.round((st.aggressiveness > 1 ? st.aggressiveness : st.aggressiveness * 100)) + ' %' : '',
            T.finite(st.runout_in) ? 'runout ' + T.len(st.runout_in) : '', st.model ? 'model ' + st.model : '', when ? 'generated ' + String(when).replace('T', ' ').slice(0, 19) : ''].filter(Boolean).join(' · ');
        const verdict = sm.verdict ? `<span class="v3-pill ${sm.verdict === 'PASS' ? 'ok' : sm.verdict === 'STOP' ? 'bad' : 'warn'}">Verdict: ${E(sm.verdict)}</span>` : '';
        const chips = ['STOP', 'CAUTION', 'INFO'].map(s => `<label class="audit-sev"><input type="checkbox" value="${s}"${hidden.has(s) ? '' : ' checked'} onchange="advisorFilter(this)"> ${T.sevBadge(s)} <strong>${c[s]}</strong></label>`).join('');
        const summary = `<div class="glass-panel"><div class="audit-filters" role="group" aria-label="Show findings by severity">${verdict}${sm.operations != null ? `<span class="v3-sub">${sm.operations} operations</span>` : ''}${chips}</div></div>`;

        // narrative: shown only when the numeric guard passed
        let narr = '';
        const chk = d.narrative_check;
        if (d.narrative && chk && chk.ok === true) narr = `<div class="glass-panel"><div class="v3-title">Advisor summary <span class="v3-pill ok">numbers verified by ToolWiz</span></div><div class="adv-narr">${E(d.narrative).replace(/\n/g, '<br>')}</div></div>`;
        else if (chk && chk.ok === false) narr = `<div class="glass-panel">${T.callout('warn', 'AI summary withheld', `The optional AI summary was not shown because it contained numbers ToolWiz could not verify${(chk.rejected_numbers || []).length ? ` (${chk.rejected_numbers.length} unverified)` : ''}. The findings below are calculated by ToolWiz and are complete without it.`)}${d.narrative_note ? `<div class="v3-sub">${E(d.narrative_note)}</div>` : ''}</div>`;
        else if (d.narrative_note) narr = `<div class="v3-sub adv-note">${E(d.narrative_note)}</div>`;

        const setupF = sortF(d.setup_findings).map(findingHtml).join('');
        const sugg = (d.strategy_suggestions || []).map(strategyHtml).join('');
        const sNotes = (d.strategy_notes || []).map(t => `<li>${E(t)}</li>`).join('');
        const ops = (d.operations || []).map((o, idx) => {
            const fs = sortF(o.findings), worst = fs.length ? sevOf(fs[0]) : 'OK';
            const tw = (o.toolwiz || {}), rec = tw.recommended, cur = tw.at_current_engagement;
            const notes = (o.notes || []).map(t => `<li>${E(t)}</li>`).join('');
            return `<details class="glass-panel adv-op"${worst === 'STOP' || worst === 'CAUTION' ? ' open' : ''}><summary><span class="adv-opname">${E(o.name || o.op_id || 'Operation')}</span>
                <span class="v3-sub">${E(o.strategy || '')}${o.kind ? ' (' + E(o.kind) + ')' : ''}</span> ${fs.length ? T.sevBadge(worst) + ` <span class="v3-sub">${fs.length} finding${fs.length > 1 ? 's' : ''}</span>` : '<span class="v3-pill ok">no findings</span>'}</summary>
                <div class="adv-cols adv-cols3"><div><h5 class="v3-h5">In the setup now</h5>${kvTable(o.current, ['rpm', 'feed_ipm', 'stepdown_in', 'stepover_in', 'chip_load_ipt', 'mrr_in3_min', 'stock_radial_in', 'stock_axial_in'])}</div>
                    ${cur ? `<div><h5 class="v3-h5">ToolWiz at your depth and width</h5>${kvTable(cur, TW_KEYS)}</div>` : ''}
                    <div><h5 class="v3-h5">ToolWiz recommends</h5>${kvTable(rec, TW_KEYS)}</div></div>
                ${fs.map(findingHtml).join('')}${applyBlock(o, idx)}${notes ? `<details class="v3-more"><summary>Assumptions</summary><ul>${notes}</ul></details>` : ''}</details>`;
        }).join('');
        $('advBody').innerHTML = summary + narr +
            (setupF ? `<div class="glass-panel"><h3 class="v3-h3">Setup-level findings</h3>${setupF}</div>` : '') +
            (sugg || sNotes ? `<div class="glass-panel"><h3 class="v3-h3">Strategy suggestions</h3>${sugg}${sNotes ? `<ul class="v2-list adv-sugg">${sNotes}</ul>` : ''}</div>` : '') +
            `<h3 class="v3-h3 adv-ophead">Operations (${(d.operations || []).length})</h3>` + (ops || '<div class="glass-panel"><div class="v3-empty">No operations in this setup.</div></div>');
    }
    window.advisorFilter = function (box) { if (box.checked) hidden.delete(box.value); else hidden.add(box.value); render(); };
})();

/** AI chat: HTML for the guard badge. The server reports `numeric_check: {ok, rejected_numbers}` and `mode`
 * ("gemini_live" = LLM text passed the guard, "guard_fallback" = LLM text withheld, ToolWiz numbers shown). */
function aiVerifiedBadge(data) {
    if (!data || typeof data !== 'object') return '';
    const nc = data.numeric_check;
    if (data.mode === 'guard_fallback') return '<span class="v3-pill warn ai-verified" title="The AI answer contained numbers ToolWiz could not verify, so it was replaced by ToolWiz calculations.">AI text withheld: unverified numbers</span>';
    if (nc && nc.ok === true) return '<span class="v3-pill ok ai-verified" title="Every speed, feed, depth and width in this answer was checked against a ToolWiz calculation.">numbers verified by ToolWiz</span>';
    return '';
}
