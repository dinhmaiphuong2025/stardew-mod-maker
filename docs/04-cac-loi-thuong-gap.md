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

---

## 7. Xung đột giữa các mod (Mod Conflicts) trong Cinderbox

Khi cài đặt nhiều mod cùng lúc trong thư mục `/sdcard/StardewValley/desktop/Mods/`, bạn có thể gặp hiện tượng xung đột: game giật lag, tính năng mod này ghi đè mod kia, hoặc game văng đột ngột (crash).

### 7.1. Trùng lặp UniqueID trong `manifest.json`
- **Hiện tượng**: SMAPI bỏ qua một trong hai mod hoặc báo lỗi:
  ```
  Skipped mod 'ModA': it has the same ID as 'ModB'
  ```
- **Nguyên nhân**: Copy template hoặc đặt UniqueID quá chung chung (ví dụ `Author.MyMod`).
- **Khắc phục**: Yêu cầu AI đổi lại UniqueID mang tính duy nhất cao trong `manifest.json`:
  ```json
  "UniqueID": "AuthorName.ModName.StardewValley"
  ```

### 7.2. Xung đột Harmony Patch (Nhiều mod cùng can thiệp một hàm gốc)
- **Hiện tượng**: Một trong hai mod mất tác dụng, hoặc văng game khi thực hiện hành động cụ thể (câu cá, đổi ngày, lưu game).
- **Nguyên nhân**: Mod A dùng Harmony `Prefix` trả về `false` (chặn hàm gốc chạy tiếp), khiến mod B (cũng patch hàm đó) không nhận được dữ liệu hoặc làm sai lệch logic game.
- **Khắc phục**:
  1. Hạn chế tối đa dùng `Prefix` trả về `false` trừ khi bắt buộc phải thay thế hoàn toàn logic gốc.
  2. Ưu tiên dùng `Postfix` để chỉ đọc kết quả hoặc bổ sung hiệu ứng sau khi hàm gốc đã xử lý xong.
  3. Sử dụng `Priority` của Harmony để xếp thứ tự chạy rõ ràng nếu cần ưu tiên:
     ```csharp
     [HarmonyPriority(Priority.High)]
     ```

### 7.3. Tranh chấp Asset / Content Pipeline
- **Hiện tượng**: Mod làm biến mất texture của mod khác, hoặc hình ảnh bị lỗi ô vuông tím/đen (missing texture).
- **Nguyên nhân**: Cả hai mod cùng can thiệp sự kiện `AssetRequested` và ghi đè toàn bộ (`e.LoadFrom(...)`) cùng một tệp đồ họa gốc (như `Characters/Farmer/farmer_base` hoặc `TileSheets/tools`).
- **Khắc phục**:
  - Không ghi đè toàn bộ tệp trừ khi làm mod đại tu texture.
  - Sử dụng phương thức chắp vá từng vùng ảnh (`e.Edit(...)` kết hợp `patch.AsImage().PatchImage(...)`) để chỉ sửa vùng pixel cần thiết, giúp các mod khác cùng chỉnh sửa mà không xung đột.

### 7.4. Xung đột lưu dữ liệu (ModData collision)
- **Hiện tượng**: Giá trị thuộc tính mod lưu vào nhân vật hoặc nông trại bị biến mất hoặc bị mod khác thay đổi.
- **Nguyên nhân**: Đặt tên key trong `modData` quá ngắn (ví dụ `level`, `dash_cooldown`, `is_glowing`).
- **Khắc phục**: Luôn gắn tiền tố UniqueID của mod vào trước key:
  ```csharp
  string key = $"{this.ModManifest.UniqueID}/DashCooldown";
  Game1.player.modData[key] = "1.5";
  ```

### 7.5. Xung đột sự kiện phím bấm / Touch Input
- **Hiện tượng**: Bấm một phím hoặc chạm màn hình làm kích hoạt đồng thời 2-3 tính năng của các mod khác nhau.
- **Khắc phục**:
  - Kiểm tra trạng thái trò chơi trước khi xử lý phím: `Context.IsPlayerFree` và `Context.IsWorldReady`.
  - Hỗ trợ file cấu hình `config.json` để người chơi tự đổi nút nếu bị trùng với mod khác.

---

## 8. Quy trình 3 bước cô lập và giải quyết xung đột mod

Khi nghi ngờ có lỗi xung đột giữa các mod:

1. **Bước 1: Chẩn đoán bằng lệnh doctor và log**
   ```bash
   stardew-mod doctor --json
   stardew-mod logs 100
   ```
   Tìm các dòng log màu đỏ `[ERROR]` hoặc vàng `[WARN]` có chứa từ khóa `Harmony`, `Duplicate`, hoặc `NullReferenceException`.

2. **Bước 2: Phương pháp nhị phân (Binary Search Mod)**
   - Tạm thời di chuyển một nửa số mod trong `/sdcard/StardewValley/desktop/Mods/` ra thư mục tạm.
   - Mở game thử lại để xác định nửa nào chứa mod gây xung đột.
   - Lặp lại cho đến khi tìm chính xác cặp mod không tương thích với nhau.

3. **Bước 3: Đưa log cho AI phân tích**
   Gửi cho AI thông báo lỗi và yêu cầu:
   > *"Mod A của tôi đang bị xung đột với Mod B. Đây là đoạn log SMAPI khi văng game: [Dán log]. Hãy kiểm tra xem xung đột ở phần Harmony patch hay sự kiện Asset/Input và điều chỉnh mã nguồn Mod A để tương thích."*
