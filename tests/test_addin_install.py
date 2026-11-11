import os
import subprocess
import sys
import tempfile
import textwrap
import unittest

from test_addin_common import REPO_ROOT

sys.path.insert(0, REPO_ROOT)
import install_addin  # noqa: E402


class TestInstallAddin(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.addins = os.path.join(self._tmp.name, "Autodesk", "Autodesk Fusion 360", "API", "AddIns")
        os.makedirs(self.addins)
        self.dest = install_addin.install_addin(appdata=self._tmp.name)

    def test_copies_addin_and_common_without_pycache(self):
        self.assertEqual(self.dest, os.path.join(self.addins, "ToolWizFusionAddin"))
        for rel in ("ToolWizFusionAddin.py", "ToolWizFusionAddin.manifest", "json_mutator.py",
                    os.path.join("toolwiz_common", "__init__.py"),
                    os.path.join("toolwiz_common", "geometry.py")):
            self.assertTrue(os.path.exists(os.path.join(self.dest, rel)), rel)
        for root, dirs, files in os.walk(self.dest):
            self.assertNotIn("__pycache__", dirs, root)
            self.assertFalse([f for f in files if f.endswith(".pyc")], root)

    def test_deploy_script_removed(self):
        self.assertFalse(os.path.exists(os.path.join(REPO_ROOT, "deploy_to_fusion.ps1")))

    def _run_import(self, code):
        env = dict(os.environ)
        env.pop("PYTHONPATH", None)
        env["PYTHONDONTWRITEBYTECODE"] = "1"
        pre = textwrap.dedent("""
            import sys
            from unittest.mock import MagicMock
            for m in ['adsk', 'adsk.core', 'adsk.cam', 'adsk.fusion']:
                sys.modules[m] = MagicMock()
        """)
        return subprocess.run([sys.executable, "-c", pre + textwrap.dedent(code)], cwd=self._tmp.name,
                              env=env, capture_output=True, text=True, timeout=60)

    def test_installed_copy_imports_bundled_common_flat_layout(self):
        # Fusion loads the add-in with its own folder on sys.path (module is not in a package).
        res = self._run_import("""
            sys.path.insert(0, %r)
            import ToolWizFusionAddin as m
            print(m.ToolGeometry.__module__, sys.modules['toolwiz_common'].__file__)
        """ % self.dest)
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertIn(os.path.join(self.dest, "toolwiz_common"), res.stdout)

    def test_installed_copy_imports_bundled_common_package_layout(self):
        res = self._run_import("""
            sys.path.insert(0, %r)
            import ToolWizFusionAddin.ToolWizFusionAddin as m
            print(m.ToolGeometry.__module__)
        """ % self.addins)
        self.assertEqual(res.returncode, 0, res.stderr)
        self.assertIn("ToolWizFusionAddin.toolwiz_common", res.stdout)


if __name__ == "__main__":
    unittest.main()
