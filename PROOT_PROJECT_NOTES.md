# TỔNG QUAN KIẾN TRÚC: STARDEW VIBECODING TRÊN ANDROID (PROOT)

Tài liệu kỹ thuật tóm tắt kiến trúc môi trường phát triển mod C# SMAPI Stardew Valley 1.6 trên hệ điều hành Android.

---

## 1. MỤC TIÊU KIẾN TRÚC
- Cho phép lập trình và biên dịch mod C# SMAPI 1.6 (.NET 10.0 aarch64) trực tiếp trên điện thoại Android mà không yêu cầu quyền Root hay giải pháp máy ảo nặng.
- Thiết lập tự động qua một dòng lệnh duy nhất.
- Hỗ trợ các công cụ AI Coding Agent (OpenCode, Antigravity, Claude, Codex, Hermes).
- Liên kết trực tiếp bộ nhớ thiết bị `/sdcard` để đồng bộ game files và thư mục `Mods/`.

---

## 2. CẤU TRÚC CÁC PHÂN LỚP HỆ THỐNG
1. **Lớp Nền tảng (Host):**
   - Ứng dụng Termux chạy trên Android OS.
2. **Lớp Ảo hóa Không Gian Người Dùng (User-space Virtualization):**
   - `proot-distro` chạy Ubuntu 24.04 LTS (aarch64) với thư viện C chuẩn (`glibc`).
3. **Cơ chế Liên kết Bộ nhớ (Storage Bindings):**
   - Cấu hình `$PREFIX/etc/proot-distro/ubuntu.override.conf` gắn kết `/sdcard:/sdcard`.
   - Đường dẫn thư mục game: `/sdcard/StardewValley/`.
   - Đường dẫn thư mục mod cài đặt: `/sdcard/StardewValley/desktop/Mods/`.
4. **Bộ công cụ Biên dịch (.NET SDK):**
   - .NET 10.0 SDK được cài đặt tại `/opt/dotnet`, liên kết lệnh toàn cục vào `/usr/local/bin/dotnet`.
   - Cấu hình `DOTNET_GCHeapHardLimit=20000000` để ngăn ngừa lỗi tràn RAM ảo trong môi trường PRoot.
5. **Bộ lệnh Hỗ trợ (`stardew-mod` CLI):**
   - Đặt tại `/usr/local/bin/stardew-mod` để người dùng và AI Agent có thể gọi trực tiếp bất kỳ lúc nào.

---

## 3. CẤU TRÚC WORKSPACE NGƯỜI DÙNG (`~/stardew-workspace`)
- `mods/`: Nơi chứa mã nguồn các dự án mod do người dùng và AI phát triển.
- `templates/`: Thư mục chứa template starter-mod chuẩn net10.0.
- `lib/`: Thư mục dự phòng cho các thư viện bổ sung.
- `game` -> Liên kết tượng trưng đến `/sdcard/StardewValley`.
- `installed-mods` -> Liên kết tượng trưng đến `/sdcard/StardewValley/desktop/Mods`.
- `AGENTS.md`: Tệp chỉ dẫn kỹ thuật duy nhất dành cho AI Agent.
- `VIBECODE_PROMPT_TEMPLATE.md`: Tệp cẩm nang hướng dẫn cách viết prompt dành cho người dùng.
