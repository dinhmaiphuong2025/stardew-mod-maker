# CẨM NANG VIBECODING: CƠ CHẾ MOD, ASSET & NGHỆ THUẬT RA LỆNH CHO AI

Tài liệu này dành cho **tất cả mọi người** — bạn không cần biết một dòng mã C# nào. Bạn chính là **"Đạo diễn điện ảnh" (Director)** nắm giữ kịch bản, hình ảnh và trải nghiệm trò chơi, còn việc viết code, vẽ hoạt ảnh, tính toán tọa độ hay sửa lỗi sẽ do **AI làm toàn bộ từ A đến Z**.

---

## PHẦN 1: BẢN CHẤT MOD HOẠT ĐỘNG THẾ NÀO? (GIẢI THÍCH DỄ HIỂU)

Một bản mod Stardew Valley C# SMAPI **không bao giờ đụng chạm hay làm hỏng game gốc**. Nó giống như một "trợ lý thông minh" đứng cạnh game:

1. **Vòng lặp trò chơi (Game Loop)**:
   - Game chạy liên tục 60 lần mỗi giây (mỗi lần gọi là 1 khung hình hay 1 `Tick`).
2. **Sự kiện (Events - Khi nào làm gì)**:
   - Khi bạn chơi game, các hành động diễn ra sẽ phát ra tín hiệu: *vừa ngủ dậy, vừa bước ra khỏi nhà, vừa chạm vào màn hình, vừa vào hầm mỏ*. Mod chỉ cần "nghe ngóng" tín hiệu này để kích hoạt tính năng.
3. **Hai kiểu hiển thị lên màn hình điện thoại (Render)**:
   - **Loại 1: Dính vào thế giới / nhân vật (World)**: Ví dụ như phi thuyền đáp xuống sân, vòng hào quang trên đầu, bóng râm dưới chân. Loại này phải **chạy theo bước chân nhân vật** và **không được trôi khi camera cuộn**.
   - **Loại 2: Dính chặt vào mặt kính điện thoại (HUD)**: Ví dụ như nút bấm cảm ứng, thanh máu, đồng hồ. Nhân vật chạy đi đâu thì các nút này vẫn đứng yên trên màn hình để bạn lấy ngón tay chạm vào.

---

## PHẦN 2: TÀI SẢN (ASSET) & DỮ LIỆU GAME TRONG MÃ NGUỒN

Khi bạn muốn thêm đồ mới hoặc sửa đổi game, mod sẽ can thiệp vào các "ngăn kéo dữ liệu" (Asset) của game:

1. **Sửa dữ liệu có sẵn (Data Edit)**:
   - Game lưu giá cả, tên gọi, công thức chế tạo trong các bảng dữ liệu ngầm (như dữ liệu cửa hàng `Data/Shops`, dữ liệu vật phẩm `Data/Objects`).
   - Mod có thể đổi giá hạt giống, làm cho tiệm bán thêm đồ hiếm mà không cần vẽ lại ảnh.
2. **Thêm hình ảnh riêng của mod (Custom Textures)**:
   - Bạn có thể đưa file ảnh PNG (ví dụ icon chiếc nhẫn thần, hình phi thuyền, vương miện) vào thư mục của mod để game nạp lên màn hình.
3. **Ghi nhớ trạng thái (ModData)**:
   - Giúp game "nhớ" được những gì bạn đã làm (ví dụ: phi thuyền đã rơi xuống chưa, hôm nay nhân vật đã nhận quà chưa) mà không làm hỏng file save game.
4. **Can thiệp sâu (Harmony Patch)**:
   - Khi có những tính năng game không hỗ trợ sẵn sự kiện (ví dụ: đổi cơ chế giật cần câu cá, đổi cách tính sát thương khi chém quái), AI sẽ dùng kỹ thuật "Harmony" để gắn thêm logic vào giữa hành động gốc của game.

---

## PHẦN 3: TỪ ĐIỂN THUẬT NGỮ (NÓI TIẾNG NGƯỜI ➡️ AI TỰ HIỂU CODE)

Khi chat với AI, bạn chỉ cần dùng các từ quen thuộc trong game:

