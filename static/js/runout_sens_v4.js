/* ToolWiz web: runout sensitivity card for tools of 1/8" and smaller (POST /api/runout_sensitivity).
 * RunoutSens.update(payload, res) is called by calculate() in the page; RunoutSens.run() fetches the sweep.
 * The API is inches / IPM; lengths are shown in the page's unit via TW.len / TW.feed. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const E = v => T.esc(v);
    const SMALL_IN = 0.125 + 1e-6;
    let lastPayload = null;
    let seq = 0;
    let shown = false;     // the sweep has been requested for this tool: refresh it when the cut changes
    let timer = null;

    function mrrText(v) {
        if (!T.finite(v)) return '—';
        return T.metric() ? (v * 16.387064).toFixed(3) + ' cm³/min' : Number(v).toFixed(5) + ' in³/min';
    }
    function mrrNum(v) { return T.metric() ? v * 16.387064 : v; }

    function chart(rows, current) {
        const pts = rows.filter(r => T.finite(r.mrr_in3_min));
        if (pts.length < 2) return '';
        const W = 520, H = 230, L = 64, R = 16, Tp = 14, B = 44, pw = W - L - R, ph = H - Tp - B;
        const xMax = Math.max(...pts.map(r => r.runout_in)) || 1;
        const yMax = Math.max(...pts.map(r => mrrNum(r.mrr_in3_min))) * 1.1 || 1;
        const px = v => (L + v / xMax * pw).toFixed(1), py = v => (Tp + ph - v / yMax * ph).toFixed(1);
        let g = '';
        for (let i = 0; i <= 4; i++) {
            const y = yMax * i / 4;
            g += `<line class="grid" x1="${L}" x2="${W - R}" y1="${py(y)}" y2="${py(y)}"/><text x="${L - 6}" y="${+py(y) + 4}" text-anchor="end">${y.toFixed(y < 1 ? 4 : 2)}</text>`;
        }
        pts.forEach(r => {
            g += `<text x="${px(r.runout_in)}" y="${Tp + ph + 15}" text-anchor="middle">${E(T.len(r.runout_in, { unit: false, dec: T.metric() ? 4 : 5 }).replace(/0+$/, '').replace(/\.$/, '') || '0')}</text>`;
        });
        g += `<line class="axis" x1="${L}" x2="${L}" y1="${Tp}" y2="${Tp + ph}"/><line class="axis" x1="${L}" x2="${W - R}" y1="${Tp + ph}" y2="${Tp + ph}"/>` +
            `<text x="${L + pw / 2}" y="${H - 6}" text-anchor="middle">Runout, TIR (${T.unitName()})</text>` +
            `<text transform="translate(13 ${Tp + ph / 2}) rotate(-90)" text-anchor="middle">MRR (${T.metric() ? 'cm³/min' : 'in³/min'})</text>`;
        g += `<polyline class="line" points="${pts.map(r => px(r.runout_in) + ',' + py(mrrNum(r.mrr_in3_min))).join(' ')}"/>`;
        pts.forEach(r => {
            const cur = Math.abs(r.runout_in - current) < 1e-9;
            g += `<circle class="dot${cur ? ' cur' : ''}" cx="${px(r.runout_in)}" cy="${py(mrrNum(r.mrr_in3_min))}" r="${cur ? 5 : 3.5}"><title>${E(T.len(r.runout_in))}: ${E(mrrText(r.mrr_in3_min))}</title></circle>`;
        });
        return `<svg class="rs-chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="Material removal rate against runout; the table below gives the same numbers. The orange point is your current runout.">${g}</svg>`;
    }

    function rowHtml(r, label, cur) {
        const flutes = r.flutes_cutting == null ? '—' : r.flutes_cutting;
        return `<tr${cur ? ' class="rs-cur"' : ''}><td>${E(label)}</td><td>${r.rpm == null ? '—' : Math.round(r.rpm).toLocaleString()}</td><td>${E(T.feed(r.feed_ipm, 1))}</td>` +
            `<td>${E(T.ipt(r.fz_in))}</td><td>${E(T.len(r.ap_in, { unit: false }))} × ${E(T.len(r.ae_in, { unit: false }))}</td>` +
            `<td>${E(mrrText(r.mrr_in3_min))}</td><td>${flutes}</td><td>${E(r.runout_regime || '—')}</td><td>${r.feasible === false ? 'infeasible' : E(r.limited_by_words || '—')}</td></tr>`;
    }
    const HEAD = '<tr><th scope="col">Runout</th><th scope="col">rpm</th><th scope="col">Feed</th><th scope="col">Chip load</th><th scope="col">ap × ae</th><th scope="col">MRR</th><th scope="col">Flutes cutting</th><th scope="col">Regime</th><th scope="col">Limited by</th></tr>';

    function render(d) {
        const cur = d.current.runout_in;
        const sum = (d.summary || []).map(s => `<li>${E(s)}</li>`).join('');
        const rows = d.rows.map(r => rowHtml(r, T.len(r.runout_in), Math.abs(r.runout_in - cur) < 1e-9)).join('');
        const hold = d.holder_classes.map(c => rowHtml(c, `${c.label} (${T.len(c.tir_in)})` + (c.is_current ? ' — nearest to yours' : '') + (c.fits_shank === false ? ' — shank does not fit' : ''), c.is_current)).join('');
        $('rsBody').innerHTML =
            `<p class="rs-note">Your runout setting: <strong>${E(T.len(cur))}</strong> (closest holder class: ${E(d.current.class_label)}). Model ${E(d.model)}, aggressiveness ${E(d.aggressiveness)}%.</p>` +
            `<ul class="rs-sum">${sum}</ul>` + chart(d.rows, cur) +
            `<div class="rs-wrap"><table class="rs-table"><caption>Recommended cut at each runout</caption><thead>${HEAD}</thead><tbody>${rows}</tbody></table></div>` +
            `<div class="rs-wrap" style="margin-top:0.6rem"><table class="rs-table"><caption>At the typical runout of each holder class (published TIR, data/holders.json)</caption><thead>${HEAD}</thead><tbody>${hold}</tbody></table></div>`;
    }

    async function run() {
        const p = lastPayload;
        if (!p) return;
        const my = ++seq, btn = $('rsRun');
        shown = true;
        btn.disabled = true;
        $('rsBody').innerHTML = '<p class="rs-note">Calculating the cut at each runout&hellip; (about 10 to 30 seconds the first time)</p>';
        const body = Object.assign({}, p);
        const r = await T.api('/api/runout_sensitivity', body, 'POST');
        if (my !== seq) return;
        btn.disabled = false;
        btn.textContent = 'Refresh';
        if (!r.ok) { $('rsBody').innerHTML = `<p class="rs-note" style="color:#f87171">Could not run the sweep: ${E(r.data.error || r.status)}</p>`; return; }
        render(r.data);
    }

    function update(payload, res) {
        const card = $('runoutSensCard');
        if (!card) return;
        const small = payload && payload.diameter > 0 && payload.diameter <= SMALL_IN;
        card.style.display = small ? '' : 'none';
        if (!small) { shown = false; return; }
        lastPayload = Object.assign({}, payload);
        delete lastPayload.cutDepth; delete lastPayload.cutWidth;   // sweep the recommended engagement, not a hand-set one
        if (payload.cutDepth && payload.cutWidth && typeof engagementManual !== 'undefined' && engagementManual) { lastPayload.cutDepth = payload.cutDepth; lastPayload.cutWidth = payload.cutWidth; }
        if (shown) { clearTimeout(timer); timer = setTimeout(run, 900); }
    }

    window.RunoutSens = { update, run };
})();
