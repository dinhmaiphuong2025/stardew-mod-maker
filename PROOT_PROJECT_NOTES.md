# DỰ ÁN: PROOT-VIBECODING-STARDEW
> Bộ công cụ 1-click thiết lập môi trường VibeCoding làm mod Stardew Valley trên Android qua Termux + PRoot (không cần root hay Droidspaces).

---

## 1. MỤC TIÊU & TẦM NHÌN
- Giúp bất kỳ ai dùng Android bình thường có thể code mod Stardew Valley (C# / SMAPI) ngay trên điện thoại.
- Thiết lập hoàn toàn tự động bằng script 1-click (Zero-configuration cho người mới).
- Tích hợp sẵn AI Coding CLI miễn phí hỗ trợ Termux (như Antigravity CLI / OpenCode khi có giải pháp).
- Mount bộ nhớ trong trực tiếp `/sdcard:/sdcard` để thao tác file game và mod dễ dàng.

---

## 2. KIẾN TRÚC MÔI TRƯỜNG
- **Lớp Host:** Termux thuần (Android OS).
- **Lớp Ảo hóa:** `proot-distro` chạy Ubuntu 24.04/26.04 aarch64 (môi trường Linux glibc chuẩn).
- **Cơ chế Mount Storage:**
  - `bind_directories+=('/sdcard:/sdcard')` trong `$PREFIX/etc/proot-distro/ubuntu.override.conf`.
  - Đường dẫn GameFiles: `/sdcard/StardewValley/desktop/GameFiles`.
  - Đường dẫn Mods: `/sdcard/StardewValley/desktop/Mods`.
- **Compiler / SDK:** .NET 10.0 / .NET 8.0 SDK cài qua `dotnet-install.sh`.

---

## 3. CHECKLIST SCRIPT 1-CLICK (`setup.sh`)
- [ ] Chạy `termux-setup-storage` và đợi người dùng cấp quyền.
- [ ] Cài đặt gói Termux: `pkg install proot-distro git curl nodejs jq -y`.
- [ ] Cài Ubuntu: `proot-distro install ubuntu`.
- [ ] Ghi đè file override config để auto-mount `/sdcard`.
- [ ] Cài .NET SDK bên trong Ubuntu container.
- [ ] Cài Antigravity CLI hoặc CLI AI coding tương thích.
- [ ] Sinh thư mục dự án mod mẫu (Hello World SMAPI Mod) có sẵn `deploy.sh` tự copy DLL vào `/sdcard/StardewValley/desktop/Mods/`.

---

## 4. TÀI NGUYÊN & ĐƯỜNG DẪN THAM CHIẾU
- Repository dự án: Sẽ khởi tạo tại `~/termux-proot-vibecoding` hoặc repo GitHub riêng.
- Cấu trúc mod Stardew chuẩn: Tham khảo từ `~/stardew-lab/SaiyanPodTeleport`.
