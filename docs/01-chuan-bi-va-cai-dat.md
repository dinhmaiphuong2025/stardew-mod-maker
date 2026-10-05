# Bước 1: Chuẩn Bị & Cài Đặt Môi Trường (Dành Cho Người Mới)

Tài liệu này hướng dẫn bạn thiết lập toàn bộ công cụ cần thiết từ con số 0 trên một chiếc điện thoại Android bình thường mà **không cần Root máy** và **không cần cài hệ điều hành phức tạp**.

---

## 1. Cài đặt Ứng dụng Termux

> **Lưu ý quan trọng:** KHÔNG tải Termux từ Google Play Store (bản trên Play Store đã ngừng cập nhật từ lâu và sẽ bị lỗi cài đặt gói).

1. Tải ứng dụng **Termux** từ F-Droid hoặc GitHub Releases chính thức:
   - Link F-Droid: [f-droid.org/packages/com.termux](https://f-droid.org/en/packages/com.termux/)
   - Link GitHub: [github.com/termux/termux-app/releases](https://github.com/termux/termux-app/releases) (Tải file có đuôi `.apk` phù hợp với chip máy bạn, thông thường là `arm64-v8a` hoặc `universal`).
2. Mở ứng dụng Termux sau khi cài đặt xong.

---

## 2. Kích hoạt Cài đặt 1-Click

Chỉ cần sao chép và dán lệnh sau vào màn hình Termux, sau đó nhấn **Enter**:

```bash
pkg install -y git && git clone https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git && cd stardew-proot-vibecoding && bash install.sh
```

*(Hoặc nếu bạn tải thư mục dự án này về máy, chỉ cần mở Termux, `cd` vào thư mục và chạy `bash install.sh`)*.

---

## 3. Quá trình Cài đặt Tự động Diễn ra Như Thế Nào?

Script sẽ tự động làm toàn bộ các việc kỹ thuật khó khăn cho bạn:
1. **Yêu cầu cấp quyền bộ nhớ:** Một hộp thoại của Android sẽ xuất hiện hỏi quyền truy cập bộ nhớ. Hãy bấm **CHO PHÉP (ALLOW)**.
2. **Cài đặt PRoot Distro:** Tạo một hệ điều hành Linux Ubuntu chuẩn (aarch64) chạy ngầm an toàn bên trong máy bạn.
3. **Kết nối Bộ nhớ trong (`/sdcard`):** Tự động liên kết bộ nhớ điện thoại vào Ubuntu để bạn sửa file, chép ảnh mod dễ dàng như dùng ứng dụng Quản lý Tệp (File Manager).
4. **Cài đặt .NET 10.0 SDK:** Bộ biên dịch C# chính thức của Microsoft tương thích hoàn hảo với SMAPI trên Cinderbox.
5. **Cài đặt công cụ `stardew-mod`:** Bộ lệnh trợ thủ siêu ngắn gọn giúp bạn tạo, build và cài mod trong chớp mắt.

---

## 4. Cách Vào Không Gian Làm Việc Sau Khi Cài Xong

Mỗi khi muốn bắt tay vào làm mod hoặc trò chuyện với AI, bạn chỉ cần mở Termux và gõ:

```bash
stardew-code
```

Lệnh này sẽ đưa bạn thẳng vào thư mục làm việc `/root/stardew-workspace` bên trong container Linux!
