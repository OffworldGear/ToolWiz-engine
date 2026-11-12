/* ToolWiz web: tool brand input and the "Vendor basis" result line (owner decisions 2026-11-12).
 * brandPayload() adds {brand} to the /api/calculate body (blank = none); setBrandFromTool(tool) fills the field from a
 * Fusion library tool's vendor; vendorBasisLine(res) is the one-line summary renderV3Result shows. */
(function () {
    'use strict';
    const $ = id => document.getElementById(id);
    window.brandPayload = function () {
        const el = $('toolBrand');
        const v = el ? String(el.value || '').trim() : '';
        return v ? { brand: v } : {};
    };
    window.setBrandFromTool = function (tool) {
        const el = $('toolBrand');
        if (!el || !tool) return;
        const v = typeof tool.vendor === 'string' ? tool.vendor.trim() : '';
        el.value = v;
    };
    window.vendorBasisLine = function (res) {
        const vb = res && res.vendor_basis;
        if (!vb || !vb.note) return '';
        const T = window.TW;
        const esc = s => (T && T.esc ? T.esc(s) : String(s));
        let range = '';
        if (Array.isArray(vb.sfm_range) && vb.sfm_range.length === 3) {
            const r = vb.sfm_range.map(x => Math.round(x));
            range = ` <span class="v3-sub" style="display:inline;">(chart SFM ${r[0]}–${r[1]}–${r[2]}, ${vb.rows} rows; 0 % / 50 % / 100 %)</span>`;
        }
        return `<span class="v3-limited-label">Vendor basis</span> ${esc(String(vb.note).replace(/^Vendor basis:\s*/, ''))}${range}`;
    };
})();
