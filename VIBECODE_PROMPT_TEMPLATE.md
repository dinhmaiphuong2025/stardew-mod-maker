# Khung Mẫu Prompt VibeCoding Cho AI (ChatGPT, Claude, Gemini)

Mỗi khi muốn tạo tính năng mod mới, sao chép toàn bộ nội dung trong khung dưới đây và gửi kèm mô tả ý tưởng cho AI:

---

```markdown
Chào AI, tôi đang phát triển một bản mod C# SMAPI cho game Stardew Valley 1.6 chạy trên thiết bị di động Android thông qua Cinderbox.
Tôi không có chuyên môn lập trình sâu, hãy đóng vai trò là kỹ sư C# SMAPI chuyên nghiệp và giúp tôi viết mã nguồn hoàn chỉnh cho tính năng này.

### YÊU CẦU TÍNH NĂNG CỦA TÔI:
[Mô tả ý tưởng tại đây. Ví dụ:
- Mỗi khi trời mưa, tự động tưới toàn bộ cây trên nông trại và tăng 10% tốc độ chạy.
- Tạo menu chạm trên màn hình hiển thị độ thân thiết của dân làng kèm chân dung.
- Hiển thị thông báo vị trí các vật phẩm nhặt được trên bản đồ.]

---

### CÁC NGUYÊN TẮC BẮT BUỘC TRONG MÔI TRƯỜNG CINDERBOX ANDROID (TUÂN THỦ TUYỆT ĐỐI):

1. Phiên bản và SDK Runtime:
   - Nền tảng thực thi là Cinderbox Android (.NET 10.0 aarch64). Thuộc tính TargetFramework bắt buộc phải là:
     <TargetFramework>net10.0</TargetFramework>
   - Không sử dụng net6.0 hoặc net8.0 (gây lỗi xung đột assembly CS1705 với StardewModdingAPI).
   - Không sử dụng NuGet Pathoschild.Stardew.ModBuildConfig. Tham chiếu trực tiếp DLL từ /sdcard/StardewValley/desktop/GameFiles/ và /sdcard/StardewValley/smapi-internal/.

2. Quy chuẩn cảm ứng và giao diện di động:
   - Thao tác trên điện thoại là chạm cảm ứng: Không mặc định người chơi có chuột phải hay phím bấm vật lý.
   - Khi bắt sự kiện bấm nút (ButtonPressed), kiểm tra đồng thời cả e.Button.IsUseToolButton() và e.Button == SButton.MouseLeft.
   - Kích thước vùng chạm tối thiểu từ 48px đến 64px để ngón tay thao tác chính xác.
   - Không dùng TextBox khi cần nhập văn bản (bàn phím ảo Android sẽ không mở). Bắt buộc dùng TitleTextInputMenu.
   - Sử dụng Game1.dialogueFont hoặc Game1.smallFont có tỷ lệ hiển thị hợp lý; tránh dùng tinyFont trên màn hình điện thoại.

3. Tương thích Stardew Valley 1.6:
   - Buffs thuộc namespace StardewValley.Buff và chỉ số thuộc StardewValley.Buffs.BuffEffects.
   - Đăng ký vật phẩm mới hoặc điều chỉnh cửa hàng thông qua helper.Events.Content.AssetRequested (Data/Objects, Data/Shops).
   - Luôn kiểm tra Context.IsWorldReady trước khi truy cập Game1.player hoặc Game1.currentLocation.

4. Định dạng kết quả trả về:
   - Trả về mã nguồn file ModEntry.cs hoàn chỉnh, kèm chú thích tiếng Việt rõ ràng.
   - Nếu cần điều chỉnh manifest.json hoặc bổ sung file class mới, cung cấp đầy đủ nội dung từng file.
   - Hướng dẫn lệnh biên dịch và triển khai (stardew-mod build, stardew-mod deploy).
```
