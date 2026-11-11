/* ToolWiz web: T-slot / keyseat inputs, the shop-cutter picker and the request fields they add to /api/calculate. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    let shopTools = null;

    window.updateTslotVisibility = function (isForm) {
        const box = $('tslotInputs');
        if (box) box.style.display = isForm ? 'block' : 'none';
        if (isForm && shopTools === null) loadShopTools();
    };

    async function loadShopTools() {
        shopTools = [];
        const r = await T.api('/api/shop_tools');
        shopTools = (r.data && r.data.tools) || [];
        const sel = $('shopToolSelect');
        if (!sel) return;
        sel.innerHTML = '<option value="">Pick one of your cutters&hellip;</option>' + shopTools.map(t =>
            `<option value="${T.esc(t.id)}">${T.esc(t.name)}${t.planned ? ' [planned]' : ''}${(t.provisional || []).length ? ' [provisional]' : ''}</option>`).join('');
    }

    /** Request fields for the T-slot model (inches), added to the /api/calculate payload for form cutters. */
    window.tslotPayload = function () {
        const faces = ['periphery', 'top', 'bottom'].filter(f => { const c = $('face' + f); return c && c.checked; });
        const out = { tslotOperation: ($('tslotOperation') || {}).value || 'full_slot', cuttingFaces: faces.length ? faces : undefined };
        const form = ($('toothForm') || {}).value; if (form) out.toothForm = form;
        const tpf = parseInt(($('teethPerFace') || {}).value); if (tpf > 0) out.teethPerFace = tpf;
        const sh = T.toIn(($('slotHeight') || {}).value); if (sh > 0) out.slotHeight = sh;
        const rd = T.toIn(($('radialDepthTotal') || {}).value); if (rd > 0) out.radialDepthTotal = rd;
        return out;
    };

    window.onShopToolPick = function () {
        const id = ($('shopToolSelect') || {}).value;
        const note = $('shopToolNote');
        const t = (shopTools || []).find(x => x.id === id);
        if (!t) { if (note) note.innerHTML = ''; return; }
        const mm = v => (v == null ? NaN : v / 25.4);        // file is in mm; the page fields are in the display unit
        const put = (fieldId, inches, dec) => { const el = $(fieldId); if (el && Number.isFinite(inches)) el.value = T.fromIn(inches, dec); if (el && typeof markManualEdit === 'function') { try { markManualEdit(fieldId === 'shaftDiameter' ? 'shaftDiameter' : fieldId); } catch (e) { /* not tracked */ } } };
        const geo = $('geometry');
        if (geo) { geo.value = 'T-Slot'; if (typeof updateGeometryDisplay === 'function') updateGeometryDisplay('geometry'); }
        put('diameter', mm(t.diameter_mm), 4);
        put('cutterThickness', mm(t.kerf_mm), 4);
        put('shaftDiameter', mm(t.shank_diameter_mm), 4);
        put('shoulderDiameter', mm(t.neck_diameter_mm), 4);
        put('shoulderLength', mm(t.reach_mm), 4);
        const fl = $('flutes_val'), fr = $('flutes');
        if (fl && t.teeth) { fl.value = t.teeth; if (fr) fr.value = t.teeth; if (typeof markManualEdit === 'function') markManualEdit('flutes'); }
        const coat = $('coating');
        if (coat && t.coating) { const c = /titan|tin$/i.test(t.coating) ? 'TiN' : t.coating; if (Array.from(coat.options).some(o => o.value === c)) coat.value = c; }
        if ($('toothForm')) $('toothForm').value = t.tooth_form || '';
        if ($('teethPerFace')) $('teethPerFace').value = t.teeth_per_face || '';
        const faces = t.cutting_faces || [];
        ['periphery', 'top', 'bottom'].forEach(f => { const c = $('face' + f); if (c) c.checked = faces.includes(f); });
        const prov = t.provisional || [];
        const parts = [];
        if (prov.length) parts.push(`<div class="v3-callout v3-warn"><div class="v3-callout-title">Provisional geometry</div><div class="v3-callout-body">These values are assumed, not measured: <strong>${T.esc(prov.join(', '))}</strong>. Measure neck diameter, reach and tooth form with calipers and correct the fields before trusting the neck deflection and pass count.</div></div>`);
        if (t.planned) parts.push('<div class="v3-sub">Planned cutter: not owned yet.</div>');
        if (/titan/i.test(t.coating || '')) parts.push('<div class="v3-sub">Listed as titanium coated; the coating menu is set to TiN, change it if you know the exact coating.</div>');
        if (t.source_note) parts.push(`<div class="v3-sub">${T.esc(t.source_note)}</div>`);
        if (t.source_url) parts.push(`<div class="v3-sub"><a href="${T.esc(t.source_url)}" target="_blank" rel="noopener noreferrer">Source listing</a></div>`);
        if (note) note.innerHTML = parts.join('');
        if (typeof calculate === 'function') calculate();
    };
})();
