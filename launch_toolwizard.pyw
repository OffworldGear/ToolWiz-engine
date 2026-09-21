"""
Tool Wizard Windows Desktop Launcher
====================================
Seamlessly checks if the Tool Wizard server is running, starts it silently
with pythonw.exe if needed, and opens http://127.0.0.1:5000 in your browser.
"""

import os
import sys
import time
import urllib.request
import subprocess
import webbrowser

URL = "http://127.0.0.1:5000/"
DIR = os.path.dirname(os.path.abspath(__file__))
APP_PY = os.path.join(DIR, "app.py")
LOG_PATH = os.path.join(DIR, "server.log")

def is_server_online() -> bool:
    try:
        req = urllib.request.Request(URL, headers={"User-Agent": "ToolWizLauncher"})
        with urllib.request.urlopen(req, timeout=1.0) as resp:
            return resp.status == 200
    except Exception:
        return False

def main():
    if not is_server_online():
        py_candidates = [
            r"C:\Python314\pythonw.exe",
            os.path.join(os.path.dirname(sys.executable), "pythonw.exe"),
            r"C:\Python314\python.exe",
            sys.executable
        ]
        py_exe = next((p for p in py_candidates if os.path.exists(p)), sys.executable)
        
        log_file = open(LOG_PATH, "a", encoding="utf-8")
        log_file.write(f"\n--- Tool Wizard Launched at {time.strftime('%Y-%m-%d %H:%M:%S')} ---\n")
        log_file.flush()

        # DETACHED_PROCESS (0x00000008) ensures background server persists independently
        creation_flags = 0x00000008 | 0x00000200
        if hasattr(subprocess, "CREATE_NO_WINDOW"):
            creation_flags |= subprocess.CREATE_NO_WINDOW

        env = os.environ.copy()
        env["PYTHONUNBUFFERED"] = "1"

        subprocess.Popen(
            [py_exe, APP_PY],
            cwd=DIR,
            stdout=log_file,
            stderr=log_file,
            creationflags=creation_flags,
            env=env,
            close_fds=True
        )

        for _ in range(30):
            time.sleep(0.2)
            if is_server_online():
                break

    webbrowser.open(URL)

if __name__ == "__main__":
    main()
