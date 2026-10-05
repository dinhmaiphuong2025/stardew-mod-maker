# Bước 3: Bí Kíp "VibeCoding" Tạo Mod Cho Người Không Biết Code

"VibeCoding" là phong cách tạo ra phần mềm bằng cách trò chuyện với Trí tuệ Nhân tạo (AI) bằng ngôn ngữ tự nhiên (tiếng Việt thông thường) thay vì phải tự tay viết từng dòng code phức tạp.

Dưới đây là quy trình 5 bước đơn giản để bạn tự tay tạo một bản mod Stardew Valley hoàn chỉnh chỉ trong 5 phút!

---

## Quy Trình 5 Bước VibeCoding

### Bước 1: Tạo dự án mod mới trong 1 giây
Mở Termux, gõ:
```bash
stardew-code
stardew-mod new SieuCauCa
```
*(Thay `SieuCauCa` bằng tên mod bạn thích, viết liền không dấu).*

Hệ thống sẽ tự động tạo thư mục `/root/stardew-workspace/mods/SieuCauCa` với đầy đủ cấu trúc chuẩn.

---

### Bước 2: Chuẩn bị ý tưởng
Hãy nghĩ xem bạn muốn mod làm gì. Càng mô tả chi tiết, AI viết càng chính xác:
- **Ý tưởng đơn giản:** Tự động tưới cây, tăng tốc chạy, hồi thể lực khi đứng yên...
- **Ý tưởng trung bình:** Tự động hiển thị radar chỉ đường tới các vật phẩm rơi dưới đất, hiển thị tim tình cảm của dân làng...
- **Ý tưởng nâng cao:** Thêm menu bấm nút cảm ứng trên màn hình, thêm vật phẩm mới vào shop của Pierre...

---

### Bước 3: Sử dụng Khuôn mẫu Prompt
Mở file `VIBECODE_PROMPT_TEMPLATE.md` có sẵn trong thư mục làm việc (hoặc copy từ tài liệu này), điền ý tưởng của bạn vào và gửi cho AI:
- **Các AI khuyên dùng:** Claude 3.5 Sonnet / Claude 3.7, ChatGPT (GPT-4o), Gemini 1.5 Pro / 2.0 Flash, DeepSeek V3/R1.

> **Tại sao cần dùng prompt mẫu?**
> Vì các AI thông thường thường nhầm lẫn giữa Stardew Valley trên máy tính (PC) và trên điện thoại (Cinderbox). Prompt mẫu này đã tích hợp sẵn các luật thép về `net10.0`, API SMAPI 1.6, và thao tác cảm ứng màn hình để AI không bao giờ viết sai!

---

### Bước 4: Lưu code của AI vào mod
AI sẽ đưa cho bạn toàn bộ đoạn code của file `ModEntry.cs`. Bạn có 2 cách cực dễ để dán code vào:

- **Cách 1 (Dùng trình soạn thảo trong terminal):**
  ```bash
  cd /root/stardew-workspace/mods/SieuCauCa
  nano ModEntry.cs
  ```
  Xóa nội dung cũ, dán code mới của AI vào, bấm `Ctrl + O` rồi `Enter` để lưu, và `Ctrl + X` để thoát.

- **Cách 2 (Dùng ứng dụng Quản lý Tệp Android như MT Manager, ZArchiver, hoặc Acode):**
  Vì bộ nhớ đã được mount, bạn có thể mở ứng dụng quản lý tệp trên điện thoại, vào thư mục và chỉnh sửa file như một file văn bản bình thường.

*(Mẹo nâng cao: Nếu bạn cài các công cụ AI CLI như Antigravity CLI hay Claude Code bên trong Ubuntu, AI có thể tự đọc và tự sửa code trực tiếp mà bạn không cần phải copy-paste thủ công).*

---

### Bước 5: Build và Cài đặt vào game
Tại thư mục của mod, bạn chỉ cần gõ 2 lệnh ngắn:

```bash
stardew-mod build
stardew-mod deploy
```

- Lệnh `build` sẽ biên dịch mã nguồn thành file thư viện `.dll`.
- Lệnh `deploy` sẽ tự động copy mod vào đúng thư mục `/sdcard/StardewValley/desktop/Mods/SieuCauCa`.

Giờ hãy mở game Stardew Valley trên Cinderbox lên và chiêm ngưỡng thành quả của bạn!

---

## Phải Làm Gì Khi Gặp Lỗi Biên Dịch (Build Error)?

Đừng lo lắng! Trong VibeCoding, gặp lỗi là chuyện hết sức bình thường.
Nếu khi gõ `stardew-mod build` mà màn hình hiện chữ đỏ báo lỗi:

1. **Quét chọn toàn bộ thông báo lỗi màu đỏ** trên màn hình Termux và bấm Sao chép (Copy).
2. Dán vào khung chat của AI với câu lệnh:
   > *"AI ơi, khi tôi chạy lệnh build thì hệ thống báo lỗi như sau. Hãy giải thích nguyên nhân và viết lại code ModEntry.cs đã sửa cho tôi nhé: [Dán lỗi vào đây]"*
3. AI sẽ tự động phân tích và đưa lại bản code chuẩn. Bạn chỉ việc dán lại và build tiếp!
