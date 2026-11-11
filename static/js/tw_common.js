/* ToolWiz web: shared helpers for the v3 panels (loaded after the main inline script).
 * The API is inches / IPM / SFM; everything is converted here, at display time, using the page's isMetric flag. */
(function () {
    'use strict';
    const MM = 25.4;
    const metric = () => (typeof isMetric !== 'undefined') && isMetric;
    const finite = v => v !== null && v !== undefined && v !== '' && Number.isFinite(Number(v));
    const E = v => (typeof esc === 'function') ? esc(v) : String(v == null ? '' : v);

    /** Length in inches -> display string with unit, e.g. 0.0002 -> "0.0002 in" or "0.0051 mm". */
    function len(inches, opts) {
        if (!finite(inches)) return '—';
        const v = Number(inches);
        const withUnit = !(opts && opts.unit === false);
        if (metric()) {
            const mm = v * MM, a = Math.abs(mm);
            const dec = (opts && opts.dec) != null ? opts.dec : (a === 0 ? 1 : a < 0.01 ? 4 : a < 0.1 ? 3 : a < 10 ? 3 : 2);
            return mm.toFixed(dec) + (withUnit ? ' mm' : '');
        }
        const a = Math.abs(v);
        const dec = (opts && opts.dec) != null ? opts.dec : (a === 0 ? 1 : a < 0.001 ? 5 : a < 10 ? 4 : 3);
        return v.toFixed(dec) + (withUnit ? ' in' : '');
    }
    /** Feed in IPM -> "12.3 IPM" or "312.4 mm/min". */
    function feed(ipm, dec) {
        if (!finite(ipm)) return '—';
        const v = Number(ipm);
        return metric() ? (v * MM).toFixed(dec != null ? dec : 0) + ' mm/min' : v.toFixed(dec != null ? dec : 2) + ' IPM';
    }
    /** Surface speed in SFM -> "260 SFM" or "80 m/min". */
    function sfm(v) {
        if (!finite(v)) return '—';
        return metric() ? Math.round(Number(v) * 0.3048) + ' m/min' : Math.round(Number(v)) + ' SFM';
    }
    /** Chip load in in/tooth. */
    function ipt(v) {
        if (!finite(v)) return '—';
        return metric() ? (Number(v) * MM).toFixed(4) + ' mm/tooth' : Number(v).toFixed(5) + ' in/tooth';
    }
    function num(v, d) { return finite(v) ? Number(v).toFixed(d == null ? 2 : d) : '—'; }
    function pct(frac, d) { return finite(frac) ? (Number(frac) * 100).toFixed(d == null ? 0 : d) + ' %' : '—'; }
    /** Input value in the display unit -> inches (for API calls). */
    function toIn(displayValue) { const v = parseFloat(displayValue); return Number.isFinite(v) ? (metric() ? v / MM : v) : NaN; }
    /** Inches -> display-unit number (for filling inputs). */
    function fromIn(inches, dec) { return metric() ? +(inches * MM).toFixed(dec != null ? dec : 3) : +Number(inches).toFixed(dec != null ? dec : 4); }
    function unitName() { return metric() ? 'mm' : 'in'; }

    /** POST/GET JSON; never throws: returns {ok, status, data}. */
    async function api(url, body, method) {
        try {
            const init = body === undefined && !method ? {} : { method: method || 'POST', headers: { 'Content-Type': 'application/json' }, body: body === undefined ? undefined : JSON.stringify(body) };
            const r = await fetch(url, init);
            let data = null;
            try { data = await r.json(); } catch (e) { data = null; }
            return { ok: r.ok && !(data && data.success === false), status: r.status, data: data || {} };
        } catch (e) {
            return { ok: false, status: 0, data: { error: String(e && e.message || e) } };
        }
    }

    const SEV_CLASS = { STOP: 'sev-stop', CAUTION: 'sev-caution', INFO: 'sev-info', critical: 'sev-stop', warning: 'sev-caution', info: 'sev-info' };
    function sevBadge(sev) {
        const s = String(sev || 'INFO');
        return `<span class="sev-badge ${SEV_CLASS[s] || 'sev-info'}">${E(s.toUpperCase())}</span>`;
    }
    function chips(list, cls) {
        return (list || []).map(t => `<span class="v3-chip ${cls || ''}">${E(t)}</span>`).join('');
    }
    function callout(kind, title, body) {
        return `<div class="v3-callout v3-${kind}"><div class="v3-callout-title">${E(title)}</div>${body ? `<div class="v3-callout-body">${body}</div>` : ''}</div>`;
    }
    /** Little tab switcher: buttons with data-sub, panels with data-subpanel inside root. */
    function subTabs(rootId, onShow) {
        const root = document.getElementById(rootId);
        if (!root) return;
        root.querySelectorAll('[data-sub]').forEach(btn => {
            btn.addEventListener('click', () => show(btn.dataset.sub));
        });
        function show(name) {
            root.querySelectorAll('[data-sub]').forEach(b => {
                const on = b.dataset.sub === name;
                b.classList.toggle('active', on);
                b.setAttribute('aria-selected', on ? 'true' : 'false');
            });
            root.querySelectorAll('[data-subpanel]').forEach(p => { p.hidden = p.dataset.subpanel !== name; });
            if (onShow) onShow(name);
        }
        root._show = show;
    }
    function safeStore(key, value) {
        try { if (value === undefined) { const v = localStorage.getItem(key); return v === null ? null : JSON.parse(v); } localStorage.setItem(key, JSON.stringify(value)); } catch (e) { /* storage unavailable */ }
        return null;
    }

    window.TW = { len, feed, sfm, ipt, num, pct, toIn, fromIn, unitName, api, sevBadge, chips, callout, subTabs, safeStore, finite, esc: E, metric, MM };
})();

/* Material family / alloy pickers filled from the page's /api/data lists (allFamilies, fullAlloys). */
(function () {
    'use strict';
    window.TW.fillFamilies = function (famId, alloyId, pref) {
        const fam = document.getElementById(famId), al = document.getElementById(alloyId);
        if (!fam || typeof allFamilies === 'undefined' || !allFamilies.length) return false;
        const keep = pref && pref.family || fam.value;
        fam.innerHTML = allFamilies.map(f => `<option value="${esc(f)}">${esc(f)}</option>`).join('');
        if (keep && allFamilies.includes(keep)) fam.value = keep;
        window.TW.fillAlloys(famId, alloyId, pref && pref.alloy);
        fam.onchange = () => window.TW.fillAlloys(famId, alloyId);
        return !!al;
    };
    window.TW.fillAlloys = function (famId, alloyId, pref) {
        const fam = document.getElementById(famId), al = document.getElementById(alloyId);
        if (!fam || !al || typeof fullAlloys === 'undefined') return;
        const rows = fullAlloys.filter(a => a.family === fam.value);
        al.innerHTML = rows.map(a => `<option value="${esc(alloyValue(a))}">${esc(alloyLabel(a))}</option>`).join('');
        if (pref && Array.from(al.options).some(o => o.value === pref)) al.value = pref;
    };
})();
