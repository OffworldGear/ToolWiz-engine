"""Desktop launcher: stale-server detection and port parsing; the server reports its code stamp."""
import importlib.machinery
import importlib.util
import os
import tempfile
import time
import unittest

import app
from toolwiz_common.server_stamp import code_stamp

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_launcher():
    path = os.path.join(ROOT, "launch_toolwizard.pyw")
    loader = importlib.machinery.SourceFileLoader("launch_toolwizard", path)
    spec = importlib.util.spec_from_loader("launch_toolwizard", loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


class TestCodeStamp(unittest.TestCase):
    def test_newest_source_file_wins_and_other_files_are_ignored(self):
        with tempfile.TemporaryDirectory() as d:
            os.makedirs(os.path.join(d, "templates"))
            for name, age in (("app.py", 100), ("templates/index.html", 50), ("server.log", 0)):
                p = os.path.join(d, name)
                open(p, "w").close()
                t = time.time() - age
                os.utime(p, (t, t))
            self.assertEqual(code_stamp(d), int(os.path.getmtime(os.path.join(d, "templates", "index.html"))))

    def test_server_reports_the_stamp_it_loaded(self):
        c = app.app.test_client()
        info = c.get("/api/server_info").get_json()
        self.assertEqual(info["pid"], os.getpid())
        self.assertEqual(info["code_stamp"], app.SERVER_INFO["code_stamp"])


class TestLauncher(unittest.TestCase):
    def test_listening_pids_only_port_5000_listeners(self):
        launcher = load_launcher()
        text = """
  Proto  Local Address          Foreign Address        State           PID
  TCP    127.0.0.1:5000         0.0.0.0:0              LISTENING       73152
  TCP    127.0.0.1:50001        0.0.0.0:0              LISTENING       111
  TCP    127.0.0.1:5000         127.0.0.1:61000        ESTABLISHED     73152
  TCP    0.0.0.0:15000          0.0.0.0:0              LISTENING       222
  TCP    [::1]:5000             [::]:0                 LISTENING       333
"""
        self.assertEqual(launcher.listening_pids(text), {73152, 333})


if __name__ == "__main__":
    unittest.main()
