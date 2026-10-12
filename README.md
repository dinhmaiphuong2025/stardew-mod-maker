# Stardew Valley Cinderbox Modding Kit (PRoot Android)

Bộ công cụ thử nghiệm hỗ trợ làm mod C# SMAPI cho Stardew Valley 1.6 trên Android Cinderbox với sự trợ giúp của AI Coding Agent (VibeCoding).

> 💡 **Ghi chú**: Dự án này là một thể nghiệm mã nguồn mở phi lợi nhuận, được xây dựng và tinh chỉnh trong quá trình tác giả tự vọc vạch làm mod cùng AI Agent.

---

## Lưu Ý Quan Trọng & Giới Hạn Thực Tế (Vui Lòng Đọc Kỹ)

Trước khi bắt đầu, xin hãy hiểu đúng bản chất của công cụ và phương pháp VibeCoding:

1. **Yêu cầu kiến thức nền tảng theo mức độ ưu tiên**:
   - **[BẮT BUỘC — ĐIỀU KIỆN TIÊN QUYẾT] Kiến thức hệ điều hành & tệp tin**:
     - Bạn **bắt buộc** phải hiểu các khái niệm tin học căn bản (đã có trong giáo trình THCS/THPT): **Đường dẫn (Path)**, **Thư mục (Folder / Directory)** và **Tệp tin (File)**; hiểu được mod được tạo ở đâu trong máy và game đọc mod từ thư mục nào.
     - *Lời khuyên chân thành*: Nếu ngay cả khái niệm thư mục hay đường dẫn tệp tin bạn cũng chưa nắm được, bạn **nên dừng lại** và bổ sung kiến thức tin học cơ bản trước. Nếu không, bạn sẽ không thể biết file mod nằm ở đâu, game bị lỗi ở chỗ nào hay log lưu ở đâu, dẫn đến bế tắc và lãng phí thời gian.
   - **[KHUYẾN KHÍCH — HỌC DẦN TRONG QUÁ TRÌNH DÙNG] Lệnh dòng lệnh cơ bản**:
     - Các lệnh Linux/Termux quen thuộc như `cd` (chuyển thư mục), `ls` (xem danh sách file), `pwd` (xem vị trí hiện tại): **Biết thì càng tốt, chưa biết cũng không sao**. Bạn hoàn toàn có thể tự tra cứu hoặc hỏi AI giải thích ngay trong lúc làm.
   - **[KỸ NĂNG QUAN TRỌNG] Đọc thông báo & Kiên nhẫn**:
     - Không hoảng sợ khi thấy thông báo lỗi, biết mở file log SMAPI (`stardew-mod logs`) và mô tả lại hiện tượng cho AI sửa tiếp.
2. **AI không phải là phép thuật "một chạm ăn ngay"**:
   - AI Agent (đặc biệt là các mô hình miễn phí như Big Pickle, Muse Spark) có giới hạn về năng lực suy luận.
   - Khi bạn đưa ra một ý tưởng, việc mod phát sinh lỗi biên dịch, lỗi tọa độ hiển thị hoặc chưa hoạt động đúng ý ở 1–3 lần thử đầu tiên là **hoàn toàn bình thường**. Bạn cần kiên nhẫn phản hồi hiện tượng trong game để AI đọc log và sửa lại mã nguồn (theo quy trình vòng lặp tại `VIBECODE_PROMPT_TEMPLATE.md`).
3. **Lựa chọn Model: Miễn Phí vs Trả Phí (Bring Your Own Key)**:
   - **Model miễn phí** (Big Pickle, Muse Spark trên OpenCode; Gemini Free Tier trên Antigravity): Tiết kiệm chi phí, thích hợp để trải nghiệm và làm các tính năng nhỏ. Đổi lại, bạn cần kiên nhẫn sửa lỗi qua lại nhiều lần hơn.
   - **Mô hình đầu bảng đỉnh cao (Frontier Flagship)** (như Claude Fable 5 / Fable 5.1, Claude Opus 4 / 4.8, OpenAI GPT-5.6 Sol, GPT-5, DeepSeek-R1): Sở hữu năng lực tư duy kiến trúc sâu, tự kiểm thử và sửa lỗi C# SMAPI ở đẳng cấp cao nhất, tỷ lệ tạo mod thành công ngay lần đầu vượt trội. Bạn có thể tự cấp API Key cá nhân hoặc kết nối tài khoản bản quyền tương ứng.
   - **Bảo mật**: Tuyệt đối **không bao giờ dán hay đẩy (commit) API Key cá nhân lên GitHub public** để tránh bị đánh cắp tài khoản. Hãy lưu key vào file môi trường cục bộ trong máy.
