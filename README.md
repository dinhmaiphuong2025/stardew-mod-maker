# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Làm mod C# SMAPI cho Stardew Valley trên điện thoại Android bằng AI (Thuần VibeCoding) — không cần PC, không cần Root, không cần biết lập trình hay gõ lệnh Linux.

---

## 1. Chuẩn Bị & Link Tải Ứng Dụng

Trước khi bắt đầu, bạn cần cài đặt các ứng dụng sau trên điện thoại:

1. **Ứng dụng Termux** (tùy chọn nguồn tải theo nhu cầu của bạn):
   - [Bản Termux Custom](https://github.com/dinhmaiphuong2025/termux-app/releases)
   - [Termux trên GitHub Releases](https://github.com/termux/termux-app/releases)
   - [Termux trên F-Droid](https://f-droid.org/packages/com.termux/)
   - [Termux trên Google Play Store](https://play.google.com/store/apps/details?id=com.termux)

2. **Trình chạy Cinderbox (Chạy Stardew Valley PC trên Android)**:
   - Tải file APK tại [GitHub Cinderbox v0.8.1 Releases](https://github.com/Ekyso/Cinderbox/releases/tag/0.8.1)

3. **Dữ liệu Game Stardew Valley**:
   - **Có tài khoản Steam**: Đăng nhập Steam trực tiếp bên trong Cinderbox để tải game chính chủ.
   - **Chưa có tài khoản Steam**: Tải file game cài sẵn từ nhóm Telegram cộng đồng:
     - [Link tải file game Stardew Valley](https://t.me/c/3796677936/14/13555)
     - [Nhóm Telegram Cộng đồng Stardew Valley VN](https://t.me/+aJTLlA0Lqzk2MThl) *(hướng dẫn cài mod, game, Việt hóa...)*

---

## 2. Cài Đặt (1 Lệnh Duy Nhất)

Mở ứng dụng **Termux** và dán dòng lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh | bash
```

- Nhập tên người dùng khi được hỏi (ví dụ: `stardew`).
- Chọn Cho phép (Allow) khi Android hỏi quyền truy cập bộ nhớ thiết bị.

---

## 3. Làm Mod Bằng AI (Thuần VibeCoding)

Mỗi khi muốn tạo mod mới, bạn mở Termux và gõ:

```bash
ubuntu
```

---

### Bước 1: Cài đặt AI Coding Agent

Gõ lệnh sau để mở bảng chọn Agent:

```bash
stardew-mod agent
```

Hệ thống sẽ hiển thị menu để bạn chọn:
- Nhấn `1`: **OpenCode CLI v2** *(Miễn phí — tích hợp sẵn model Cloud free Big Pickle, Muse Spark)*
- Nhấn `2`: **Antigravity CLI** *(Miễn phí có quota hàng ngày qua tài khoản Google)*
- Nhấn `3`: **Claude Code** *(Trả phí qua gói Claude Pro hoặc Anthropic API Key)*
- Nhấn `4`: **OpenAI Codex CLI** *(Trả phí qua OpenAI API Key)*
- Nhấn `5`: **Hermes Agent CLI** *(Miễn phí — mã nguồn mở, hỗ trợ BYOK và local models)*

*(Mẹo: Bạn cũng có thể cài nhanh trực tiếp bằng lệnh `stardew-mod agent opencode` hoặc `stardew-mod agent antigravity`).*

Sau khi cài xong, bạn chỉ cần nhấn **Enter**, màn hình sẽ tự động xoá sạch để bạn gõ lệnh khởi động Agent (ví dụ: `opencode` hoặc `agy`).

---

### Bước 2: Ra lệnh cho AI tạo mod (Prompt mẫu)

Mở Agent vừa cài (ví dụ: `opencode`) và mô tả ý tưởng bằng tiếng Việt:

> **"Tạo cho tôi mod HaloGlowMod: Thêm hiệu ứng vòng tròn ánh sáng trắng phát quang (glow) quanh nhân vật theo phong cách thần thoại. Hãy tự tạo mod bằng stardew-mod, viết toàn bộ code C#, tự build sửa lỗi và deploy thẳng vào game cho tôi."**

*(Xem chi tiết cẩm nang cơ chế mod, từ điển thuật ngữ game và công thức prompt 3 bước tại file [VIBECODE_PROMPT_TEMPLATE.md](VIBECODE_PROMPT_TEMPLATE.md)).*

Trợ lý AI sẽ tự động xử lý toàn bộ:
1. Tự khởi tạo khung dự án mod C# SMAPI.
2. Viết mã nguồn logic đồ họa và sự kiện game.
3. Tự biên dịch và tự sửa lỗi nếu phát sinh.
4. Tự đưa mod vào đúng thư mục game Stardew Valley.

Khi AI báo xong, bạn chỉ cần mở game **Stardew Valley** trên điện thoại lên và chơi!

---

## 4. Các Lệnh Tiện Ích (Tùy Chọn)

Bạn không bắt buộc phải nhớ các lệnh này vì AI đã tự làm giúp bạn. Chỉ dùng khi bạn muốn tự kiểm tra:

| Lệnh | Chức năng |
|---|---|
| `stardew-mod` | Menu bảng điều khiển trực quan |
| `stardew-mod update` | Cập nhật bộ công cụ lên bản mới nhất từ GitHub |
| `stardew-mod logs` | Xem nhật ký SMAPI khi game gặp sự cố |

---

---

## HƯỚNG DẪN GỠ CÀI ĐẶT (UNINSTALL & RESET)

Nếu bạn muốn dọn sạch toàn bộ môi trường để kiểm thử lại từ đầu, hoặc muốn giải phóng dung lượng bộ nhớ khi không còn nhu cầu sử dụng:

### 1. Lệnh gỡ cài đặt tự động (1 dòng duy nhất)

Mở **Termux** và dán lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/uninstall.sh | bash
```

*(Nếu muốn chạy tự động bỏ qua bước hỏi xác nhận: thêm cờ `-y` vào cuối).*

### 2. Kịch bản gỡ cài đặt sẽ làm những gì?
- **Gỡ bỏ hoàn toàn container PRoot Ubuntu** và toàn bộ công cụ lập trình bên trong (.NET SDK, OpenCode, thư viện tạm).
- **Xóa các lệnh tắt trên Termux** (`ubuntu`, `stardew-code`) để đưa Termux về trạng thái sạch sẽ ban đầu.
- **Dọn sạch các cấu hình mount** liên kết bộ nhớ.
- Hiển thị thanh tiến trình động duy nhất (`[██████████] 100%`) trực quan và báo kết quả rõ ràng.

### 3. Cam kết an toàn dữ liệu
- **Bảo lưu an toàn 100%**: Thư mục game gốc, các file save và toàn bộ mod bạn đã cài đặt tại `/sdcard/StardewValley` **hoàn toàn KHÔNG bị ảnh hưởng hay xóa mất**.
- Bạn có thể chạy lại lệnh cài đặt bất cứ lúc nào mà không phải lo mất tiến trình chơi game!