| Bạn muốn nhắc tới cái gì trong game | Từ bạn nên nói với AI | AI sẽ tự động xử lý trong code C# |
| :--- | :--- | :--- |
| **Nhân vật của bạn** | Người chơi / Nhân vật chính | `Game1.player` (`Farmer`) |
| **Dân làng trong thị trấn** | Dân làng / NPC (Robin, Pierre...) | `NPC` |
| **Nơi đang đứng** | Bản đồ / Khu vực (Nông trại, Hầm mỏ, Trong nhà) | `GameLocation` (`Farm`, `MineShaft`) |
| **Một ô đất trên sân** | Ô đất (để trồng cây, cuốc đất) | `Tile` / `HoeDirt` (kích thước 64x64 pixel) |
| **Góc nhìn camera** | Ống kính camera / Khung nhìn màn hình | `Game1.viewport` |
| **Máu & Thể lực** | Thanh máu / Thể lực (năng lượng dùng cuốc rìu) | `player.health` & `player.stamina` |
| **Hiệu ứng tăng lực** | Buff (chạy nhanh, may mắn, hút đồ xa, tăng thủ) | `Buff` (`Speed`, `Luck`, `MagneticRadius`) |
| **Balo / Rương chứa đồ** | Túi đồ / Rương | `Inventory` (`player.Items`) |
| **Nút bấm trên màn hình điện thoại** | Nút cảm ứng trên HUD | Vẽ ở `RenderedHud` và bắt chạm ngón tay |
| **Bàn phím nhập chữ trên Android** | Bàn phím ảo | `TitleTextInputMenu` (kích hoạt bàn phím hệ thống) |
| **Dữ liệu cửa hàng / giá bán** | Hàng hóa tiệm Pierre / giá hạt giống | `AssetRequested` can thiệp `Data/Shops` |

---

## PHẦN 4: NGHỆ THUẬT PROMPTING: ĐẠO DIỄN Ý TƯỞNG THÀNH SIÊU PHẨM

### 1. Vì sao những câu lệnh 1 dòng chỉ tạo ra "Mod đồ chơi"?
- **Prompt sơ sài**: *"Làm cho tôi mod phi thuyền rơi xuống nông trại"*
  - **Hậu quả**: AI không biết phi thuyền to hay nhỏ, rơi như thế nào, rơi xong làm gì. AI sẽ chỉ vẽ một cục hình vuông trắng đơn điệu hoặc in ra dòng chữ báo "Tàu đã rơi", cực kỳ nhàm chán!
- **Sự thật về AI**: AI viết code C# rất giỏi, nhưng **AI hoàn toàn mù về mặt thẩm mỹ và kịch bản nếu bạn không miêu tả**. Bạn càng mô tả chi tiết như một bộ phim ngắn, AI tạo ra mod càng đẳng cấp và chân thực!

---

### 2. Khung kịch bản 6 mảnh ghép điện ảnh (The 6-Layer Cinematic Formula)

