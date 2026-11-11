/* ToolWiz web: last script. Unit-toggle fan-out and #tab deep links. */
(function () {
    'use strict';
    window.onUnitToggled = function () {
        ['plannerUnitChanged', 'masterUnitChanged', 'advisorUnitChanged', 'finishUnitChanged'].forEach(fn => { if (typeof window[fn] === 'function') window[fn](); });
        if (typeof renderTwinTools === 'function' && typeof activeTwinTools !== 'undefined' && activeTwinTools.length) renderTwinTools();
        if (typeof window.onShopToolUnit === 'function') window.onShopToolUnit();
    };
    const tab = (location.hash || '').replace('#', '');
    if (tab && typeof TAB_VIEWS !== 'undefined' && TAB_VIEWS[tab] && tab !== 'calculator') {
        // wait for init() of the main script (material lists) before opening a data-driven tab
        const go = () => { if (typeof allFamilies !== 'undefined' && allFamilies.length) switchTab(tab); else setTimeout(go, 150); };
        go();
    }
})();
