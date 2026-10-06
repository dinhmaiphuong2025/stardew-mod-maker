# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Làm mod C# SMAPI cho Stardew Valley trên điện thoại Android bằng AI (Thuần VibeCoding) — không cần PC, không cần Root, không cần biết lập trình hay gõ lệnh Linux.

---

## 1. Cài Đặt (1 Lệnh Duy Nhất)

Mở ứng dụng **Termux** và dán dòng lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/install.sh | bash
```

- Nhập tên người dùng khi được hỏi (ví dụ: `stardew`).
- Chọn Cho phép (Allow) khi Android hỏi quyền truy cập bộ nhớ thiết bị.

---

## 2. Làm Mod Bằng AI (Thuần VibeCoding)

Mỗi khi muốn tạo mod mới, bạn mở Termux và gõ:

```bash
ubuntu
```

Khởi động trợ lý AI (hoàn toàn miễn phí):

```bash
opencode
```

*(Nếu chưa cài agent, gõ `stardew-mod agent` và chọn `1` để cài OpenCode CLI v2 có sẵn model cloud free).*

---

### Mẫu câu lệnh (Prompt) ra lệnh cho AI

Trong cửa sổ trò chuyện của AI, bạn chỉ cần mô tả ý tưởng bằng tiếng Việt:

> **"Tạo cho tôi mod HaloGlowMod: Thêm hiệu ứng vòng tròn ánh sáng trắng phát quang (glow) quanh nhân vật theo phong cách thần thoại. Hãy tự tạo mod bằng stardew-mod, viết toàn bộ code C#, tự build sửa lỗi và deploy thẳng vào game cho tôi."**

Trợ lý AI sẽ tự động xử lý toàn bộ:
1. Tự khởi tạo khung dự án mod C# SMAPI.
2. Viết mã nguồn logic đồ họa và sự kiện game.
3. Tự biên dịch và tự sửa lỗi nếu phát sinh.
4. Tự đưa mod vào đúng thư mục game Stardew Valley.

Khi AI báo xong, bạn chỉ cần mở game **Stardew Valley** trên điện thoại lên và chơi!

---

## 3. Các Lệnh Tiện Ích (Tùy Chọn)

Bạn không bắt buộc phải nhớ các lệnh này vì AI đã tự làm giúp bạn. Chỉ dùng khi bạn muốn tự kiểm tra:

| Lệnh | Chức năng |
|---|---|
| `stardew-mod` | Menu bảng điều khiển trực quan |
| `stardew-mod update` | Cập nhật bộ công cụ lên bản mới nhất từ GitHub |
| `stardew-mod logs` | Xem nhật ký SMAPI khi game gặp sự cố |

---

## 4. Gỡ Cài Đặt Sạch Sẽ

Nếu muốn dọn dẹp toàn bộ môi trường PRoot (không làm mất file game hay dữ liệu save):

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/uninstall.sh | bash
```
