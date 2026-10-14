"""
Tool Wizard Windows Desktop Launcher
====================================
Makes sure the Tool Wizard server on port 5000 is running the code that is on disk, then opens
http://127.0.0.1:5000 in your browser.

  * Server running current code  -> just open the browser.
  * Server stale (code updated since it started), hung, or an old version without
    /api/server_info               -> stop it, start a fresh one, wait until it answers.
  * Not running                    -> start it.

Arguments:  --restart  always restart the server      --stop  stop it and exit
Problems are shown in a message box (details in server.log next to this file).
"""

import ctypes
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
import webbrowser

PORT = 5000
URL = f"http://127.0.0.1:{PORT}/"
DIR = os.path.dirname(os.path.abspath(__file__))
APP_PY = os.path.join(DIR, "app.py")
LOG_PATH = os.path.join(DIR, "server.log")
LOG_MAX_BYTES = 5 * 1024 * 1024
NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)

sys.path.insert(0, DIR)
from toolwiz_common.server_stamp import code_stamp  # noqa: E402


def message(text, error=True):
    flags = 0x10 if error else 0x40  # MB_ICONERROR / MB_ICONINFORMATION
    try:
        ctypes.windll.user32.MessageBoxW(None, text, "Tool Wizard", flags)
    except Exception:
        pass


def server_info(timeout=1.5):
    """{'code_stamp', 'pid', 'started'} from a current server; {} from an old one that is up
    but has no /api/server_info; None when nothing answers."""
    try:
        with urllib.request.urlopen(URL + "api/server_info", timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError:
        return {}          # an older server: it answers, but has no version endpoint
    except Exception:
        pass
    try:
        with urllib.request.urlopen(URL, timeout=timeout):
            return {}
    except Exception:
        return None


def listening_pids(netstat_text, port=PORT):
    """PIDs listening on `port` in `netstat -ano` output."""
    pids = set()
    for line in netstat_text.splitlines():
        parts = line.split()
        if (len(parts) >= 5 and parts[0].upper() == "TCP" and parts[3].upper() == "LISTENING"
                and re.search(rf":{port}$", parts[1]) and parts[4].isdigit() and parts[4] != "0"):
            pids.add(int(parts[4]))
    return pids


def port_pids():
    try:
        out = subprocess.run(["netstat", "-ano", "-p", "TCP"], capture_output=True, text=True,
                             creationflags=NO_WINDOW, timeout=15).stdout
    except Exception:
        return set()
    return listening_pids(out)


def stop_server(info=None):
    pids = port_pids()
    if info and isinstance(info.get("pid"), int):
        pids.add(info["pid"])
    for pid in pids:
        subprocess.run(["taskkill", "/F", "/PID", str(pid)], capture_output=True, creationflags=NO_WINDOW)
    for _ in range(50):                      # wait up to 5 s for the port to free up
        if not port_pids():
            return True
        time.sleep(0.1)
    return not port_pids()


def start_server():
    py_candidates = [
        r"C:\Python314\pythonw.exe",
        os.path.join(os.path.dirname(sys.executable), "pythonw.exe"),
        sys.executable,
    ]
    py_exe = next((p for p in py_candidates if os.path.exists(p)), sys.executable)
    try:
        if os.path.exists(LOG_PATH) and os.path.getsize(LOG_PATH) > LOG_MAX_BYTES:
            os.replace(LOG_PATH, LOG_PATH + ".1")
    except OSError:
        pass
    log_file = open(LOG_PATH, "a", encoding="utf-8")
    log_file.write(f"\n--- Tool Wizard launched at {time.strftime('%Y-%m-%d %H:%M:%S')} ---\n")
    log_file.flush()
    env = os.environ.copy()
    env["PYTHONUNBUFFERED"] = "1"
    # DETACHED_PROCESS | CREATE_NEW_PROCESS_GROUP | CREATE_NO_WINDOW: keeps running after this exits
    subprocess.Popen([py_exe, APP_PY], cwd=DIR, stdout=log_file, stderr=log_file, env=env,
                     creationflags=0x00000008 | 0x00000200 | NO_WINDOW, close_fds=True)


def log_tail(lines=12):
    try:
        with open(LOG_PATH, "r", encoding="utf-8", errors="replace") as f:
            return "".join(f.readlines()[-lines:])
    except OSError:
        return "(no server.log)"


def main(argv):
    force = "--restart" in argv
    info = server_info()

    if "--stop" in argv:
        ok = stop_server(info)
        message("Tool Wizard server stopped." if ok else "Could not stop the Tool Wizard server.", error=not ok)
        return

    current = code_stamp(DIR)
    up_to_date = bool(info) and info.get("code_stamp") == current
    if force or not up_to_date:
        if info is not None or port_pids():
            if not stop_server(info):
                message(f"Another program is holding port {PORT} and could not be stopped.\n"
                        f"Close it (or run stop_toolwizard.bat) and try again.")
                return
        start_server()
        for _ in range(75):                  # up to 15 s
            time.sleep(0.2)
            info = server_info(timeout=1.0)
            if info and info.get("code_stamp") == current:
                break
        else:
            message("The Tool Wizard server did not start.\n\nEnd of server.log:\n\n" + log_tail())
            return

    webbrowser.open(URL)


if __name__ == "__main__":
    main(sys.argv[1:])
