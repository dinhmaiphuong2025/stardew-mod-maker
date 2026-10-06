# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Tự làm mod C# SMAPI cho Stardew Valley trên điện thoại Android bằng AI (VibeCoding) — không cần PC, không cần Root, không cần biết lập trình.

---

## 1. Cài Đặt (1 Lệnh Duy Nhất)

Mở ứng dụng **Termux** và chạy lệnh:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/install.sh | bash
```

- Nhập tên người dùng khi được hỏi (ví dụ: `stardew`).
- Cấp quyền bộ nhớ khi Android hiển thị hộp thoại.

---

## 2. Quy Trình Tạo Mod Cùng AI

Mỗi khi muốn làm mod, bạn mở Termux và gõ:

```bash
ubuntu
```

### Bước 1: Cài đặt AI Coding Agent
Chọn trợ lý AI hỗ trợ viết code:
```bash
stardew-mod agent
```
*(Gợi ý: chọn `1` để cài **OpenCode CLI v2** — có sẵn các model Cloud miễn phí như Big Pickle, Muse Spark).*

### Bước 2: Tạo dự án mod
```bash
stardew-mod new MyFirstMod
cd mods/MyFirstMod
```

### Bước 3: Ra lệnh cho AI (VibeCoding)
Khởi động AI Agent bạn đã cài:
```bash
opencode
```
Gõ ý tưởng của bạn bằng tiếng Việt, ví dụ:
> *"Tạo hiệu ứng vòng tròn ánh sáng trắng phát quang (glow) quanh nhân vật theo phong cách thần thoại. Khi viết xong hãy chạy lệnh stardew-mod build để kiểm tra lỗi biên dịch."*

### Bước 4: Đưa mod vào game
Sau khi AI hoàn thành, thoát AI và chạy:
```bash
stardew-mod deploy
```
Mở game Stardew Valley (Cinderbox) để trải nghiệm mod vừa tạo!

---

## 3. Các Lệnh Tiện Ích

| Lệnh | Chức năng |
|---|---|
| `stardew-mod` | Mở menu quản lý tương tác trực quan |
| `stardew-mod doctor` | Kiểm tra kết nối game và thư viện SMAPI |
| `stardew-mod build` | Biên dịch mã nguồn C# |
| `stardew-mod deploy` | Đưa mod trực tiếp vào thư mục game |
| `stardew-mod logs` | Xem log SMAPI để tìm lỗi khi game có sự cố |
| `stardew-mod update` | Cập nhật bộ công cụ lên phiên bản mới nhất |

---

## 4. Gỡ Cài Đặt

Khi muốn dọn sạch môi trường PRoot để cài lại từ đầu (không ảnh hưởng dữ liệu game):

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/uninstall.sh | bash
```

---

## 5. Tài Liệu Chi Tiết

Tất cả tài liệu kỹ thuật nâng cao được đặt tại thư mục `docs/`:
- `docs/01-chuan-bi-va-cai-dat.md`: Cài đặt Termux và chuẩn bị môi trường.
- `docs/02-cau-truc-cinderbox.md`: Bản đồ thư mục Cinderbox trên Android.
- `docs/03-bi-kip-vibecoding.md`: Mẹo đặt prompt và ra lệnh cho AI hiệu quả.
- `docs/04-cac-loi-thuong-gap.md`: Cách xử lý các lỗi build và crash thường gặp.
- `docs/05-agent-tools.md`: Danh mục lệnh và bảng phân loại chi tiết các Agent.
