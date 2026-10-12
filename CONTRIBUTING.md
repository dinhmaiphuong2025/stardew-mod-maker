# HƯỚNG DẪN ĐÓNG GÓP CHO DỰ ÁN (CONTRIBUTING GUIDE)

Chào mừng bạn đến với cộng đồng **Stardew Valley Mod Maker - VibeCoding trên Android**!
Chúng mình rất trân trọng mọi đóng góp từ cộng đồng, dù là báo lỗi nhỏ, bổ sung tài liệu hay gửi Pull Request cải tiến mã nguồn.

---

## 1. Các Cách Bạn Có Thể Đóng Góp

### A. Kiểm thử thiết bị (Device Testing & Feedback)
- Cinderbox và PRoot Ubuntu hoạt động trên nhiều dòng chip (Snapdragon, MediaTek Dimensity, Exynos, Google Tensor).
- Hãy chạy thử bộ cài đặt trên thiết bị của bạn và mở một [Issue](https://github.com/dinhmaiphuong2025/stardew-mod-maker/issues) với thông tin:
  - Tên máy & Vi xử lý (Chipset).
  - Phiên bản Android & Bản Termux đang dùng.
  - Tốc độ tải và độ ổn định khi biên dịch mod.

### B. Báo lỗi & Đóng góp ý tưởng (Issues & Feature Requests)
- **Lỗi biên dịch hoặc lỗi crash**: Đính kèm 30 dòng log SMAPI gần nhất (`stardew-mod logs 30`).
- **Ý tưởng mod hoặc tính năng mới**: Đề xuất các lệnh hỗ trợ mới cho `stardew-mod` hoặc các mẫu prompt hay.

### C. Gửi Pull Requests (PR)
- Fork repository về tài khoản GitHub của bạn.
- Tạo một nhánh mới (`git checkout -b feature/ten-tinh-nang`).
- Thực hiện chỉnh sửa và kiểm tra cú pháp Bash:
  ```bash
  bash -n install.sh
  bash -n uninstall.sh
  bash -n scripts/stardew-mod.sh
  bash -n scripts/ui.sh
  ```
- Commit với thông điệp rõ ràng (`feat: ...`, `fix: ...`, `docs: ...`).
- Mở Pull Request vào nhánh `main`.

---

## 2. Tiêu Chuẩn Mã Nguồn & Thiết Kế (Code & UI Guidelines)
- **UI Style Shell**: Các script dòng lệnh phải tuân thủ phong cách tối giản, sử dụng ký tự Braille (`⠿`, `⠋`, `✓`) thay vì emoji, có kiểm tra độ rộng màn hình Termux (`cols`) để không bao giờ bị vỡ dòng khi zoom.
- **Tương thích đa nền tảng**: Template C# phải luôn đảm bảo chạy được trên cả PC 1.6 và Mobile Cinderbox 1.6.
- **Tiếng Việt có dấu**: Toàn bộ thông báo người dùng và tài liệu phải viết bằng Tiếng Việt chuẩn mực, đầy đủ dấu.

---

Cảm ơn bạn đã đồng hành xây dựng một cộng đồng VibeCoding mod game không cần PC!
