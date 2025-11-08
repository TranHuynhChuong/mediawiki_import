# `run.py` — Script hỗ trợ chuyển đổi và import tài liệu vào Wikimedia

## Giới thiệu

`run.py` là **chương trình điều khiển dòng lệnh (CLI)** phục vụ cho việc:

* **Chuyển đổi** các file Word (`.docx`) trong một thư mục sang định dạng **Wikitext**.
* **Nhập (import)** nội dung đã chuyển đổi trực tiếp lên một trang **MediaWiki** thông qua API.

Chương trình được viết bằng **Python**, hoạt động như phần điều phối (entry point) cho các module trong thư mục `utils/`, bao gồm:

* `export_to_wikitext()` — xử lý chuyển đổi file `.docx` sang wikitext.
* `download_exported_files()` — đóng gói và cung cấp file kết quả (zip + danh sách file).
* `import_to_wiki()` — gửi dữ liệu đến MediaWiki qua API, tạo hoặc cập nhật trang.

---

## ⚙️ Cấu trúc

```
mediawiki-import_python/
│
├── run.py                       # Script điều khiển chính
├── utils.py                     # Hàm tiện ích: chuyển đổi nội dung, gửi dữ liệu đến MediaWiki API
└── requirements.txt             # Danh sách thư viện cần cài
```

---

## Cách sử dụng

### 1️⃣ Xuất file `.docx` sang định dạng Wikitext

```bash
python run.py export <docs_dir>
```

**Tham số:**

* `<docs_dir>`: đường dẫn đến thư mục chứa các file `.docx`.

**Kết quả:**

* Tất cả file `.docx` được chuyển thành `.txt` định dạng **Wikitext**.
* Một file `.zip` chứa toàn bộ nội dung đã chuyển đổi được tạo ra.
* Dữ liệu JSON được in ra **stdout**, ví dụ:

```json
{
  "exported_count": 3,
  "files": ["Cây Chôm Chôm.txt", "Cây Bưởi.txt", "Giống ĐT22.txt"],
  "zip": "exports/exported_wikitext.zip"
}
```

---

### 2️⃣ Import trực tiếp lên MediaWiki

```bash
python run.py import <docs_dir> <api_url> <username> <password> [overwrite]
```

**Tham số:**

| Tên           | Bắt buộc | Mô tả                                                         |
| ------------- | -------- | ------------------------------------------------------------- |
| `<docs_dir>`  | ✅        | Thư mục chứa file `.docx` cần import                          |
| `<api_url>`   | ✅        | URL API MediaWiki (ví dụ: `https://wiki.example.org/api.php`) |
| `<username>`  | ✅        | Tên tài khoản MediaWiki                                       |
| `<password>`  | ✅        | Mật khẩu MediaWiki                                            |
| `[overwrite]` | ❌        | `true` để ghi đè trang cũ (mặc định: `true`)                  |

**Ví dụ:**

```bash
python run.py import ./docs https://wiki.example.org/api.php username password true
```

**Kết quả JSON:**

```json
{
  "imported_count": 3,
  "results": [
    {"title": "Cây Chôm Chôm", "status": "created"},
    {"title": "Cây Bưởi", "status": "updated"},
    {"title": "Giống ĐT22", "status": "created"}
  ]
}
```

---

## Ghi chú kỹ thuật

* Script đảm bảo **encoding UTF-8** cho toàn bộ `stdout` và `stderr` để tránh lỗi ký tự Unicode.
* Mọi đầu ra đều được in dưới dạng **JSON**, giúp dễ dàng tích hợp với giao diện hoặc ứng dụng khác.
* Khi thực thi lệnh `import`, chương trình sẽ:

  1. Gọi `export_to_wikitext()` để tạo nội dung wikitext.
  2. Xác thực tài khoản Wiki qua API.
  3. Kiểm tra quyền `edit` và `createpage`.
  4. Gửi yêu cầu tạo/cập nhật trang.

---

## Cài đặt môi trường

1. Cài Python 3.8+
2. Cài các thư viện cần thiết:

   ```bash
   pip install -r requirements.txt
   ```
3. Chạy thử lệnh:

   ```bash
   python run.py export ./docs
   ```

---

## Build file .exe với PyInstaller

Bạn có thể đóng gói toàn bộ script thành một file chạy duy nhất (.exe) để sử dụng mà không cần cài Python.

🔹 Cài đặt PyInstaller
```bash
pip install pyinstaller
```
🔹 Lệnh build cơ bản
```bash
pyinstaller --onefile run.py
```
Kết quả sau khi build:

dist/run.exe
🔹 Build có tên tùy chỉnh
```bash
pyinstaller --onefile --name mediawiki_import run.py
```
→ Tạo file: dist/mediawiki_import.exe

Ẩn cửa sổ console (tùy chọn)

Nếu không muốn hiển thị console khi chạy:
```bash
pyinstaller --onefile --noconsole --name mediawiki_import run.py
```
⚠️ Khi bật --noconsole, các lệnh print() sẽ không hiển thị — chỉ nên dùng nếu chương trình được gọi từ app khác (như Flutter).


🔹 Giữ nguyên hỗ trợ tiếng Việt

File run.py đã được cấu hình UTF-8:

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

Vì vậy, không cần chỉnh sửa thêm — xuất tiếng Việt bình thường khi chạy file .exe.

---

## Lưu ý bảo mật

* Không chia sẻ thông tin đăng nhập Wiki công khai.
* Nếu dùng trong môi trường sản xuất, nên cấu hình xác thực qua **bot password** hoặc **token** thay vì mật khẩu trực tiếp.

---


**Tác giả:** Chương Chương
**Phiên bản:** 1.0.0
