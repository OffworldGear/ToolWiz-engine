/* ToolWiz web: "Alternative tools" card under the main result (POST /api/advice/alternative_tools, docs/TOOL_RECOMMENDER.md).
 * ToolAlt.update(payload, res) is called by calculate() in the page (it only shows the card and remembers the cut: nothing is
 * requested on a keystroke); ToolAlt.run() sends the request when the button is pressed. The API is inches / IPM; lengths are shown
 * in the page's unit through TW.len / TW.feed. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const E = v => T.esc(v);
    const NOT_MILL = /drill|tap|ream|thread|bore|woodruff|saw|t-slot|keyseat|dovetail|lollipop|chamfer|engrav|v-bit|face mill/i;
    let lastPayload = null, ranFor = null, seq = 0;

    function sig(p) {
        return p ? JSON.stringify([p.family, p.alloy, p.operation, p.diameter, p.flutes, p.fluteLength, p.stickout, p.cornerRadius, p.brand, p.coating, p.aggressiveness, p.model]) : '';
    }
    function rateText(a) {
        const m = a.rate_metric;
        const v = Number(a.rate);
        if (m === 'mrr_in3_min') return 'MRR ' + (T.metric() ? (v * 16.387064).toFixed(3) + ' cm³/min' : v.toFixed(4) + ' in³/min');
        const u = T.metric() ? (v * 645.16).toFixed(1) + ' mm²/min' : v.toFixed(4) + ' in²/min';
        return (m === 'slot_advance_in2_min' ? 'Slot advance ' : m === 'finish_area_rate_in2_min' ? 'Finish rate ' : 'Wall finish rate ') + u;
    }
    function toolName(a) {
        const d = T.len(a.diameter, { dec: T.metric() ? 2 : 4 });
        if (a.source === 'library' && a.library_tool) {
            const n = a.library_tool.number ? 'T' + a.library_tool.number + ' ' : '';
            return `${n}${a.library_tool.description || 'library tool'}`;
        }
        const b = a.brand ? a.brand + (a.series ? ' ' + a.series : '') : 'Any brand';
        return `${b}, ${a.flutes}-flute ${d}`;
    }
    function itemHtml(a) {
        const nums = `${Math.round(a.rpm).toLocaleString()} rpm · ${T.feed(a.feed_ipm, 1)} · ap ${T.len(a.ap, { unit: false })} × ae ${T.len(a.ae, { unit: false })} ${T.unitName()} · ${rateText(a)}`;
        const fin = a.finish ? ` · Ra ${Number(a.finish.predicted_ra_uin).toFixed(0)} µin, wall error ${T.len(a.finish.predicted_wall_error_in, { dec: T.metric() ? 4 : 5 })}` : '';
        const dim = `${a.flutes} flutes, ${T.len(a.diameter)} dia, ${T.len(a.flute_length)} flute length`;
        const cav = (a.caveats || []).map(c => `<li>${E(c)}</li>`).join('');
        const ct = a.cycle_time_min != null ? ` · cycle time ${Number(a.cycle_time_min).toFixed(2)} min` : '';
        return `<li class="ta-item ${a.source === 'library' ? 'ta-lib' : ''}">
            <div class="ta-top"><span class="ta-gain">+${Number(a.gain_pct).toFixed(0)} %</span><span class="ta-name">${E(toolName(a))}</span>
            <span class="ta-tag">${a.source === 'library' ? 'your library' : 'catalog geometry'}</span></div>
            <div class="ta-nums">${E(nums + fin + ct)}</div>
            <div class="ta-why">${E(a.why)}</div>
            <details class="ta-more"><summary>Details and caveats</summary><ul><li>${E(dim)}${a.limited_by ? '; limited by ' + E(String(a.limited_by)) : ''}</li>${cav}</ul></details></li>`;
    }
    function render(d) {
        const cur = d.current || {};
        const head = `<p class="ta-note">Current tool: ${Math.round(cur.rpm).toLocaleString()} rpm · ${E(T.feed(cur.feed_ipm, 1))} · ${E(rateText(cur))}. ${E(cur.basis || '')}</p>`;
        let body;
        if ((d.alternatives || []).length) {
            body = `<p class="ta-note"><strong>${d.alternatives.length}</strong> alternative${d.alternatives.length === 1 ? '' : 's'} gain ${Number(d.min_gain_pct).toFixed(0)} % or more.</p><ul class="ta-list">${d.alternatives.map(itemHtml).join('')}</ul>`;
        } else {
            const rs = (d.not_recommended_reasons || []).map(r => `<li>${E(r)}</li>`).join('');
            const best = (d.below_threshold || [])[0];
            body = `<div class="ta-none"><strong>No tool change is worth it for this cut.</strong><ul>${rs}</ul>${best ? `<div>The best other tool tried gains only ${Number(best.gain_pct).toFixed(0)} % (${E(toolName(best))}).</div>` : ''}</div>`;
        }
        const assume = (d.assumptions || []).map(r => `<li>${E(r)}</li>`).join('');
        const disc = (d.disclaimers || []).map(r => `<li>${E(r)}</li>`).join('');
        $('taBody').innerHTML = head + body +
            `<details class="ta-more"><summary>How this was compared (${d.engine_runs} ToolWiz runs)</summary><ul>${assume}${disc}</ul></details>`;
    }

    async function run() {
        const p = lastPayload;
        if (!p) return;
        const my = ++seq, btn = $('taRun');
        btn.disabled = true;
        $('taBody').innerHTML = '<p class="ta-note">Rerunning this cut with other tools&hellip; (about 5 to 30 seconds)</p>';
        const body = {
            family: p.family, alloy: p.alloy, operation: p.operation, diameter: p.diameter, flutes: p.flutes, flute_length: p.fluteLength,
            shank_diameter: p.shankDiameter, stickout: p.stickout, corner_radius: p.cornerRadius, coating: p.coating, brand: p.brand,
            aggressiveness: p.aggressiveness, runout: p.runout, max_rpm: p.maxRpm, max_hp: p.maxHp, model: p.model, is_carbide: p.isCarbide,
            finish_mode: p.finishMode, target_ra: p.targetRa, wall_tolerance: p.wallTolerance
        };
        const maxD = T.toIn($('taMaxDia').value), reach = T.toIn($('taReach').value);
        if (maxD > 0) body.max_diameter_in = maxD;
        if (reach > 0) body.min_reach_in = reach;
        body.full_slot = $('taSlot').checked;
        const r = await T.api('/api/advice/alternative_tools', body, 'POST');
        if (my !== seq) return;
        btn.disabled = false;
        btn.textContent = 'Find again';
        if (!r.ok) { $('taBody').innerHTML = `<p class="ta-note" style="color:#f87171">Could not compare tools: ${E(r.data.error || r.status)}</p>`; return; }
        ranFor = sig(p);
        render(r.data);
    }

    function update(payload, res) {
        const card = $('toolAltCard');
        if (!card) return;
        const kind = payload ? `${payload.tool || ''} ${payload.geometry || ''}` : '';
        const ok = payload && payload.diameter > 0 && res && !res.tslot && !NOT_MILL.test(kind);
        card.style.display = ok ? '' : 'none';
        if (!ok) return;
        lastPayload = Object.assign({}, payload);
        delete lastPayload.cutDepth; delete lastPayload.cutWidth;
        document.querySelectorAll('#toolAltCard .ta-unit').forEach(e => { e.textContent = T.unitName(); });
        const op = String(payload.operation || '').toLowerCase();
        const slot = $('taSlot');
        if (slot && !slot.dataset.touched) slot.checked = op.includes('slot');
        if (ranFor !== null && ranFor !== sig(payload) && !$('taBody').querySelector('.ta-stale')) {
            $('taBody').insertAdjacentHTML('afterbegin', '<p class="ta-note ta-stale">The tool or cut changed since this comparison. Press Find again.</p>');
        }
    }
    document.addEventListener('DOMContentLoaded', () => { const s = $('taSlot'); if (s) s.addEventListener('change', () => { s.dataset.touched = '1'; }); });

    window.ToolAlt = { update, run };
})();
