# KHUÔN MẪU PROMPT VIBECODING DÀNH CHO AI (CHATGPT / CLAUDE / GEMINI)
> Dành cho người không biết code: Mỗi khi bạn muốn tạo một tính năng mod mới, hãy copy toàn bộ nội dung bên dưới và gửi kèm ý tưởng của bạn cho AI!

---

```markdown
Chào AI, tôi đang phát triển một bản mod C# SMAPI cho game Stardew Valley 1.6 chạy trên thiết bị di động Android thông qua Cinderbox.
Tôi không rành về lập trình, hãy đóng vai trò là một kỹ sư C# SMAPI chuyên nghiệp và giúp tôi viết code hoàn chỉnh cho tính năng này.

### YÊU CẦU TÍNH NĂNG CỦA TÔI:
[Mô tả ý tưởng của bạn ở đây. Ví dụ:
- Mỗi khi trời mưa, tự động tưới toàn bộ cây trên nông trại và tăng 10% tốc độ chạy.
- Tạo một menu chạm trên màn hình cho phép xem độ thân thiết của dân làng kèm avatar.
- Bấm vào nhân vật để hiển thị danh sách vật phẩm yêu thích của NPC đó.]

---

### CÁC NGUYÊN TẮC BẮT BUỘC TRONG MÔI TRƯỜNG CINDERBOX ANDROID (AI PHẢI TUÂN THỦ TUYỆT ĐỐI):

1. **Phiên bản & SDK Runtime:**
   - Game chạy trên nền Cinderbox Android (.NET 10.0 aarch64). TargetFramework bắt buộc là `<TargetFramework>net10.0</TargetFramework>`.
   - KHÔNG sử dụng `net6.0` hay `net8.0` (sẽ gây lỗi xung đột assembly CS1705 với StardewModdingAPI).
   - KHÔNG sử dụng NuGet `Pathoschild.Stardew.ModBuildConfig` (sẽ lỗi đường dẫn trên Android). Tham chiếu trực tiếp DLL từ `/sdcard/StardewValley/desktop/GameFiles/` và `/sdcard/StardewValley/smapi-internal/`.

2. **Quy chuẩn Cảm ứng & Giao diện Điện thoại (Mobile Touch UX):**
   - Màn hình điện thoại là cảm ứng chạm: KHÔNG giả định người chơi có chuột phải hay phím bấm vật lý.
   - Khi bắt sự kiện bấm nút (`ButtonPressed`), luôn kiểm tra cả `e.Button.IsUseToolButton()` và `e.Button == SButton.MouseLeft`.
   - Vùng bấm (hitbox) của nút bấm/icon tối thiểu phải từ 48px - 64px để ngón tay chạm dễ dàng.
   - KHÔNG dùng `TextBox` của PC khi muốn nhập chữ (bàn phím ảo Android sẽ không mở ra). Bắt buộc dùng `TitleTextInputMenu` nếu cần nhập text.
   - Dùng `Game1.dialogueFont` hoặc `Game1.smallFont` có scale phù hợp cho text; tránh `tinyFont` vì bị lỗi khoảng cách chữ trên mobile.

3. **Tương thích Stardew Valley 1.6:**
   - Sử dụng đúng API 1.6: Buffs nằm trong namespace `StardewValley.Buff` và chỉ số trong `StardewValley.Buffs.BuffEffects`.
   - Đăng ký vật phẩm mới hoặc sửa shop qua sự kiện `helper.Events.Content.AssetRequested` (`Data/Objects`, `Data/Shops`).
   - Kiểm tra `Context.IsWorldReady` trước khi truy cập `Game1.player` hoặc `Game1.currentLocation`.

4. **Định dạng kết quả trả về:**
   - Hãy trả về toàn bộ mã nguồn file `ModEntry.cs` hoàn chỉnh, có chú thích tiếng Việt rõ ràng.
   - Nếu cần cập nhật file `manifest.json` hoặc thêm class mới, hãy cung cấp đầy đủ nội dung từng file.
   - Hướng dẫn tôi chính xác vị trí lưu file và lệnh biên dịch (`stardew-mod build` / `stardew-mod deploy`).
```
