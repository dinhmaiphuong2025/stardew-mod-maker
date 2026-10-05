# Hướng Dẫn 03: Quy Trình VibeCoding Tạo Mod Bằng AI

VibeCoding là phương pháp phát triển phần mềm bằng cách truyền đạt ý tưởng bằng ngôn ngữ tự nhiên thông qua AI, để AI tự động chuyển hóa thành mã nguồn kỹ thuật chuẩn xác.

Toàn bộ quá trình diễn ra bên trong không gian làm việc của người dùng (`~/stardew-workspace/mods/`), đảm bảo quyền sở hữu file thuộc tài khoản người dùng thông thường, không bị vướng quyền root.

---

## Hai phương thức VibeCoding phổ biến

### Cách 1: Sử dụng OpenCode AI CLI (Khuyên dùng - Miễn phí & Tự động)

OpenCode là trợ lý AI mã nguồn mở chạy trực tiếp trong terminal Linux, hoàn toàn miễn phí và cực kỳ dễ sử dụng:

1. Di chuyển vào thư mục mod vừa tạo:
   ```bash
   cd ~/stardew-workspace/mods/SieuCauCa
   ```
2. Khởi chạy OpenCode:
   ```bash
   opencode
   ```
3. Ra lệnh trực tiếp cho OpenCode bằng tiếng Việt:
   > "Hãy đọc file ../../VIBECODE_PROMPT_TEMPLATE.md và giúp tôi viết tính năng: Mỗi khi thức dậy, hồi phục 100% thể lực và tặng 500 vàng. Hãy sửa trực tiếp vào file ModEntry.cs rồi chạy lệnh stardew-mod build để kiểm tra."
4. OpenCode sẽ tự động phân tích cấu trúc dự án, tự điền code và tự chạy build. Bạn không cần phải copy-paste thủ công.
5. Sau khi OpenCode hoàn thành, chỉ cần thoát và gõ:
   ```bash
   stardew-mod deploy
   ```

---

### Cách 2: Sử dụng Web AI (ChatGPT, Claude, Gemini)

Nếu bạn quen dùng các trang web AI trên trình duyệt:

1. Khởi tạo dự án mod:
   ```bash
   stardew-code
   stardew-mod new SieuCauCa
   ```
2. Mở file `VIBECODE_PROMPT_TEMPLATE.md` trong thư mục `~/stardew-workspace/`, sao chép toàn bộ nội dung khuôn mẫu và gửi kèm ý tưởng tính năng cho AI.
3. Nhận mã nguồn C# từ AI và cập nhật vào file:
   ```bash
   cd ~/stardew-workspace/mods/SieuCauCa
   nano ModEntry.cs
   ```
   (Hoặc mở app Acode / MT Manager trên Android vào `stardew-workspace/mods/SieuCauCa/ModEntry.cs` để dán).
4. Chạy kiểm tra và cài đặt:
   ```bash
   stardew-mod build
   stardew-mod deploy
   ```

---

## Xử lý khi gặp lỗi biên dịch

Nếu xảy ra lỗi biên dịch:
- Với OpenCode CLI: Chỉ cần nói: "Lệnh build bị lỗi, hãy đọc thông báo và sửa lại cho tôi".
- Với Web AI: Sao chép toàn bộ đoạn báo lỗi màu đỏ trong terminal, dán cho AI và yêu cầu viết lại file `ModEntry.cs` đã khắc phục.