4. **Tinh thần mã nguồn mở**:
   - Dự án được chia sẻ miễn phí với tinh thần cùng thử nghiệm, học hỏi và đóng góp. Xin vui lòng không kỳ vọng đây là một sản phẩm thương mại hoàn chỉnh không có lỗi. Nếu gặp lỗi, hãy bình tĩnh kiểm tra log (`stardew-mod logs`) và cùng nhau tìm hướng giải quyết!

---

## 1. Chuẩn Bị & Link Tải Ứng Dụng

Trước khi bắt đầu, bạn cần cài đặt các ứng dụng sau trên điện thoại:

1. **Ứng dụng Termux** *(Lưu ý: Không tải từ Google Play Store vì bản Play Store đã ngừng cập nhật từ lâu và bị lỗi kho gói)*:
   - [Termux trên GitHub Releases](https://github.com/termux/termux-app/releases) (Bản chính thức)
   - [Termux trên F-Droid](https://f-droid.org/packages/com.termux/) (Bản chính thức)
   - [Bản Termux Custom](https://github.com/dinhmaiphuong2025/termux-app/releases) (Tùy chọn giao diện)

2. **Trình chạy Cinderbox (Chạy Stardew Valley PC trên Android)**:
   - Tải file APK tại [GitHub Cinderbox v0.8.1 Releases](https://github.com/Ekyso/Cinderbox/releases/tag/0.8.1)

3. **Dữ liệu Game Stardew Valley**:
   - **Có tài khoản Steam**: Đăng nhập Steam trực tiếp bên trong Cinderbox để tải game chính chủ.
   - **Chưa có tài khoản Steam**: Tải file game cài sẵn từ nhóm Telegram cộng đồng:
     - [Link tải file game Stardew Valley](https://t.me/c/3796677936/14/13555)
     - [Nhóm Telegram Cộng đồng Stardew Valley VN](https://t.me/+aJTLlA0Lqzk2MThl) *(hướng dẫn cài mod, game, Việt hóa...)*

---

## 2. Cài Đặt (1 Lệnh Duy Nhất)

Mở ứng dụng **Termux** và dán dòng lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh | bash
```

- Nhập tên người dùng khi được hỏi (ví dụ: `stardew`).
- Chọn Cho phép (Allow) khi Android hỏi quyền truy cập bộ nhớ thiết bị.

---

## 3. Làm Mod Bằng AI (Thuần VibeCoding)

Mỗi khi muốn tạo mod mới, bạn mở Termux và gõ:

```bash
ubuntu
```

---

### Bước 1: Cài đặt AI Coding Agent

Gõ lệnh sau để mở bảng chọn Agent:

```bash
stardew-mod agent
```

Hệ thống sẽ hiển thị menu để bạn chọn:
- Nhấn `1`: **OpenCode CLI v2** *(Mô hình đám mây miễn phí: Big Pickle, Muse Spark hoặc kết nối API Key tùy ý)*
- Nhấn `2`: **Antigravity CLI** *(Tài khoản Google — miễn phí có hạn mức hàng ngày với Gemini 2.5 Pro / Flash)*
- Nhấn `3`: **Claude Code** *(Sử dụng Claude Fable 5, Claude Opus 4 / 4.8 — yêu cầu tài khoản Claude Pro/Team/Enterprise hoặc Anthropic API Key)*
- Nhấn `4`: **Codex CLI** *(Coding Agent chính thức từ OpenAI — sử dụng GPT-5.6 Sol, GPT-5 qua tài khoản ChatGPT hoặc OpenAI API Key)*
- Nhấn `5`: **Hermes Agent CLI** *(Mã nguồn mở từ Nous Research, hỗ trợ kết nối mọi mô hình đầu bảng)*

*(Mẹo: Bạn cũng có thể cài nhanh trực tiếp bằng lệnh `stardew-mod agent opencode` hoặc `stardew-mod agent antigravity`).*

Sau khi cài xong, bạn chỉ cần nhấn **Enter**, màn hình sẽ tự động xoá sạch để bạn gõ lệnh khởi động Agent (ví dụ: `opencode` hoặc `agy`).

*(Lưu ý: Với các Agent yêu cầu đăng nhập như Claude Code hoặc Codex, bạn xác thực tài khoản chính chủ qua trình duyệt/mã thiết bị hoặc nhập API Key trực tiếp trong terminal; không lưu khóa vào tệp công khai).*

---

### Bước 2: Ra lệnh cho AI tạo mod (Prompt mẫu khi làm mod mới)

Mở Agent vừa cài (ví dụ: `opencode`) và mô tả ý tưởng bằng tiếng Việt:

> **"Tạo cho tôi mod HaloGlowMod: Thêm hiệu ứng vòng tròn ánh sáng trắng phát quang (glow) quanh nhân vật theo phong cách thần thoại. Hãy tự tạo mod bằng stardew-mod, viết toàn bộ code C#, tự build sửa lỗi và deploy thẳng vào game cho tôi."**

*(Xem chi tiết cẩm nang cơ chế mod, từ điển thuật ngữ game và công thức prompt 3 bước tại file [VIBECODE_PROMPT_TEMPLATE.md](VIBECODE_PROMPT_TEMPLATE.md)).*

Trợ lý AI sẽ tự động xử lý toàn bộ:
1. Tự khởi tạo khung dự án mod C# SMAPI.
2. Viết mã nguồn logic đồ họa và sự kiện game.
3. Tự biên dịch và tự sửa lỗi nếu phát sinh.
4. Tự đưa mod vào đúng thư mục game Stardew Valley.

Khi AI báo xong, bạn chỉ cần mở game **Stardew Valley** trên điện thoại lên và chơi!

---

### Bước 3: Quay lại tiếp tục làm mod sau khi tắt Termux

Khi bạn tắt ứng dụng Termux, khởi động lại điện thoại hoặc thoát game ra làm việc khác, toàn bộ mã nguồn mod của bạn **vẫn được lưu nguyên vẹn** tại `~/stardew-workspace/mods/<TênMod>/`.

Để tiếp tục phát triển hoặc sửa lỗi mod cũ:

1. Mở Termux, gõ:
   ```bash
   ubuntu
   ```
2. Xem lại danh sách mod hiện có:
   ```bash
   stardew-mod list
   ```
3. Di chuyển thẳng vào thư mục của bản mod đó và khởi động AI Agent:
   ```bash
   cd mods/<TênMod>
   opencode   # hoặc agy / claude
   ```
4. Ra lệnh cho AI tiếp tục hoàn thiện (không cần bảo AI tạo mới):
   > **"Tiếp tục nâng cấp mod này: [mô tả tính năng muốn thêm hoặc lỗi vừa thấy trong game]. Hãy tự xem mã nguồn hiện tại trong ModEntry.cs, tự sửa code, tự chạy stardew-mod build và deploy lại vào game cho tôi."**

*(Mẹo: Nếu game vừa bị văng (crash), hãy bảo AI: `"Game vừa bị crash, hãy tự chạy stardew-mod logs 50 để đọc log SMAPI và sửa lỗi giúp tôi."`)*

---

## 4. Danh Sách Lệnh `stardew-mod` Đầy Đủ

Bộ công cụ `stardew-mod` được cài đặt sẵn trong `PATH` của môi trường Ubuntu. Bạn hoặc AI có thể gọi trực tiếp các lệnh sau:

| Lệnh | Chức năng chi tiết |
|---|---|
| `stardew-mod help` | Hiển thị bảng hướng dẫn cú pháp và mô tả đầy đủ các lệnh |
| `stardew-mod` | Mở menu bảng điều khiển tương tác trực quan bằng phím số |
| `stardew-mod doctor [--json]` | Kiểm tra môi trường hệ thống: .NET 10.0 SDK, game files, SMAPI và bộ nhớ `/sdcard` |
| `stardew-mod agent [TênAgent]` | Cài đặt nhanh AI Coding Agent (`opencode`, `antigravity`, `claude`, `codex`, `hermes`) |
| `stardew-mod new <TênMod>` | Khởi tạo dự án mod mới tại `mods/<TênMod>/` theo template SMAPI net10.0 chuẩn |
| `stardew-mod build [ĐườngDẫn]` | Biên dịch mã nguồn C# ra file DLL Release (mặc định tại thư mục hiện tại) |
| `stardew-mod deploy [ĐườngDẫn]` | Đóng gói DLL, manifest và copy thẳng vào `/sdcard/StardewValley/desktop/Mods/` |
| `stardew-mod list` | Liệt kê danh sách dự án mod trong workspace và danh sách mod đã cài trong game |
| `stardew-mod logs [SốDòng]` | Đọc file log SMAPI mới nhất (`smapi-crash.txt`, `smapi-log.txt`) để chẩn đoán lỗi |
| `stardew-mod update` | Tải và cập nhật bộ script `stardew-mod` và `ui.sh` lên phiên bản mới nhất từ GitHub |

---

## 5. Minh Chứng Thực Tế Được Tạo Bằng VibeCoding (Showcase)

Dưới đây là các dự án mod thực tế hoàn chỉnh đã được phát triển, kiểm thử và đóng gói trực tiếp bằng phương pháp VibeCoding trên môi trường di động này:

1. **[Forage & NPC Radar](https://github.com/dinhmaiphuong2025/Forage-Radar)** (SMAPI C# Mod):
   - Mod radar dò tìm vật phẩm thu lượm theo mùa, điểm đào giun (Artifact Spot), bụi dâu rừng và theo dõi Dân Làng (NPC Tracker) thời gian thực trên bản đồ.
   - Vòng tròn radar neo trong không gian thế giới (world-space), cơ chế ẩn icon thông minh khi mục tiêu đã vào tầm mắt và giao diện quản lý 2 tab tối ưu màn hình cảm ứng.

2. **[Saiyan Pod Teleport](https://github.com/dinhmaiphuong2025/SaiyanPodTeleport)** (SMAPI C# Mod):
   - Mod dịch chuyển không gian lấy cảm hứng từ Dragon Ball với chuỗi hoạt cảnh cinematic điện ảnh (tàu rơi bốc khói lửa, rung chấn màn hình, mở buồng lái).
   - Hỗ trợ 18 điểm dịch chuyển toàn bộ Thung lũng Pelican và Quần đảo Ginger, tính năng ghim tọa độ hạ cánh tùy ý và menu chia tab ngang chống chạm nhầm trên mobile.

3. **[[CP] Chrono Merchant](https://github.com/dinhmaiphuong2025/ChronoMerchant)** (Content Patcher Add-on):
   - Mod NPC độc lập bổ sung Thương Nhân Thời Không du mục xuất hiện tại Rừng Cindersap bán các dòng Saiyan Remote và vật phẩm quý hiếm.
   - Tích hợp hiệu ứng xé rách không gian vũ trụ, hoạt ảnh búng đồng xu và lịch trình làm việc độc lập.

---

## 6. Nhật Ký Quá Trình Thử Nghiệm

Bộ công cụ, kịch bản PRoot Ubuntu và các tài liệu này được hình thành trong quá trình tác giả **thử nghiệm phương pháp VibeCoding** trực tiếp trên điện thoại cùng AI Agent:
- **Tự động hóa trên di động**: Dùng AI để sinh mã nguồn Bash, thiết kế TUI Termux gọn gàng cho màn hình cảm ứng, cấu hình SDK .NET và SMAPI.
- **Vòng lặp sửa lỗi thực tế**: Quá trình phát triển đã phải trải qua nhiều lần thử-và-sai để tìm ra các giải pháp cho lỗi tràn RAM ảo GC 256 GiB, thiếu MonoGame hay lệch tọa độ cảm ứng UI Scale.
- **Thông điệp**: AI là công cụ hỗ trợ đắc lực để biến ý tưởng thành mã nguồn, nhưng thành quả luôn đòi hỏi sự kiên nhẫn kiểm thử và phản hồi của người thực hiện.

---

## 7. Định Hướng Hỗ Trợ Đa Nền Tảng (PC & Mobile 1.6)

Template mặc định được thiết kế với mục tiêu thân thiện cho cả hai môi trường:
- **Stardew Valley 1.6+**: Nhắm đến hệ sinh thái SMAPI 4.x hiện đại.
- **Cơ chế điều khiển linh hoạt**:
  - Hỗ trợ phím bấm bàn phím (mặc định `F5`, có thể đổi trong `config.json`).
  - Hỗ trợ nút bấm cảm ứng HUD (`MobileTouchButton`) tự co giãn theo tỷ lệ giao diện (`Game1.options.uiScale`).
- *Lưu ý*: Tùy thuộc vào độ phức tạp của từng tính năng, bạn có thể cần tự kiểm thử và điều chỉnh thêm trên từng thiết bị để đạt trải nghiệm ưng ý nhất.

---

## 8. Đóng Góp & Chia Sẻ Ý Tưởng Cùng Cộng Đồng

Dự án được mở hoàn toàn miễn phí vì mục đích học hỏi và chia sẻ kinh nghiệm:

- **Cùng kiểm thử thiết bị**: Nếu bạn thử nghiệm trên các dòng chip khác nhau (Snapdragon, MediaTek, Exynos), hãy chia sẻ trải nghiệm để cùng tối ưu script.
- **Báo lỗi & Đóng góp giải pháp**: Khi gặp lỗi lạ hoặc tìm ra cách sửa lỗi hay, hãy mở [Issue](https://github.com/dinhmaiphuong2025/stardew-mod-maker/issues) hoặc gửi Pull Request để cùng hoàn thiện bộ công cụ.
- **Giao lưu & Hỗ trợ**: Tham gia nhóm Telegram cộng đồng để trao đổi kinh nghiệm vọc vạch mod và chia sẻ các bản mod bạn tự làm được!

---

---

## HƯỚNG DẪN GỠ CÀI ĐẶT (UNINSTALL & RESET)

Nếu bạn muốn dọn sạch toàn bộ môi trường để kiểm thử lại từ đầu, hoặc muốn giải phóng dung lượng bộ nhớ khi không còn nhu cầu sử dụng:

### 1. Lệnh gỡ cài đặt tự động (1 dòng duy nhất)

Mở **Termux** và dán lệnh sau:

```bash
curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/uninstall.sh | bash
```

*(Nếu muốn chạy tự động bỏ qua bước hỏi xác nhận: thêm cờ `-y` vào cuối).*

### 2. Kịch bản gỡ cài đặt sẽ làm những gì?
- **Gỡ bỏ hoàn toàn container PRoot Ubuntu** và toàn bộ công cụ lập trình bên trong (.NET SDK, OpenCode, thư viện tạm).
- **Xóa các lệnh tắt trên Termux** (`ubuntu`, `stardew-code`) để đưa Termux về trạng thái sạch sẽ ban đầu.
- **Dọn sạch các cấu hình mount** liên kết bộ nhớ.
- Hiển thị thanh tiến trình tinh gọn (`[▆▆▆▆▆▆▆▆▆▆] 100%`) trực quan và báo kết quả rõ ràng.

### 3. Cam kết an toàn dữ liệu
- **Bảo lưu an toàn 100%**: Thư mục game gốc, các file save và toàn bộ mod bạn đã cài đặt tại `/sdcard/StardewValley` **hoàn toàn KHÔNG bị ảnh hưởng hay xóa mất**.
- Bạn có thể chạy lại lệnh cài đặt bất cứ lúc nào mà không phải lo mất tiến trình chơi game!
