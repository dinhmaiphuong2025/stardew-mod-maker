# Hướng Dẫn 01: Chuẩn Bị Và Cài Đặt Môi Trường

Tài liệu này hướng dẫn thiết lập toàn bộ môi trường lập trình Mod Cinderbox trên điện thoại Android tiêu chuẩn (không cần quyền Root).

---

## 1. Cài đặt ứng dụng Termux

Lưu ý: Không tải Termux từ Google Play Store vì các bản trên Play Store đã ngừng cập nhật từ lâu và sẽ phát sinh lỗi khi cài đặt gói.

Các kênh tải chính thức:
- Bản Termux Custom: https://github.com/dinhmaiphuong2025/termux-app/releases (Khuyên dùng)
- GitHub Releases: https://github.com/termux/termux-app/releases (chọn bản arm64-v8a hoặc universal)
- F-Droid: https://f-droid.org/en/packages/com.termux/

Sau khi cài đặt xong, mở ứng dụng Termux.

---

## 2. Khởi chạy cài đặt 1-Lệnh duy nhất

Trên màn hình Termux, dán và chạy duy nhất dòng lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh | bash
```

Hệ thống sẽ hiển thị thanh tiến trình thanh thoát ở trên cùng kèm tốc độ mạng thực tế (`· X.X MB/s`), và tự động tích xanh lưu vết từng bước cài đặt bên dưới.

---

## 3. Các bước hệ thống xử lý tự động

Kịch bản `install.sh` sẽ lần lượt thực hiện các bước tự động:
1. `Kiểm tra quyền truy cập bộ nhớ thiết bị Android (/sdcard)`: Khi hộp thoại xuất hiện, chọn Cho phép (Allow).
2. `Cập nhật danh sách kho gói Termux (apt update)`.
3. `Cài đặt gói công cụ lõi Termux (proot-distro, git, curl, jq)`.
4. `Tải hệ điều hành PRoot Ubuntu 24.04 (rootfs aarch64)`.
5. `Thiết lập container Ubuntu & liên kết thư mục /sdcard`.
6. `Cập nhật kho gói Ubuntu & cài đặt thư viện phụ thuộc`.
7. `Tải và cài đặt .NET 10.0 SDK & thư viện SMAPI`.
8. `Khởi tạo stardew-mod CLI, template dự án & môi trường VibeCoding`.
9. `Khởi tạo tài khoản sudo gọn gàng và thiết lập workspace tại ~/stardew-workspace`.

---

## 4. Truy cập không gian làm việc

Mỗi khi cần thao tác viết mod hoặc sử dụng AI, bạn chỉ cần mở Termux và gõ:

```bash
ubuntu
```

Lệnh này sẽ đưa bạn thẳng vào thư mục làm việc `~/stardew-workspace` bên trong Ubuntu dưới tư cách tài khoản người dùng của bạn.

---

## 5. Gỡ cài đặt để kiểm thử lại nhiều lần

Trong trường hợp bạn muốn xóa sạch mọi thứ để chạy thử lại kịch bản cài đặt, chỉ cần chạy lệnh sau trên Termux:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/uninstall.sh | bash
```

Kịch bản sẽ dọn sạch container và cấu hình mà không làm mất file game hay các bản mod trong `/sdcard/StardewValley`.
