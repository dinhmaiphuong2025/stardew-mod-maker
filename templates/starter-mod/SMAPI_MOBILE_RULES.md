# CHỈ DẪN KỸ THUẬT LẬP TRÌNH MOD SMAPI 1.6 CHO AI AGENT (CINDERBOX ANDROID)

Bạn đang phát triển mod C# SMAPI 1.6 (.NET 10.0) cho Stardew Valley trên Android Cinderbox.
Môi trường di động có những đặc thù rất nghiêm ngặt, bạn PHẢI tuân thủ các quy tắc sau:

## 1. QUY TẮC PHÁT VẬT PHẨM (ITEMS / SKILL OBJECTS)
- Nếu mod có vật phẩm hoặc kỹ năng dựa trên vật phẩm: **LUÔN LUÔN cấp vật phẩm cho người chơi** khi tải save hoặc bắt đầu ngày mới nếu trong túi chưa có:
  ```csharp
  helper.Events.GameLoop.SaveLoaded += (s, e) => {
      // Cấp vật phẩm mẫu nếu chưa có
  };
  ```
- Hoặc hỗ trợ lệnh console (`helper.ConsoleCommands.Add("player_giveitem", ...)`) để người chơi có thể tự lấy vật phẩm bất cứ lúc nào.

## 2. NÚT BẤM CẢM ỨNG TRÊN HUD (TOUCH BUTTONS)
- Màn hình cảm ứng trên Android Cinderbox có **UI Scale**:
  - Không so sánh trực tiếp tọa độ màn hình thô với hitbox nút bấm.
  - Sử dụng class helper `MobileTouchButton` có sẵn trong dự án:
    ```csharp
    // Khởi tạo nút ở góc màn hình HUD (ví dụ 64x64)
    var btn = new MobileTouchButton(100, 100, 64, 64, "Blink", () => {
        // Thực thi kỹ năng
    });
    ```
- **Tầng vẽ HUD**: Luôn vẽ các nút điều khiển cảm ứng ở sự kiện `Display.RenderedHud` (KHÔNG vẽ ở `RenderedWorld` vì sẽ bị trôi theo camera khi nhân vật bước đi).
- **Sự kiện bấm**: Bắt chạm tại `Input.ButtonPressed` với `e.Button == SButton.MouseLeft` và gọi `btn.TryHandleClick(e.Button)`.
- **An toàn thao tác**: Luôn kiểm tra `Context.IsPlayerFree` và `Context.IsWorldReady` trước khi kích hoạt kỹ năng.

## 3. KHÔNG DÙNG CÁC API KHÔNG HỖ TRỢ TRÊN MOBILE
- **KHÔNG gọi `e.SuppressButton()`**: Hàm này không tồn tại trên SMAPI Android di động và sẽ gây lỗi biên dịch `CS1061`.
- **KHÔNG dùng `TextBox`**: Muốn nhập văn bản, dùng `TitleTextInputMenu` để kích hoạt bàn phím ảo Android.

## 4. HIỆU ỨNG THẾ GIỚI (VFX / TÀN ẢNH / HÀO QUANG)
- Luôn vẽ sprite trong thế giới ở sự kiện `Display.RenderedWorld`.
- Luôn quy đổi tọa độ thế giới sang tọa độ camera màn hình bằng:
  `Vector2 screenPos = Game1.GlobalToLocal(Game1.viewport, worldPos);`
- Dùng `TemporaryAnimatedSprite` nếu muốn tạo khói, nổ, tàn ảnh tự tiêu biến.

## 5. QUY TRÌNH BIÊN DỊCH VÀ CÀI ĐẶT
1. Sau khi viết code vào `ModEntry.cs`, luôn chạy lệnh:
   `stardew-mod build`
2. Nếu có lỗi biên dịch (CSxxxx), đọc kỹ thông báo, tự sửa code và build lại.
3. Khi build thành công (0 Warning, 0 Error), chạy lệnh:
   `stardew-mod deploy`
