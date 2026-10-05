# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Bộ công cụ thiết lập môi trường PRoot Distro tự động dành cho việc xây dựng và VibeCoding mod Stardew Valley chạy trên Cinderbox Android. Thiết kế đơn giản hóa tối đa cho người chưa từng lập trình.

---

## 1. Giới thiệu

Bộ công cụ này giúp người dùng Android tự tạo mod C# SMAPI cho Stardew Valley 1.6 chạy trên Cinderbox mà không cần máy tính PC, không cần quyền Root và không cần kiến thức lập trình chuyên sâu.

Đặc biệt, hệ thống tối ưu cho phương pháp **VibeCoding** với sự hỗ trợ của trợ lý AI **OpenCode CLI** (hoàn toàn miễn phí, tự động sửa code và kiểm tra build ngay trong terminal) hoặc các mô hình web như ChatGPT, Claude, Gemini.

### Đặc điểm chính:
- Thao tác 1 bước: Tự động hóa toàn bộ quá trình cài đặt môi trường trên Termux.
- Không gian làm việc chuẩn Sudo User: Tự động tạo người dùng sudo riêng và đặt workspace tại `~/stardew-workspace` (`/home/<user>/stardew-workspace`), tránh hoàn toàn các lỗi xung đột file hoặc quyền sở hữu root.
- Tích hợp OpenCode CLI: Hỗ trợ cài đặt trợ lý AI miễn phí để ra lệnh tạo mod trực tiếp bằng tiếng Việt ngay trong dòng lệnh.
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

Trong quá trình chạy:
1. Khi có hộp thoại Android yêu cầu quyền bộ nhớ: Chọn "Cho phép" (Allow).
2. Khi hệ thống hỏi thiết lập người dùng: Nhập tên tài khoản của bạn (ví dụ: `stardew`) và chọn có muốn cài đặt OpenCode AI CLI hay không.

---

## 3. Cách sử dụng

Sau khi cài đặt xong, mỗi khi muốn bắt đầu làm việc, bạn mở Termux và gõ:

```bash
stardew-code
```

Lệnh này sẽ tự động đưa bạn vào môi trường Ubuntu với tư cách tài khoản người dùng của bạn tại thư mục `~/stardew-workspace`.

### Các lệnh quản lý:

| Lệnh | Chức năng |
| :--- | :--- |
| `stardew-mod` | Mở menu tương tác trực quan để chọn thao tác |
| `stardew-mod doctor` | Kiểm tra kết nối thư mục game Cinderbox và các file thư viện SMAPI |
| `stardew-mod new <TenMod>` | Tạo một dự án mod mới từ khung mẫu chuẩn |
| `stardew-mod build` | Biên dịch mã nguồn C# thành file thư viện `.dll` |
| `stardew-mod deploy` | Tự động chép file mod đã biên dịch vào thư mục `Mods/` của game |
| `opencode` | Mở trợ lý AI OpenCode để VibeCoding trực tiếp |

---

## 4. Quy trình VibeCoding tạo mod cùng AI

### Cách 1: Dùng OpenCode CLI (Tự động & Miễn phí - Khuyên dùng)
1. Tạo mod mới:
   ```bash
   stardew-mod new SieuNongDan
   cd mods/SieuNongDan
   ```
2. Khởi động AI:
   ```bash
   opencode
   ```
3. Nhập yêu cầu bằng tiếng Việt:
   > "Đọc file ../../VIBECODE_PROMPT_TEMPLATE.md và giúp tôi thêm tính năng tăng 20% tốc độ chạy khi ở ngoài trời vào ModEntry.cs, sau đó chạy stardew-mod build để kiểm tra."
4. Triển khai vào game:
   ```bash
   stardew-mod deploy
   ```

### Cách 2: Dùng Web AI (ChatGPT, Claude, Gemini)
1. Tạo mod mới bằng `stardew-mod new <TenMod>`.
2. Sao chép nội dung `VIBECODE_PROMPT_TEMPLATE.md` kèm ý tưởng gửi cho Web AI.
3. Dán code AI tạo vào `ModEntry.cs` và chạy `stardew-mod build` rồi `stardew-mod deploy`.

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
│   ├── init-user.sh               # Khởi tạo user sudo và cài OpenCode
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
