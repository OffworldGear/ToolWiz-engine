import os
import shutil
import sys

def install_addin():
    appdata = os.environ.get('APPDATA')
    if not appdata:
        print("Error: APPDATA environment variable not found.")
        sys.exit(1)
        
    fusion_addons_dir = os.path.join(appdata, 'Autodesk', 'Autodesk Fusion 360', 'API', 'AddIns')
    
    if not os.path.exists(fusion_addons_dir):
        print(f"Error: Fusion 360 AddIns directory not found at {fusion_addons_dir}")
        print("Please ensure Autodesk Fusion 360 is installed.")
        sys.exit(1)
        
    source_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ToolWizFusionAddin')
    dest_dir = os.path.join(fusion_addons_dir, 'ToolWizFusionAddin')
    
    if os.path.exists(dest_dir):
        print(f"Removing existing add-in at {dest_dir}...")
        shutil.rmtree(dest_dir)
        
    print(f"Copying add-in from {source_dir} to {dest_dir}...")
    shutil.copytree(source_dir, dest_dir)
    print("\nInstall complete! Please restart Fusion 360 or go to Scripts and Add-Ins (Shift+S) to enable ToolWizFusionAddin.")

if __name__ == '__main__':
    install_addin()
