# Bước 2: Hiểu Về Cinderbox & Cấu Trúc Thư Mục Game

Để mod hoạt động được, bạn cần hiểu sơ lược về cách game Stardew Valley chạy trên Cinderbox Android. Bạn không cần học lập trình sâu, chỉ cần nhớ các vị trí thư mục chính sau.

---

## 1. Cinderbox Là Gì?

**Cinderbox** là một giải pháp môi trường cho phép chạy trực tiếp phiên bản Stardew Valley PC (1.6+) và SMAPI trên các thiết bị Android với hiệu năng cao.

Khi bạn cài Cinderbox trên điện thoại, toàn bộ dữ liệu game sẽ nằm ngay trong bộ nhớ trong của máy:
```
Bộ nhớ máy (/sdcard/) ──> StardewValley/
```

---

## 2. Bản Đồ Thư Mục Cần Nhớ

Dưới đây là các thư mục quan trọng nhất mà bạn hoặc AI sẽ tương tác:

| Đường dẫn trên Android | Ý nghĩa | Bạn cần làm gì ở đây? |
| :--- | :--- | :--- |
| `/sdcard/StardewValley/desktop/GameFiles/` | Chứa file gốc của game PC (`Stardew Valley.dll`, `xTile.dll`,...) | Môi trường build mod sẽ đọc thư viện từ đây. Bạn không cần chỉnh sửa gì. |
| `/sdcard/StardewValley/smapi-internal/` | Chứa nhân SMAPI của Cinderbox (`StardewModdingAPI.dll`) | Chứa bộ điều khiển mod. |
| `/sdcard/StardewValley/desktop/Mods/` | **Thư mục cài đặt Mod** | Mỗi mod là một thư mục con tại đây. Lệnh `stardew-mod deploy` sẽ tự động copy mod của bạn vào đây. |
| `/sdcard/StardewValley/desktop/ErrorLogs/` | Thư mục ghi lỗi SMAPI | Nếu vào game bị văng hoặc mod không chạy, xem file `SMAPI-crash.txt` tại đây. |

---

## 3. Lệnh Kiểm Tra Tự Động: `stardew-mod doctor`

Bạn không cần phải tự đi tìm từng file bằng tay. Trong môi trường dòng lệnh (sau khi gõ `stardew-code`), bạn chỉ cần chạy:

```bash
stardew-mod doctor
```

Hệ thống sẽ tự động quét:
- [x] Đã kết nối được `/sdcard` chưa?
- [x] Đã tìm thấy `Stardew Valley.dll` chưa?
- [x] Đã có `StardewModdingAPI.dll` chưa?
- [x] Thư mục `Mods` đã sẵn sàng chưa?

Nếu có bất kỳ dấu hiệu cảnh báo nào màu vàng hoặc đỏ, công cụ sẽ ghi rõ nguyên nhân và cách khắc phục ngay trên màn hình.
