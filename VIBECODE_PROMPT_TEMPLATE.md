# CẨM NANG VIBECODING: CƠ CHẾ MOD, ASSET & NGHỆ THUẬT RA LỆNH CHO AI

Tài liệu này dành cho **tất cả mọi người** — bạn không cần biết một dòng mã C# nào, không cần biết hàm hay thuật toán. Bạn chỉ cần đóng vai trò là **"Đạo diễn ý tưởng"**, còn việc viết code, tính toán tọa độ hay xử lý lỗi sẽ do **AI làm từ A đến Z**.

---

## PHẦN 1: BẢN CHẤT MOD HOẠT ĐỘNG THẾ NÀO? (GIẢI THÍCH DỄ HIỂU)

Một bản mod Stardew Valley C# SMAPI **không bao giờ đụng chạm hay làm hỏng game gốc**. Nó giống như một "trợ lý thông minh" đứng cạnh game:

1. **Vòng lặp trò chơi (Game Loop)**:
   - Game chạy liên tục 60 lần mỗi giây (mỗi lần gọi là 1 khung hình hay 1 `Tick`).
2. **Sự kiện (Events - Khi nào làm gì)**:
   - Khi bạn chơi game, các hành động diễn ra sẽ phát ra tín hiệu: *vừa ngủ dậy, vừa bước ra khỏi nhà, vừa chạm vào màn hình, vừa vào hầm mỏ*. Mod chỉ cần "nghe ngóng" tín hiệu này để kích hoạt tính năng.
3. **Hai kiểu hiển thị lên màn hình điện thoại (Render)**:
   - **Loại 1: Dính vào thế giới / nhân vật (World)**: Ví dụ như vòng hào quang trên đầu, bóng râm dưới chân, bùa chú trên mặt đất. Loại này phải **chạy theo bước chân nhân vật** và **không được trôi khi camera cuộn**.
   - **Loại 2: Dính chặt vào mặt kính điện thoại (HUD)**: Ví dụ như nút bấm cảm ứng, thanh máu, đồng hồ. Nhân vật chạy đi đâu thì các nút này vẫn đứng yên trên màn hình để bạn lấy ngón tay chạm vào.

---

## PHẦN 2: TÀI SẢN (ASSET) & DỮ LIỆU GAME TRONG MÃ NGUỒN

Khi bạn muốn thêm đồ mới hoặc sửa đổi game, mod sẽ can thiệp vào các "ngăn kéo dữ liệu" (Asset) của game:

1. **Sửa dữ liệu có sẵn (Data Edit)**:
   - Game lưu giá cả, tên gọi, công thức chế tạo trong các bảng dữ liệu ngầm (như dữ liệu cửa hàng `Data/Shops`, dữ liệu vật phẩm `Data/Objects`).
   - Mod có thể đổi giá hạt giống, làm cho tiệm bán thêm đồ hiếm mà không cần vẽ lại ảnh.
2. **Thêm hình ảnh riêng của mod (Custom Textures)**:
   - Bạn có thể đưa file ảnh PNG (ví dụ icon chiếc nhẫn thần, hình vương miện) vào thư mục của mod để game nạp lên màn hình.
3. **Ghi nhớ trạng thái (ModData)**:
   - Giúp game "nhớ" được những gì bạn đã làm (ví dụ: hôm nay nhân vật đã nhận quà chưa, đã bật chế độ bất tử chưa) mà không làm hỏng file save game.
4. **Can thiệp sâu (Harmony Patch)**:
   - Khi có những tính năng game không hỗ trợ sẵn sự kiện (ví dụ: đổi cơ chế giật cần câu cá, đổi cách tính sát thương khi chém quái), AI sẽ dùng kỹ thuật "Harmony" để gắn thêm logic vào giữa hành động gốc của game.

---

## PHẦN 3: TỪ ĐIỂN THUẬT NGỮ (NÓI TIẾNG NGƯỜI ➡️ AI TỰ HIỂU CODE)

Khi chat với AI, bạn chỉ cần dùng các từ quen thuộc trong game. Bảng này giúp bạn hiểu AI sẽ làm gì sau lưng:

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

## PHẦN 4: NGHỆ THUẬT PROMPTING DÀNH CHO VIBECODER (KHÔNG CẦN BIẾT CODE)

