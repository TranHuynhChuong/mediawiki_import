# Dự án Hỗ trợ nhập liệu Mediawiki (Dự án WikiCrop)

## Giới thiệu

**Dự án Hỗ trợ nhập liệu Mediawiki** là một công cụ tự động hóa quy trình **chuyển đổi và nhập nội dung tài liệu Word (.docx)** vào hệ thống **MediaWiki**.
Ứng dụng hỗ trợ người dùng biên tập và cập nhật dữ liệu nhanh chóng thông qua giao diện đồ họa (Flutter) và xử lý logic nền bằng Python.

Mục tiêu của dự án:

* Giảm thiểu thao tác thủ công khi đăng nội dung lên Wiki.
* Tự động chuyển đổi file `.docx` thành nội dung định dạng **Wikitext**.
* Hỗ trợ **kiểm tra tài khoản**, **import dữ liệu trực tiếp lên Wiki**, hoặc **xuất file zip** chứa dữ liệu để tải lên thủ công.

---

## Cấu trúc thư mục dự án

```
wikimedia-import/
│
├── mediawiki-import_exe/
│   ├── mediawiki_import.exe          # Ứng dụng chính đã build hoàn chỉnh (chạy trực tiếp)
│   ├── ...                           # Các file/bibli thư viện kèm theo
│   └── README.txt                    # Hướng dẫn sử dụng bản chạy (nếu có)
│
├── mediawiki_import_flutter/
│   ├── lib/                          # Mã nguồn Flutter phần giao diện
│   ├── pubspec.yaml                  # Cấu hình dependencies
│   └── README.md                     # Hướng dẫn phát triển frontend (Flutter)
│
└── mediawiki-import_python/
    ├── run.py                       # Mã nguồn Python chính xử lý logic
    ├── utils                         # Các module hỗ trợ xử lý
    ├── requirements.txt              # Danh sách thư viện Python
    └── README.md                     # Hướng dẫn phát triển backend (Python)
```

---

## Thành phần hệ thống

### 1. `mediawiki_import.exe` – Ứng dụng chính

* Là **phiên bản build hoàn chỉnh** từ phần code Python và Flutter.
* Có thể chạy độc lập, không cần cài đặt môi trường lập trình.
* Giao diện thân thiện, hỗ trợ:

  * Nhập đường dẫn thư mục chứa file `.docx`.
  * Tự động chuyển đổi nội dung sang **Wikitext**.
  * Đăng nhập tài khoản Wiki.
  * Kiểm tra quyền người dùng (`edit` và `createpage` bắt buộc để có thể tạo trang).
  * Chọn giữa **nhập trực tiếp lên Wiki** hoặc **xuất file zip** kết quả.

### 🧩 2. `mediawiki_import_flutter` – Phần giao diện (Frontend)

* Xây dựng bằng **Flutter** (hiện hỗ trợ **desktop Windows**).
* Kết hợp với Python thông qua gọi exe.
* Cung cấp UI để người dùng:

  * Nhập thông tin tài khoản Wiki.
  * Quản lý danh sách file `.docx`.
  * Theo dõi tiến trình chuyển đổi và import.

### 🐍 3. `mediawiki-import_python` – Phần xử lý logic

* Viết bằng **Python**, đảm nhiệm toàn bộ xử lý nền:

  * Đọc và phân tích file `.docx`.
  * Chuyển đổi nội dung sang định dạng **Wikitext**.
  * Gọi API MediaWiki để tạo hoặc cập nhật trang.
  * Kiểm tra quyền truy cập và xác thực tài khoản.
* Có thể chạy độc lập: Xem chi tiết trong `README.me` của `mediawiki-import_python`

---

## 🔐 Yêu cầu tài khoản

Để **import nội dung trực tiếp lên Wiki**, tài khoản cần có:

* Quyền **edit** – chỉnh sửa nội dung trang hiện có.
* Quyền **createpage** – tạo trang mới.

Yêu cầu **kiểm tra thông tin và quyền tài khoản** trước khi cho phép import.
Nếu không đủ quyền, người dùng vẫn có thể chọn **xuất file zip** thay thế.

---

## 🚀 Cách sử dụng nhanh

### 🔧 Cách 1: Chạy ứng dụng đã build

1. Mở thư mục `mediawiki-import_exe/`.
2. Chạy file `mediawiki_import.exe`.
3. Nhập thông tin tài khoản và đường dẫn thư mục chứa file `.docx`.
4. Chọn chế độ:

   * **Import trực tiếp** lên Wiki.
   * **Tải về file zip** (định dạng Wikitext).

### 🧠 Cách 2: Chạy từ mã nguồn

Nếu muốn phát triển hoặc chỉnh sửa:

1. Clone repo
2. Cài môi trường Python:

   ```bash
   cd mediawiki-import_python
   pip install -r requirements.txt
   python main.py
   ```
3. Chạy giao diện Flutter (chỉ Windows):

   ```bash
   cd ../mediawiki_import_flutter
   flutter run -d windows
   ```

---

## Ghi chú

* Người dùng có trách nhiệm đảm bảo tài khoản Wiki của mình hợp lệ và được cấp quyền chỉnh sửa/truy cập cần thiết.

---

## Tác giả & Liên hệ

**Tác giả:** Chương Chương
**Phiên bản hiện tại:** v1.0.0 (build đầu tiên – chỉ hỗ trợ Windows Desktop, chỉ hỗ trợ import và xuất file định dạng wikitext với docx với các định dạng cơ bản)

---

> *Dự án được xây dựng nhằm hỗ trợ quá trình nhập liệu và bảo tồn nội dung mở trên nền tảng Wikimedia một cách hiệu quả, chính xác và thân thiện với người dùng.*
