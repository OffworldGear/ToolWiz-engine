/* ToolWiz web: Advisor Chat tab (routes_advisor_chat.py, docs/ADVISOR_CHAT.md).
 * The browser never holds an API key after saving it; numbers in a reply that no ToolWiz result supports are marked "unverified". */
(function () {
    'use strict';
    const T = window.TW;
    const $ = id => document.getElementById(id);
    const E = T.esc;
    const API = '/api/advisor_chat';
    const ASSUMPTION_KEYS = ['coating', 'tool_material', 'tool_grade', 'family', 'alloy', 'aggressiveness', 'runout', 'finish_mode', 'holder_type'];
    let conv = null, settings = null, busy = false, inited = false, liveTimer = null, pollTimers = {};

    const store = {
        get(k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
        set(k, v) { try { localStorage.setItem(k, v); } catch (e) { /* private window */ } },
    };

    // ---- start ---------------------------------------------------------------------------------------------------
    window.initAdvisorChat = async function () {
        if (!inited) {
            inited = true;
            bind();
            $('chatAsmKey').innerHTML = ASSUMPTION_KEYS.map(k => `<option value="${k}">${k.replace('_', ' ')}</option>`).join('');
            T.fillFamilies('chatFamily', 'chatAlloy', { family: ($('family') || {}).value, alloy: ($('alloy') || {}).value });
            await loadSettings();
            await loadModels();
            const last = store.get('toolwiz_chat_last');
            if (last) await openConversation(last, true);
            await loadHistory();
            render();
        }
        refreshLive();
        clearInterval(liveTimer);
        liveTimer = setInterval(() => { if ($('chatView').style.display !== 'none') refreshLive(); else clearInterval(liveTimer); }, 5000);
    };

    function bind() {
        $('chatSend').onclick = send;
        $('chatInput').addEventListener('keydown', e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); send(); } });
        $('chatNewBtn').onclick = newChat;
        $('chatStartBtn').onclick = () => { const b = $('chatStartBox'); b.open = !b.open; if (b.open) T.fillFamilies('chatFamily', 'chatAlloy'); };
        $('chatStartGo').onclick = startFromAdvisor;
        $('chatProvider').onchange = async () => { await patchSettings({ provider: $('chatProvider').value }); await loadModels(); };
        $('chatModel').onchange = () => patchSettings({ model: $('chatModel').value });
        $('chatEffort').onchange = () => patchSettings({ effort: $('chatEffort').value });
        $('chatStrict').onchange = () => patchSettings({ strict: $('chatStrict').checked });
        $('chatViewport').onchange = () => patchSettings({ viewport_image: $('chatViewport').checked });
        document.querySelectorAll('[data-key-save]').forEach(b => b.onclick = () => saveKey(b.dataset.keySave, false));
        document.querySelectorAll('[data-key-clear]').forEach(b => b.onclick = () => saveKey(b.dataset.keyClear, true));
        $('chatAsmAdd').onclick = addAssumption;
    }

    // ---- settings / models / live status -------------------------------------------------------------------------
    async function loadSettings() {
        const r = await T.api(API + '/settings', undefined, 'GET');
        if (!r.ok) { $('chatErr').textContent = r.data.error || 'Could not load the settings.'; return; }
        settings = r.data.settings;
        $('chatProvider').innerHTML = settings.providers.map(p => `<option value="${p}">${p === 'anthropic' ? 'Claude (Anthropic)' : 'Gemini (Google)'}</option>`).join('');
        $('chatProvider').value = settings.provider;
        $('chatEffort').value = settings.effort;
        $('chatStrict').checked = !!settings.strict;
        $('chatViewport').checked = !!settings.viewport_image;
        ['anthropic', 'gemini'].forEach(p => {
            const k = settings.keys[p], id = 'chatKeyStatus' + p[0].toUpperCase() + p.slice(1);
            $(id).innerHTML = k.set ? `Key set (ends in <code>${E(k.last4)}</code>, ${E(k.source)}).` : '<span class="err-text">No key set.</span>';
        });
        $('chatSettings').open = settings.keys[settings.provider] && !settings.keys[settings.provider].set;
    }
    async function patchSettings(patch) {
        const r = await T.api(API + '/settings', patch);
        if (!r.ok) { T.toast(r.data.error || 'Could not save the setting', true); return false; }
        settings = r.data.settings;
        if (conv && (patch.provider || patch.model || patch.effort)) {
            if (patch.provider) { conv.provider = patch.provider; conv.model = settings.models[patch.provider] || ''; }
            if (patch.model) conv.model = patch.model;
            if (patch.effort) conv.effort = patch.effort;
        }
        return true;
    }
    async function saveKey(provider, clear) {
        const id = 'chatKey' + provider[0].toUpperCase() + provider.slice(1);
        const val = clear ? '' : $(id).value.trim();
        if (!clear && !val) { T.toast('Paste the key first', true); return; }
        const ok = await patchSettings({ keys: { [provider]: val } });
        $(id).value = '';                       // the key is not kept in the page
        if (ok) { await loadSettings(); if (provider === settings.provider) await loadModels(); T.toast(clear ? 'Key removed' : 'Key saved on this computer'); }
    }
    async function loadModels() {
        const p = $('chatProvider').value || (settings && settings.provider) || 'anthropic';
        $('chatModelNote').textContent = 'Loading models…';
        const r = await T.api(API + '/models?provider=' + encodeURIComponent(p), undefined, 'GET');
        const sel = $('chatModel');
        if (!r.ok) { sel.innerHTML = ''; $('chatModelNote').innerHTML = `<span class="err-text">${E(r.data.error || 'Could not list models')}</span>`; return; }
        const want = (conv && conv.provider === p && conv.model) || r.data.selected;
        const ids = r.data.models.map(m => m.id);
        sel.innerHTML = r.data.models.map(m => `<option value="${E(m.id)}">${E(m.label)}${m.note ? ' (' + E(m.note) + ')' : ''}</option>`).join('');
        sel.value = ids.includes(want) ? want : ids[0];
        $('chatModelNote').textContent = r.data.error || (r.data.source === 'api' ? 'Models listed from your account.' : '');
    }
    async function refreshLive() {
        const r = await T.api(API + '/status', undefined, 'GET');
        const el = $('chatLive');
        if (!r.ok) { el.innerHTML = '<span class="err-text">ToolWiz server not reachable.</span>'; return; }
        const s = r.data;
        if (!s.connected) { el.innerHTML = '<span><span class="chat-dot"></span>Fusion not connected: run the ToolWiz Setup Advisor command in Fusion so the add-in sends your setup.</span>'; return; }
        const age = s.snapshot_age_seconds, ageTxt = age == null ? '' : age < 90 ? age + ' s ago' : Math.round(age / 60) + ' min ago';
        el.innerHTML = `<span><span class="chat-dot ${s.stale ? 'stale' : 'on'}"></span>${s.stale ? 'Snapshot is old' : 'Connected'}</span><span>Document: <strong>${E(s.document || '?')}</strong></span><span>${s.operations} operation(s), snapshot ${E(ageTxt)}</span>`;
    }

    // ---- conversations -------------------------------------------------------------------------------------------
    async function loadHistory() {
        const r = await T.api(API + '/conversations', undefined, 'GET');
        const box = $('chatHistory');
        const list = (r.data && r.data.conversations) || [];
        box.innerHTML = list.length ? list.map(c => `<div style="display:flex;gap:0.3rem;"><button class="item ${conv && conv.id === c.id ? 'cur' : ''}" data-open="${E(c.id)}">${E(c.title || 'Chat')}<br><span class="v3-sub">${E((c.updated || '').replace('T', ' '))}</span></button><button class="item" style="width:auto;" data-del="${E(c.id)}" title="Delete this chat" aria-label="Delete this chat">&times;</button></div>`).join('') : '<div class="v3-sub">No saved chats.</div>';
        box.querySelectorAll('[data-open]').forEach(b => b.onclick = () => openConversation(b.dataset.open));
        box.querySelectorAll('[data-del]').forEach(b => b.onclick = async () => {
            if (!confirm('Delete this saved chat?')) return;
            await T.api(API + '/conversations/' + b.dataset.del, undefined, 'DELETE');
            if (conv && conv.id === b.dataset.del) { conv = null; render(); }
            loadHistory();
        });
    }
    async function openConversation(id, quiet) {
        const r = await T.api(API + '/conversations/' + encodeURIComponent(id), undefined, 'GET');
        if (!r.ok) { if (!quiet) T.toast(r.data.error || 'Could not open the chat', true); return; }
        setConv(r.data.conversation);
        render(true);
        loadHistory();
    }
    function setConv(c) {
        conv = c;
        store.set('toolwiz_chat_last', c.id);
        if (c.provider && $('chatProvider').value !== c.provider) { $('chatProvider').value = c.provider; loadModels(); }
        else if (c.model && Array.from($('chatModel').options).some(o => o.value === c.model)) $('chatModel').value = c.model;
        if (c.effort) $('chatEffort').value = c.effort;
        resumePolls();
    }
    async function newChat() {
        const r = await T.api(API + '/conversations', { provider: $('chatProvider').value, model: $('chatModel').value, effort: $('chatEffort').value });
        if (!r.ok) { T.toast(r.data.error || 'Could not start a chat', true); return; }
        setConv(r.data.conversation); render(true); loadHistory(); $('chatInput').focus();
    }
    async function startFromAdvisor() {
        const fam = $('chatFamily').value, alloy = $('chatAlloy').value;
        if (!fam) { T.toast('Pick the material first', true); return; }
        setBusy(true, 'Running the Setup Advisor…');
        const r = await T.api(API + '/conversations', { provider: $('chatProvider').value, model: $('chatModel').value, effort: $('chatEffort').value, start_from_advisor: true, family: fam, alloy: alloy });
        setBusy(false);
        if (!r.ok) { $('chatErr').textContent = r.data.error || 'Could not start'; return; }
        $('chatStartBox').open = false;
        setConv(r.data.conversation); render(true); loadHistory();
        if (r.data.advisor && !r.data.advisor.ok) $('chatErr').textContent = r.data.advisor.error || '';
    }

    async function send() {
        const input = $('chatInput'), text = input.value.trim();
        if (!text || busy) return;
        if (!conv) { await newChat(); if (!conv) return; }
        $('chatErr').textContent = '';
        input.value = '';
        conv.messages.push({ role: 'user', content: text });
        setBusy(true, 'Thinking… (tools run on the ToolWiz server)');
        render(true);
        const r = await T.api(API + '/conversations/' + conv.id + '/messages', { message: text, provider: $('chatProvider').value, model: $('chatModel').value, effort: $('chatEffort').value });
        setBusy(false);
        if (r.data && r.data.conversation) setConv(r.data.conversation);
        if (!r.ok && !(r.data && r.data.conversation)) { $('chatErr').textContent = r.data.error || 'The message could not be sent.'; input.value = text; }
        else if (r.data.error) $('chatErr').textContent = r.data.error;
        render(true);
        loadHistory();
    }
    function setBusy(b, msg) {
        busy = b;
        $('chatSend').disabled = b; $('chatStartGo').disabled = b;
        const log = $('chatLog');
        const old = $('chatBusy'); if (old) old.remove();
        if (b) { const d = document.createElement('div'); d.id = 'chatBusy'; d.className = 'chat-busy'; d.textContent = msg || 'Working…'; log.appendChild(d); log.scrollTop = log.scrollHeight; }
    }

    // ---- assumptions ---------------------------------------------------------------------------------------------
    async function addAssumption() {
        if (!conv) await newChat();
        if (!conv) return;
        const key = $('chatAsmKey').value, val = $('chatAsmVal').value.trim();
        if (!val) { T.toast('Enter a value', true); return; }
        const tools = $('chatAsmScope').value.split(/[,\s]+/).map(s => s.trim().replace(/^T/i, '')).filter(Boolean).map(Number);
        if (tools.some(n => !Number.isInteger(n))) { T.toast('Tool numbers must be whole numbers', true); return; }
        const body = { key, value: val, scope: tools.length ? { tools } : { all: true } };
        if (key === 'runout') body.unit = $('chatAsmUnit').value;
        const r = await T.api(API + '/conversations/' + conv.id + '/assumptions', body);
        if (!r.ok) { T.toast(r.data.error || 'Could not add', true); return; }
        setConv(r.data.conversation); $('chatAsmVal').value = ''; render();
    }
    async function removeAssumption(id) {
        const r = await T.api(API + '/conversations/' + conv.id + '/assumptions/' + id, undefined, 'DELETE');
        if (r.ok) { setConv(r.data.conversation); render(); }
    }

    // ---- proposals -----------------------------------------------------------------------------------------------
    async function decide(pid, what) {
        const r = await T.api(API + '/conversations/' + conv.id + '/proposals/' + pid + '/' + what, {});
        if (r.data && r.data.proposal) { const i = conv.proposals.findIndex(p => p.id === pid); if (i >= 0) conv.proposals[i] = r.data.proposal; }
        if (!r.ok) T.toast(r.data.error || 'Not done', true);
        renderProposals(); resumePolls();
    }
    function resumePolls() {
        if (!conv) return;
        (conv.proposals || []).filter(p => p.status === 'queued' && !pollTimers[p.id]).forEach(p => {
            pollTimers[p.id] = setInterval(async () => {
                if (!conv) return;
                const r = await T.api(API + '/conversations/' + conv.id + '/proposals/' + p.id, undefined, 'GET');
                const np = r.data && r.data.proposal;
                if (np && np.status !== 'queued') {
                    clearInterval(pollTimers[p.id]); delete pollTimers[p.id];
                    const i = conv.proposals.findIndex(x => x.id === p.id); if (i >= 0) conv.proposals[i] = np;
                    renderProposals();
                }
            }, 2500);
        });
    }
    function renderProposals() {
        const box = $('chatProposals'), list = (conv && conv.proposals) || [];
        if (!list.length) { box.innerHTML = '<div class="v3-sub">None yet.</div>'; return; }
        const label = { pending: 'waiting for you', queued: 'waiting for Fusion', applied: 'applied', failed: 'failed', rejected: 'rejected', declined: 'declined', declined_in_fusion: 'declined in Fusion' };
        box.innerHTML = list.map(p => {
            const res = p.result || {};
            const detail = p.status === 'applied' ? Object.entries(res.applied || {}).map(([k, v]) => `${E(k)}: ${E(v.old)} &rarr; ${E(v.new)}`).join('<br>')
                : (res.error ? E(res.error) : '');
            const skipped = Object.entries(res.skipped || {}).map(([k, v]) => `skipped ${E(k)}: ${E(v)}`).join('<br>');
            return `<div class="chat-prop"><span class="st ${E(p.status)}">${E(label[p.status] || p.status)}</span> <strong>${E(p.id)}</strong> ${p.kind === 'tool_fields' ? 'tool fields' : 'operation values'}
                <div>${E(p.summary)}</div>${p.reason ? `<div class="v3-sub">${E(p.reason)}</div>` : ''}
                ${p.status === 'queued' ? '<div class="v3-sub">Confirm the change in the Fusion dialog.</div>' : ''}
                ${detail ? `<div class="v3-sub">${detail}</div>` : ''}${skipped ? `<div class="v3-sub">${skipped}</div>` : ''}
                ${p.status === 'pending' ? `<div class="acts"><button class="btn-ratio v3-btn" data-approve="${E(p.id)}">Approve</button><button class="btn-ratio" data-decline="${E(p.id)}">Decline</button></div>` : ''}</div>`;
        }).join('');
        box.querySelectorAll('[data-approve]').forEach(b => b.onclick = () => decide(b.dataset.approve, 'approve'));
        box.querySelectorAll('[data-decline]').forEach(b => b.onclick = () => decide(b.dataset.decline, 'decline'));
    }
    function renderAssumptions() {
        const box = $('chatAssumptions'), list = (conv && conv.assumptions) || [];
        box.innerHTML = list.length ? list.map(a => `<span class="chat-chip" title="${E(a.scope && a.scope.all ? 'all tools' : JSON.stringify(a.scope))}">${E(a.key.replace('_', ' '))}: <strong>${E(String(a.key === 'runout' ? a.value + ' in' : a.value))}</strong> &middot; ${E(scopeText(a.scope))}<button data-rm="${E(a.id)}" aria-label="Remove this assumption">&times;</button></span>`).join('')
            : '<div class="v3-sub">None. Tell the assistant, or add one below.</div>';
        box.querySelectorAll('[data-rm]').forEach(b => b.onclick = () => removeAssumption(b.dataset.rm));
    }
    function scopeText(s) {
        if (!s || s.all) return 'all tools';
        const p = [];
        if (s.tools) p.push(s.tools.map(n => 'T' + n).join(', '));
        if (s.diameter_in) p.push(s.diameter_in + ' in tools');
        if (s.op_ids) p.push(s.op_ids.join(', '));
        return p.join('; ');
    }

    // ---- rendering the conversation --------------------------------------------------------------------------------
    /** Small markdown subset (bold, code, lists, headings) on text that is escaped first. `rejected` numbers are marked. */
    function md(src, rejected) {
        let t = E(String(src || ''));
        const marks = [];
        const list = (rejected || []).map(n => E(n)).filter(Boolean).sort((a, b) => b.length - a.length);
        if (list.length) {
            const re = new RegExp('(^|[^\\d.])(' + list.map(n => n.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|') + ')(?!\\d)', 'g');
            t = t.replace(re, (m, pre, num) => { marks.push(num); return pre + '\u0001' + (marks.length - 1) + '\u0002'; });
        }
        const out = []; let inList = false, inCode = false;
        const close = () => { if (inList) { out.push('</ul>'); inList = false; } };
        const inline = s => s.replace(/`([^`]+)`/g, '<code>$1</code>').replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
        for (const line of t.split('\n')) {
            if (/^\s*```/.test(line)) { close(); out.push(inCode ? '</pre>' : '<pre>'); inCode = !inCode; continue; }
            if (inCode) { out.push(line + '\n'); continue; }
            let m;
            if ((m = line.match(/^\s*[-*]\s+(.*)$/))) { if (!inList) { out.push('<ul>'); inList = true; } out.push('<li>' + inline(m[1]) + '</li>'); continue; }
            close();
            if ((m = line.match(/^#{1,4}\s+(.*)$/))) { out.push('<p><strong>' + inline(m[1]) + '</strong></p>'); continue; }
            if (line.trim()) out.push('<p>' + inline(line) + '</p>');
        }
        close(); if (inCode) out.push('</pre>');
        return out.join('').replace(/\u0001(\d+)\u0002/g, (m, i) => `<mark class="unv" title="No ToolWiz result in this chat contains this number">${marks[+i]}<sup>unverified</sup></mark>`);
    }
    function prettyJson(s) { try { return JSON.stringify(JSON.parse(s), null, 1); } catch (e) { return String(s); } }

    function renderLog(scroll) {
        const log = $('chatLog');
        const msgs = (conv && conv.messages) || [];
        if (!conv || !msgs.length) {
            log.innerHTML = `<div class="v3-empty"><strong>Nothing here yet.</strong><br>Press <em>Start from Setup Advisor</em> to review the setup that is open in Fusion, or just ask a question.</div>`;
            return;
        }
        const results = {};
        msgs.forEach(m => (m.results || []).forEach(r => { results[r.tool_call_id] = r; }));
        let html = '';
        msgs.forEach((m, i) => {
            if (m.role === 'user') html += `<div class="chat-msg user">${E(m.content).replace(/\n/g, '<br>')}</div>`;
            else if (m.role === 'system') html += `<div class="chat-note">Session note: ${E(m.content)}</div>`;
            else if (m.role === 'notice') {
                const kind = m.kind === 'error' ? 'bad' : m.kind === 'fallback' ? '' : 'warn';
                html += T.callout(kind || 'ok', m.kind === 'error' ? 'Error' : m.kind === 'refusal' ? 'The model declined' : m.kind === 'fallback' ? 'Another model answered' : 'Notice', E(m.content));
            } else if (m.role === 'assistant') {
                if ((m.text || '').trim()) html += assistantHtml(m);
                if ((m.tool_calls || []).length) html += traceHtml(m, results);
            }
        });
        log.innerHTML = html;
        log.querySelectorAll('[data-reveal]').forEach(b => b.onclick = () => { const el = $('chatWh' + b.dataset.reveal); el.style.display = el.style.display === 'none' ? '' : 'none'; });
        if (scroll) log.scrollTop = log.scrollHeight;
    }
    function assistantHtml(m) {
        const g = m.guard || {}, rej = g.rejected_numbers || [];
        let head = '';
        if (rej.length) head = `<div class="chat-guard">${T.callout('warn', 'Unverified numbers', `${rej.length} number(s) in this reply are not in any ToolWiz result of this chat and may be wrong: <strong>${rej.map(E).join(', ')}</strong>. Check them with ToolWiz before you use them.`)}</div>`;
        const idx = conv.messages.indexOf(m);
        let body;
        if (m.withheld) {
            body = `<div class="chat-guard">${T.callout('bad', 'Reply withheld (strict numbers)', 'It contained numbers ToolWiz did not provide' + (rej.length ? ': ' + rej.map(E).join(', ') : '') + '.')}</div>
                <button class="btn-ratio" data-reveal="${idx}" style="padding:2px 8px;cursor:pointer;">Show it anyway</button><div id="chatWh${idx}" style="display:none;margin-top:0.4rem;">${md(m.text, rej)}</div>`;
            head = '';
        } else body = md(m.text, rej);
        const meta = [];
        const mm = m.meta || {};
        if (mm.served_model || mm.model) meta.push(E(mm.served_model || mm.model));
        if (mm.fallback) meta.push('answered by a fallback model');
        if (g.checked && !rej.length) meta.push('&#10003; ' + g.checked + ' number(s) checked against ToolWiz results');
        return `<div class="chat-msg assistant">${head}${body}${meta.length ? `<div class="chat-meta">${meta.map(x => `<span>${x}</span>`).join('')}</div>` : ''}</div>`;
    }
    function traceHtml(m, results) {
        const calls = m.tool_calls || [];
        const inner = calls.map(c => {
            const r = results[c.id];
            return `<div class="chat-call ${r && r.is_error ? 'err' : ''}"><strong>${E(c.name)}</strong><pre>${E(JSON.stringify(c.arguments, null, 1))}</pre>
                ${r ? `<div class="v3-sub">${r.is_error ? 'Error' : 'Result'}${r.has_image ? ' (screenshot attached)' : ''}</div><pre>${E(prettyJson(r.content))}</pre>` : '<div class="v3-sub">No result.</div>'}</div>`;
        }).join('');
        return `<details class="chat-trace chat-msg-trace"><summary>Used ${calls.length} ToolWiz tool${calls.length > 1 ? 's' : ''}: ${calls.map(c => E(c.name)).join(', ')}</summary>${inner}</details>`;
    }

    function render(scroll) {
        renderLog(scroll);
        renderAssumptions();
        renderProposals();
        if (busy) setBusy(true, 'Thinking… (tools run on the ToolWiz server)');
    }
})();
