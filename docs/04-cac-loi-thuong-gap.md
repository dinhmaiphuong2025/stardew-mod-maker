# Hướng Dẫn 04: Sổ Tay Khắc Phục Các Lỗi Thường Gặp

Tổng hợp các lỗi kỹ thuật phổ biến khi xây dựng mod cho Stardew Valley Cinderbox trên Android và giải pháp xử lý.

---

## 1. Lỗi xung đột phiên bản runtime (CS1705)

### Hiện tượng:
Khi chạy `stardew-mod build`, trình biên dịch trả về:
```
error CS1705: Assembly 'StardewModdingAPI' uses 'System.Runtime, Version=10.0.0.0' which has a higher version than referenced assembly 'System.Runtime, Version=6.0.0.0'
```

### Nguyên nhân:
Bản game PC gốc sử dụng .NET 6.0, nhưng nhân SMAPI trong Cinderbox Android được biên dịch trên nền tảng .NET 10.0. Nếu file `.csproj` cấu hình `net6.0` hoặc `net8.0`, trình biên dịch sẽ từ chối.

### Giải pháp:
Mở file `.csproj` của dự án và đảm bảo giá trị thẻ `TargetFramework` là `net10.0`:
```xml
<TargetFramework>net10.0</TargetFramework>
```

---

## 2. Lỗi không tìm thấy file game hoặc thư viện SMAPI

### Hiện tượng:
```
The reference file "/sdcard/StardewValley/desktop/GameFiles/Stardew Valley.dll" was not found.
```

### Nguyên nhân:
- Trò chơi Cinderbox chưa từng được mở trên thiết bị, nên các file dữ liệu chưa được giải nén vào bộ nhớ.
- Chưa cấp quyền truy cập bộ nhớ cho Termux.

### Giải pháp:
1. Mở Cinderbox vào đến menu chính của game một lần để hệ thống hoàn tất giải nén file.
2. Kiểm tra lại quyền bộ nhớ bằng lệnh:
   ```bash
   stardew-mod doctor
   ```
   Nếu thiếu quyền, chạy lệnh `termux-setup-storage` trên Termux và chọn "Cho phép" (Allow).

---

## 3. Lỗi thiếu thư viện đồ họa MonoGame.Framework.dll

### Hiện tượng:
```
error CS0246: The type or namespace name 'Microsoft.Xna' could not be found
error CS0246: The type or namespace name 'Vector2' could not be found
```

### Nguyên nhân:
Các định nghĩa đồ họa (Vector2, SpriteBatch, Texture2D) nằm trong `MonoGame.Framework.dll`.

### Giải pháp:
Hệ thống hỗ trợ tìm file tại các vị trí:
1. `/root/stardew-workspace/lib/MonoGame.Framework.dll`
2. `/sdcard/StardewValley/desktop/GameFiles/MonoGame.Framework.dll`

Nếu thiếu, sao chép file `MonoGame.Framework.dll` vào thư mục `lib/` của workspace.

---

## 4. Bàn phím ảo không xuất hiện khi nhập văn bản

### Hiện tượng:
Thao tác chạm vào ô nhập dữ liệu không kích hoạt bàn phím hệ thống của Android.

### Nguyên nhân:
Class `TextBox` của phiên bản PC không hỗ trợ gửi tín hiệu mở bàn phím ảo trên nền tảng Android.

### Giải pháp:
Yêu cầu AI sử dụng class `TitleTextInputMenu` thay thế cho `TextBox` để kích hoạt giao diện nhập liệu di động.

---

## 5. Nút bấm trên giao diện khó chạm hoặc không nhận tương tác

### Hiện tượng:
Giao diện có nút điều khiển nhưng ngón tay chạm vào hay bị trượt hoặc không kích hoạt.

### Nguyên nhân:
Vùng kiểm tra va chạm (hitbox) quá nhỏ (dưới 48px), hoặc chỉ kiểm tra sự kiện chuột phải.

### Giải pháp:
1. Thiết lập kích thước tối thiểu của nút bấm từ 48px đến 64px.
2. Trong hàm xử lý sự kiện bấm, luôn kiểm tra đồng thời cả `e.Button.IsUseToolButton()` và `e.Button == SButton.MouseLeft`.
3. Bổ sung khoảng đệm va chạm (padding) từ 16px đến 24px quanh phần tử giao diện.

---

## 6. Mod đã deploy nhưng không xuất hiện trong game

### Quy trình kiểm tra:
1. Kiểm tra file nhật ký lỗi tại:
   `/sdcard/StardewValley/desktop/ErrorLogs/SMAPI-crash.txt` hoặc `SMAPI-latest.txt`.
2. Tìm tên mod của bạn trong file log để xác định nguyên nhân SMAPI từ chối tải file.
3. Sao chép đoạn log lỗi đó gửi cho AI để nhận phương án xử lý tương ứng.
