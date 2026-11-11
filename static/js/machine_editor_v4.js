/* ToolWiz web: machine editor v4 (brand, model, controller, spindle taper, dual contact, feeds, coolant,
 * holder stiffness with override, simple torque mode) and the compact active-machine switcher at the top.
 * Loaded after the page script: it wraps the page's editor functions (renderMachineSelectors,
 * showMachineEditorProfile, loadSpindleForm, collectSpindleForm, saveMachineProfile) and reuses its state
 * (machineEd, machineListData). Every new field is optional; a profile without them behaves as before. */
(function () {
    'use strict';
    const $ = id => document.getElementById(id);
    const TAPERS = ['BT30', 'BBT30', 'CAT40', 'BT40', 'BBT40', 'HSK-A63', 'HSK-E40', 'HSK-E32', 'ISO30', 'R8', 'ER-spindle', 'other'];
    const DUAL_NATIVE = { BBT30: true, BBT40: true, 'HSK-A63': true, 'HSK-E40': true, 'HSK-E32': true };
    const esc = v => (window.TW && TW.esc) ? TW.esc(v) : String(v == null ? '' : v).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
    const num = id => { const el = $(id); const v = el ? parseFloat(el.value) : NaN; return Number.isFinite(v) ? v : null; };
    const estCache = {};
    let origStiff = null;     // holder_stiffness the profile carried when loaded (kept when unchanged)
    let lastEst = null;

    // ---- taper select -------------------------------------------------------------------------
    function fillTaperSelect() {
        const sel = $('machineEdTaper');
        if (!sel || sel.options.length) return;
        sel.add(new Option('(not set)', ''));
        TAPERS.forEach(t => sel.add(new Option(t, t)));
    }

    function profile() { return (typeof machineEd !== 'undefined' && machineEd) ? machineEd.profile : null; }

    function spindleDual(sp, p) {
        if (sp && typeof sp.dual_contact === 'boolean') return sp.dual_contact;
        if (p && typeof p.dual_contact === 'boolean') return p.dual_contact;
        return !!DUAL_NATIVE[p && p.spindle_taper];
    }

    // ---- stiffness --------------------------------------------------------------------------
    async function estimate(taper, dual) {
        const key = taper + '|' + (dual ? 1 : 0);
        if (estCache[key]) return estCache[key];
        try {
            const r = await fetch('/api/machines/stiffness_default?taper=' + encodeURIComponent(taper) + '&dual_contact=' + (dual ? 1 : 0));
            const d = await r.json();
            if (d.success) return (estCache[key] = d.stiffness);
        } catch (e) { /* offline: no estimate */ }
        return null;
    }

    async function refreshStiff() {
        const box = $('machineEdStiffNow');
        if (!box) return;
        const taper = $('machineEdTaper').value, dual = $('machineEdDual').checked;
        const k = num('machineEdStiffK'), kt = num('machineEdStiffKt');
        const est = taper ? await estimate(taper, dual) : null;
        lastEst = est;
        $('machineEdStiffSrc').textContent = est ? est.status : 'Choose a spindle taper to see the estimate and its sources.';
        let html;
        if (k) {
            html = '<span class="tag" style="background:rgba(34,197,94,0.2);color:#4ade80">override</span>In use: <strong>' + k + ' N/&micro;m</strong>' + (kt ? ', ' + kt + ' N&middot;m/&micro;rad' : '') +
                (est ? ' (taper estimate would be ' + est.k_n_um + ' N/&micro;m)' : '') + '.';
        } else if (est) {
            html = '<span class="tag">estimate</span>In use: <strong>' + est.k_n_um + ' N/&micro;m</strong>, ' + est.ktheta_nm_urad + ' N&middot;m/&micro;rad for ' + esc(taper) + (dual ? ' with dual contact' : ' without dual contact') + '. Not measured.';
        } else {
            html = 'No taper chosen and no override: the engine uses its built-in default stiffness.';
        }
        box.innerHTML = html;
    }

    function useEstimate() {
        $('machineEdStiffK').value = '';
        $('machineEdStiffKt').value = '';
        origStiff = null;
        refreshStiff();
    }

    function onTaperChange() { refreshStiff(); }

    // ---- show / collect -------------------------------------------------------------------
    function showV4(p) {
        fillTaperSelect();
        const set = (id, v) => { const el = $(id); if (el) el.value = (v === undefined || v === null) ? '' : v; };
        set('machineEdBrand', p.brand); set('machineEdModel', p.model); set('machineEdController', p.controller);
        set('machineEdTaper', TAPERS.includes(p.spindle_taper) ? p.spindle_taper : '');
        set('machineEdMaxFeed', p.max_cutting_feed_mm_min);
        const r = p.rapid_m_min || {};
        set('machineEdRapidX', r.x); set('machineEdRapidY', r.y); set('machineEdRapidZ', r.z);
        set('machineEdTsc', p.through_spindle_coolant_bar);
        const hs = p.holder_stiffness;
        const own = hs && hs.k_n_um && !hs.derived ? hs : null;
        origStiff = own ? JSON.parse(JSON.stringify(own)) : null;
        set('machineEdStiffK', own ? own.k_n_um : ''); set('machineEdStiffKt', own ? own.ktheta_nm_urad : '');
        refreshStiff();
    }

    // Writes the new machine-level fields into machineEd.profile; returns an error string or null.
    function collectV4() {
        const p = profile();
        if (!p) return null;
        const text = (field, id) => { const v = $(id).value.trim(); if (v) p[field] = v; else delete p[field]; };
        text('brand', 'machineEdBrand'); text('model', 'machineEdModel'); text('controller', 'machineEdController');
        const taper = $('machineEdTaper').value;
        if (taper) { p.spindle_taper = taper; p.dual_contact = $('machineEdDual').checked; } else { delete p.spindle_taper; delete p.dual_contact; }
        const numField = (field, id) => { const v = num(id); if (v === null) delete p[field]; else p[field] = v; };
        numField('max_cutting_feed_mm_min', 'machineEdMaxFeed');
        numField('through_spindle_coolant_bar', 'machineEdTsc');
        const rapid = {};
        [['x', 'machineEdRapidX'], ['y', 'machineEdRapidY'], ['z', 'machineEdRapidZ']].forEach(([ax, id]) => { const v = num(id); if (v !== null) rapid[ax] = v; });
        if (Object.keys(rapid).length) p.rapid_m_min = rapid; else delete p.rapid_m_min;
        const k = num('machineEdStiffK'), kt = num('machineEdStiffKt');
        if (k) {
            const same = origStiff && origStiff.k_n_um === k && (origStiff.ktheta_nm_urad || null) === kt;
            p.holder_stiffness = same ? origStiff : Object.assign({ k_n_um: k }, kt ? { ktheta_nm_urad: kt } : {}, { status: 'User override from the machine editor' });
        } else {
            delete p.holder_stiffness;   // back to the taper estimate (or the engine default when no taper)
        }
        return null;
    }

    // ---- simple mode ------------------------------------------------------------------------
    function generateSimple() {
        const peak = num('machineEdSimpleTorque'), base = num('machineEdSimpleBase'), kw = num('machineEdSimplePower'), maxRpm = num('machineEdMaxRpm');
        if (!peak || !base || !kw) { setMachineEdMsg('Simple mode needs peak torque, base rpm and continuous power.', 'err'); return; }
        if (!maxRpm) { setMachineEdMsg('Enter Max RPM first.', 'err'); return; }
        if (base > maxRpm) { setMachineEdMsg('Base rpm cannot exceed Max RPM.', 'err'); return; }
        const omega = base * 2 * Math.PI / 60;
        const peakKw = Math.max(kw, Math.round(peak * omega) / 1000);
        $('machineEdBaseRpm').value = base; $('machineEdPowerCont').value = kw;
        $('machineEdTorque').value = peak; $('machineEdPowerPeak').value = peakKw;
        const fills = machineEd.fill[machineEd.spindleKey] = machineEd.fill[machineEd.spindleKey] || {};
        const note = 'Generated from peak torque, base rpm and continuous power (simple mode); not a quoted curve.';
        const cont = powerCurvePoints(kw, base, maxRpm), mom = [[0, peak], [base, peak]];
        $('machineEdPts_continuous').value = pointsToText(cont);
        $('machineEdPts_momentary').value = pointsToText(mom);
        fills.continuous = { points: cont, power_kw: kw, note };
        fills.momentary = { points: mom, power_kw: peakKw, note };
        setMachineEdMsg('Curves generated from the simple fields; saved as derived.', 'ok');
        onMachineEdInput();
    }

    // ---- top switcher -----------------------------------------------------------------------
    function fillTop(list) {
        const msel = $('machineSwitchTop'), ssel = $('spindleSwitchTop');
        if (!msel || !ssel || !list) return;
        msel.innerHTML = '';
        (list.machines || []).forEach(m => msel.add(new Option(m.name + (m.modified ? ' (edited)' : ''), m.id)));
        if (list.active_machine) msel.value = list.active_machine;
        const m = (list.machines || []).find(x => x.id === msel.value);
        ssel.innerHTML = '';
        ((m && m.spindles) || []).forEach(sp => ssel.add(new Option(sp.label, sp.key)));
        const want = list.active_machine === msel.value ? list.active_spindle : (m && m.active_spindle);
        if (want) ssel.value = want;
        ssel.style.display = ssel.options.length > 1 ? '' : 'none';
        const sp = ((m && m.spindles) || []).find(s => s.key === ssel.value);
        const parts = [];
        if (m && (m.brand || m.model)) parts.push([m.brand, m.model].filter(Boolean).join(' '));
        if (m && m.spindle_taper) parts.push(m.spindle_taper + (m.dual_contact ? ' dual contact' : ' single contact'));
        if (sp && sp.max_rpm) parts.push(Number(sp.max_rpm).toLocaleString('en-US') + ' rpm');
        if (sp && sp.power_kw_continuous) parts.push(sp.power_kw_continuous + ' kW');
        $('machineSwitchMeta').textContent = parts.join(' · ');
    }
    function switchMachine() { selectMachine($('machineSwitchTop').value, null); }
    function switchSpindle() { selectMachine($('machineSwitchTop').value, $('spindleSwitchTop').value); }

    // ---- wrap the page's functions ------------------------------------------------------------
    function wrap(name, fn) {
        const orig = window[name];
        if (typeof orig !== 'function') return;
        window[name] = function () { return fn(orig, arguments); };
    }
    wrap('renderMachineSelectors', (orig, a) => { const r = orig.apply(null, a); fillTop(a[0]); return r; });
    wrap('showMachineEditorProfile', (orig, a) => { const r = orig.apply(null, a); showV4(machineEd.profile); return r; });
    wrap('loadSpindleForm', (orig, a) => {
        const r = orig.apply(null, a);
        const p = profile();
        if (p && $('machineEdDual')) { $('machineEdDual').checked = spindleDual(p.spindle_options[a[0]], p); refreshStiff(); }
        return r;
    });
    wrap('collectSpindleForm', (orig, a) => {
        const err = orig.apply(null, a);
        const p = profile();
        if (!err && p && $('machineEdTaper') && $('machineEdTaper').value) {
            const sp = p.spindle_options[machineEd.spindleKey];
            if (sp) sp.dual_contact = $('machineEdDual').checked;
        }
        return err;
    });
    wrap('saveMachineProfile', (orig, a) => {
        const err = collectV4();
        if (err) { setMachineEdMsg(err, 'err'); return undefined; }
        return orig.apply(null, a);
    });

    fillTaperSelect();
    if (typeof machineListData !== 'undefined' && machineListData) fillTop(machineListData);
    else if (typeof loadMachineList === 'function') { /* the page's init() loads the list, which fills the switcher */ }

    window.MachineEditorV4 = { onTaperChange, refreshStiff, useEstimate, generateSimple, switchMachine, switchSpindle, fillTop, TAPERS };
})();