Là một VibeCoder, bạn **không bao giờ phải viết tên hàm hay cú pháp C#**. Bạn chỉ cần miêu tả **trải nghiệm người chơi** theo 3 câu cực kỳ tự nhiên:

```text
1. [TÊN MOD & MỤC TIÊU]: Tôi muốn làm mod tên gì, để làm gì?
2. [CÁCH HOẠT ĐỘNG TRONG GAME]: Diễn ra lúc nào (ngủ dậy, chạm màn hình, vào mỏ)? Hiển thị ở đâu (trên đầu nhân vật, góc màn hình)?
3. [DẶN DÒ TỰ ĐỘNG]: "Hãy tự viết toàn bộ code C#, tự build sửa lỗi và cài vào game cho tôi."
```

---

### BẢNG TRA CỨU PROMPT MẪU THUẦN TIẾNG VIỆT (COPY & ĐỔI Ý TƯỞNG)

#### Mẫu 1: Thêm hiệu ứng hào quang quanh người (Như HaloGlowMod)
> **"Tạo cho tôi mod HaloGlowMod:**
> - Tạo một vòng tròn hào quang phát sáng màu trắng lơ lửng ngay trên đỉnh đầu nhân vật.
> - Khi nhân vật bước đi, chạy hay cuộn màn hình thì vòng hào quang phải dính chặt trên đầu, không được bị trôi lệch khỏi nhân vật.
> - Hãy tự tạo dự án, viết toàn bộ code C#, tự build sửa lỗi và deploy vào game cho tôi."

#### Mẫu 2: Nút bấm cảm ứng hồi máu trên điện thoại
> **"Tạo cho tôi mod QuickHealTouch:**
> - Vẽ một nút tròn màu đỏ hình trái tim ở góc trên bên phải màn hình điện thoại, kích thước vừa ngón tay chạm.
> - Mỗi khi tôi lấy ngón tay chạm vào nút đó, hãy hồi đầy bình máu và thể lực cho nhân vật, đồng thời hiện thông báo nhỏ đã hồi phục.
> - Tự viết code tối ưu cho màn hình cảm ứng Android, tự build và cài vào game cho tôi."

#### Mẫu 3: Nông trại tự động (Tự tưới cây mỗi sáng)
> **"Tạo cho tôi mod AutoFarmMorning:**
> - Mỗi khi nhân vật thức dậy bắt đầu ngày mới trên nông trại, hãy tự động tưới nước cho toàn bộ các ô đất đang có cây trồng.
> - Tặng thêm hiệu ứng chạy nhanh cho nhân vật trong suốt ngày hôm đó.
> - Tự viết code, tự biên dịch và đưa vào game cho tôi."

#### Mẫu 4: Sửa giá hàng hóa & Cửa hàng
> **"Tạo cho tôi mod SpringSale:**
> - Can thiệp vào cửa hàng tạp hóa của Pierre, giảm giá 50% cho tất cả các loại hạt giống mùa xuân để người chơi dễ làm quen game.
> - Tự viết code theo chuẩn Stardew Valley 1.6, tự build và deploy cho tôi."

#### Mẫu 5: Hỗ trợ thám hiểm hầm mỏ
> **"Tạo cho tôi mod MineExplorer:**
> - Mỗi khi tôi bước chân vào hầm mỏ (MineShaft), tự động bật hiệu ứng nam châm hút quặng và vật phẩm từ khoảng cách thật xa, đồng thời giữ cho máu không bị tụt về 0.
> - Tự viết code C#, tự build và cài đặt vào game cho tôi."

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

### 5. Khi game bị văng ra ngoài màn hình chính (Crash):
Bạn mở Termux gõ:
```bash
stardew-mod logs 50
```
Sau đó nhắn cho AI:
> *"Game vừa bị văng ra ngoài. Đây là 50 dòng nhật ký lỗi cuối cùng của game: [Dán kết quả vừa hiện vào]. Bạn hãy đọc xem bị xung đột ở đâu và sửa lại bản mod cho tôi."*

---

**Kết luận**: Bạn chỉ cần có trí tưởng tượng và biết nói tiếng Việt rõ ràng, toàn bộ phần kỹ thuật còn lại đã có AI và bộ công cụ `stardew-mod` lo liệu!
