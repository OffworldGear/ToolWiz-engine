import os
import json
import glob
import time
import re
from datetime import datetime

class BackupManager:
    def __init__(self, base_dir=None, max_backups=15):
        if base_dir is None:
            base_dir = os.path.dirname(os.path.abspath(__file__))
        self.base_dir = base_dir
        self.data_dir = os.path.join(base_dir, "data")
        self.backups_dir = os.path.join(base_dir, "backups")
        self.max_backups = max_backups
        
        os.makedirs(self.data_dir, exist_ok=True)
        os.makedirs(self.backups_dir, exist_ok=True)
        
    def get_working_library_path(self):
        return os.path.join(self.data_dir, "working_library.json")
        
    def save_working_library(self, library_data, library_name="Default_Library"):
        """Saves data to data/working_library.json atomically and creates a timestamped backup."""
        working_path = self.get_working_library_path()
        
        # Ensure library_data has metadata
        if isinstance(library_data, dict):
            if "library_name" not in library_data:
                library_data["library_name"] = library_name
            library_data["last_modified"] = datetime.now().isoformat()
            
        tmp_working_path = f"{working_path}.tmp.{os.getpid()}"
        with open(tmp_working_path, "w", encoding="utf-8") as f:
            json.dump(library_data, f, indent=2)
        os.replace(tmp_working_path, working_path)
            
        # Create timestamped versioned backup
        backup_info = self.create_backup(library_name, library_data)
        return backup_info
        
    def load_working_library(self):
        """Loads the active working library JSON."""
        working_path = self.get_working_library_path()
        if not os.path.exists(working_path):
            return None
        with open(working_path, "r", encoding="utf-8") as f:
            return json.load(f)
            
    def create_backup(self, library_name, library_data):
        """Creates an immutable timestamped backup file atomically."""
        clean_name = "".join(c for c in library_name if c.isalnum() or c in ('_', '-')).strip()
        if not clean_name:
            clean_name = "Library"
            
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Determine existing backup count for versioning using strict regex matching
        pattern = re.compile(rf"^{re.escape(clean_name)}_\d{{8}}_\d{{6}}(?:_\d+)?_v\d+\.json$")
        existing = [f for f in os.listdir(self.backups_dir) if pattern.match(f)]
        version = len(existing) + 1
        
        filename = f"{clean_name}_{timestamp}_v{version}.json"
        filepath = os.path.join(self.backups_dir, filename)
        if os.path.exists(filepath):
            counter = 1
            while os.path.exists(filepath):
                filename = f"{clean_name}_{timestamp}_{counter}_v{version}.json"
                filepath = os.path.join(self.backups_dir, filename)
                counter += 1
        
        tmp_filepath = f"{filepath}.tmp.{os.getpid()}"
        with open(tmp_filepath, "w", encoding="utf-8") as f:
            json.dump(library_data, f, indent=2)
        os.replace(tmp_filepath, filepath)
            
        self._prune_old_backups(clean_name)
        
        return {
            "filename": filename,
            "version": version,
            "timestamp": timestamp,
            "path": filepath
        }
        
    def list_backups(self):
        """Lists all available backups ordered from newest to oldest."""
        files = glob.glob(os.path.join(self.backups_dir, "*.json"))
        backups = []
        
        for f in sorted(files, key=os.path.getmtime, reverse=True):
            try:
                stat = os.stat(f)
                mtime = datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S")
                with open(f, "r", encoding="utf-8") as fp:
                    data = json.load(fp)
                    tool_count = len(data.get("tools", [])) if isinstance(data, dict) else len(data) if isinstance(data, list) else 0
                    lib_name = data.get("library_name", os.path.basename(f)) if isinstance(data, dict) else os.path.basename(f)
                    
                backups.append({
                    "filename": os.path.basename(f),
                    "library_name": lib_name,
                    "timestamp": mtime,
                    "size_kb": round(stat.st_size / 1024, 1),
                    "tool_count": tool_count
                })
            except Exception:
                continue
                
        return backups
        
    def restore_backup(self, filename):
        """Restores a selected backup file into data/working_library.json atomically."""
        target_path = os.path.join(self.backups_dir, os.path.basename(filename))
        if not os.path.exists(target_path):
            raise FileNotFoundError(f"Backup file not found: {filename}")
            
        with open(target_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            
        working_path = self.get_working_library_path()
        tmp_working_path = f"{working_path}.tmp.{os.getpid()}"
        with open(tmp_working_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
        os.replace(tmp_working_path, working_path)
            
        return data
        
    def _prune_old_backups(self, prefix):
        """Keeps only the newest max_backups for a given library prefix."""
        pattern = re.compile(rf"^{re.escape(prefix)}_\d{{8}}_\d{{6}}(?:_\d+)?_v\d+\.json$")
        matched_files = [
            os.path.join(self.backups_dir, f)
            for f in os.listdir(self.backups_dir)
            if pattern.match(f)
        ]
        files_sorted = sorted(matched_files, key=os.path.getmtime)
        while len(files_sorted) > self.max_backups:
            oldest = files_sorted.pop(0)
            try:
                os.remove(oldest)
            except OSError:
                pass

if __name__ == "__main__":
    bm = BackupManager()
    dummy = {"library_name": "TestHubLib", "tools": [{"id": 1, "desc": "1/4 Endmill"}]}
    res = bm.save_working_library(dummy, "TestHubLib")
    print("Backup created:", res)
    print("Available backups:", bm.list_backups())
