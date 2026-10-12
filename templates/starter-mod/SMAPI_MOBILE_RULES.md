# CHỈ DẪN KỸ THUẬT LẬP TRÌNH MOD ĐA NỀN TẢNG (PC 1.6 & ANDROID CINDERBOX 1.6)

Bạn đang phát triển mod C# SMAPI 1.6 (.NET 10.0) cho Stardew Valley.
Mục tiêu là bản mod tạo ra có thể **chạy mượt mà trên cả PC (Windows/Mac/Linux) lẫn Android Cinderbox** chỉ với một file DLL duy nhất!

---

## 1. NGUYÊN TẮC ĐIỀU KHIỂN LAI (HYBRID INPUT: PC + TOUCH)
- Người chơi PC dùng bàn phím/chuột; người chơi Cinderbox dùng màn hình cảm ứng ngón tay.
- **LUÔN LUÔN hỗ trợ cả hai hình thức điều khiển**:
  ```csharp
  // 1. Phím bấm PC (đọc từ ModConfig config.json)
  if (e.Button == this.Config.ActivationKey) { ... }

  // 2. Nút cảm ứng Mobile (dùng MobileTouchButton)
  if (this.TouchButton != null && this.TouchButton.TryHandleClick(e.Button)) { ... }
  ```
- **Hỗ trợ `ModConfig`**: Luôn cho phép người chơi đổi phím kích hoạt trong `config.json` để tránh trùng phím với mod khác trên PC.

## 2. NÚT BẤM CẢM ỨNG TRÊN HUD (TOUCH BUTTONS)
- Màn hình điện thoại có độ phân giải cao và game áp dụng tỷ lệ phóng to `Game1.options.uiScale`.
- Sử dụng class helper `MobileTouchButton` có sẵn trong dự án:
  - Tự động quy đổi tọa độ qua `uiScale` (chạm đâu ăn đó).
  - Tự động bắt sự kiện `SButton.MouseLeft`.
- **Tầng vẽ HUD**: Luôn vẽ ở sự kiện `Display.RenderedHud` (KHÔNG vẽ ở `RenderedWorld` vì sẽ bị trôi theo camera khi nhân vật bước đi).
- **An toàn thao tác**: Luôn kiểm tra `Context.IsPlayerFree` và `Context.IsWorldReady` trước khi thực thi tính năng.

## 3. QUY TẮC CẤP VẬT PHẨM (ITEMS / SKILL OBJECTS)
- Nếu mod yêu cầu cầm một vật phẩm cụ thể trên tay để kích hoạt:
  - **LUÔN LUÔN cấp vật phẩm mẫu cho người chơi** khi tải save (`GameLoop.SaveLoaded`) hoặc khi bắt đầu ngày (`GameLoop.DayStarted`) nếu túi đồ chưa có:
    ```csharp
    if (!Game1.player.hasItemInInventoryNamed("TênVậtPhẩm")) {
        // Cấp vật phẩm vào túi đồ
    }
    ```
  - Thêm lệnh console `helper.ConsoleCommands.Add(...)` để người chơi có thể tự lấy lại nếu lỡ vứt mất.

## 4. CÁC API KHÔNG HỢP LỆ TRÊN CINDERBOX MOBILE
- **KHÔNG gọi `e.SuppressButton()`**: Hàm này không tồn tại trên SMAPI di động và sẽ gây lỗi biên dịch `CS1061`.
- **KHÔNG dùng `TextBox`**: Muốn người dùng nhập chữ, hãy dùng `TitleTextInputMenu` để bật bàn phím ảo Android.

## 5. HIỆU ỨNG THẾ GIỚI (VFX / TÀN ẢNH / HÀO QUANG)
- Luôn vẽ sprite trong thế giới ở sự kiện `Display.RenderedWorld`.
- Luôn quy đổi tọa độ thế giới sang tọa độ camera màn hình bằng:
  `Vector2 screenPos = Game1.GlobalToLocal(Game1.viewport, worldPos);`
- Dùng `TemporaryAnimatedSprite` nếu muốn tạo khói, nổ, tàn ảnh tự tiêu biến theo thời gian.

## 6. QUY TRÌNH BIÊN DỊCH VÀ CÀI ĐẶT
1. Sau khi chỉnh sửa code, luôn chạy lệnh:
   `stardew-mod build`
2. Nếu trình biên dịch báo lỗi (CSxxxx), đọc kỹ log lỗi, tự sửa code và build lại cho đến khi thành công.
3. Chạy lệnh cài đặt vào game:
   `stardew-mod deploy`
