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

## 2. Khởi chạy cài đặt 1-Lệnh duy nhất

Trên màn hình Termux, dán và chạy duy nhất dòng lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh | bash
```

*(Hoặc: `bash -c "$(curl -fsSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh)"`)*

Hệ thống sẽ hiển thị giao diện dòng lệnh hiện đại với thanh tiến trình theo từng bước (`[████░░] 60%`) cùng hiệu ứng loading spinner Braille sinh động và tiếng Việt đầy đủ dấu.

---

## 3. Các bước hệ thống xử lý tự động

Kịch bản `install.sh` sẽ lần lượt thực hiện 6 bước:
1. `[1/6]` Kiểm tra và yêu cầu cấp quyền truy cập bộ nhớ: Khi hộp thoại Android xuất hiện, chọn "Cho phép" (Allow).
2. `[2/6]` Cài đặt các gói công cụ nền tảng Termux (`proot-distro`, `git`, `curl`, `jq`, `tar`).
3. `[3/6]` Cài đặt môi trường Linux Ubuntu aarch64 qua PRoot Distro.
4. `[4/6]` Cấu hình liên kết tự động thư mục `/sdcard` vào container để đồng bộ dữ liệu game.
5. `[5/6]` Cài đặt .NET 10.0 SDK từ Microsoft vào `/opt/dotnet` cho toàn hệ thống.
6. `[6/6]` Thiết lập tài khoản sudo riêng của bạn, tạo thư mục làm việc tại `~/stardew-workspace` và cài đặt OpenCode AI CLI.
7. Tạo binary khởi động `ubuntu` trên Termux.

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
