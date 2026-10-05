# Hướng Dẫn 03: Quy Trình VibeCoding Tạo Mod Bằng AI

VibeCoding là phương pháp phát triển phần mềm bằng cách truyền đạt ý tưởng bằng ngôn ngữ tự nhiên thông qua AI, để AI tự động chuyển hóa thành mã nguồn kỹ thuật chuẩn xác.

Dưới đây là quy trình 5 bước để tạo một bản mod hoàn chỉnh cho Cinderbox Android.

---

## Quy trình 5 bước thực hiện

### Bước 1: Khởi tạo dự án mod mới
Mở Termux và thực thi:
```bash
stardew-code
stardew-mod new SieuCauCa
```
(Thay `SieuCauCa` bằng tên mod mong muốn, viết liền không dấu).

Thư mục dự án sẽ được tạo tại `/root/stardew-workspace/mods/SieuCauCa`.

---

### Bước 2: Chuẩn bị nội dung yêu cầu
Mô tả rõ ràng hành vi của mod:
- Mức độ cơ bản: Tự động tưới cây, điều chỉnh tốc độ di chuyển, hồi phục thể lực khi nghỉ ngơi.
- Mức độ trung bình: Hiển thị radar tìm kiếm tài nguyên rơi trên bản đồ, hiển thị mức độ tình cảm của dân làng.
- Mức độ nâng cao: Bổ sung menu nút bấm cảm ứng, chèn thêm vật phẩm mới vào cửa hàng Pierre.

---

### Bước 3: Sử dụng khuôn mẫu Prompt
Mở file `VIBECODE_PROMPT_TEMPLATE.md` có sẵn trong thư mục làm việc, sao chép toàn bộ nội dung khuôn mẫu kèm theo yêu cầu tính năng của bạn và gửi cho AI (Claude, ChatGPT, Gemini, DeepSeek).

Khuôn mẫu này đảm bảo AI tuân thủ đúng phiên bản `net10.0`, cấu trúc API của Stardew Valley 1.6 và quy chuẩn cảm ứng màn hình trên thiết bị di động.

---

### Bước 4: Lưu mã nguồn vào mod
AI sẽ cung cấp mã nguồn hoàn chỉnh của file `ModEntry.cs`. Bạn có thể cập nhật vào file theo một trong hai cách:

- Cách 1: Dùng trình soạn thảo trong terminal:
  ```bash
  cd /root/stardew-workspace/mods/SieuCauCa
  nano ModEntry.cs
  ```
  Xóa nội dung cũ, dán mã nguồn mới, nhấn `Ctrl + O` rồi `Enter` để lưu và `Ctrl + X` để thoát.

- Cách 2: Dùng ứng dụng quản lý tệp trên Android:
  Mở MT Manager, ZArchiver hoặc Acode, tìm đến thư mục mod tương ứng và chỉnh sửa tệp như file văn bản thông thường.

---

### Bước 5: Biên dịch và cài đặt vào game
Tại thư mục của mod, chạy hai lệnh:

```bash
stardew-mod build
stardew-mod deploy
```

- Lệnh `build`: Biên dịch mã nguồn C# thành file nhị phân `.dll`.
- Lệnh `deploy`: Chuyển file kết quả vào thư mục `/sdcard/StardewValley/desktop/Mods/SieuCauCa`.

Sau khi hoàn tất, mở game Stardew Valley trên Cinderbox để kiểm tra.

---

## Xử lý khi gặp lỗi biên dịch

Nếu lệnh `stardew-mod build` trả về thông báo lỗi:

1. Sao chép toàn bộ khối văn bản báo lỗi trên màn hình terminal.
2. Gửi lại cho AI kèm chỉ dẫn:
   > "Quá trình biên dịch báo lỗi sau đây. Hãy phân tích nguyên nhân và cung cấp lại file ModEntry.cs hoàn chỉnh đã được sửa lỗi: [Dán nội dung lỗi vào đây]"
3. Cập nhật lại file `ModEntry.cs` và tiến hành biên dịch lại.
