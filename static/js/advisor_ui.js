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
        if (!Array.isArray(data.operations) && !data.setup_findings && !data.strategy_suggestions && !data.narrative) { renderEmpty(); return; }
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

    // Values of `current` / `toolwiz` come in inches, IPM, SFM; keys with those suffixes are converted for display.
    function fmtVal(k, v) {
        if (v == null || typeof v === 'object') return v == null ? '—' : JSON.stringify(v);
        if (typeof v !== 'number') return String(v);
        if (/_in$|^(doc|woc|ap|ae|stepdown|stepover|diameter|stickout)$/i.test(k)) return T.len(v);
        if (/_ipm$|^feed(rate)?$/i.test(k)) return T.feed(v);
        if (/_sfm$|^sfm$/i.test(k)) return T.sfm(v);
        if (/_ipt$|^ipt$/i.test(k)) return T.ipt(v);
        return Number.isInteger(v) ? String(v) : String(+v.toPrecision(4));
    }
    const label = k => String(k).replace(/_(in|ipm|sfm|ipt)$/i, '').replace(/_/g, ' ');
    function kvTable(obj) {
        const keys = Object.keys(obj || {}).filter(k => obj[k] != null && typeof obj[k] !== 'object');
        return keys.length ? `<div class="v3-kv">${keys.map(k => `<div><span>${E(label(k))}</span><strong>${E(fmtVal(k, obj[k]))}</strong></div>`).join('')}</div>` : '<div class="v3-sub">—</div>';
    }

    function render() {
        const d = data, c = counts(d);
        const when = d.received_at || d.pushed_at || d.timestamp || d.created_at;
        $('advMeta').textContent = [d.setup || d.setup_name, d.family ? d.family + (d.alloy ? ' / ' + d.alloy : '') : '', when ? 'received ' + String(when).replace('T', ' ').slice(0, 19) : ''].filter(Boolean).join(' · ');
        const chips = ['STOP', 'CAUTION', 'INFO'].map(s => `<label class="audit-sev"><input type="checkbox" value="${s}"${hidden.has(s) ? '' : ' checked'} onchange="advisorFilter(this)"> ${T.sevBadge(s)} <strong>${c[s]}</strong></label>`).join('');
        const summary = `<div class="glass-panel"><div class="audit-filters" role="group" aria-label="Show findings by severity">${chips}</div></div>`;

        // narrative: only when the numeric guard passed
        let narr = '';
        const chk = d.narrative_check;
        if (d.narrative) {
            if (chk && chk.ok === true) narr = `<div class="glass-panel"><div class="v3-title">Advisor summary <span class="v3-pill ok">numbers verified by ToolWiz</span></div><div class="adv-narr">${E(d.narrative).replace(/\n/g, '<br>')}</div></div>`;
            else narr = `<div class="glass-panel">${T.callout('warn', 'Narrative withheld', `The optional AI summary was not shown because it contained numbers ToolWiz could not verify${chk && (chk.rejected_numbers || []).length ? ` (${chk.rejected_numbers.length} unverified)` : ''}. The findings below are calculated by ToolWiz and are complete without it.`)}</div>`;
        }
        const setupF = sortF(d.setup_findings).map(findingHtml).join('');
        const sugg = (d.strategy_suggestions || []).map(s => typeof s === 'string' ? `<li>${E(s)}</li>` : `<li><strong>${E(s.title || s.name || '')}</strong> ${E(s.detail || s.reason || s.recommendation || '')}</li>`).join('');
        const ops = (d.operations || []).map(o => {
            const fs = sortF(o.findings), worst = fs.length ? sevOf(fs[0]) : 'OK';
            return `<details class="glass-panel adv-op"${worst === 'STOP' || worst === 'CAUTION' ? ' open' : ''}><summary><span class="adv-opname">${E(o.name || o.op_id || 'Operation')}</span>
                <span class="v3-sub">${E(o.strategy || '')}</span> ${fs.length ? T.sevBadge(worst) + ` <span class="v3-sub">${fs.length} finding${fs.length > 1 ? 's' : ''}</span>` : '<span class="v3-pill ok">no findings</span>'}</summary>
                <div class="adv-cols"><div><h5 class="v3-h5">In the setup now</h5>${kvTable(o.current)}</div><div><h5 class="v3-h5">ToolWiz recommends</h5>${kvTable(o.toolwiz)}</div></div>
                ${fs.map(findingHtml).join('')}</details>`;
        }).join('');
        $('advBody').innerHTML = summary + narr +
            (setupF ? `<div class="glass-panel"><h3 class="v3-h3">Setup-level findings</h3>${setupF}</div>` : '') +
            (sugg ? `<div class="glass-panel"><h3 class="v3-h3">Strategy suggestions</h3><ul class="v2-list adv-sugg">${sugg}</ul></div>` : '') +
            `<h3 class="v3-h3 adv-ophead">Operations (${(d.operations || []).length})</h3>` + (ops || '<div class="glass-panel"><div class="v3-empty">No operations in this setup.</div></div>');
    }
    window.advisorFilter = function (box) { if (box.checked) hidden.delete(box.value); else hidden.add(box.value); render(); };
})();

/** AI chat: HTML for the "numbers verified by ToolWiz" badge. The server reports the numeric guard result; the field
 * name is not fixed yet, so several spellings are accepted. Returns '' when the server says nothing (older server). */
function aiVerifiedBadge(data) {
    if (!data || typeof data !== 'object') return '';
    const g = data.numbers_verified !== undefined ? data.numbers_verified
        : (data.verified !== undefined ? data.verified
        : (data.narrative_check && data.narrative_check.ok !== undefined ? data.narrative_check.ok
        : (data.numeric_guard && data.numeric_guard.ok !== undefined ? data.numeric_guard.ok
        : (data.guard && data.guard.ok !== undefined ? data.guard.ok : undefined))));
    if (g === true) return '<span class="v3-pill ok ai-verified" title="Every speed, feed, depth and width in this answer was checked against a ToolWiz calculation.">numbers verified by ToolWiz</span>';
    if (g === false) return '<span class="v3-pill warn ai-verified" title="The answer contained numbers ToolWiz could not verify; do not rely on them.">unverified numbers withheld</span>';
    return '';
}