Để tạo một bản mod có chiều sâu và sống động, hãy mô tả cho AI theo 6 mảnh ghép sau:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ 1. DIỄN BIẾN THEO THỜI GIAN (Timeline Cutscene):                       │
│    Giây thứ mấy có âm thanh gì, giây thứ mấy vật thể xuất hiện?        │
│                                                                        │
│ 2. VỊ TRÍ & TỌA ĐỘ TIẾP ĐẤT (Spawn Location):                          │
│    Rơi ở đâu? Cách người chơi mấy ô đất? Rơi từ trên trời chéo xuống?  │
│                                                                        │
│ 3. HÌNH DÁNG, MÀU SẮC & KÍCH THƯỚC (Visuals & Geometry):               │
│    Vật thể hình gì (hình cầu, vòm)? Rộng mấy ô đất? Màu sắc gì?        │
│                                                                        │
│ 4. HIỆU ỨNG MÔI TRƯỜNG & ÂM THANH (VFX & SFX Polish):                  │
│    Rung màn hình, khói bụi bốc lên, vệt lửa cháy, tiếng nổ va chạm?    │
│                                                                        │
│ 5. HOẠT ẢNH & TRẠNG THÁI NHÂN VẬT (Player Animation & State):          │
│    Nhân vật có bị đóng băng di chuyển không? Bước ra hay quỳ xuống?    │
│                                                                        │
│ 6. TƯƠNG TÁC SAU KHI TIẾP ĐẤT (Post-Interaction Gameplay):             │
│    Con tàu nằm đó để làm gì? Chạm vào mở menu, hồi máu, hay dịch chuyển?│
└────────────────────────────────────────────────────────────────────────┘
```

---

### 3. VÍ DỤ MẪU THỰC CHIẾN ĐỈNH CAO: MOD PHI THUYỀN SAIYAN (SAIYAN POD)

Đây là ví dụ điển hình về cách một VibeCoder ra lệnh cho AI để tạo ra một bản mod điện ảnh hoàn hảo mà không cần viết một dòng code nào:

> **"Tạo cho tôi mod SaiyanPodArrival cho Android Cinderbox theo đúng kịch bản chi tiết dưới đây:**
>
> #### 1. Kịch bản thời gian & Hoạt ảnh tàu rơi (Cutscene Timeline):
> - **Giây 0 - 1**: Khi người chơi vừa bước chân ra nông trại vào sáng ngày đầu tiên, màn hình khóa di chuyển của nhân vật. Phát âm thanh tiếng gió rít xé gió từ trên cao (`Game1.playSound('wind')`).
> - **Giây 1 - 2**: Một cái bóng đen tròn trên mặt đất xuất hiện tại vị trí trước mặt người chơi 4 ô đất, bóng đen to dần lên.
> - **Giây 2**: Một phi thuyền hình cầu lao chéo từ góc trên màn hình cắm thẳng xuống đất tại vị trí bóng đen.
> - **Giây 3**: Tàu chạm đất! Màn hình rung lắc mạnh trong 1 giây (`Game1.shakeScreen`), phát âm thanh va chạm nổ lớn (`explosion`). Bụi khói màu trắng đục bung tỏa ra xung quanh trong bán kính 2 ô đất (`TemporaryAnimatedSprite`).
> - **Giây 4**: Khói tan dần. Cửa kính tròn ở giữa phi thuyền bật mở hất lên trên kèm tiếng xì hơi nén (`steam`).
>
> #### 2. Hình dáng, Màu sắc & Kích thước con tàu:
> - Tàu hình cầu tròn đặc trưng của người Saiyan, chiếm diện tích khoảng 2x2 ô đất (128x128 pixel).
> - Thân tàu màu trắng kim loại sáng bóng, có viền nẹp kim loại xám.
> - Cửa kính tròn ở trung tâm màu đỏ ruby trong suốt phát sáng nhẹ.
> - Nếu chưa có sprite riêng, hãy dùng code vẽ tạm các khối hình học phối màu chuẩn xác và bám chặt vào tầng `RenderedWorld` bằng `Game1.GlobalToLocal`.
>
> #### 3. Hoạt ảnh & Trạng thái nhân vật:
> - Trong suốt 4 giây đầu, nhân vật đứng nhìn về hướng tàu rơi (đóng băng thao tác di chuyển để tạo cảm giác kinh ngạc).
> - Đến giây thứ 5, nhân vật bước ra khỏi vùng ảnh hưởng, mở khóa di chuyển bình thường.
>
> #### 4. Tương tác sau khi tiếp đất:
> - Sau khi tiếp đất, phi thuyền nằm cố định tại ô đất đó trên nông trại như một cỗ máy thần bí.
> - Khi người chơi lấy ngón tay chạm vào phi thuyền: Hiển thị hộp thoại hỏi *"Bạn có muốn bước vào buồng hồi phục không?"*. Nếu chọn Có: Màn hình mờ dần (fade out), hồi đầy 100% Máu và Thể lực cho người chơi.
>
> **Hãy tự động tạo dự án net10.0, tự viết toàn bộ logic C# vào ModEntry.cs, tự build kiểm tra lỗi và cài đặt vào game cho tôi."**

---

### 4. VÍ DỤ MẪU THỰC CHIẾN 2: MOD KỸ NĂNG / VẬT PHẨM THUẤN DI (BLINK DASH & TÀN ẢNH)

> **"Tạo cho tôi mod BlinkDashSkill cho Android Cinderbox với tính năng thuấn di (dịch chuyển tức thời):**
>
> #### 1. Cơ chế kích hoạt & Thao tác:
> - Khi nhân vật cầm trên tay vật phẩm có tên là 'Ngọc Thuấn Di' (hoặc người chơi chạm vào nút kỹ năng 'Blink' ở thanh công cụ HUD):
> - Khi người chơi chạm vào bất kỳ điểm nào trên màn hình cảm ứng trong phạm vi bán kính tối đa 5 ô đất (5 tiles): Nhân vật lập tức thuấn di tức thời đến vị trí vừa chạm!
>
> #### 2. Cơ chế đi xuyên vật cản & Quy tắc an toàn:
> - Cho phép dịch chuyển xuyên qua các chướng ngại vật mỏng (như hàng rào, tảng đá nhỏ, bụi cây, vách tường mỏng) với độ dày vật cản tối đa khoảng 3 ô đất.
> - Nếu vật cản quá dày (hơn 3 ô, ví dụ vách núi lớn) hoặc điểm chạm là vị trí không thể đứng (như giữa lòng hồ nước sâu, ngoài rìa bản đồ): Tự động tìm ô đất trống an toàn gần nhất theo hướng đó để nhân vật đáp xuống, không để nhân vật bị kẹt vào vật thể hay rơi vào khoảng không.
>
> #### 3. Hiệu ứng thị giác (VFX) & Hoạt ảnh Tàn Ảnh (Afterimage):
> - **Tại vị trí cũ:** Ngay khoảnh khắc biến mất, để lại một 'tàn ảnh' (bóng mờ silhouette màu xanh lam nhạt hoặc trắng trong suốt) giữ nguyên tư thế chuyển động vừa rồi của nhân vật. Tàn ảnh này mờ dần (fade out) và tan biến hoàn toàn sau 0.4 giây để tạo cảm giác dịch chuyển tức thời siêu tốc như ninja / anime!
> - **Đường bay:** Xuất hiện một vệt bụi khói nhỏ hoặc tia chớp mảnh nối từ điểm cũ sang điểm mới.
> - **Tại vị trí mới:** Chớp sáng nhẹ một vòng tròn năng lượng dưới chân khi nhân vật xuất hiện.
>
> #### 4. Âm thanh (SFX) & Cooldown:
> - Phát âm thanh dịch chuyển chớp nhoáng (âm thanh tiếng vút gió hoặc phép thuật 'wand' / 'dwoop').
> - Đặt thời gian hồi chiêu (Cooldown) là 1.5 giây giữa mỗi lần lướt để tránh bị spam liên tục gây lỗi game.
>
> **Hãy tự viết toàn bộ logic C# net10.0, tự tính toán tọa độ thế giới (RenderedWorld) cho tàn ảnh để tàn ảnh nằm đúng vị trí ô đất cũ, tự build và cài đặt vào game cho tôi."**

---

## PHẦN 5: CẨM NANG "BẮT ĐỀN" AI KHI MOD CHƯA NHƯ Ý (DEBUG CHO VIBECODER)

Khi bạn vào game test mà thấy chưa đúng ý, **tuyệt đối không cần mở file code ra xem**. Bạn chỉ cần "mô tả hiện tượng bằng mắt thấy" cho AI như sau:

### 1. Khi Terminal hiện chữ đỏ lúc build:
Không cần đọc lỗi đó là gì, bạn chỉ cần nói:
> *"Lệnh build đang bị báo lỗi chữ đỏ trên màn hình. Bạn hãy tự đọc log lỗi, tự sửa code trong ModEntry.cs rồi build lại cho tôi."*

### 2. Khi vào game mà bấm không thấy hiện tượng gì:
Nói với AI:
> *"Mod đã cài thành công vào game nhưng khi mình vào chơi thì không thấy có tác dụng gì cả. Bạn hãy kiểm tra lại xem điều kiện kích hoạt đã đúng chưa, và chèn thêm các dòng ghi chú log để mình kiểm tra nhé."*

### 3. Khi hình vẽ bị trôi khỏi người nhân vật khi bước đi:
Nói với AI:
> *"Vòng sáng khi đứng yên thì thấy rất đẹp, nhưng khi mình đi ra ngoài nông trại thì nó bị trôi mất khỏi người nhân vật. Bạn hãy chỉnh lại để hình vẽ bám chặt vào tọa độ của nhân vật theo camera nhé."*

### 4. Khi vòng sáng bị đặt sai chỗ (ví dụ ngang bụng thay vì trên đầu):
Nói với AI:
> *"Vòng sáng hiện tại đang nằm ở ngang bụng nhân vật. Bạn hãy dời nó lên cao một chút, nằm ngay trên đỉnh đầu như một chiếc vương miện hào quang nhé."*

### 5. Khi hoạt ảnh diễn ra quá nhanh hoặc giật cục:
Nói với AI:
> *"Hiệu ứng tàu rơi xuống đất diễn ra quá nhanh khiến mình chưa kịp nhìn rõ. Bạn hãy kéo dài thời gian rơi ra thêm 2 giây, cho hiệu ứng rung màn hình kéo dài hơn một chút và tăng thêm bụi khói bốc lên khi va chạm nhé."*

### 6. Khi game bị văng ra ngoài màn hình chính (Crash):
Bạn mở Termux gõ:
```bash
stardew-mod logs 50
```
Sau đó nhắn cho AI:
> *"Game vừa bị văng ra ngoài. Đây là 50 dòng nhật ký lỗi cuối cùng của game: [Dán kết quả vừa hiện vào]. Bạn hãy đọc xem bị xung đột ở đâu và sửa lại bản mod cho tôi."*

---

**Tóm lại**: AI là người thợ kỹ thuật, bạn là đạo diễn. Hãy thoải mái vẽ nên câu chuyện, hoạt ảnh và hiệu ứng bạn muốn thấy — AI sẽ biến mọi ý tưởng đó thành mã nguồn thực tế!
