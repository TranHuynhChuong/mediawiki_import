# mediawiki_import_flutter

Ứng dụng Flutter hỗ trợ giao diện nhập liệu và import nội dung lên **MediaWiki**, sử dụng cho dự án “WikiCrop - Mediawiki”.

---

## Giới thiệu

Ứng dụng này cung cấp giao diện đồ họa (GUI) cho người dùng để:

* Chọn và chuyển đổi các file `.docx` thành định dạng **Wikitext (.txt)**.
* Tải nội dung dạng `.zip` hoặc import trực tiếp lên MediaWiki.
* Kiểm tra và xác thực tài khoản có quyền **edit** và **createpage** trước khi cho phép import.

Ứng dụng hiện tại **chỉ hỗ trợ Desktop (Windows)**.

---

## Cấu hình khi build

Khi build Flutter, cần **sao chép thư mục `python` (Thư mục chứa file `run.exe` bản build của mediawiki-import_python)** vào cạnh file `.exe` của Flutter build.
Cụ thể:

**Sau khi build xong, copy:**

```
python/
   └── run.exe     # Bản build của mediawiki-import_python
```

vào:

```
\build\windows\x64\runner\Release\
```

---

## Chạy ứng dụng

### Chạy trong môi trường phát triển

Khi chạy local, cần chỉnh đường dẫn thực thi Python trong mã Flutter:

```dart
final exePath = '${Directory.current.path}\\python\\run.exe';
```

Hãy cập nhật lại thành đường dẫn thực tế nơi chứa file `run.exe` (hoặc `run.py` nếu chưa đóng gói).

---

## Build file Python thành .exe

Để đóng gói phần Python thành file thực thi duy nhất, dùng lệnh:

```bash
pyinstaller --onefile run.py
```

File `.exe` tạo ra sẽ nằm trong thư mục `dist/`.
Sau đó, đặt file `run.exe` này vào thư mục `python` bên cạnh file `.exe` của Flutter như hướng dẫn ở trên.

---

##  Gợi ý bảo mật

Nếu sử dụng trong môi trường thật, **không nên** lưu mật khẩu trực tiếp.
Thay vào đó, hãy cấu hình xác thực thông qua **bot password** hoặc **token** để đảm bảo an toàn cho tài khoản MediaWiki.

---

## Thông tin thêm

* Flutter: [https://docs.flutter.dev/](https://docs.flutter.dev/)
* MediaWiki API: [https://www.mediawiki.org/wiki/API:Main_page](https://www.mediawiki.org/wiki/API:Main_page)

---

 *Dự án này là một phần trong hệ thống hỗ trợ nhập liệu tự động cho MediaWiki, kết hợp giữa Flutter (giao diện), Python (xử lý chính), và MediaWiki API.*
