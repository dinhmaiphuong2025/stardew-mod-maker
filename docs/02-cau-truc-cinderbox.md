# Hướng Dẫn 02: Cấu Trúc Thư Mục Cinderbox

Để mod hoạt động chính xác, bạn cần nắm rõ sơ đồ tổ chức thư mục của Stardew Valley chạy qua Cinderbox trên Android.

---

## 1. Giới thiệu Cinderbox

Cinderbox là môi trường thực thi cho phép chạy trực tiếp bản Stardew Valley PC (1.6+) và SMAPI trên thiết bị Android.

Dữ liệu game được lưu tại bộ nhớ trong của thiết bị:
```
/sdcard/StardewValley/
```

---

## 2. Sơ đồ các thư mục quan trọng

| Đường dẫn trên Android | Ý nghĩa | Chức năng đối với việc làm mod |
| :--- | :--- | :--- |
| `/sdcard/StardewValley/desktop/GameFiles/` | Chứa file gốc của game PC (`Stardew Valley.dll`, `xTile.dll`,...) | Môi trường build đọc các thư viện tham chiếu từ đây. Không chỉnh sửa nội dung bên trong. |
| `/sdcard/StardewValley/smapi-internal/` | Chứa nhân điều khiển SMAPI (`StardewModdingAPI.dll`) | Cung cấp API điều khiển cho mod. |
| `/sdcard/StardewValley/desktop/Mods/` | Thư mục chứa các bản mod | Mỗi bản mod nằm trong một thư mục con tại đây. Lệnh `stardew-mod deploy` sẽ tự động chuyển file vào đây. |
| `/sdcard/StardewValley/desktop/ErrorLogs/` | Thư mục ghi nhận nhật ký lỗi SMAPI | Chứa file `SMAPI-crash.txt` dùng để tra cứu khi game bị dừng đột ngột hoặc mod không nạp được. |

---

## 3. Lệnh kiểm tra hệ thống: `stardew-mod doctor`

Bạn không cần kiểm tra thủ công từng file. Khi đang ở trong môi trường `stardew-code`, bạn chỉ cần chạy:

```bash
stardew-mod doctor
```

Công cụ sẽ tự động xác minh:
- Trạng thái kết nối thư mục `/sdcard`.
- Sự hiện diện của `Stardew Valley.dll`.
- Sự hiện diện của `StardewModdingAPI.dll`.
- Trạng thái sẵn sàng của thư mục `Mods/`.

Mọi vấn đề phát hiện sẽ được hiển thị kèm chỉ dẫn xử lý tương ứng.
