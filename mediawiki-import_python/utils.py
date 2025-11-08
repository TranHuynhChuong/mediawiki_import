import os
from pathlib import Path
import unicodedata
import requests
import pypandoc
import shutil
import zipfile
from datetime import datetime
import re


# --- Authentication ---
def login(session, api_url, username, password):
    """Log in to MediaWiki and return an authenticated session."""
    resp = session.get(api_url, params={
        "action": "query",
        "meta": "tokens",
        "type": "login",
        "format": "json"
    }).json()
    login_token = resp["query"]["tokens"]["logintoken"]

    resp = session.post(api_url, data={
        "action": "login",
        "lgname": username,
        "lgpassword": password,
        "lgtoken": login_token,
        "format": "json"
    }).json()

    if resp.get("login", {}).get("result") != "Success":
        raise Exception(f"Login failed: {resp}")
    return session

def get_csrf_token(session, api_url):
    """Get CSRF token for editing pages."""
    resp = session.get(api_url, params={
        "action": "query",
        "meta": "tokens",
        "format": "json"
    }).json()
    return resp["query"]["tokens"]["csrftoken"]

# --- Conversion ---
def docx_to_wikitext(file_path):
    """Convert .docx file to MediaWiki wikitext using pypandoc."""
    try:
        return pypandoc.convert_file(file_path, to='mediawiki', format='docx')
    except Exception:
        return None

def export_to_wikitext(docs_dir: str):
    """
    Read all .docx files in a folder and convert them to Wikitext.
    Returns a list of dicts for Flutter usage.
    """
    results = []
    if not os.path.exists(docs_dir):
        return results

    for root, _, files in os.walk(docs_dir):
        for filename in files:
            if not filename.lower().endswith('.docx'):
                continue
            file_path = os.path.join(root, filename)
            title = os.path.splitext(filename)[0]
            wikitext = docx_to_wikitext(file_path)
            results.append({
                "path": file_path,
                "title": title,
                "wikitext": wikitext
            })
    return results

def get_downloads_folder():
    """Return the default Downloads folder of the system (Windows/Mac/Linux)."""
    home = Path.home()
    downloads = home / "Downloads"
    return str(downloads)


def download_exported_files(results):
    """
    Save the exported wikitext list as .txt files and compress into a ZIP.
    
    Returns:
        dict: {'zip_path': path to ZIP, 'files': list of saved files}
    """
    if not results:
        return {"zip_path": None, "files": []}

    base_download_dir = get_downloads_folder()

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    export_dir = os.path.join(base_download_dir, f"wiki_export_{timestamp}")
    os.makedirs(export_dir, exist_ok=True)

    saved_files = []

    for item in results:
        title = item["title"]
        content = item.get("wikitext", "")
        safe_title = title.replace("/", "_").replace("\\", "_")
        save_path = os.path.join(export_dir, f"{safe_title}.txt")
        with open(save_path, "w", encoding="utf-8") as f:
            f.write(content if content else "")
        saved_files.append(save_path)

    zip_path = os.path.join(base_download_dir, f"wiki_export_{timestamp}.zip")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(export_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, export_dir)
                zipf.write(file_path, arcname)

    shutil.rmtree(export_dir)  # Delete temporary folder

    return {"zip_path": zip_path, "files": saved_files}


def solve_captcha(question: str) -> str:
    """Solve a simple math CAPTCHA like '85+7' or '63−9' and return the result."""
    # Replace Unicode minus with ASCII -
    question = question.replace("−", "-")
    match = re.match(r"(\d+)\s*([\+\-])\s*(\d+)", question)
    if not match:
       raise ValueError(f"Cannot solve CAPTCHA: {question}")
    a, op, b = match.groups()
    a, b = int(a), int(b)
    return str(a + b if op == "+" else a - b)


# # --- MediaWiki API ---
def create_page(session, csrf_token, api_url, title, content, overwrite=True):
    """
    Create or update a MediaWiki page.
    Returns a status string: "✅ Created", "🔄 Updated", or "⚠️ Unknown/Error".
    """

    title = unicodedata.normalize('NFC', title)
    content = unicodedata.normalize('NFC', content)

    data = {
        "action": "edit",
        "title": title,
        "text": content,
        "token": csrf_token,
        "format": "json",
    }
    if not overwrite:
        data["createonly"] = True

    resp = session.post(api_url, data=data).json()

    if "edit" in resp and "captcha" in resp["edit"]:
        captcha = resp["edit"]["captcha"]
        captcha_answer = solve_captcha(captcha["question"])
        data["captchaid"] = captcha["id"]
        data["captchaword"] = captcha_answer

        # Send edit request with captcha
        resp = session.post(api_url, data=data).json()

    # Handle edit result
    if "error" in resp:
        return f"⚠️ Error: {resp['error'].get('info', 'Unknown')}"

    edit_result = resp.get("edit", {}).get("result")
    if edit_result == "Success":
        # If "new" key exists in resp["edit"] => new page
        return "✅ Created" if "new" in resp.get("edit", {}) else "🔄 Updated"
    return "⚠️ Unknown"


def import_to_wiki(results, api_url, username, password, overwrite_existing=True):
    """ 
    Upload each page from the export_to_wikitext results list. 
    Returns a JSON list. 
    """
    session = requests.Session()
    session = login(session, api_url, username, password)
    csrf_token = get_csrf_token(session, api_url)

    imported_results = []
    for idx, item in enumerate(results, start=1):
        title = item["title"]
        content = item.get("wikitext") or ""
        status = create_page(session, csrf_token, api_url, title, content, overwrite_existing)
        imported_results.append({
            "index": idx,
            "title": title,
            "status": status
        })

    return imported_results
