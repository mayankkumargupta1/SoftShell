#!/usr/bin/env python3
import sys
import os
import time
import json
import shutil
import subprocess
from pathlib import Path

def format_size(bytes_val):
    if bytes_val < 1024:
        return f"{bytes_val} B"
    elif bytes_val < 1024 * 1024:
        return f"{bytes_val / 1024:.0f} KB"
    elif bytes_val < 1024 * 1024 * 1024:
        return f"{bytes_val / (1024 * 1024):.1f} MB"
    else:
        return f"{bytes_val / (1024 * 1024 * 1024):.1f} GB"

def format_relative_time(mtime):
    diff = int(time.time() - mtime)
    if diff < 60:
        return "Just now"
    elif diff < 3600:
        mins = diff // 60
        return f"{mins}m ago"
    elif diff < 86400:
        hours = diff // 3600
        return f"{hours}h ago"
    elif diff < 172800:
        return "Yesterday"
    else:
        days = diff // 86400
        if days < 30:
            return f"{days}d ago"
        months = days // 30
        return f"{months}mo ago"

def get_file_glyph(name, is_dir):
    if is_dir:
        return "󰉋"
    ext = Path(name).suffix.lower()
    if ext in ['.pdf']:
        return "󰈦"
    elif ext in ['.doc', '.docx', '.odt', '.rtf', '.txt', '.md']:
        return "󰈙"
    elif ext in ['.xls', '.xlsx', '.csv', '.tsv', '.ods']:
        return "󰈟"
    elif ext in ['.ppt', '.pptx', '.odp']:
        return "󰈧"
    elif ext in ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.svg', '.bmp', '.ico']:
        return "󰋩"
    elif ext in ['.mp3', '.flac', '.wav', '.ogg', '.m4a', '.aac', '.opus']:
        return "󰎆"
    elif ext in ['.mp4', '.mkv', '.avi', '.mov', '.webm', '.flv', '.wmv']:
        return "󰕧"
    elif ext in ['.zip', '.tar', '.gz', '.xz', '.bz2', '.7z', '.rar']:
        return "󰛫"
    elif ext in ['.apk', '.deb', '.rpm', '.iso', '.img']:
        return "󰀻"
    elif ext in ['.py', '.js', '.ts', '.qml', '.sh', '.c', '.cpp', '.rs', '.go', '.html', '.css', '.json']:
        return "󰅩"
    return "󰈔"

def get_folder_glyph(name):
    low = name.lower()
    if "home" in low:
        return "󰋜"
    elif "doc" in low:
        return "󰈙"
    elif "down" in low:
        return "󰉍"
    elif "pic" in low or "photo" in low or "image" in low:
        return "󰉏"
    elif "vid" in low or "movie" in low:
        return "󰉐"
    elif "music" in low or "audio" in low:
        return "󰉌"
    elif "desk" in low:
        return "󰇄"
    return "󰉋"

def cmd_status():
    home = Path.home()
    downloads_dir = home / "Downloads"

    # 1. Recent 5 downloads
    downloads = []
    if downloads_dir.exists():
        try:
            files = [f for f in downloads_dir.iterdir() if not f.name.startswith(".")]
            files.sort(key=lambda f: f.stat().st_mtime, reverse=True)
            for f in files[:5]:
                try:
                    st = f.stat()
                    is_dir = f.is_dir()
                    downloads.append({
                        "name": f.name,
                        "path": str(f.resolve()),
                        "isDir": is_dir,
                        "sizeStr": format_size(st.st_size) if not is_dir else "Folder",
                        "timeStr": format_relative_time(st.st_mtime),
                        "glyph": get_file_glyph(f.name, is_dir),
                        "ext": f.suffix.lower()
                    })
                except Exception:
                    pass
        except Exception:
            pass

    # 2. Bookmarked and standard places
    bookmarks = []
    seen_paths = set()
    gtk_bm = home / ".config" / "gtk-3.0" / "bookmarks"
    if gtk_bm.exists():
        try:
            for line in gtk_bm.read_text().splitlines():
                line = line.strip()
                if not line or not line.startswith("file://"):
                    continue
                parts = line.split(" ", 1)
                uri = parts[0]
                path = uri.replace("file://", "")
                name = parts[1] if len(parts) > 1 else Path(path).name
                if path not in seen_paths and os.path.exists(path):
                    seen_paths.add(path)
                    bookmarks.append({
                        "name": name,
                        "path": path,
                        "glyph": get_folder_glyph(name)
                    })
        except Exception:
            pass

    # Standard default places if not already added
    defaults = [
        ("Home", str(home)),
        ("Documents", str(home / "Documents")),
        ("Downloads", str(home / "Downloads")),
        ("Pictures", str(home / "Pictures")),
        ("Videos", str(home / "Videos")),
        ("Desktop", str(home / "Desktop")),
    ]
    for name, path in defaults:
        if path not in seen_paths and os.path.exists(path):
            seen_paths.add(path)
            bookmarks.append({
                "name": name,
                "path": path,
                "glyph": get_folder_glyph(name)
            })

    # 3. Trash status
    trash_files_dir = home / ".local" / "share" / "Trash" / "files"
    trash_count = 0
    if trash_files_dir.exists():
        try:
            trash_count = len(list(trash_files_dir.iterdir()))
        except Exception:
            pass

    # 4. Storage quick-stat (home filesystem)
    try:
        du = shutil.disk_usage(home)
        storage = {
            "used": format_size(du.used),
            "available": format_size(du.free),
        }
    except Exception:
        storage = {"used": "", "available": ""}

    print(json.dumps({
        "downloads": downloads,
        "bookmarks": bookmarks,
        "storage": storage,
        "trash": {
            "count": trash_count,
            "glyph": "󰩹" if trash_count > 0 else "󰩺",
            "text": f"{trash_count} items" if trash_count > 0 else "Empty",
            "path": "trash:///"
        }
    }))

def open_file_manager_folder(path):
    if shutil.which("nautilus"):
        subprocess.Popen(["nautilus", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    elif shutil.which("dolphin"):
        subprocess.Popen(["dolphin", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        subprocess.Popen(["xdg-open", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def reveal_in_file_manager(path):
    if shutil.which("nautilus"):
        subprocess.Popen(["nautilus", "--select", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    elif shutil.which("dolphin"):
        subprocess.Popen(["dolphin", "--select", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        open_file_manager_folder(str(Path(path).parent))

def open_file(path):
    subprocess.Popen(["xdg-open", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def empty_trash():
    if shutil.which("gio"):
        subprocess.run(["gio", "trash", "--empty"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    else:
        trash_files = Path.home() / ".local" / "share" / "Trash" / "files"
        trash_info = Path.home() / ".local" / "share" / "Trash" / "info"
        if trash_files.exists():
            shutil.rmtree(trash_files, ignore_errors=True)
            trash_files.mkdir(parents=True, exist_ok=True)
        if trash_info.exists():
            shutil.rmtree(trash_info, ignore_errors=True)
            trash_info.mkdir(parents=True, exist_ok=True)

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "status":
        cmd_status()
    elif sys.argv[1] == "open" and len(sys.argv) > 2:
        open_file(sys.argv[2])
    elif sys.argv[1] == "reveal" and len(sys.argv) > 2:
        reveal_in_file_manager(sys.argv[2])
    elif sys.argv[1] == "open-folder" and len(sys.argv) > 2:
        open_file_manager_folder(sys.argv[2])
    elif sys.argv[1] == "empty-trash":
        empty_trash()
    else:
        cmd_status()
