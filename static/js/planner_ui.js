/* ToolWiz web: Strategy Planner tab (POST /api/strategy/compare). Lengths typed in the display unit, sent in inches. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    let rows = [];            // candidate tools: {kind:'manual'|'shop', ...}
    let nextId = 1;
    let shopTools = null, libTools = null;
    let lastResult = null;
    let inited = false;

    const feature = () => ($('plFeature') || {}).value || 'profile_cutout';

    window.initPlanner = async function () {
        if (!inited) {
            inited = true;
            const saved = T.safeStore('toolwiz_planner') || {};
            T.fillFamilies('plFamily', 'plAlloy', { family: saved.family || ($('family') || {}).value, alloy: saved.alloy || ($('alloy') || {}).value });
            const a = $('plAggr'); if (a && $('aggressiveness')) { a.value = $('aggressiveness').value; $('plAggrVal').textContent = a.value + '%'; }
            if (rows.length === 0) plannerAddManual({ d: 0.125, flutes: 2, flute: 0.375, shank: 0.125, stick: 0.6 }, true);
            const sr = await T.api('/api/shop_tools'); shopTools = (sr.data && sr.data.tools) || [];
            $('plShopPick').innerHTML = '<option value="">+ Shop cutter&hellip;</option>' + shopTools.map(t => `<option value="${T.esc(t.id)}">${T.esc(t.name)}${t.planned ? ' [planned]' : ''}</option>`).join('');
            const lr = await T.api('/api/twin/load'); libTools = ((lr.data && lr.data.tools) || []).filter(t => t.diameter_in > 0 && !t.geometry_error);
            $('plLibPick').innerHTML = '<option value="">+ From working library&hellip;</option>' + libTools.map(t => `<option value="${T.esc(t.guid || t.index)}">${t.number > 0 ? 'T' + T.esc(t.number) + ' ' : ''}${T.esc(t.description)}</option>`).join('');
            plannerFeatureChanged();
        }
        $('plRunout').value = T.fromIn(typeof runoutInches !== 'undefined' ? runoutInches : 0.0002, 5);
        const m = $('cutModelSelect'); if (m && m.value && !$('plModel').value) $('plModel').value = m.value;
        renderRows();
    };

    window.plannerFeatureChanged = function () {
        const f = feature();
        const map = { profile_cutout: 'profile', slot: 'slot', tslot: 'tslot', pocket: 'pocket' };
        document.querySelectorAll('#plannerView [class*="pl-f-"]').forEach(el => {
            el.style.display = el.classList.contains('pl-f-' + map[f]) ? '' : 'none';
        });
        if (f === 'pocket') {
            const by = ($('plPocketBy') || {}).value || 'rect';
            document.querySelectorAll('#plannerView .pl-pk-rect').forEach(el => { el.style.display = by === 'rect' ? '' : 'none'; });
            document.querySelectorAll('#plannerView .pl-pk-area').forEach(el => { el.style.display = by === 'area' ? '' : 'none'; });
        }
        $('plLengthLbl').textContent = f === 'profile_cutout' ? 'Perimeter (cut path length)' : 'Slot length';
        $('plAddManual').style.display = f === 'tslot' ? 'none' : '';
        $('plLibPick').style.display = f === 'tslot' ? 'none' : '';
        $('plShopPick').style.display = f === 'tslot' ? '' : 'none';
        // Candidates of the other kind do not apply: drop them.
        rows = rows.filter(r => (f === 'tslot') === (r.kind === 'shop'));
        if (!rows.length && f !== 'tslot') plannerAddManual({ d: 0.125, flutes: 2, flute: 0.375, shank: 0.125, stick: 0.6 }, true);
        renderRows();
    };

    window.plannerAddManual = function (v, quiet) {
        v = v || { d: 0.0625, flutes: 2, flute: 0.1875, shank: 0.125, stick: 0.4 };
        rows.push({ id: nextId++, kind: 'manual', d: v.d, flutes: v.flutes, flute: v.flute, shank: v.shank, stick: v.stick, coating: v.coating || 'Uncoated', label: v.label || '' });
        if (!quiet) renderRows();
    };
    window.plannerAddFromLibrary = function (sel) {
        const t = (libTools || []).find(x => String(x.guid || x.index) === sel.value);
        sel.value = '';
        if (!t) return;
        plannerAddManual({ d: t.diameter_in, flutes: t.flutes, flute: t.flute_length_in, shank: t.shank_diameter_in || t.diameter_in, stick: t.stickout_in || undefined, label: `${t.number > 0 ? 'T' + t.number + ' ' : ''}${t.description}` });
    };
    window.plannerAddShop = function (sel) {
        const t = (shopTools || []).find(x => x.id === sel.value);
        sel.value = '';
        if (!t || rows.some(r => r.id_shop === t.id)) return;
        rows.push({ id: nextId++, kind: 'shop', id_shop: t.id, tool: t });
        renderRows();
    };
    window.plannerRemove = function (id) { rows = rows.filter(r => r.id !== id); renderRows(); };

    function numField(r, key, label, step) {
        const v = r[key];
        return `<div class="input-group"><label for="pl_${r.id}_${key}">${label} (<span class="unit-lbl">${T.unitName()}</span>)</label>
            <input type="number" id="pl_${r.id}_${key}" class="tool-dialog-input" step="any" min="0" value="${v != null ? T.fromIn(v, 4) : ''}" onchange="plannerEdit(${r.id}, '${key}', this.value, true)"></div>`;
    }
    window.plannerEdit = function (id, key, val, isLen) {
        const r = rows.find(x => x.id === id); if (!r) return;
        if (key === 'coating' || key === 'label') r[key] = val;
        else if (key === 'flutes') r[key] = parseInt(val) || 2;
        else r[key] = isLen ? T.toIn(val) : parseFloat(val);
    };
    function renderRows() {
        const box = $('plTools'); if (!box) return;
        if (!rows.length) { box.innerHTML = `<div class="v3-empty">${feature() === 'tslot' ? 'Add one or more shop cutters to compare.' : 'Add at least one candidate tool.'}</div>`; return; }
        box.innerHTML = rows.map((r, i) => {
            if (r.kind === 'shop') {
                const t = r.tool, prov = (t.provisional || []);
                return `<div class="pl-tool"><div class="pl-tool-head"><strong>${T.esc(t.name)}</strong>
                    <button type="button" class="tool-action-btn delete" aria-label="Remove ${T.esc(t.name)}" onclick="plannerRemove(${r.id})">&times;</button></div>
                    <div class="v3-sub">${(t.diameter_mm / 25.4).toFixed(3)} in (${t.diameter_mm} mm) &times; ${t.kerf_mm} mm kerf, ${t.teeth} teeth${t.planned ? ', planned (not owned)' : ''}</div>
                    ${prov.length ? `<div class="v3-callout v3-warn"><div class="v3-callout-body">Provisional geometry: ${T.esc(prov.join(', '))}. Results depend on guesses until you measure them.</div></div>` : ''}</div>`;
            }
            return `<div class="pl-tool"><div class="pl-tool-head"><strong>Tool ${i + 1}</strong><input type="text" class="pl-label" aria-label="Tool ${i + 1} name" placeholder="name (optional)" value="${T.esc(r.label)}" onchange="plannerEdit(${r.id}, 'label', this.value)">
                <button type="button" class="tool-action-btn delete" aria-label="Remove tool ${i + 1}" onclick="plannerRemove(${r.id})">&times;</button></div>
                <div class="grid-layout pl-grid3">
                    ${numField(r, 'd', 'Diameter')}
                    <div class="input-group"><label for="pl_${r.id}_flutes">Flutes</label><input type="number" id="pl_${r.id}_flutes" class="tool-dialog-input" min="1" step="1" value="${r.flutes}" onchange="plannerEdit(${r.id}, 'flutes', this.value)"></div>
                    ${numField(r, 'flute', 'Flute length')}
                    ${numField(r, 'shank', 'Shank dia.')}
                    ${numField(r, 'stick', 'Stickout')}
                    <div class="input-group"><label for="pl_${r.id}_coating">Coating</label><select id="pl_${r.id}_coating" onchange="plannerEdit(${r.id}, 'coating', this.value)">${['Uncoated', 'TiN', 'TiCN', 'TiAlN', 'AlTiN', 'ZrN', 'Diamond'].map(c => `<option${c === r.coating ? ' selected' : ''}>${c}</option>`).join('')}</select></div>
                </div></div>`;
        }).join('');
    }

    function request() {
        const f = feature();
        const len = id => T.toIn($(id).value);
        const feat = { type: f };
        if (f !== 'pocket') feat.length = len('plLength');
        if (f === 'profile_cutout') {
            feat.depth = len('plDepth');
            const n = parseInt($('plTabCount').value) || 0;
            if (n > 0) feat.tabs = { count: n, width: len('plTabWidth'), height: len('plTabHeight'), style: $('plTabStyle').value };
            const ch = len('plChannel'); if (ch > 0) feat.channel_width = ch;
        } else if (f === 'pocket') {
            feat.depth = len('plDepth');
            if (($('plPocketBy') || {}).value === 'area') { feat.area = (parseFloat($('plPocketArea').value) || 0) / (T.metric() ? T.MM * T.MM : 1); feat.perimeter = len('plPocketPerim'); }
            else { feat.length = len('plPocketL'); feat.width = len('plPocketW'); }
            const cr = len('plCorner'); if (cr >= 0) feat.corner_radius = cr;
            const ia = parseFloat($('plIsland').value); if (ia > 0) feat.island_area = T.metric() ? ia / (T.MM * T.MM) : ia;
            const fm = $('plFinishMode').value; if (fm) feat.finish_mode = fm;
        } else if (f === 'slot') { feat.depth = len('plDepth'); feat.width = len('plWidth'); }
        else { feat.slot_height = len('plSlotHeight'); feat.radial_depth = len('plRadial'); }
        const body = { family: $('plFamily').value, alloy: $('plAlloy').value, aggressiveness: (parseFloat($('plAggr').value) || 50) / 100, runout: T.toIn($('plRunout').value), feature: feat };
        if (!(body.runout >= 0)) body.runout = 0.0002;
        const m = $('plModel').value; if (m) body.model = m;
        body.candidate_tools = rows.map(r => r.kind === 'shop' ? { id: r.id_shop } : { diameter: r.d, flutes: r.flutes, flute_length: r.flute, shank_diameter: r.shank || r.d, stickout: r.stick || undefined, coating: r.coating, geometry: 'Square', name: r.label || undefined });
        return body;
    }

    window.runStrategyCompare = async function () {
        const st = $('plStatus'), btn = $('plRun');
        if (!rows.length) { st.textContent = 'Add at least one candidate tool.'; st.className = 'v3-status err'; return; }
        const body = request();
        T.safeStore('toolwiz_planner', { family: body.family, alloy: body.alloy });
        st.textContent = 'Comparing… adaptive options can take a few seconds.'; st.className = 'v3-status'; btn.disabled = true;
        const r = await T.api('/api/strategy/compare', body);
        btn.disabled = false;
        if (!r.ok) { st.textContent = 'Could not compare: ' + (r.data.error || ('HTTP ' + r.status)); st.className = 'v3-status err'; return; }
        st.textContent = ''; lastResult = r.data; renderResult(r.data);
        const res = $('plResults'); if (res && res.scrollIntoView && window.innerWidth < 1000) res.scrollIntoView({ behavior: 'smooth', block: 'start' });
    };

    function minutes(m) { return T.finite(m) ? (m >= 10 ? m.toFixed(1) : m.toFixed(2)) + ' min' : '—'; }
    function renderResult(d) {
        const opts = d.options || [];
        const maxT = Math.max(...opts.map(o => o.cycle_time_min || 0), 1e-9);
        const maxW = Math.max(...opts.map(o => o.tool_wear_per_part || 0), 1e-9);
        const rec = opts.find(o => o.name === d.recommended);
        const bar = (v, max, cls) => `<span class="pl-bar ${cls}" style="width:${Math.max(3, Math.round(100 * (v || 0) / max))}%"></span>`;
        const head = rec ? `<div class="pl-rec"><div class="pl-rec-label">Recommended</div><div class="pl-rec-name">${T.esc(rec.name)}</div>
            <div class="v3-kv"><div><span>Time per part</span><strong>${minutes(rec.cycle_time_min)}</strong></div><div><span>Wear per part</span><strong>${T.num(rec.tool_wear_per_part, 2)}&times;</strong></div>
            <div><span>Speed / feed</span><strong>${Math.round(rec.rpm)} rpm, ${T.feed(rec.feed_ipm)}</strong></div><div><span>Depth &times; width</span><strong>${T.len(rec.ap)} &times; ${T.len(rec.ae)}</strong></div></div></div>`
            : T.callout('bad', 'No feasible option', 'ToolWiz found no safe cut for these tools. See the skipped and risk notes below.');
        const table = `<div class="why-table-wrap"><table class="why-table pl-table"><caption class="sr-only">Strategy options</caption><thead><tr><th>Option</th><th>Strategy</th><th class="v2-num">Time / part</th><th class="v2-num">Wear / part</th><th class="v2-num">Levels</th><th class="v2-num">ap</th><th class="v2-num">ae</th><th class="v2-num">RPM</th><th class="v2-num">Feed</th></tr></thead><tbody>${
            opts.map((o, i) => `<tr class="${o.name === d.recommended ? 'pl-row-rec' : ''}${o.feasible === false ? ' pl-row-bad' : ''}">
                <td><strong>${T.esc(o.name)}</strong>${o.name === d.recommended ? ' <span class="v3-pill ok">best</span>' : ''}${o.feasible === false ? ' <span class="v3-pill bad">not feasible</span>' : ''}</td>
                <td>${T.esc(String(o.strategy || '').replace(/_/g, ' '))}</td>
                <td class="v2-num"><div class="pl-bartxt">${minutes(o.cycle_time_min)}</div>${bar(o.cycle_time_min, maxT, 'time')}</td>
                <td class="v2-num"><div class="pl-bartxt">${T.num(o.tool_wear_per_part, 2)}&times;</div>${bar(o.tool_wear_per_part, maxW, 'wear')}</td>
                <td class="v2-num">${o.levels != null ? o.levels : '—'}</td><td class="v2-num">${T.len(o.ap, { unit: false })}</td><td class="v2-num">${T.len(o.ae, { unit: false })}</td>
                <td class="v2-num">${Math.round(o.rpm)}</td><td class="v2-num">${T.feed(o.feed_ipm, 1)}</td></tr>`).join('')}</tbody></table></div>
            <div class="v3-sub">Depth and width in ${T.unitName()}. Wear per part: 1.00 is the option that wears the tool least; recommendation limit is ${T.num(d.wear_ratio_limit, 2)}&times; at this aggressiveness.</div>`;
        const reasoning = (d.reasoning || []).length ? `<h4 class="v3-h4">Reasoning</h4><ul class="v2-list pl-reason">${d.reasoning.map(t => `<li>${T.esc(t)}</li>`).join('')}</ul>` : '';
        const details = opts.map(o => detailBlock(o)).join('');
        const tabs = (d.tab_advice || []).length ? `<h4 class="v3-h4">Tab advice</h4><ul class="v2-list">${d.tab_advice.map(t => `<li>${T.esc(t)}</li>`).join('')}</ul>` : '';
        const skipped = (d.skipped || []).length ? `<h4 class="v3-h4">Skipped</h4><ul class="v2-list">${d.skipped.map(t => `<li>${T.esc(typeof t === 'string' ? t : JSON.stringify(t))}</li>`).join('')}</ul>` : '';
        const assume = (d.assumptions || []).length ? `<details class="v3-more"><summary>Assumptions (${d.assumptions.length})</summary><ul>${d.assumptions.map(t => `<li>${T.esc(t)}</li>`).join('')}</ul></details>` : '';
        $('plResults').innerHTML = `<h3 class="v3-h3">Result</h3>${head}${table}${reasoning}<h4 class="v3-h4">Option details, risks and Fusion hints</h4>${details}${tabs}${skipped}${assume}`;
    }

    function hintLines(h) {
        if (!h) return '';
        const L = [];
        const add = (k, v) => { if (v != null && v !== '') L.push(`<li><strong>${T.esc(k)}:</strong> ${T.esc(v)}</li>`); };
        add('Fusion strategy', h.fusion_strategy);
        if (h.multiple_depths) add('Multiple depths', `${h.multiple_depths.levels} levels, maximum stepdown ${T.len(h.multiple_depths.maximumStepdown_in)}`);
        if (h.optimal_load_in != null) add('Optimal load', T.len(h.optimal_load_in));
        if (h.stepover) add('Stepover', h.stepover);
        if (h.tabs) add('Tabs', `useTabs, ${h.tabs.tabPositioning}; width ${T.len(h.tabs.tabWidth_in)}, height ${T.len(h.tabs.tabHeight_in)}; ${h.tabs.tab_style}`);
        if (h.ramp) add('Ramp', `${h.ramp.type} at ${h.ramp.ramp_angle_deg}°, ramp feed ${T.feed(h.ramp.ramp_feed_ipm)}, plunge ${T.feed(h.ramp.plunge_feed_ipm)}`);
        const s = h.stock_to_leave;
        if (s && s.toolwiz_recommendation_in) add('Stock to leave', `${T.len(s.radial_in)} radial / ${T.len(s.axial_in)} axial in this operation. ToolWiz recommends ${T.len(s.toolwiz_recommendation_in.radial)} radial, ${T.len(s.toolwiz_recommendation_in.axial)} axial for a true-to-size finish. ${s.note || ''}`);
        add('Finishing', h.finishing_pass);
        if (h.rest_machining && h.rest_machining.needed) add('Rest machining', h.rest_machining.note);
        if (h.corner_feed && h.corner_feed.scale < 0.999) add('Corner feed', `Feed Optimization at ${Math.round(h.corner_feed.scale * 100)}% of feed in tight corners (engagement rises to ${T.len(h.corner_feed.effective_ae_in)})`);
        return L.length ? `<ul class="v2-list">${L.join('')}</ul>` : '';
    }
    function detailBlock(o) {
        const risks = (o.risks || []).map(t => `<li>${T.esc(t)}</li>`).join('');
        const notes = (o.notes || []).map(t => `<li>${T.esc(t)}</li>`).join('');
        const tb = o.time_breakdown_min || {};
        return `<details class="v3-more pl-detail"><summary>${T.esc(o.name)} <span class="v3-sub">${minutes(o.cycle_time_min)}, wear ${T.num(o.tool_wear_per_part, 2)}&times;</span></summary>
            <div class="v3-sub">Cutting ${minutes(tb.cutting)}, ramp entries ${minutes(tb.ramp_entries)}, links and retracts ${minutes(tb.links_and_retracts)}. Relative tool life ${T.num(o.relative_tool_life, 1)}. Path length ${T.len(o.path_length_in)}.</div>
            ${o.data_basis ? `<div class="v3-sub">Basis: ${T.esc(o.data_basis)}</div>` : ''}
            ${risks ? `<h5 class="v3-h5">Risks</h5><ul class="v2-list v2-warn">${risks}</ul>` : ''}
            ${notes ? `<h5 class="v3-h5">Notes</h5><ul class="v2-list">${notes}</ul>` : ''}
            <h5 class="v3-h5">Fusion hints</h5>${hintLines(o.fusion_hints)}</details>`;
    }
    window.plannerUnitChanged = function () {
        // Typed values are in the display unit: convert them when the unit toggle flips (isMetric is already the new state).
        ['plDepth', 'plLength', 'plWidth', 'plChannel', 'plSlotHeight', 'plRadial', 'plTabWidth', 'plTabHeight', 'plRunout', 'plPocketL', 'plPocketW', 'plPocketPerim', 'plCorner'].forEach(id => {
            const el = $(id); const v = el ? parseFloat(el.value) : NaN;
            if (Number.isFinite(v)) el.value = +(T.metric() ? v * T.MM : v / T.MM).toFixed(T.metric() ? 4 : 5);
        });
        ['plPocketArea', 'plIsland'].forEach(id => {     // areas scale with the square of the unit
            const el = $(id); const v = el ? parseFloat(el.value) : NaN;
            if (Number.isFinite(v)) el.value = +(T.metric() ? v * T.MM * T.MM : v / (T.MM * T.MM)).toFixed(T.metric() ? 2 : 4);
        });
        renderRows(); if (lastResult) renderResult(lastResult);
    };
})();
