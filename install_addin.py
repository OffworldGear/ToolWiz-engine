import os
import shutil
import sys

_IGNORE = shutil.ignore_patterns('__pycache__', '*.pyc', '*.pyo')


def install_addin(appdata=None):
    """Copy the add-in plus the shared toolwiz_common package into Fusion's AddIns folder."""
    appdata = appdata or os.environ.get('APPDATA')
    if not appdata:
        print("Error: APPDATA environment variable not found.")
        sys.exit(1)

    fusion_addons_dir = os.path.join(appdata, 'Autodesk', 'Autodesk Fusion 360', 'API', 'AddIns')

    if not os.path.exists(fusion_addons_dir):
        print(f"Error: Fusion 360 AddIns directory not found at {fusion_addons_dir}")
        print("Please ensure Autodesk Fusion 360 is installed.")
        sys.exit(1)

    repo_dir = os.path.dirname(os.path.abspath(__file__))
    source_dir = os.path.join(repo_dir, 'ToolWizFusionAddin')
    common_dir = os.path.join(repo_dir, 'toolwiz_common')
    dest_dir = os.path.join(fusion_addons_dir, 'ToolWizFusionAddin')

    if not os.path.isdir(common_dir):
        print(f"Error: shared package not found at {common_dir}")
        sys.exit(1)

    if os.path.exists(dest_dir):
        print(f"Removing existing add-in at {dest_dir}...")
        shutil.rmtree(dest_dir)

    print(f"Copying add-in from {source_dir} to {dest_dir}...")
    shutil.copytree(source_dir, dest_dir, ignore=_IGNORE)

    dest_common = os.path.join(dest_dir, 'toolwiz_common')
    print(f"Copying shared package from {common_dir} to {dest_common}...")
    shutil.copytree(common_dir, dest_common, ignore=_IGNORE)

    print("\nInstall complete! Please restart Fusion 360 or go to Scripts and Add-Ins (Shift+S) to enable ToolWizFusionAddin.")
    return dest_dir


if __name__ == '__main__':
    install_addin()
