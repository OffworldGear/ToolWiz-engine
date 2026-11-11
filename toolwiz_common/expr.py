"""Safe arithmetic evaluator for Fusion length expressions (no eval)."""
import ast
import operator
import re

MAX_LEN = 200

_BIN = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul, ast.Div: operator.truediv}
_UN = {ast.USub: operator.neg, ast.UAdd: operator.pos}
_UNIT_RE = re.compile(r'(millimeters?|inches|inch|mm|in|")', re.IGNORECASE)


def safe_eval_length(expr: str) -> float:
    """Evaluate + - * / unary minus and parentheses over numbers.

    Unit tokens (mm, in, ", inch, millimeter) are stripped (multiplier 1.0).
    Anything else, including **, raises ValueError.
    """
    if not isinstance(expr, str):
        raise ValueError("expression must be a string")
    if len(expr) > MAX_LEN:
        raise ValueError("expression too long")
    s = _UNIT_RE.sub(" ", expr).strip()
    if not s:
        raise ValueError("empty expression")
    try:
        node = ast.parse(s, mode="eval")
    except SyntaxError as e:
        raise ValueError("invalid expression: %s" % e) from None

    def ev(n):
        if isinstance(n, ast.Expression):
            return ev(n.body)
        if isinstance(n, ast.Constant) and isinstance(n.value, (int, float)) and not isinstance(n.value, bool):
            return float(n.value)
        if isinstance(n, ast.BinOp) and type(n.op) in _BIN:
            left = ev(n.left)
            right = ev(n.right)
            if isinstance(n.op, ast.Div) and right == 0:
                raise ValueError("division by zero")
            return _BIN[type(n.op)](left, right)
        if isinstance(n, ast.UnaryOp) and type(n.op) in _UN:
            return _UN[type(n.op)](ev(n.operand))
        raise ValueError("unsupported syntax: %s" % type(n).__name__)

    return ev(node)
