# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Bộ công cụ thiết lập môi trường PRoot Distro tự động dành cho việc xây dựng và VibeCoding mod Stardew Valley chạy trên Cinderbox Android. Thiết kế đơn giản hóa tối đa cho người chưa từng lập trình.

---

## 1. Giới thiệu

Bộ công cụ này giúp người dùng Android tự tạo mod C# SMAPI cho Stardew Valley 1.6 chạy trên Cinderbox mà không cần máy tính PC, không cần quyền Root và không cần kiến thức lập trình chuyên sâu.

Nhờ cơ chế VibeCoding, bạn chỉ cần mô tả ý tưởng tính năng bằng tiếng Việt thông thường, các mô hình AI (ChatGPT, Claude, Gemini, DeepSeek) sẽ sinh toàn bộ mã nguồn theo đúng chuẩn kỹ thuật của Android Cinderbox.

### Đặc điểm chính:
- Thao tác 1 bước: Tự động hóa toàn bộ quá trình cài đặt môi trường trên Termux.
- Không cần Root: Chạy hoàn toàn trong không gian người dùng thông qua PRoot Distro (Ubuntu aarch64).
- Liên kết bộ nhớ trực tiếp: Tự động mount thư mục `/sdcard` của Android vào container, cho phép xem và sửa file bằng các ứng dụng quản lý tệp quen thuộc (MT Manager, ZArchiver, Acode).
- Tương thích .NET 10.0: Cài đặt .NET 10.0 SDK chính thức từ Microsoft, giải quyết triệt để lỗi bionic libc và lỗi xung đột assembly CS1705 với SMAPI Cinderbox.
- Công cụ stardew-mod: Quản lý kiểm tra lỗi, tạo mod, biên dịch và triển khai vào game qua giao diện dòng lệnh đơn giản.
- Khung mẫu prompt chuẩn: Đi kèm template chỉ dẫn dành cho AI để tránh lỗi phiên bản và hỗ trợ đúng cơ chế cảm ứng di động.

---

## 2. Hướng dẫn cài đặt

Mở ứng dụng Termux và chạy dòng lệnh sau:

```bash
pkg install -y git && git clone https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git && cd stardew-proot-vibecoding && bash install.sh
```

Khi hệ thống hiển thị thông báo yêu cầu cấp quyền truy cập bộ nhớ, chọn "Cho phép" (Allow).

---

## 3. Cách sử dụng

Sau khi cài đặt xong, mỗi khi muốn bắt đầu làm việc, bạn mở Termux và gõ:

```bash
stardew-code
```

Lệnh này sẽ đưa bạn vào môi trường Ubuntu với thư mục làm việc `/root/stardew-workspace`.

### Các lệnh quản lý:

| Lệnh | Chức năng |
| :--- | :--- |
| `stardew-mod` | Mở menu tương tác trực quan để chọn thao tác |
| `stardew-mod doctor` | Kiểm tra kết nối thư mục game Cinderbox và các file thư viện SMAPI |
| `stardew-mod new <TenMod>` | Tạo một dự án mod mới từ khung mẫu chuẩn |
| `stardew-mod build` | Biên dịch mã nguồn C# thành file thư viện `.dll` |
| `stardew-mod deploy` | Tự động chép file mod đã biên dịch vào thư mục `Mods/` của game |

---

## 4. Quy trình VibeCoding tạo mod cùng AI

1. Khởi tạo mod mới:
   ```bash
   stardew-mod new NongDanVuiVe
   cd mods/NongDanVuiVe
   ```
2. Chuẩn bị prompt cho AI:
   Sao chép nội dung trong file `VIBECODE_PROMPT_TEMPLATE.md`, bổ sung ý tưởng tính năng mong muốn và gửi cho AI (ChatGPT, Claude, Gemini).
3. Cập nhật mã nguồn:
   Lấy đoạn code C# do AI tạo ra và dán vào file `ModEntry.cs` (bằng trình biên tập `nano ModEntry.cs` hoặc ứng dụng chỉnh sửa văn bản trên Android).
4. Biên dịch và triển khai:
   ```bash
   stardew-mod build
   stardew-mod deploy
   ```
5. Mở game Stardew Valley trên Cinderbox để kiểm tra tính năng.

---

## 5. Tài liệu hướng dẫn chuyên sâu

- `docs/01-chuan-bi-va-cai-dat.md`: Hướng dẫn cài Termux và cấu hình ban đầu.
- `docs/02-cau-truc-cinderbox.md`: Bản đồ thư mục game và vị trí các file hệ thống.
- `docs/03-bi-kip-vibecoding.md`: Kỹ thuật mô tả yêu cầu cho AI và cách khắc phục lỗi code.
- `docs/04-cac-loi-thuong-gap.md`: Danh mục các lỗi phổ biến (CS1705, thiếu DLL, bàn phím ảo, cảm ứng).

---

## 6. Cấu trúc thư mục

```
stardew-proot-vibecoding/
├── install.sh                     # Kịch bản cài đặt ban đầu trên Termux host
├── README.md                      # Tài liệu tổng quan dự án
├── VIBECODE_PROMPT_TEMPLATE.md    # Khung mẫu chỉ dẫn dành cho AI
├── docs/                          # Hệ thống tài liệu chi tiết
│   ├── 01-chuan-bi-va-cai-dat.md
│   ├── 02-cau-truc-cinderbox.md
│   ├── 03-bi-kip-vibecoding.md
│   └── 04-cac-loi-thuong-gap.md
├── scripts/
│   ├── ui.sh                      # Thư viện giao diện dòng lệnh TUI
│   ├── setup-proot.sh             # Cấu hình bên trong container Ubuntu
│   └── stardew-mod.sh             # Bộ công cụ dòng lệnh quản lý mod
└── templates/
    └── starter-mod/               # Dự án mẫu SMAPI 1.6 net10.0
        ├── StarterMod.csproj
        ├── manifest.json
        ├── ModEntry.cs
        ├── deploy.sh
        └── .gitignore
```

---

## 7. Giấy phép

Dự án được phân phối dưới giấy phép MIT License.
