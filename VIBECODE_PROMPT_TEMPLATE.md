# CẨM NANG VIBECODING: CƠ CHẾ MOD & TỪ ĐIỂN THUẬT NGỮ STARDEW VALLEY

Tài liệu này giúp bạn hiểu rõ mod hoạt động như thế nào, các thành phần trong game được gọi là gì, và cách mô tả cho AI (OpenCode, Claude, ChatGPT) để AI viết đúng 100% tính năng bạn mong muốn.

---

## 1. BẢN CHẤT MOD HOẠT ĐỘNG NHƯ THẾ NÀO?

Một bản mod C# SMAPI **không thay đổi file gốc của game**. Thay vào đó, nó hoạt động như một "người lắng nghe thông minh":

1. **Vòng lặp trò chơi (Game Loop)**:
   - Stardew Valley chạy liên tục 60 khung hình mỗi giây (mỗi khung hình gọi là 1 `Tick`).
2. **Sự kiện (Events - Khi nào hành động diễn ra)**:
   - Khi có điều gì xảy ra trong game, SMAPI sẽ phát tín hiệu. Mod của bạn chỉ cần đăng ký "lắng nghe" sự kiện đó:
     - `DayStarted`: Người chơi vừa thức dậy bắt đầu ngày mới.
     - `ButtonPressed`: Người chơi vừa chạm vào màn hình hoặc bấm phím.
     - `Warped`: Nhân vật vừa bước chuyển từ bản đồ này sang bản đồ khác.
     - `RenderedWorld`: Game đang vẽ cảnh vật, cây cối, nhân vật trong thế giới.
     - `RenderedHud`: Game đang vẽ giao diện phẳng lên màn hình (thanh máu, thanh công cụ, menu).
3. **Thao tác (Actions - Làm cái gì)**:
   - Khi sự kiện được kích hoạt, mã nguồn C# của bạn sẽ can thiệp: cộng tiền, hồi thể lực, vẽ hào quang, hoặc mở cửa sổ mới.

> **Quy tắc vàng khi vẽ hình ảnh lên màn hình**:
> - Muốn vẽ thứ **đi theo nhân vật** (như vòng sáng hào quang, bóng đổ): Phải vẽ ở tầng **World** và dùng tọa độ chuyển đổi camera (`Game1.GlobalToLocal`).
> - Muốn vẽ thứ **đứng yên trên màn hình điện thoại** (nút bấm cảm ứng, bảng thông tin): Phải vẽ ở tầng **HUD** (`RenderedHud`).

---

## 2. TỪ ĐIỂN THUẬT NGỮ GAME (DÀNH CHO NGƯỜI KHÔNG BIẾT CODE)

Khi chat với AI, bạn chỉ cần dùng đúng các từ khóa dưới đây, AI sẽ hiểu ngay lập tức:

### A. Nhân vật & Sinh vật
- **Farmer / Player (`Game1.player`)**: Nhân vật chính của người chơi.
- **NPC / Villagers**: Dân làng (Robin, Pierre, Abigail...).
- **Monsters**: Quái vật trong hầm mỏ (dơi, slime, bóng ma...).
- **Sprite**: Hình ảnh 2D hoạt họa của nhân vật hoặc vật phẩm.

### B. Chỉ số & Trạng thái
- **Health**: Máu / Sinh lực (thanh màu đỏ).
- **Stamina / Energy**: Thể lực / Năng lượng để dùng cuốc, rìu, câu cá (thanh màu xanh lá).
- **Buff**: Hiệu ứng tăng cường tạm thời hoặc vĩnh viễn (Speed = chạy nhanh, Luck = may mắn, Magnetism = hút vật phẩm từ xa, Attack = tăng lực đánh).

### C. Bản đồ & Tọa độ
- **Location (`GameLocation`)**: Khu vực người chơi đang đứng (Farm = Nông trại, Town = Thị trấn, MineShaft = Hầm mỏ, FarmHouse = Trong nhà).
- **Tile**: Ô đất trên bản đồ (mỗi ô vuông trong game rộng 64x64 pixel).
- **Viewport / Camera**: Khung nhìn của camera điện thoại theo dõi nhân vật.

