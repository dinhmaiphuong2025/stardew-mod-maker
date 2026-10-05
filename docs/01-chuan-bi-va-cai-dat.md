# Hướng Dẫn 01: Chuẩn Bị Và Cài Đặt Môi Trường

Tài liệu này hướng dẫn thiết lập toàn bộ môi trường lập trình Mod Cinderbox trên điện thoại Android tiêu chuẩn (không cần quyền Root).

---

## 1. Cài đặt ứng dụng Termux

Lưu ý: Không tải Termux từ Google Play Store vì các bản trên Play Store đã ngừng cập nhật từ lâu và sẽ phát sinh lỗi khi cài đặt gói.

Các kênh tải chính thức:
- F-Droid: https://f-droid.org/en/packages/com.termux/
- GitHub Releases: https://github.com/termux/termux-app/releases (chọn file apk phù hợp với thiết bị, thông thường là bản arm64-v8a hoặc universal).

Sau khi cài đặt xong, mở ứng dụng Termux.

---

## 2. Khởi chạy cài đặt tự động

Trên màn hình Termux, chạy dòng lệnh sau:

```bash
pkg install -y git && git clone https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git && cd stardew-proot-vibecoding && bash install.sh
```

---

## 3. Các bước hệ thống xử lý tự động

Kịch bản `install.sh` sẽ lần lượt thực hiện:
1. Kiểm tra và yêu cầu cấp quyền truy cập bộ nhớ: Khi hộp thoại Android xuất hiện, chọn "Cho phép" (Allow).
2. Cài đặt các gói nền tảng Termux: `proot-distro`, `git`, `curl`, `nodejs`, `jq`, `tar`.
3. Cài đặt môi trường Linux Ubuntu aarch64 qua PRoot Distro.
4. Cấu hình liên kết tự động thư mục `/sdcard` vào container để đồng bộ dữ liệu game.
5. Cài đặt .NET 10.0 SDK từ Microsoft bên trong Ubuntu để phù hợp với SMAPI Cinderbox.
6. Cài đặt bộ công cụ dòng lệnh `stardew-mod` và lệnh truy cập nhanh `stardew-code`.

---

## 4. Truy cập không gian làm việc

Mỗi khi cần thao tác viết mod hoặc sử dụng AI, bạn mở Termux và gõ:

```bash
stardew-code
```

Lệnh này sẽ đưa bạn thẳng vào thư mục làm việc `/root/stardew-workspace` bên trong Ubuntu.
