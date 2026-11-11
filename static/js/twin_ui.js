/* ToolWiz web: Digital Twin library manager (moved out of the inline script, tools addressed by guid). */
        // Tools are addressed by guid (stable across deletes); a tool that has none falls back to its list index.
        let currentInspectorToolIndex = null;   // holds the inspector tool's key (guid or '#index')
        function twinKey(t) { return t.guid ? String(t.guid) : '#' + t.index; }
        function twinFind(key) { return activeTwinTools.find(t => twinKey(t) === key); }
        function twinAddr(key) {
            const t = twinFind(key);
            if (t && t.guid) return { tool_guid: t.guid };
            return { tool_index: t ? t.index : parseInt(String(key).replace('#', ''), 10) };
        }

        async function loadDigitalTwin() {
            try {
                const res = await fetch('/api/twin/load');
                const data = await res.json();
                
                const libNameEl = document.getElementById('twinLibName');
                if (libNameEl) libNameEl.innerText = data.library_name || "Master Shop Tool Crib";
                
                const toolCountEl = document.getElementById('twinToolCountBadge');
                if (toolCountEl) toolCountEl.innerText = `${data.tool_count || 0} Cutters`;

                const presetsCountEl = document.getElementById('twinPresetsCountBadge');
                if (presetsCountEl) presetsCountEl.innerText = `${data.total_presets_count || 0} Presets`;

                const dupsBadgeEl = document.getElementById('twinDuplicatesBadge');
                if (dupsBadgeEl) {
                    if (data.duplicates_cleaned && data.duplicates_cleaned > 0) {
                        dupsBadgeEl.style.display = 'inline-block';
                        dupsBadgeEl.innerText = `${data.duplicates_cleaned} Duplicates Cleaned`;
                    } else {
                        dupsBadgeEl.style.display = 'none';
                    }
                }

                const lastSyncEl = document.getElementById('twinLastSync');
                if (lastSyncEl) {
                    lastSyncEl.innerText = data.last_modified ? `Synced: ${data.last_modified.replace('T', ' ').substring(0, 19)}` : '';
                }
                
                activeTwinTools = data.tools || [];
                renderTwinTools();
                renderTwinBackups(data.backups || []);
                updateTwinMaterialSuggestion(false);
            } catch (e) {
                console.error("Failed to load Digital Twin data:", e);
            }
        }

        function renderTwinBackups(backups) {
            const select = document.getElementById('twinBackupSelect');
            if (!select) return;
            select.innerHTML = `<option value="">-- Backup History (${backups.length}) --</option>`;
            backups.forEach(b => {
                let opt = document.createElement('option');
                opt.value = b.filename;
                opt.innerText = `${b.timestamp} | ${b.library_name} (${b.tool_count} tools, ${b.size_kb}KB)`;
                select.appendChild(opt);
            });
        }

        async function restoreSelectedBackup() {
            const filename = document.getElementById('twinBackupSelect').value;
            if (!filename) {
                alert('Please select a backup from the history dropdown to restore.');
                return;
            }
            if (!confirm(`Are you sure you want to restore the library from snapshot:\n${filename}?`)) {
                return;
            }
            try {
                const res = await fetch('/api/twin/backups', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ filename })
                });
                const data = await res.json();
                if (data.success) {
                    alert(`Successfully restored snapshot: ${filename}`);
                    loadDigitalTwin();
                } else {
                    alert(`Restore failed: ${data.error}`);
                }
            } catch (e) {
                alert(`Restore error: ${e}`);
            }
        }

        function setToolTypeFilter(filterType, btn) {
            activeTwinTypeFilter = filterType;
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            renderTwinTools();
        }

        function filterTwinTools() {
            renderTwinTools();
        }

        function selectAllTwinTools(select) {
            document.querySelectorAll('.twin-tool-chk').forEach(chk => {
                chk.checked = select;
            });
            const masterChk = document.getElementById('selectAllTwinCheckbox');
            if (masterChk) masterChk.checked = select;
            updateTwinSelectionCount();
        }

        function toggleSelectAllTwin(checked) {
            selectAllTwinTools(checked);
        }

        function updateTwinSelectionCount() {
            const selected = document.querySelectorAll('.twin-tool-chk:checked');
            const badge = document.getElementById('selectedCountBadge');
            if (badge) badge.innerText = `${selected.length} of ${activeTwinTools.length} selected`;
            
            document.querySelectorAll('.twin-tool-chk').forEach(chk => {
                const row = document.getElementById(`twin_tool_row_${chk.dataset.idx}`);
                if (row) {
                    row.classList.toggle('selected', chk.checked);
                }
            });
        }

        function renderTwinTools() {
            const tbody = document.getElementById('twinToolsTbody');
            if (!tbody) return;
            const search = (document.getElementById('twinSearchInput')?.value || '').toLowerCase().trim();
            tbody.innerHTML = '';
            
            const masterChk = document.getElementById('selectAllTwinCheckbox');
            if (masterChk) masterChk.checked = false;
            
            if (!activeTwinTools || activeTwinTools.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; color: var(--text-secondary); padding: 2.5rem;">No tools found in Master Crib. Drop library files above or click "Export Digital Twin" in Fusion 360 to populate.</td></tr>';
                return;
            }

            let renderedCount = 0;

            const sortKey = (document.getElementById('twinSortSelect') || {}).value || 'number';
            const sorted = activeTwinTools.slice().sort((a, b) => sortKey === 'diameter' ? (a.diameter_in - b.diameter_in)
                : sortKey === 'name' ? String(a.description).localeCompare(String(b.description))
                : sortKey === 'presets' ? (b.preset_count - a.preset_count)
                : ((a.number || 1e9) - (b.number || 1e9)) || (a.index - b.index));
            sorted.forEach(t => {
                const tType = (t.type || '').toLowerCase();
                const desc = (t.description || '').toLowerCase();
                
                // Type Filter
                if (activeTwinTypeFilter === 'flat' && !desc.includes('flat') && !tType.includes('flat')) return;
                if (activeTwinTypeFilter === 'ball' && !desc.includes('ball') && !tType.includes('ball')) return;
                if (activeTwinTypeFilter === 'bullnose' && !desc.includes('bull') && !desc.includes('radius') && !tType.includes('bull')) return;
                if (activeTwinTypeFilter === 'slot' && !/slot|keyseat|woodruff|dovetail/.test(desc + ' ' + tType)) return;
                if (activeTwinTypeFilter === 'nopresets' && (t.presets || []).length > 0) return;
                if (activeTwinTypeFilter === 'drill' && !desc.includes('drill') && !tType.includes('drill')) return;

                // Search Filter
                if (search && !desc.includes(search) && !t.number.toString().includes(search) && !t.diameter_in.toString().includes(search)) {
                    return;
                }

                renderedCount++;
                const tr = document.createElement('tr');
                const key = twinKey(t);
                tr.id = `twin_tool_row_${t.index}`;
                
                // Material and Presets list
                let presetTags = '';
                const presets = t.presets || [];
                if (presets.length === 0) {
                    presetTags = '<span style="opacity: 0.35; font-size: var(--fs-xs);">No presets</span>';
                } else {
                    const displayed = presets.slice(0, 3);
                    presetTags = displayed.map(p => {
                        const pName = p.name || "Preset";
                        const isTW = p.is_toolwiz;
                        const shortName = pName.length > 22 ? pName.substring(0, 20) + '…' : pName;
                        return `<span class="preset-tag ${isTW ? 'toolwiz' : ''}" title="${esc(pName)}" onclick="openToolInspector(${jsArg(key)})">
                            ${esc(shortName)}
                            <span style="color: #ff5555; cursor: pointer; margin-left: 5px; font-weight: bold; font-size: var(--fs-sm);" onclick="event.stopPropagation(); deletePreset(${jsArg(key)}, ${jsArg(p.guid)})">&times;</span>
                        </span>`;
                    }).join(' ');

                    if (presets.length > 3) {
                        presetTags += ` <span class="preset-tag" style="background: rgba(255,255,255,0.06); cursor:pointer;" onclick="openToolInspector(${jsArg(key)})">+${presets.length - 3} more</span>`;
                    }
                }

                const customAggr = t.custom_aggressiveness;
                const hasCustom = customAggr !== null && customAggr !== undefined;
                const aggrSelectHtml = `
                    <select id="tool_aggr_select_${t.index}" class="tool-aggr-select ${hasCustom ? 'custom' : ''}" onchange="onToolAggrChange(${jsArg(key)}, this.value)" title="Cutter specific aggressiveness override">
                        <option value="" ${!hasCustom ? 'selected' : ''}>Material Def</option>
                        <option value="20" ${customAggr == 20 ? 'selected' : ''}>20% (Safe)</option>
                        <option value="30" ${customAggr == 30 ? 'selected' : ''}>30% (Cons.)</option>
                        <option value="40" ${customAggr == 40 ? 'selected' : ''}>40% (Mild)</option>
                        <option value="50" ${customAggr == 50 ? 'selected' : ''}>50% (Std)</option>
                        <option value="65" ${customAggr == 65 ? 'selected' : ''}>65% (Brisk)</option>
                        <option value="75" ${customAggr == 75 ? 'selected' : ''}>75% (Aggr)</option>
                        <option value="85" ${customAggr == 85 ? 'selected' : ''}>85% (Extreme)</option>
                    </select>
                `;

                tr.innerHTML = `
                    <td><input type="checkbox" class="twin-tool-chk" value="${esc(key)}" data-idx="${t.index}" aria-label="Select ${esc(t.description)}" onchange="updateTwinSelectionCount()"></td>
                    <td style="font-weight: 700; color: var(--accent);">${t.number > 0 ? 'T' + esc(t.number) : '<span style="opacity:0.3;">-</span>'}</td>
                    <td>
                        <div style="font-weight: 600; cursor: pointer; color: #f8fafc;" onclick="openToolInspector(${jsArg(key)})">${esc(t.description)}</div>
                        <div style="font-size: var(--fs-xs); color: var(--text-secondary);">${esc(t.type || 'End Mill')} · Stickout: ${t.stickout_in ? TW.len(t.stickout_in) : '-'}</div>
                    </td>
                    ${t.geometry_error ? `
                    <td colspan="2" class="twin-geo-error" title="${esc('Presets cannot be generated for this cutter: its geometry could not be read (' + t.geometry_error + '). Fix the tool definition in Fusion and reload the library.')}">
                        <span>&#9888; ${esc(t.geometry_error)}</span>
                    </td>` : `
                    <td>
                        <div>${esc(TW.len(t.diameter_in))}</div>
                        <div style="font-size: var(--fs-xs); color: var(--text-secondary);">${esc(TW.metric() ? t.diameter_in + ' in' : t.diameter_mm + ' mm')}</div>
                    </td>
                    <td style="font-weight: 600; text-align: center;">${esc(t.flutes)}</td>`}
                    <td>${aggrSelectHtml}</td>
                    <td><div class="preset-tag-list">${presetTags}</div></td>
                    <td>
                        <div style="display:flex; gap:0.35rem; justify-content:center;">
                            <button class="tool-action-btn" onclick="openToolInspector(${jsArg(key)})" title="Inspect Cutter & Presets">🔍</button>
                            <button class="tool-action-btn delete" onclick="deleteTool(${jsArg(key)})" title="Delete Cutter">🗑️</button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });

            if (renderedCount === 0 && activeTwinTools.length > 0) {
                tbody.innerHTML = '<tr><td colspan="8" style="text-align: center; color: var(--text-secondary); padding: 2rem;">No tools match the active search or filter.</td></tr>';
            }

            updateTwinSelectionCount();
        }

        async function onToolAggrChange(toolKey, val) {
            const aggr = val !== "" ? parseFloat(val) : null;
            try {
                const res = await fetch('/api/twin/update_tool', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(Object.assign(twinAddr(toolKey), { custom_aggressiveness: aggr }))
                });
                const data = await res.json();
                if (data.success) {
                    const tool = twinFind(toolKey);
                    if (tool) tool.custom_aggressiveness = aggr;
                    const selectEl = document.getElementById(`tool_aggr_select_${(twinFind(toolKey) || {}).index}`);
                    if (selectEl) {
                        selectEl.classList.toggle('custom', aggr !== null);
                    }
                } else {
                    alert('Error updating tool aggressiveness: ' + data.error);
                }
            } catch (e) {
                alert('Network error updating tool: ' + e);
            }
        }

        function openToolInspector(toolKey) {
            const tool = twinFind(toolKey);
            if (!tool) return;
            const toolIndex = toolKey;
            currentInspectorToolIndex = toolKey;

            const modal = document.getElementById('toolInspectorModal');
            if (!modal) return;

            document.getElementById('inspectorToolTitle').innerText = `${tool.number > 0 ? 'T' + tool.number + ' · ' : ''}${tool.description || 'Tool'}`;
            document.getElementById('inspectorToolSubtitle').innerText = `${tool.type || 'End Mill'} · Signature: ${tool.signature || 'N/A'}`;

            const geoGrid = document.getElementById('inspectorGeoGrid');
            if (geoGrid) {
                geoGrid.innerHTML = `
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Diameter</span>
                        <span class="inspector-geo-val">${esc(tool.diameter_in)}" <small style="font-weight:normal; color:#94a3b8;">(${esc(tool.diameter_mm)}mm)</small></span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Flutes</span>
                        <span class="inspector-geo-val">${esc(tool.flutes)}</span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Flute Length</span>
                        <span class="inspector-geo-val">${esc(tool.flute_length_in || '-')} "</span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Stickout</span>
                        <span class="inspector-geo-val">${esc(tool.stickout_in || '-')} "</span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Corner Radius</span>
                        <span class="inspector-geo-val">${tool.corner_radius_in ? esc(tool.corner_radius_in) + '"' : '0.00"'}</span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Shank Dia</span>
                        <span class="inspector-geo-val">${esc(tool.shank_diameter_in || tool.diameter_in)}"</span>
                    </div>
                    <div class="inspector-geo-item">
                        <span class="inspector-geo-label">Vendor Product ID</span>
                        <span class="inspector-geo-val" style="font-family:monospace; font-size:var(--fs-md);">${esc(tool.product_id || 'Generic')}</span>
                    </div>
                `;
            }

            const aggrSelect = document.getElementById('inspectorAggrSelect');
            const aggrDisplay = document.getElementById('inspectorAggrDisplay');
            const curVal = tool.custom_aggressiveness !== undefined && tool.custom_aggressiveness !== null ? String(tool.custom_aggressiveness) : "";
            if (aggrSelect) aggrSelect.value = curVal;
            if (aggrDisplay) {
                if (curVal) {
                    aggrDisplay.innerText = `${curVal}% Override`;
                    aggrDisplay.style.color = '#34d399';
                } else {
                    aggrDisplay.innerText = 'Default (Follows Material)';
                    aggrDisplay.style.color = 'var(--accent)';
                }
            }

            const tbody = document.getElementById('inspectorPresetsTbody');
            const presets = tool.presets || [];
            const countEl = document.getElementById('inspectorPresetCount');
            if (countEl) countEl.innerText = presets.length;

            if (tbody) {
                if (presets.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align: center; color: #94a3b8; padding: 1.5rem;">No cutting presets in this cutter yet. Use the Batch Generator on the right to inject physics-optimized presets.</td></tr>';
                } else {
                    tbody.innerHTML = '';
                    presets.forEach(p => {
                        const tr = document.createElement('tr');
                        const isTW = p.is_toolwiz;
                        const isCutterMetric = Boolean(tool.is_metric) || (typeof tool.unit === 'string' && tool.unit.toLowerCase().startsWith('mill'));
                        // Preset v_c is m/min on metric cutters; the inspector always shows SFM.
                        const rawSfm = parseFloat(p.sfm || p.v_c);
                        const sfm = isNaN(rawSfm) || rawSfm <= 0 ? '-' : Math.round(isCutterMetric ? rawSfm / 0.3048 : rawSfm);
                        const rpmNum = parseFloat(p.rpm || p.n);
                        const rpm = isNaN(rpmNum) || rpmNum <= 0 ? '-' : Math.round(rpmNum);
                        const rawFeed = (p.feed != null) ? p.feed : p.v_f;
                        const rawFz = (p.ipt != null) ? p.ipt : p.f_z;
                        const rawDoc = p.stepdown;
                        const rawWoc = p.stepover;

                        let vfeed_disp = '-';
                        let fpt_disp = '-';
                        let doc_disp = '-';
                        let woc_disp = '-';

                        if (rawFeed != null && rawFeed !== '') {
                            const fNum = parseFloat(rawFeed);
                            if (!isNaN(fNum)) {
                                vfeed_disp = isCutterMetric 
                                    ? `${fNum.toFixed(1)} mm/min (${(fNum / 25.4).toFixed(1)} IPM)`
                                    : `${fNum.toFixed(1)} IPM (${(fNum * 25.4).toFixed(1)} mm/min)`;
                            }
                        }

                        if (rawFz != null && rawFz !== '') {
                            const fzNum = parseFloat(rawFz);
                            if (!isNaN(fzNum)) {
                                fpt_disp = isCutterMetric 
                                    ? `${fzNum.toFixed(4)} mm/t (${(fzNum / 25.4).toFixed(5)}" IPT)`
                                    : `${fzNum.toFixed(5)}" IPT (${(fzNum * 25.4).toFixed(4)} mm/t)`;
                            }
                        }

                        if (rawDoc != null && rawDoc !== '') {
                            const docNum = parseFloat(rawDoc);
                            if (!isNaN(docNum)) {
                                doc_disp = isCutterMetric ? `${docNum.toFixed(2)}mm` : `${docNum.toFixed(3)}"`;
                            }
                        }

                        if (rawWoc != null && rawWoc !== '') {
                            const wocNum = parseFloat(rawWoc);
                            if (!isNaN(wocNum)) {
                                woc_disp = isCutterMetric ? `${wocNum.toFixed(2)}mm` : `${wocNum.toFixed(3)}"`;
                            }
                        }

                        tr.innerHTML = `
                            <td>
                                <div style="font-weight: 600; color: ${isTW ? '#38bdf8' : '#f8fafc'};">
                                    ${isTW ? '<span style="color:#38bdf8; font-size:var(--fs-xs); border:1px solid rgba(56,189,248,0.3); padding:1px 4px; border-radius:3px; margin-right:4px;">ToolWiz</span>' : ''}
                                    ${esc(p.name || 'Preset')}
                                </div>
                                <div style="font-size: var(--fs-xs); color: #94a3b8;">${esc(p.guid ? p.guid.substring(0, 8) + '...' : '')}</div>
                            </td>
                            <td style="color: #cbd5e1;">${esc(p.operation_type || 'Milling')}</td>
                            <td>
                                <div><strong>${esc(rpm)}</strong> RPM</div>
                                <div style="font-size:var(--fs-xs); color:#94a3b8;">${esc(sfm)} SFM</div>
                            </td>
                            <td>
                                <div><strong>${esc(vfeed_disp)}</strong></div>
                                <div style="font-size:var(--fs-xs); color:#94a3b8;">${esc(fpt_disp)}</div>
                            </td>
                            <td>
                                <div>DOC: ${esc(doc_disp)}</div>
                                <div style="font-size:var(--fs-xs); color:#94a3b8;">WOC: ${esc(woc_disp)}</div>
                            </td>
                            <td style="text-align: center;">
                                <button class="tool-action-btn delete" onclick="deletePresetFromInspector(${toolIndex}, ${jsArg(p.guid)})" title="Delete Preset">✕</button>
                            </td>
                        `;
                        tbody.appendChild(tr);
                    });
                }
            }

            modal.style.display = 'flex';
        }

        function closeToolInspector() {
            const modal = document.getElementById('toolInspectorModal');
            if (modal) modal.style.display = 'none';
            currentInspectorToolIndex = null;
        }

        function onInspectorAggrChange(val) {
            const aggrDisplay = document.getElementById('inspectorAggrDisplay');
            if (!aggrDisplay) return;
            if (val) {
                aggrDisplay.innerText = `${val}% Override`;
                aggrDisplay.style.color = '#34d399';
            } else {
                aggrDisplay.innerText = 'Default (Follows Material)';
                aggrDisplay.style.color = 'var(--accent)';
            }
        }

        async function saveInspectorAggr() {
            if (currentInspectorToolIndex === null) return;
            const val = document.getElementById('inspectorAggrSelect').value;
            await onToolAggrChange(currentInspectorToolIndex, val);
            renderTwinTools();
            TW.toast('Tool aggressiveness override saved.');
        }

        async function deletePresetFromInspector(toolKey, presetGuid) {
            await deletePreset(toolKey, presetGuid);
            openToolInspector(toolKey);
        }

        function deleteToolFromInspector() {
            if (currentInspectorToolIndex === null) return;
            const idx = currentInspectorToolIndex;
            closeToolInspector();
            deleteTool(idx);
        }

        async function deletePreset(toolKey, presetGuid) {
            if (!confirm('Are you sure you want to delete this cutting preset?')) return;
            
            try {
                const res = await fetch('/api/twin/delete_preset', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(Object.assign(twinAddr(toolKey), { preset_guid: presetGuid }))
                });
                const data = await res.json();
                if (data.success) {
                    loadDigitalTwin();
                } else {
                    alert('Error deleting preset: ' + data.error);
                }
            } catch (err) {
                alert('Network error deleting preset: ' + err);
            }
        }

        async function deleteTool(toolKey) {
            const tool = twinFind(toolKey);
            const desc = tool ? `T${tool.number} (${tool.description})` : `Tool ${toolKey}`;
            
            if (!confirm(`Are you sure you want to permanently delete cutter:\n${desc}?\n\nA safety backup snapshot will be automatically created before deletion.`)) {
                return;
            }

            try {
                const res = await fetch('/api/twin/delete_tool', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(twinAddr(toolKey))
                });
                const data = await res.json();
                if (data.success) {
                    loadDigitalTwin();
                } else {
                    alert('Failed to delete tool: ' + data.error);
                }
            } catch (e) {
                alert('Network error deleting tool: ' + e);
            }
        }

        async function runDeduplicateLibrary() {
            if (!confirm("Deduplicate Master Shop Tool Crib?\n\nThis will group cutters with identical physical geometry, combine all unique cutting presets, select the cleanest metadata, and eliminate duplicate entries.\n\nA safety backup snapshot will be created before applying changes.")) {
                return;
            }
            
            try {
                const res = await fetch('/api/twin/deduplicate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                });
                const data = await res.json();
                if (data.success) {
                    const banner = document.getElementById('twinDedupBanner');
                    const details = document.getElementById('twinDedupDetails');
                    if (banner && details) {
                        banner.style.display = 'flex';
                        details.innerHTML = `Merged <strong>${esc(data.report.duplicates_removed)}</strong> duplicate cutters. Consolidated library now contains <strong>${esc(data.tool_count)}</strong> unique cutters.<br><small>Safety snapshot saved: <code>${esc(data.backup && data.backup.filename)}</code></small>`;
                    }
                    loadDigitalTwin();
                } else {
                    alert('Deduplication failed: ' + (data.error || 'Unknown error'));
                }
            } catch (e) {
                alert('Network error during deduplication: ' + e);
            }
        }

        // ---- Material Batch Generator: remember the last selections (per-browser, best effort) ----
        const TWIN_PREFS_KEY = 'toolwiz_twin_prefs';
        const TWIN_STRAT_IDS = ['stratAdaptive', 'stratRoughing', 'stratSemiFinishing', 'stratFinishing', 'stratFloorFinishing', 'stratSlotting', 'stratHighFeed'];
        function saveTwinPrefs() {
            try {
                const prefs = {
                    family: document.getElementById('twinFamily')?.value || '',
                    alloy: document.getElementById('twinAlloy')?.value || '',
                    coating: document.getElementById('twinCoating')?.value || '',
                    aggressiveness: document.getElementById('twinAggressiveness')?.value || '',
                    strategies: {}
                };
                TWIN_STRAT_IDS.forEach(id => { const el = document.getElementById(id); if (el) prefs.strategies[id] = !!el.checked; });
                localStorage.setItem(TWIN_PREFS_KEY, JSON.stringify(prefs));
            } catch (e) { /* storage unavailable: skip */ }
        }
        function restoreTwinPrefs() {
            let prefs = null;
            try { prefs = JSON.parse(localStorage.getItem(TWIN_PREFS_KEY) || 'null'); } catch (e) { prefs = null; }
            if (prefs && typeof prefs === 'object') {
                const famSel = document.getElementById('twinFamily');
                if (prefs.family && famSel && Array.from(famSel.options).some(o => o.value === prefs.family)) {
                    famSel.value = prefs.family;
                    updateTwinAlloys();
                    const alloySel = document.getElementById('twinAlloy');
                    if (prefs.alloy && alloySel && Array.from(alloySel.options).some(o => o.value === prefs.alloy)) alloySel.value = prefs.alloy;
                }
                const coat = document.getElementById('twinCoating');
                if (prefs.coating && coat && Array.from(coat.options).some(o => o.value === prefs.coating)) coat.value = prefs.coating;
                const slider = document.getElementById('twinAggressiveness');
                const n = parseFloat(prefs.aggressiveness);
                if (slider && Number.isFinite(n)) {
                    slider.value = n;
                    const lbl = document.getElementById('twinAggrVal');
                    if (lbl) lbl.innerText = slider.value + '%';
                }
                if (prefs.strategies) TWIN_STRAT_IDS.forEach(id => {
                    const el = document.getElementById(id);
                    if (el && typeof prefs.strategies[id] === 'boolean') el.checked = prefs.strategies[id];
                });
            }
            updateTwinMaterialSuggestion(false);   // refresh banner only; never override the restored slider
            const panel = document.getElementById('twinBatchPanel');
            if (panel) {
                panel.addEventListener('change', saveTwinPrefs);
                panel.addEventListener('input', saveTwinPrefs);
            }
        }

        function updateTwinMaterialSuggestion(autoSetSlider = true) {
            const family = (document.getElementById('twinFamily')?.value || '').toLowerCase();
            const alloy = (document.getElementById('twinAlloy')?.value || '').toLowerCase();
            const banner = document.getElementById('twinMaterialSuggestionBanner');
            const slider = document.getElementById('twinAggressiveness');
            const aggrVal = document.getElementById('twinAggrVal');
            if (!banner) return;

            let suggested = 50;
            let rationale = "Standard 1.00x baseline; balances tool life, spindle load, and positive shearing.";

            if (family.includes('titanium') || alloy.includes('ti-') || alloy.includes('titanium') || alloy.includes('nitronic') || alloy.includes('inconel') || alloy.includes('monel') || alloy.includes('hastelloy') || alloy.includes('stainless')) {
                suggested = 50;
                rationale = "Recommended 50% baseline: maintains positive chip load under edge hone to prevent rubbing & work hardening.";
            } else if (family.includes('aluminum') || family.includes('plastic') || alloy.includes('6061') || alloy.includes('7075') || alloy.includes('brass') || alloy.includes('delrin')) {
                suggested = 80;
                rationale = "Free-machining non-ferrous; high SFM & aggressive chip evacuation optimized for high-speed spindles (Speedio 16K).";
            } else if (family.includes('hardened') || alloy.includes('d2') || alloy.includes('m2') || alloy.includes('magnacut') || alloy.includes('cpm')) {
                suggested = 50;
                rationale = "Controlled chipping baseline for abrasive high-hardness tool steels.";
            } else if (family.includes('cast iron')) {
                suggested = 60;
                rationale = "Standard rigid cut characteristics; clean shearing through abrasive casting scale.";
            } else if (family.includes('steel') || alloy.includes('4140') || alloy.includes('1018') || alloy.includes('1045') || alloy.includes('4340')) {
                suggested = 60;
                rationale = "High-efficiency baseline balancing MRR and tool life on alloy steels.";
            }

            banner.innerHTML = `💡 <strong>Suggested Baseline:</strong> ${suggested}% (${rationale})`;

            if (autoSetSlider && slider && aggrVal) {
                slider.value = suggested;
                aggrVal.innerText = `${suggested}%`;
            }
        }

        async function runBatchPresetGeneration() {
            const checkedKeys = Array.from(document.querySelectorAll('.twin-tool-chk:checked')).map(c => c.value);
            const checked = checkedKeys;
            if (checked.length === 0) {
                alert('Please select at least one cutter from the table to inject presets into.');
                return;
            }

            const strategies = [];
            if (document.getElementById('stratAdaptive')?.checked) strategies.push('Adaptive Roughing');
            if (document.getElementById('stratRoughing')?.checked) strategies.push('Standard Roughing');
            if (document.getElementById('stratSemiFinishing')?.checked) strategies.push('Semi-Finishing');
            if (document.getElementById('stratFinishing')?.checked) strategies.push('Wall Finishing (Deep DOC)');
            if (document.getElementById('stratFloorFinishing')?.checked) strategies.push('Floor Finishing (Skim)');
            if (document.getElementById('stratSlotting')?.checked) strategies.push('Slotting / Tab Milling');
            if (document.getElementById('stratHighFeed')?.checked) strategies.push('High Feed Milling');

            if (strategies.length === 0) {
                alert('Please select at least one operation strategy checkbox.');
                return;
            }

            const customPresetName = document.getElementById('customPresetName') ? document.getElementById('customPresetName').value : '';
            const useToolOverrides = document.getElementById('twinUseToolOverrides')?.checked ?? true;
            const cleanMaterial = document.getElementById('twinCleanMaterial')?.checked ?? true;
            const cleanNonToolwiz = document.getElementById('twinCleanNonToolwiz')?.checked ?? false;

            const payload = {
                ...(checkedKeys.every(k => twinFind(k) && twinFind(k).guid) ? { tool_guids: checkedKeys.map(k => twinFind(k).guid) } : { tool_indices: checkedKeys.map(k => (twinFind(k) || {}).index) }),
                family: document.getElementById('twinFamily').value,
                alloy: document.getElementById('twinAlloy').value,
                strategies: strategies,
                aggressiveness: parseFloat(document.getElementById('twinAggressiveness').value),
                use_tool_overrides: useToolOverrides,
                clean_existing_for_material: cleanMaterial,
                clean_all_non_toolwiz: cleanNonToolwiz,
                coating: document.getElementById('twinCoating').value,
                maxRpm: parseFloat(document.getElementById('maxRpm')?.value) || (machineProfile && machineProfile.max_rpm) || 16000,
                maxHp: parseFloat(document.getElementById('maxHp')?.value) || (machineProfile && machineProfile.max_hp) || 10.0,
                runout: runoutInches,
                custom_preset_name: customPresetName,
                model: document.getElementById('cutModelSelect')?.value || undefined
            };

            const statusBox = document.getElementById('twinStatusBox');
            statusBox.style.display = 'block';
            statusBox.innerHTML = `⏳ Computing ToolWiz cutting physics and injecting presets across ${checked.length} cutters...`;

            try {
                const res = await fetch('/api/twin/batch_generate', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });
                const data = await res.json();
                
                if (data.success) {
                    const skipped = Array.isArray(data.skipped) ? data.skipped : [];
                    let skippedHtml = '';
                    if (skipped.length > 0) {
                        const shown = skipped.slice(0, 25).map(sk => {
                            const label = (sk.number ? 'T' + sk.number + ' ' : '') + (sk.description || ('tool #' + sk.tool_index));
                            const strat = sk.strategy ? ' [' + sk.strategy + ']' : '';
                            return `<li>${esc(label)}${esc(strat)}: ${esc(sk.reason)}</li>`;
                        }).join('');
                        const more = skipped.length > 25 ? `<li>…and ${skipped.length - 25} more</li>` : '';
                        skippedHtml = `<div style="margin-top:0.5rem; color:#fbbf24;"><strong>⚠️ Skipped (${skipped.length}):</strong><ul style="margin:0.25rem 0 0 1.1rem; padding:0; font-size:var(--fs-sm);">${shown}${more}</ul></div>`;
                    }
                    statusBox.innerHTML = `
                        <strong>✅ Batch Injection Complete!</strong><br>
                        • Updated Cutters: <strong>${esc(data.updated_tools_count)}</strong><br>
                        • Total Presets Injected: <strong>${esc(data.total_presets_injected)}</strong><br>
                        • Workpiece Material: <strong>${esc(payload.alloy)}</strong><br>
                        • Safety Snapshot: <code>${esc(data.backup && data.backup.filename)}</code>
                        ${skippedHtml}<br>
                        <em>Click 'Download Master Crib' above or sync directly in Fusion 360 using 'Import Digital Twin'!</em>
                    `;
                    loadDigitalTwin();
                } else {
                    statusBox.innerHTML = `❌ Error: ${esc(data.error)}`;
                }
            } catch (e) {
                statusBox.innerHTML = `❌ Network Error: ${esc(e)}`;
            }
        }



/* Shop T-slot cutters from the working library: POST /api/shop_tools/refresh (shop_tool_builder). */
async function refreshShopCutters() {
    const st = document.getElementById('twinShopStatus'), btn = document.getElementById('twinShopBtn');
    if (!st) return;
    btn.disabled = true; st.className = 'v3-status'; st.textContent = 'Reading the slot mills of the working library…';
    const r = await window.TW.api('/api/shop_tools/refresh', { library: 'working' });
    btn.disabled = false;
    if (!r.ok) { st.className = 'v3-status err'; st.textContent = 'Could not refresh the shop cutters: ' + ((r.data && r.data.error) || ('HTTP ' + r.status)); return; }
    const ids = r.data.library_added || [];
    const prov = (r.data.tools || []).filter(t => ids.includes(t.id) && (t.provisional || []).length).length;
    st.className = 'v3-status ok-text';
    st.textContent = ids.length
        ? `Shop T-slot cutters updated from ${r.data.library}: ${ids.length} slot mill${ids.length === 1 ? '' : 's'} read from Fusion${prov ? ` (${prov} still need a tooth form: see the add-in guide)` : ''}.`
        : `No slot mills / keyseat cutters found in ${r.data.library}; the shop cutter list was not changed.`;
}
