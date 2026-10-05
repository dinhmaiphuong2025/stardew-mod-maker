# Bước 4: Sổ Tay Khắc Phục Các Lỗi Thường Gặp

Khi làm mod cho Stardew Valley Cinderbox trên Android, đây là danh sách những lỗi phổ biến nhất và cách xử lý nhanh trong 30 giây.

---

## 1. Lỗi Xung Đột Phiên Bản .NET (Lỗi CS1705)

### Triệu chứng:
Khi chạy `stardew-mod build`, màn hình hiện lỗi:
```
error CS1705: Assembly 'StardewModdingAPI' uses 'System.Runtime, Version=10.0.0.0' which has a higher version than referenced assembly 'System.Runtime, Version=6.0.0.0'
```

### Nguyên nhân:
Bản game PC Stardew 1.6 gốc dùng `.NET 6.0`, nhưng SMAPI bên trong Cinderbox Android được biên dịch trên nền `.NET 10.0`. Nếu AI vô tình sửa file `.csproj` về `net6.0` hoặc `net8.0`, trình biên dịch sẽ từ chối.

### Cách khắc phục:
Mở file `.csproj` của mod và đảm bảo thẻ `TargetFramework` luôn là `net10.0`:
```xml
<TargetFramework>net10.0</TargetFramework>
```

---

## 2. Lỗi Thiếu File Game Hoặc DLL Không Tìm Thấy

### Triệu chứng:
```
The reference file "/sdcard/StardewValley/desktop/GameFiles/Stardew Valley.dll" was not found.
```

### Nguyên nhân:
1. Bạn chưa mở game Cinderbox lên lần nào, nên game chưa kịp giải nén các file vào bộ nhớ máy.
2. Hoặc bạn chưa cấp quyền đọc bộ nhớ máy cho Termux (`/sdcard`).

### Cách khắc phục:
1. Thoát ra màn hình chính điện thoại, mở ứng dụng Cinderbox lên, đợi vào menu chính của game một lúc rồi thoát ra.
2. Chạy lệnh:
   ```bash
   stardew-mod doctor
   ```
   Nếu báo thiếu quyền, hãy chạy lệnh `termux-setup-storage` trên Termux và bấm **Cho phép (Allow)**.

---

## 3. Lỗi Thiếu MonoGame.Framework.dll

### Triệu chứng:
```
error CS0246: The type or namespace name 'Microsoft.Xna' could not be found
error CS0246: The type or namespace name 'Vector2' could not be found
```

### Nguyên nhân:
Trong Cinderbox Android, các kiểu dữ liệu đồ họa (như `Vector2`, `SpriteBatch`, `Texture2D`) nằm trong file `MonoGame.Framework.dll`.

### Cách khắc phục:
Bộ cài đặt đã hỗ trợ tìm file này tự động tại:
1. `/root/stardew-workspace/lib/MonoGame.Framework.dll`
2. Hoặc `/sdcard/StardewValley/desktop/GameFiles/MonoGame.Framework.dll`

Nếu thiếu, bạn có thể copy file `MonoGame.Framework.dll` đặt vào thư mục `lib/` của workspace.

---

## 4. Bàn Phím Ảo Không Hiện Lên Khi Cần Nhập Chữ

### Triệu chứng:
Khi bấm vào ô nhập text trong mod, bàn phím gõ chữ của điện thoại không chịu bật lên.

### Nguyên nhân:
Trên máy tính PC, game dùng class `TextBox` để nhận phím cơ. Nhưng trên Android, `TextBox` không thể ra lệnh kích hoạt bàn phím ảo của hệ điều hành.

### Cách khắc phục:
Hãy nhắc AI:
> *"Trên Cinderbox Android, bắt buộc phải dùng class `TitleTextInputMenu` thay vì `TextBox` để mở bàn phím ảo Android."*

---

## 5. Nút Bấm Menu Khó Chạm Hoặc Chạm Bị Hụt

### Triệu chứng:
Trên màn hình điện thoại có nút bấm nhưng lấy ngón tay chạm vào lúc được lúc không.

### Nguyên nhân:
Màn hình cảm ứng ngón tay có diện tích tiếp xúc lớn hơn nhiều so với con trỏ chuột máy tính. Các nút bấm mặc định nhỏ hơn 40px rất khó chạm trúng.

### Cách khắc phục:
1. Đặt kích thước nút tối thiểu từ `48px` đến `64px`.
2. Trong hàm bắt sự kiện chạm, luôn kiểm tra cả `e.Button.IsUseToolButton()` và `e.Button == SButton.MouseLeft`.
3. Mở rộng vùng kiểm tra va chạm (`bounds`) thêm 16px - 24px mỗi chiều.

---

## 6. Mod Đã Deploy Nhưng Vào Game Không Thấy Hoạt Động

### Cách kiểm tra:
1. Mở ứng dụng Quản lý Tệp trên điện thoại, vào thư mục:
   `/sdcard/StardewValley/desktop/ErrorLogs/`
2. Mở file `SMAPI-crash.txt` hoặc `SMAPI-latest.txt`.
3. Tìm kiếm tên mod của bạn xem SMAPI có báo lỗi gì khi nạp file không.
4. Copy đoạn log lỗi đó gửi cho AI để được hướng dẫn sửa ngay tức khắc!