### D. Giao diện (UI) & Điều khiển
- **HUD (Heads-Up Display)**: Giao diện trực tiếp trên màn hình (đồng hồ ngày giờ, tiền vàng, thanh hotbar chứa đồ ăn và công cụ).
- **Menu (`IClickableMenu`)**: Các bảng mở ra che màn hình (rương đồ, balo túi xách, bảng quan hệ dân làng, bảng chế tạo).
- **Touch Button**: Nút bấm cảm ứng được vẽ lên màn hình điện thoại để ngón tay chạm vào kích hoạt tính năng.

---

## 3. CÔNG THỨC VIẾT PROMPT CHUẨN XỊN (3 BƯỚC)

Để AI viết code chính xác nhất, hãy mô tả ý tưởng theo công thức:

```text
[MỤC TIÊU] + [THỜI ĐIỂM KÍCH HOẠT (SỰ KIỆN)] + [TÁC ĐỘNG CỤ THỂ VÀO GAME]
```

### Ví dụ mẫu thực tế:

#### Mẫu 1: Mod tiện ích nông trại (Tự tưới cây & tăng tốc)
> "Hãy tạo mod FarmHelper: Mỗi khi người chơi thức dậy vào buổi sáng (DayStarted), nếu người chơi đang ở nông trại, hãy tự động tưới nước cho toàn bộ các ô đất đã gieo hạt (HoeDirt) và tặng buff tăng 2 tốc độ chạy trong cả ngày."

#### Mẫu 2: Mod đồ họa / Hào quang quanh người (Aura)
> "Hãy tạo mod HaloGlowMod: Vẽ một vòng tròn hào quang màu trắng phát sáng trên đỉnh đầu nhân vật. Hiệu ứng phải vẽ ở sự kiện RenderedWorld và dùng tọa độ Game1.GlobalToLocal để vòng sáng bám chặt vào đầu nhân vật khi di chuyển, không bị trôi khi camera cuộn."

#### Mẫu 3: Mod nút bấm cảm ứng trên Android
> "Hãy tạo mod MobileQuickHeal: Vẽ một nút tròn hình trái tim ở góc trên bên phải màn hình (tầng RenderedHud, kích thước 64x64 pixel để ngón tay dễ chạm). Khi người chơi chạm vào nút này, tự động hồi phục đầy thanh máu và thể lực."

#### Mẫu 4: Mod thám hiểm hầm mỏ (Bất tử & Hút đồ xa)
> "Hãy tạo mod MineGod: Mỗi khi người chơi bước vào khu vực MineShaft, tự động kích hoạt buff tăng tầm nhặt đồ (Magnetism) lên cực đại và giữ cho thanh máu không bao giờ giảm xuống dưới 1."

---

## 4. KHUNG PROMPT MẪU ĐỂ GỬI CHO AI (COPY DÁN NGUYÊN KHUNG NÀY)

Khi dùng ChatGPT, Claude, Gemini hoặc OpenCode, bạn copy đoạn dưới đây kèm ý tưởng của bạn:

```markdown
Chào AI, tôi đang làm một bản mod C# SMAPI cho Stardew Valley 1.6 trên Android (Cinderbox).
Tôi không chuyên lập trình C#, hãy đóng vai trò là Senior SMAPI Mod Developer và hỗ trợ tôi viết code hoàn chỉnh.

### Ý TƯỞNG TÍNH NĂNG CỦA TÔI:
[Dán mô tả theo công thức 3 bước ở trên vào đây]

### QUY CHUẨN BẮT BUỘC TRÊN ANDROID CINDERBOX:
1. TargetFramework bắt buộc: net10.0 (không dùng net6.0 hay net8.0).
2. Nền tảng cảm ứng: Không gán phím chuột phải hay bàn phím cứng PC. Tương tác dựa trên chạm màn hình hoặc nút bấm HUD.
3. Nếu vẽ hình ảnh theo nhân vật, bắt buộc dùng RenderedWorld + Game1.GlobalToLocal. Nếu vẽ menu/nút bấm, dùng RenderedHud.
4. Kiểm tra Context.IsWorldReady trước khi truy cập Game1.player hoặc Game1.currentLocation.
5. Cập nhật mã nguồn trực tiếp vào ModEntry.cs và hướng dẫn lệnh stardew-mod build để kiểm tra.
```
