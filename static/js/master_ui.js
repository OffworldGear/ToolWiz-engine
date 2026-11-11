/* ToolWiz web: Digital Twin sub-tabs, Master Library builder and Library Audit.
 * Endpoints: /api/twin/material_sets, /api/twin/master_library/merge, /api/twin/build_sets(/<id>), /api/twin/audit. */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const E = T.esc;
    let inited = false;
    let sets = null;            // material sets document {sets:[...]}
    let uploaded = [];          // [{library_name, source:'upload', tools:[...]}]
    let previewData = null;
    let pollTimer = null;
    let jobId = null;
    const JOB_KEY = 'toolwiz_master_job';
    const COMMON_TYPES = ['flat end mill', 'ball end mill', 'bull nose end mill', 'slot mill', 'face mill', 'chamfer mill', 'dovetail mill', 'lollipop mill', 'thread mill', 'drill', 'reamer', 'tap right hand'];

    window.initMasterLibrary = function () {
        if (!inited) {
            inited = true;
            T.subTabs('digitalTwinView', name => {
                if (name === 'master') masterShown();
                if (name === 'audit') auditShown();
            });
            const root = $('digitalTwinView');
            if (root && root._show) root._show((location.hash.match(/^#twin-(master|audit)$/) || [0, 'library'])[1]);
            const saved = T.safeStore(JOB_KEY);
            if (saved && saved.id) { jobId = saved.id; }
        }
    };
    window.masterUnitChanged = function () {
        ['mlDiaMin', 'mlDiaMax', 'mlRunout', 'auRunout'].forEach(id => {
            const el = $(id), v = el ? parseFloat(el.value) : NaN;
            if (Number.isFinite(v)) el.value = +(T.metric() ? v * T.MM : v / T.MM).toFixed(T.metric() ? 4 : 5);
        });
    };

    /* ---------------------------------------------------------------- Master Library */
    async function masterShown() {
        $('mlRunout').value = T.fromIn(typeof runoutInches !== 'undefined' ? runoutInches : 0.0002, 5);
        const m = $('cutModelSelect'); if (m && m.value && !$('mlModel').value) $('mlModel').value = m.value;
        const nm = $('twinLibName'); if ($('mlWorkingName') && nm) $('mlWorkingName').textContent = nm.textContent;
        renderTypes();
        if (!sets) await loadSets();
        if (jobId && !pollTimer) { poll(); }   // resume a build started before a page reload
    }
    function renderTypes() {
        const present = (typeof activeTwinTools !== 'undefined' ? activeTwinTools : []).map(t => String(t.type || '').toLowerCase()).filter(Boolean);
        const types = Array.from(new Set(COMMON_TYPES.concat(present))).filter(t => t !== 'holder').sort();
        const keep = new Set(Array.from(document.querySelectorAll('#mlTypes input:checked')).map(i => i.value));
        $('mlTypes').innerHTML = types.map(t => `<label class="check-inline"><input type="checkbox" value="${E(t)}"${keep.has(t) ? ' checked' : ''}> ${E(t)}${present.includes(t) ? '' : ''}</label>`).join('');
    }
    async function loadSets() {
        const r = await T.api('/api/twin/material_sets');
        if (!r.ok) { $('mlSets').innerHTML = `<div class="v3-status err">Could not load material sets: ${E(r.data.error || r.status)}</div>`; return; }
        sets = r.data.material_sets;
        renderSets(r.data.source);
    }
    function renderSets(source) {
        const prevMats = new Set(Array.from(document.querySelectorAll('#mlSets .ml-mat:not(:checked)')).map(i => i.value));
        $('mlSets').innerHTML = (source === 'user' ? '<div class="v3-sub">Using your edited material sets.</div>' : '') + (sets.sets || []).map(s => `
            <div class="ml-set" data-set="${E(s.id)}">
                <div class="ml-set-head"><label class="check-inline"><input type="checkbox" class="ml-setchk" value="${E(s.id)}" checked onchange="masterSetToggled(this)"> ${E(s.name)}</label>
                    <span class="v3-sub">${(s.materials || []).length} materials, one library</span></div>
                <div class="ml-mats">${(s.materials || []).map(m => `<label class="check-inline" title="${E(m.family)} / ${E(m.alloy)}${m.note ? ' - ' + E(m.note) : ''}"><input type="checkbox" class="ml-mat" value="${E(m.id)}" data-set="${E(s.id)}"${prevMats.has(m.id) ? '' : ' checked'} onchange="masterMatToggled(this)"> ${E(m.label)}</label>`).join('')}</div>
            </div>`).join('');
    }
    window.masterSetToggled = function (box) {
        document.querySelectorAll(`.ml-mat[data-set="${CSS.escape(box.value)}"]`).forEach(m => { m.checked = box.checked; });
    };
    window.masterMatToggled = function (m) {
        const any = Array.from(document.querySelectorAll(`.ml-mat[data-set="${CSS.escape(m.dataset.set)}"]`)).some(x => x.checked);
        const box = document.querySelector(`.ml-setchk[value="${CSS.escape(m.dataset.set)}"]`); if (box) box.checked = any;
    };
    window.masterSourcesChanged = function () { previewData = null; $('mlPreview').innerHTML = ''; };

    window.masterFilesChosen = async function (files) {
        uploaded = [];
        const notes = [];
        for (const f of Array.from(files || [])) {
            try {
                const doc = JSON.parse(await f.text());
                const tools = Array.isArray(doc) ? doc : (doc.data || doc.tools || []);
                if (!Array.isArray(tools) || !tools.length) throw new Error('no tools found');
                uploaded.push({ library_name: String(doc.library_name || f.name.replace(/\.(json|tools)$/i, '')), source: 'upload', tools });
                notes.push(`${E(f.name)}: ${tools.length} tools`);
            } catch (e) { notes.push(`<span class="err-text">${E(f.name)}: not a tool library (${E(e.message)})</span>`); }
        }
        $('mlFileList').innerHTML = notes.join('<br>');
        masterSourcesChanged();
    };
    function sourceBody() {
        const body = { repair: $('mlRepair').checked, deduplicate: $('mlDedup').checked };
        if (uploaded.length) body.libraries = uploaded;
        if ($('mlUseWorking').checked) { body.use_working_library = true; }
        else if (!uploaded.length) return null;
        return body;
    }
    window.masterPreview = async function () {
        const body = sourceBody();
        const box = $('mlPreview');
        if (!body) { box.innerHTML = '<div class="v3-status err">Choose the working library or add a library file.</div>'; return; }
        box.innerHTML = '<div class="v3-status">Merging…</div>'; $('mlPreviewBtn').disabled = true;
        const r = await T.api('/api/twin/master_library/merge', body);
        $('mlPreviewBtn').disabled = false;
        if (!r.ok) { box.innerHTML = `<div class="v3-status err">Preview failed: ${E(r.data.error || r.status)}</div>`; return; }
        previewData = r.data; renderPreview(r.data);
    };
    function renderPreview(d) {
        const kv = (k, v) => `<div><span>${k}</span><strong>${v}</strong></div>`;
        const srcRows = (d.sources || []).map(s => `<tr><td>${E(s.library_name)}</td><td>${E(s.source)}</td><td class="v2-num">${s.tools}</td><td class="v2-num">${s.holders}</td></tr>`).join('');
        const sv = d.stickout_variants || [];
        const rep = (d.repairs || []).filter(x => (x.changes || []).length || (x.warnings || []).length);
        const unread = d.unreadable || [];
        $('mlPreview').innerHTML = `<div class="v3-kv">${kv('Tools in', d.tools_in)}${kv('Master tools', d.tools_out)}${kv('Duplicates merged', d.duplicates_merged)}${kv('Holders', d.holders)}${kv('Tools repaired', d.repaired_tools)}${kv('Stickout variants', sv.length)}</div>
            <div class="why-table-wrap"><table class="why-table"><thead><tr><th>Library</th><th>Source</th><th class="v2-num">Tools</th><th class="v2-num">Holders</th></tr></thead><tbody>${srcRows}</tbody></table></div>
            ${sv.length ? `<details class="v3-more"><summary>Kept separate: different stickout (${sv.length})</summary><ul>${sv.map(x => `<li>${E(typeof x === 'string' ? x : (x.description || JSON.stringify(x)))}</li>`).join('')}</ul></details>` : ''}
            ${(d.merged_details || []).length ? `<details class="v3-more"><summary>Merged duplicates (${d.merged_details.length})</summary><ul>${d.merged_details.slice(0, 60).map(x => `<li>${E(typeof x === 'string' ? x : (x.description || JSON.stringify(x)))}</li>`).join('')}</ul></details>` : ''}
            ${rep.length ? `<details class="v3-more"><summary>Repairs and warnings (${rep.length} tools)</summary><ul>${rep.slice(0, 80).map(x => `<li>${E(x.description || '')}: ${E([].concat(x.changes || [], x.warnings || []).map(c => typeof c === 'string' ? c : (c.message || JSON.stringify(c))).join('; '))}</li>`).join('')}</ul></details>` : ''}
            ${unread.length ? T.callout('warn', `${unread.length} unreadable item(s) skipped`, E(unread.map(u => typeof u === 'string' ? u : JSON.stringify(u)).join('; '))) : ''}`;
        const libs = Array.from(new Set((d.sources || []).map(s => s.library_name)));
        $('mlLibsGroup').style.display = libs.length > 1 ? '' : 'none';
        $('mlLibs').innerHTML = libs.map(n => `<label class="check-inline"><input type="checkbox" value="${E(n)}"> ${E(n)}</label>`).join('');
    }

    function buildBody() {
        const base = sourceBody();
        if (!base) throw new Error('Choose the working library or add a library file.');
        const allMats = Array.from(document.querySelectorAll('#mlSets .ml-mat'));
        const chosen = allMats.filter(m => m.checked);
        if (!chosen.length) throw new Error('Select at least one material.');
        const strategies = Array.from(document.querySelectorAll('#mlStrats input:checked')).map(i => i.value);
        if (!strategies.length) throw new Error('Select at least one strategy.');
        const body = Object.assign(base, {
            sets: Array.from(new Set(chosen.map(m => m.dataset.set))),
            strategies, aggressiveness: parseFloat($('mlAggr').value) || 50,
            runout: T.toIn($('mlRunout').value), use_tool_overrides: $('mlOverrides').checked, include_holders: true
        });
        if (chosen.length < allMats.length) body.materials = chosen.map(m => m.value);
        if (!(body.runout >= 0)) body.runout = 0.0002;
        const m = $('mlModel').value; if (m) body.model = m;
        const types = Array.from(document.querySelectorAll('#mlTypes input:checked')).map(i => i.value);
        const filt = {};
        if (types.length) filt.types = types;
        const dmin = parseFloat($('mlDiaMin').value), dmax = parseFloat($('mlDiaMax').value);
        if (dmin >= 0) filt.diameter_min = dmin; if (dmax > 0) filt.diameter_max = dmax;
        if (Object.keys(filt).some(k => k.startsWith('diameter'))) filt.diameter_unit = T.metric() ? 'mm' : 'in';
        const libs = Array.from(document.querySelectorAll('#mlLibs input:checked')).map(i => i.value);
        if (libs.length) filt.libraries = libs;
        if (Object.keys(filt).length) body.filter = filt;
        return body;
    }
    window.masterStart = async function () {
        const st = $('mlStatus');
        let body; try { body = buildBody(); } catch (e) { st.textContent = e.message; st.className = 'v3-status err'; return; }
        st.textContent = 'Starting…'; st.className = 'v3-status'; $('mlStart').disabled = true; $('mlResults').innerHTML = '';
        const r = await T.api('/api/twin/build_sets', body);
        if (!r.ok) { $('mlStart').disabled = false; st.textContent = 'Could not start: ' + (r.data.error || ('HTTP ' + r.status)); st.className = 'v3-status err'; return; }
        jobId = r.data.job_id; T.safeStore(JOB_KEY, { id: jobId });
        st.textContent = `Building ${r.data.sets.length} librar${r.data.sets.length === 1 ? 'y' : 'ies'} for ${r.data.tools} tools…`;
        poll();
    };
    async function poll() {
        clearTimeout(pollTimer); pollTimer = null;
        if (!jobId) return;
        const r = await T.api('/api/twin/build_sets/' + encodeURIComponent(jobId), undefined, 'GET');
        const st = $('mlStatus'), bar = $('mlProgressBar'), wrap = $('mlProgress');
        if (!r.ok) {
            $('mlStart').disabled = false; wrap.hidden = true; T.safeStore(JOB_KEY, {}); jobId = null;
            if (r.status !== 404) { st.textContent = 'Lost the build job: ' + (r.data.error || r.status); st.className = 'v3-status err'; }
            return;
        }
        const d = r.data;
        if (d.state === 'done') {
            $('mlStart').disabled = false; wrap.hidden = true; st.textContent = `Done in ${T.num(d.elapsed_s, 1)} s.`; st.className = 'v3-status';
            T.safeStore(JOB_KEY, {}); renderResults(d); jobId = null; return;
        }
        if (d.state === 'error') {
            $('mlStart').disabled = false; wrap.hidden = true; st.textContent = 'Build failed: ' + (d.error || 'unknown error'); st.className = 'v3-status err'; T.safeStore(JOB_KEY, {}); jobId = null; return;
        }
        const p = d.progress || {};
        wrap.hidden = false; $('mlStart').disabled = true;
        const pct = Math.max(2, Math.min(100, p.percent || 0));
        bar.style.width = pct + '%'; bar.setAttribute('aria-valuenow', Math.round(pct));
        st.textContent = `${d.phase || d.state}: ${p.tools_done || 0} of ${p.tools_total || '?'} tools${p.current_tool ? ' (' + p.current_tool + ')' : ''}, ${T.num(d.elapsed_s, 0)} s elapsed`; st.className = 'v3-status';
        pollTimer = setTimeout(poll, 1500);
    }
    function renderResults(d) {
        const res = d.result || {}; const m = res.merge || {};
        const head = `<div class="glass-panel"><h3 class="v3-h3">Build result</h3>
            <div class="v3-kv"><div><span>Tools in</span><strong>${m.tools_in != null ? m.tools_in : '—'}</strong></div><div><span>Master tools</span><strong>${m.tools_out != null ? m.tools_out : '—'}</strong></div><div><span>Duplicates merged</span><strong>${m.duplicates_merged != null ? m.duplicates_merged : '—'}</strong></div><div><span>Aggressiveness</span><strong>${d.request ? d.request.aggressiveness + ' %' : '—'}</strong></div><div><span>Model</span><strong>${E(d.request && d.request.model || '')}</strong></div><div><span>Generate / total</span><strong>${T.num((res.timing || {}).generate_s, 1)} s / ${T.num((res.timing || {}).total_s, 1)} s</strong></div></div></div>`;
        $('mlResults').innerHTML = head + (res.libraries || []).map(libCard).join('');
    }
    function codeList(obj) { const k = Object.keys(obj || {}); return k.length ? k.map(c => `<span class="v3-chip">${E(c)}: ${obj[c]}</span>`).join(' ') : '<span class="v3-sub">none</span>'; }
    function libCard(l) {
        const a = l.audit || {}, sum = a.summary || {};
        const dropped = a.dropped_presets || [], owner = a.owner_preset_stop_findings || [], skipped = l.skipped || [];
        const table = (rows, cols) => `<div class="ml-table-wrap"><table class="why-table"><thead><tr>${cols.map(c => `<th>${c[0]}</th>`).join('')}</tr></thead><tbody>${rows.slice(0, 200).map(r => `<tr>${cols.map(c => `<td>${E(r[c[1]] != null ? r[c[1]] : '')}</td>`).join('')}</tr>`).join('')}</tbody></table></div>${rows.length > 200 ? `<div class="v3-sub">Showing 200 of ${rows.length}.</div>` : ''}`;
        return `<div class="glass-panel ml-lib"><div class="ml-lib-head"><div><h3 class="v3-h3" style="border:0;margin:0;">${E(l.name)}</h3>
            <div class="v3-sub">${l.tool_count} tools, ${l.preset_count} presets (${l.toolwiz_preset_count} by ToolWiz${l.previous_toolwiz_presets_replaced ? ', ' + l.previous_toolwiz_presets_replaced + ' older ToolWiz presets replaced' : ''}), ${l.holder_count || 0} holders</div></div>
            <div>${l.download_url ? `<a class="ml-dl" href="${E(l.download_url)}" download>Download for Fusion</a>` : ''}</div></div>
            <div class="v3-chiprow"><span class="v3-chiplabel">Materials</span>${T.chips(l.materials || [])}</div>
            <h4 class="v3-h4">Audit</h4>
            <div class="v3-chiprow">${T.sevBadge('STOP')} <strong>${sum.toolwiz_STOP != null ? sum.toolwiz_STOP : 0}</strong> on ToolWiz presets after pruning (${sum.STOP || 0} STOP in all presets) &nbsp; ${T.sevBadge('CAUTION')} <strong>${sum.CAUTION || 0}</strong> &nbsp; ${T.sevBadge('INFO')} <strong>${sum.INFO || 0}</strong></div>
            <div class="v3-chiprow"><span class="v3-chiplabel">Cautions</span>${codeList(a.cautions_by_code)}</div>
            ${dropped.length ? `<details class="v3-more" open><summary>Presets dropped for a STOP finding (${dropped.length})</summary>${table(dropped, [['Tool', 'tool'], ['Preset', 'preset'], ['Code', 'code'], ['Why', 'message']])}</details>` : ''}
            ${owner.length ? `<details class="v3-more"><summary>STOP findings on your own presets, left untouched (${owner.length})</summary>${table(owner, [['Tool', 'tool'], ['Preset', 'preset'], ['Code', 'code'], ['Why', 'message']])}</details>` : ''}
            ${skipped.length ? `<details class="v3-more"><summary>Skipped tool / material / strategy combinations (${skipped.length})</summary>${table(skipped, [['Tool', 'tool'], ['Type', 'type'], ['Material', 'material'], ['Strategy', 'strategy'], ['Reason', 'reason']])}</details>` : '<div class="v3-sub">Nothing skipped.</div>'}
            ${l.backup && l.backup.filename ? `<div class="v3-sub">Saved in backup history as <code>${E(l.backup.filename)}</code>; restore it from the Library tab.</div>` : ''}</div>`;
    }

    /* ---------------------------------------------------------------- material set editor */
    window.masterToggleEditor = function () {
        const ed = $('mlEditor'), open = ed.hidden;
        ed.hidden = !open; $('mlEditBtn').setAttribute('aria-expanded', open ? 'true' : 'false');
        if (open) renderEditor();
    };
    function famOptions(sel) { return (typeof allFamilies !== 'undefined' ? allFamilies : []).map(f => `<option${f === sel ? ' selected' : ''}>${E(f)}</option>`).join(''); }
    function renderEditor(errors) {
        const ed = $('mlEditor');
        ed.innerHTML = `${errors && errors.length ? `<div class="v3-callout v3-bad"><div class="v3-callout-title">Not saved</div><div class="v3-callout-body">${errors.map(e => E(typeof e === 'string' ? e : JSON.stringify(e))).join('<br>')}</div></div>` : ''}
            <p class="v3-sub">Each material is a family from the materials database and an alloy name ToolWiz can match to one row of it. The label is used in preset names and in the Fusion material query.</p>
            ${(sets.sets || []).map((s, si) => `<div class="ml-set" data-si="${si}">
                <div class="ml-set-head"><input type="text" class="ed-setname" aria-label="Library name of set ${si + 1}" value="${E(s.name)}" style="flex:1; min-width:10rem;"><button type="button" class="tool-action-btn delete" onclick="masterEdRemoveSet(${si})" aria-label="Remove set ${E(s.name)}">Remove set</button></div>
                <div class="ml-edit-row v3-sub" aria-hidden="true"><span>Id</span><span>Label</span><span>Family</span><span>Alloy</span><span></span></div>
                ${(s.materials || []).map((m, mi) => `<div class="ml-edit-row" data-mi="${mi}">
                    <input type="text" class="ed-id" aria-label="Material id" value="${E(m.id)}">
                    <input type="text" class="ed-label" aria-label="Material label" value="${E(m.label)}">
                    <select class="ed-family" aria-label="Family">${famOptions(m.family)}</select>
                    <input type="text" class="ed-alloy" aria-label="Alloy" value="${E(m.alloy)}">
                    <button type="button" class="tool-action-btn delete" onclick="masterEdRemoveMat(${si}, ${mi})" aria-label="Remove material ${E(m.label)}">&times;</button></div>`).join('')}
                <button type="button" class="btn-ratio" onclick="masterEdAddMat(${si})">+ Material</button></div>`).join('')}
            <div class="v3-row"><button type="button" class="btn-ratio" onclick="masterEdAddSet()">+ Set</button>
                <span><button type="button" class="btn-ratio" onclick="masterEdReset()">Reset to defaults</button> <button type="button" class="btn-ratio v3-btn" onclick="masterEdSave()">Save sets</button></span></div>`;
    }
    function readEditor() {
        const out = JSON.parse(JSON.stringify(sets));
        document.querySelectorAll('#mlEditor .ml-set').forEach(div => {
            const s = out.sets[parseInt(div.dataset.si)]; if (!s) return;
            s.name = div.querySelector('.ed-setname').value.trim();
            s.materials = Array.from(div.querySelectorAll('.ml-edit-row[data-mi]')).map(row => ({
                id: row.querySelector('.ed-id').value.trim(), label: row.querySelector('.ed-label').value.trim(),
                family: row.querySelector('.ed-family').value, alloy: row.querySelector('.ed-alloy').value.trim(), note: ''
            }));
        });
        return out;
    }
    window.masterEdRemoveSet = function (si) { sets = readEditor(); sets.sets.splice(si, 1); renderEditor(); };
    window.masterEdRemoveMat = function (si, mi) { sets = readEditor(); sets.sets[si].materials.splice(mi, 1); renderEditor(); };
    window.masterEdAddMat = function (si) { sets = readEditor(); sets.sets[si].materials.push({ id: 'material_' + Date.now().toString(36), label: 'New material', family: (allFamilies || [])[0] || '', alloy: '', note: '' }); renderEditor(); };
    window.masterEdAddSet = function () { sets = readEditor(); sets.sets.push({ id: 'set_' + Date.now().toString(36), name: 'ToolWiz - New set', materials: [] }); renderEditor(); };
    window.masterEdSave = async function () {
        const doc = readEditor();
        const r = await T.api('/api/twin/material_sets', { material_sets: doc });
        if (!r.ok) { sets = doc; renderEditor(r.data.errors || [r.data.error || 'save failed']); return; }
        sets = r.data.material_sets; renderSets(r.data.source); $('mlEditor').hidden = true; $('mlEditBtn').setAttribute('aria-expanded', 'false');
    };
    window.masterEdReset = async function () {
        if (!confirm('Replace your material sets with the ToolWiz defaults?')) return;
        const r = await T.api('/api/twin/material_sets', { reset: true });
        if (r.ok) { sets = r.data.material_sets; renderSets(r.data.source); renderEditor(); }
    };

    /* ---------------------------------------------------------------- Library audit */
    let auditData = null, auditPage = 0;
    function auditShown() {
        $('auRunout').value = T.fromIn(typeof runoutInches !== 'undefined' ? runoutInches : 0.0002, 5);
        const dl = $('auMaterialList');
        if (dl && !dl.children.length && typeof allFamilies !== 'undefined') dl.innerHTML = allFamilies.map(f => `<option value="${E(f)}">`).join('');
    }
    window.runLibraryAudit = async function () {
        const st = $('auStatus'); $('auRun').disabled = true; st.textContent = 'Auditing… the physics model can take a minute for a large library.'; st.className = 'v3-status';
        const body = { aggressiveness: parseFloat($('auAggr').value) || 50, runout: T.toIn($('auRunout').value) };
        if (!(body.runout >= 0)) delete body.runout;
        if ($('auMaterial').value.trim()) body.material = $('auMaterial').value.trim();
        const m = $('cutModelSelect'); if (m && m.value) body.model = m.value;
        const r = await T.api('/api/twin/audit', body);
        $('auRun').disabled = false;
        if (!r.ok) { st.textContent = 'Audit failed: ' + (r.data.error || r.status); st.className = 'v3-status err'; return; }
        st.textContent = ''; auditData = r.data; auditPage = 0; renderAudit();
    };
    function auditRows() {
        const f = (auditData && auditData.findings) || [];
        const sev = new Set(Array.from(document.querySelectorAll('.audit-sev input:checked')).map(i => i.value));
        const code = ($('auCode') || {}).value || '', q = (($('auSearch') || {}).value || '').toLowerCase();
        return f.filter(x => (!document.querySelector('.audit-sev') || sev.has(x.severity)) && (!code || x.code === code) &&
            (!q || `${x.tool_description || ''} ${x.tool || ''} ${x.preset || ''} ${x.message || ''}`.toLowerCase().includes(q)));
    }
    function toolName(x) { const t = x.tool; return typeof t === 'object' && t ? (t.description || '') : (t || x.tool_description || ('#' + x.tool_index)); }
    function renderAudit() {
        const d = auditData, s = d.summary || {}, f = d.findings || [];
        const codes = Array.from(new Set(f.map(x => x.code))).sort();
        const keepSev = new Set(Array.from(document.querySelectorAll('.audit-sev input:not(:checked)')).map(i => i.value));
        const keepCode = ($('auCode') || {}).value || '', keepQ = ($('auSearch') || {}).value || '';
        $('auResults').innerHTML = `<div class="glass-panel"><div class="v3-kv"><div><span>Tools audited</span><strong>${s.tools}</strong></div><div><span>Presets audited</span><strong>${s.presets}</strong></div>
            <div><span>${T.sevBadge('STOP')}</span><strong>${s.STOP}</strong></div><div><span>${T.sevBadge('CAUTION')}</span><strong>${s.CAUTION}</strong></div><div><span>${T.sevBadge('INFO')}</span><strong>${s.INFO}</strong></div></div>
            <div class="audit-filters" role="group" aria-label="Filter findings">
                ${['STOP', 'CAUTION', 'INFO'].map(v => `<label class="audit-sev"><input type="checkbox" value="${v}"${keepSev.has(v) ? '' : ' checked'} onchange="auditRefilter()"> ${T.sevBadge(v)}</label>`).join('')}
                <select id="auCode" aria-label="Finding code" onchange="auditRefilter()"><option value="">All codes</option>${codes.map(c => `<option${c === keepCode ? ' selected' : ''}>${E(c)}</option>`).join('')}</select>
                <input type="text" id="auSearch" aria-label="Search findings" placeholder="Search tool, preset or text" value="${E(keepQ)}" oninput="auditRefilter()">
                <button type="button" class="btn-ratio" onclick="auditCsv()">Download CSV</button></div>
            <div id="auTable"></div></div>`;
        renderAuditTable();
    }
    function renderAuditTable() {
        const rows = auditRows(), per = 100, pages = Math.max(1, Math.ceil(rows.length / per));
        if (auditPage >= pages) auditPage = pages - 1;
        const cur = rows.slice(auditPage * per, auditPage * per + per);
        const val = x => (x.toolwiz_value != null || x.preset_value != null) ? `<div class="v3-sub">preset ${E(x.preset_value)} vs ToolWiz ${E(x.toolwiz_value)}</div>` : '';
        $('auTable').innerHTML = `<div class="v3-sub">${rows.length} finding${rows.length === 1 ? '' : 's'}${pages > 1 ? `, page ${auditPage + 1} of ${pages}` : ''}</div>
            <div class="why-table-wrap"><table class="why-table audit-table"><thead><tr><th>Severity</th><th>Tool</th><th>Preset</th><th>Code</th><th>Finding</th></tr></thead><tbody>${cur.map(x => `<tr><td>${T.sevBadge(x.severity)}</td><td>${E(toolName(x))}</td><td>${E(x.preset || '')}</td><td><code>${E(x.code)}</code></td><td class="msg">${E(x.message)}${val(x)}</td></tr>`).join('') || '<tr><td colspan="5" class="v3-empty">No findings match.</td></tr>'}</tbody></table></div>
            ${pages > 1 ? `<div class="v3-row"><button type="button" class="btn-ratio" ${auditPage === 0 ? 'disabled' : ''} onclick="auditPageGo(-1)">Previous</button><button type="button" class="btn-ratio" ${auditPage >= pages - 1 ? 'disabled' : ''} onclick="auditPageGo(1)">Next</button></div>` : ''}`;
    }
    window.auditRefilter = function () { auditPage = 0; renderAuditTable(); };
    window.auditPageGo = function (d) { auditPage += d; renderAuditTable(); };
    window.auditCsv = function () {
        const q = v => '"' + String(v == null ? '' : v).replace(/"/g, '""') + '"';
        const lines = [['severity', 'tool', 'preset', 'code', 'message'].join(',')].concat(auditRows().map(x => [x.severity, toolName(x), x.preset, x.code, x.message].map(q).join(',')));
        const a = document.createElement('a'); a.href = URL.createObjectURL(new Blob([lines.join('\n')], { type: 'text/csv' })); a.download = 'toolwiz_library_audit.csv'; a.click();
        setTimeout(() => URL.revokeObjectURL(a.href), 2000);
    };
})();
