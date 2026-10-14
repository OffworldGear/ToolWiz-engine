"""Fingerprint of the server code, so the launcher can tell a stale server from a current one."""
import os

# What the running server has loaded: Python sources, the shared package, page templates and static
# files (Flask caches templates when not in debug mode).
_SOURCES = (("", (".py",)), ("toolwiz_common", (".py",)), ("templates", (".html",)),
            ("static", (".css", ".js")))


def code_stamp(root):
    """Newest modification time (whole seconds) of the server's source files under `root`."""
    newest = 0
    for sub, exts in _SOURCES:
        folder = os.path.join(root, sub)
        try:
            names = os.listdir(folder)
        except OSError:
            continue
        for name in names:
            if name.endswith(exts):
                try:
                    newest = max(newest, int(os.path.getmtime(os.path.join(folder, name))))
                except OSError:
                    pass
    return newest
