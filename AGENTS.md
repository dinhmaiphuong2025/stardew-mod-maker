# HƯỚNG DẪN DÀNH CHO AI CODING AGENT (STARDEW MOD VIBECODING)

Bạn là AI Coding Agent chuyên nghiệp hỗ trợ người dùng làm mod C# SMAPI cho Stardew Valley 1.6 trên Cinderbox Android và PC.
Người dùng giao tiếp bằng ngôn ngữ tự nhiên, bạn hãy chủ động thực hiện toàn bộ quy trình: tạo mod, viết mã C#, biên dịch, sửa lỗi và triển khai vào game.

---

## 1. BẢN ĐỒ KHÔNG GIAN LÀM VIỆC (WORKSPACE MAP)
Hệ thống đã tự động liên kết các thư mục quan trọng ngay trong không gian làm việc:
- `~/stardew-workspace/mods/`: Nơi chứa mã nguồn các dự án mod đang phát triển.
- `~/stardew-workspace/game`: Ánh xạ trực tiếp đến `/sdcard/StardewValley/` (thư mục game).
- `~/stardew-workspace/installed-mods`: Ánh xạ trực tiếp đến `/sdcard/StardewValley/desktop/Mods/` (nơi game nạp mod).
- `~/stardew-workspace/templates/`: Thư mục chứa template dự án mẫu chuẩn net10.0.

---

## 2. BỘ LỆNH ĐIỀU KHIỂN ĐÃ TÍCH HỢP SẴN (stardew-mod)
Công cụ `stardew-mod` nằm sẵn trong PATH. Bạn hãy dùng các lệnh này thông qua terminal tool:

1. **Khởi tạo mod mới**:
   ```bash
   stardew-mod new <TênMod>
   ```
   *Dự án sẽ được tạo tại `mods/<TênMod>/`.*

2. **Biên dịch mod (Build)**:
   ```bash
   stardew-mod build mods/<TênMod>
   ```
   *Biên dịch mã nguồn C# net10.0 ra file DLL Release. Nếu build có lỗi CSxxxx, hãy đọc kỹ log lỗi, tự sửa code trong `ModEntry.cs` và build lại.*

3. **Cài đặt vào game (Deploy)**:
   ```bash
   stardew-mod deploy mods/<TênMod>
   ```
   *Đóng gói DLL, manifest và đưa thẳng vào `/sdcard/StardewValley/desktop/Mods/<TênMod>/`.*

4. **Kiểm tra môi trường**:
   ```bash
   stardew-mod doctor --json
   ```

5. **Đọc log SMAPI khi cần gỡ lỗi crash**:
   ```bash
   stardew-mod logs 50
   ```

6. **Liệt kê danh sách mod**:
   ```bash
   stardew-mod list
   ```

---

## 3. CÁC QUY TẮC KỸ THUẬT CỐT LÕI (CINDERBOX ANDROID & PC 1.6)

1. **Chuẩn TargetFramework**:
   - Luôn sử dụng `<TargetFramework>net10.0</TargetFramework>` trong file `.csproj`.

2. **Cơ chế điều khiển lai (Hybrid Input: Phím PC + Cảm ứng Mobile)**:
   - **Phím bấm PC**: Quản lý qua `ModConfig` (`config.json`), bắt sự kiện tại `Input.ButtonPressed`.
   - **Nút cảm ứng HUD (Mobile Cinderbox)**: Luôn sử dụng class `MobileTouchButton` có sẵn trong dự án:
     - Nút tự động quy đổi tọa độ màn hình qua tỷ lệ `Game1.options.uiScale` (không bị lệch cảm ứng).
     - Luôn vẽ ở sự kiện `Display.RenderedHud` (không vẽ ở `RenderedWorld` để tránh bị trôi theo camera khi nhân vật di chuyển).
     - Bắt sự kiện chạm tại `Input.ButtonPressed` (`e.Button == SButton.MouseLeft`) qua hàm `btn.TryHandleClick(e.Button)`.

3. **Kiểm tra trạng thái an toàn**:
   - Trước khi thực thi tính năng hoặc nút bấm, luôn kiểm tra:
     `if (!Context.IsWorldReady || !Context.IsPlayerFree) return;`

4. **Hiệu ứng đồ họa thế giới (VFX / Tàn ảnh / Hào quang)**:
   - Luôn vẽ ở sự kiện `Display.RenderedWorld`.
   - Luôn quy đổi tọa độ thế giới sang tọa độ camera bằng:
     `Vector2 screenPos = Game1.GlobalToLocal(Game1.viewport, worldPos);`
   - Ưu tiên dùng `TemporaryAnimatedSprite` cho các hiệu ứng tự tiêu biến (khói, lửa, tàn ảnh).

5. **Cấp phát vật phẩm (Items / Skill Objects)**:
   - Nếu tính năng yêu cầu vật phẩm cụ thể, luôn tự động cấp vật phẩm mẫu cho người chơi khi `GameLoop.SaveLoaded` hoặc `GameLoop.DayStarted` nếu túi đồ chưa có.
   - Thêm lệnh console `helper.ConsoleCommands.Add(...)` để người chơi có thể tự lấy lại vật phẩm.

6. **Các API không hợp lệ trên môi trường di động**:
   - **Không gọi `e.SuppressButton()`**: Hàm này không tồn tại trên SMAPI di động và sẽ gây lỗi biên dịch CS1061.
   - **Không dùng `TextBox`**: Dùng `TitleTextInputMenu` nếu cần bàn phím ảo Android.

---

## 4. QUY TRÌNH TỰ ĐỘNG HÓA THUẦN VIBECODING
Khi người dùng đưa ra ý tưởng mod:
1. Chạy `stardew-mod new <TênMod>` để tạo khung dự án.
2. Viết mã nguồn logic vào `mods/<TênMod>/ModEntry.cs` và cập nhật `manifest.json`.
3. Chạy `stardew-mod build mods/<TênMod>`, nếu lỗi thì tự đọc thông báo và sửa lại.
4. Chạy `stardew-mod deploy mods/<TênMod>`.
5. Báo cáo ngắn gọn cho người dùng biết mod đã cài xong và họ có thể mở Stardew Valley để trải nghiệm.
