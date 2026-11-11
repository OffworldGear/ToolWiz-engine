"""Session assumptions: what the owner told the chat that the Fusion snapshot does not say ("all my tools are AlTiN").

They are applied to every advisor / calculation run of the conversation and never written to Fusion. Validation and the way
they enter the advisor live in ``setup_advisor`` (``normalize_assumption`` / ``apply_assumptions``); this module keeps the list.
"""
from __future__ import annotations

from typing import Any, Dict, List, Optional, Tuple

import setup_advisor

#: a global set used by the MCP tools (an external assistant has no conversation object)
MCP_ASSUMPTIONS: List[Dict[str, Any]] = []


def _scope_key(rec: Dict[str, Any]) -> Tuple[str, str]:
    sc = rec["scope"]
    return rec["key"], repr(sorted((k, tuple(v) if isinstance(v, list) else v) for k, v in sc.items()))


def public(rec: Dict[str, Any]) -> Dict[str, Any]:
    return {"id": rec["id"], "key": rec["key"], "value": rec["value"], "scope": setup_advisor.describe_scope(rec["scope"]),
            "override": rec["override"]}


def add(store: List[Dict[str, Any]], raw: Dict[str, Any]) -> Dict[str, Any]:
    """Validate and add (or replace the same key + scope) in ``store`` (mutated). Returns the stored record. ValueError on bad input."""
    rec = setup_advisor.normalize_assumption(raw)
    sk = _scope_key(rec)
    for i, old in enumerate(store):
        if _scope_key(old) == sk:
            rec["id"] = old["id"]
            store[i] = rec
            return rec
    n = 1 + max([int(r["id"][1:]) for r in store if str(r.get("id", "")).startswith("a") and r["id"][1:].isdigit()] or [0])
    rec["id"] = f"a{n}"
    store.append(rec)
    return rec


def remove(store: List[Dict[str, Any]], *, rec_id: Optional[str] = None, key: Optional[str] = None, all_: bool = False) -> List[Dict[str, Any]]:
    """Remove by id, by key (every scope) or everything. Returns the removed records."""
    gone = [r for r in store if all_ or (rec_id and r["id"] == rec_id) or (key and not rec_id and r["key"] == key)]
    store[:] = [r for r in store if r not in gone]
    return gone


def resolve(store: List[Dict[str, Any]], tool_number: Optional[int] = None, diameter_in: Optional[float] = None) -> Dict[str, Any]:
    """The assumption values that apply to one tool (later records win; scoped ones after general ones)."""
    probe = {"op_id": "", "name": "", "tool": {"number": tool_number, "diameter_in": diameter_in}}
    out: Dict[str, Any] = {}
    for rec in sorted(store, key=lambda r: 0 if r["scope"].get("all") else 1):
        if setup_advisor._scope_hit(rec["scope"], probe):
            out[rec["key"]] = rec
    return out
