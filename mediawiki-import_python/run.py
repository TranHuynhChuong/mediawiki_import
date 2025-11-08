import sys
import json
from utils import export_to_wikitext, download_exported_files, import_to_wiki
import io

# Ensure UTF-8 encoding for stdout/stderr
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def main():
    """
    Usage:
    python run.py export <docs_dir>
    python run.py import <docs_dir> <api_url> <username> <password> [overwrite]
    """
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Missing parameters"}))
        return

    action = sys.argv[1].lower()

    if action == "export":
        docs_dir = sys.argv[2]
        results = export_to_wikitext(docs_dir)
        download_info = download_exported_files(results)

        print(json.dumps({
            "exported_count": len(results),
            "files": download_info["files"],
            "zip": download_info["zip_path"]
        }, ensure_ascii=False))

    elif action == "import":
        if len(sys.argv) < 6:
            print(json.dumps({"error": "Missing parameters for import"}))
            return
        docs_dir = sys.argv[2]
        api_url = sys.argv[3]
        username = sys.argv[4]
        password = sys.argv[5]
        overwrite = True
        if len(sys.argv) >= 7:
            overwrite = sys.argv[6].lower() == "true"


        results = export_to_wikitext(docs_dir)
        imported_results = import_to_wiki(results, api_url, username, password, overwrite)
        print(json.dumps({
            "imported_count": len(imported_results),
            "results": imported_results
        }, ensure_ascii=False))

    else:
        print(json.dumps({"error": f"Invalid action: {action}"}))
    
if __name__ == "__main__":
    main()