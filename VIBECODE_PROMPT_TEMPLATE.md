# CẨM NANG VIBECODING: KIẾN TRÚC MÃ NGUỒN, ASSET & TỪ ĐIỂN MOD STARDEW VALLEY

Tài liệu này là cẩm nang toàn diện dành cho người dùng VibeCoding: từ việc hiểu rõ cơ chế mã nguồn C# SMAPI, cách game nạp tài nguyên (Asset), từ điển thuật ngữ game, đến phương pháp viết Prompt chính xác để AI tạo mod không bao giờ bị lỗi.

---

## PHẦN 1: BẢN CHẤT KIẾN TRÚC MÃ NGUỒN C# SMAPI

Một bản mod C# SMAPI **không bao giờ can thiệp thô bạo hay ghi đè lên file cài đặt của game**. Nó chạy song song cùng game và tương tác thông qua 3 trụ cột kỹ thuật:

```text
┌────────────────────────────────────────────────────────┐
│                   STARDEW VALLEY (Game)                │
└───────────┬────────────────────────────────┬───────────┘
            │ 1. Phát tín hiệu Sự kiện       │ 2. Yêu cầu nạp Tài nguyên
            ▼                                ▼
┌───────────────────────┐        ┌───────────────────────┐
│     SMAPI EVENTS      │        │     ASSET PIPELINE    │
│ (Game Loop, Input,    │        │ (Textures, Game Data, │
│  DayStarted, Warped)  │        │  Shops, Objects)      │
└───────────┬───────────┘        └───────────┬───────────┘
            │                                │
            └───────────────┬────────────────┘
                            ▼
               ┌─────────────────────────┐
               │     BẢN MOD CỦA BẠN     │
               │ (ModEntry.cs + Assets)  │
               └────────────┬────────────┘
                            │ (Khi cần can thiệp hàm private gốc)
                            ▼
               ┌─────────────────────────┐
               │      HARMONY PATCH      │
               │  (Prefix / Postfix)     │
               └─────────────────────────┘
```

### 1. Vòng lặp trò chơi (Game Loop & Ticks)
- Game chạy liên tục ở tốc độ 60 khung hình/giây. Mỗi khung hình được gọi là 1 `Tick` (~16.6 mili-giây).
- **Không bao giờ dùng vòng lặp vô tận (`while(true)`) hay `Thread.Sleep()` trong mod**: Điều này sẽ làm toàn bộ game trên điện thoại bị đơ ngay lập tức. Mọi hành động theo thời gian phải đếm qua số Tick (`GameLoop.UpdateTicked`).

### 2. Hai tầng vẽ đồ họa (Render Pipeline)
Khi mod muốn hiển thị hình ảnh (vòng sáng, icon, chữ viết), bạn bắt buộc phải chỉ định đúng tầng vẽ:
- **Tầng thế giới (`RenderedWorld`)**:
  - Dùng để vẽ các vật thể **thuộc về thế giới game** (vòng hào quang quanh nhân vật, hiệu ứng phép thuật trên mặt đất, bóng râm dưới gốc cây).
  - *Bắt buộc chuyển đổi tọa độ qua Camera*: Điểm vẽ trên thế giới (`Tile` hoặc vị trí nhân vật) phải được đổi sang điểm ảnh màn hình bằng hàm `Game1.GlobalToLocal(Game1.viewport, vi_tri_the_gioi)`. Nếu thiếu hàm này, hình vẽ sẽ bị trôi dạt khi nhân vật bước đi.
- **Tầng giao diện (`RenderedHud`)**:
  - Dùng để vẽ các vật thể **dính cố định trên mặt kính điện thoại** (nút bấm cảm ứng, thanh máu phụ, đồng hồ đếm ngược, icon chỉ báo).
  - Tọa độ ở tầng này được tính thẳng bằng pixel màn hình cảm ứng (`0, 0` là góc trên cùng bên trái của điện thoại).

---

## PHẦN 2: TÀI NGUYÊN (ASSET PIPELINE) & DỮ LIỆU TẦNG MÃ NGUỒN

Trong Stardew Valley 1.6, toàn bộ hình ảnh và dữ liệu được quản lý tập trung thông qua **Asset Pipeline**. Đây là cách mod thêm đồ mới hoặc sửa đổi game:

### 1. Cơ chế `AssetRequested` (Nạp & Sửa tài nguyên)
Khi game cần nạp bất kỳ thứ gì, SMAPI sẽ gửi sự kiện `helper.Events.Content.AssetRequested`. Mod có 3 cách can thiệp:
- **Chỉnh sửa dữ liệu (Data Edit)**: Sửa bảng thông số của game mà không cần vẽ lại ảnh.
  - Ví dụ: Thay đổi giá bán cá, thêm hạt giống mới vào tiệm tạp hóa Pierre (`Data/Shops`), thêm công thức chế tạo (`Data/CraftingRecipes`).
  - Dùng lệnh: `e.Edit(asset => { var data = asset.AsDictionary<string, ObjectData>().Data; ... });`
- **Tải đè tài nguyên riêng (Load From Mod)**: Nạp file ảnh PNG riêng của mod vào game.
  - Dùng lệnh: `e.LoadFromModFile<Texture2D>("assets/my_custom_sword.png", AssetLoadPriority.Medium);`
- **Dán đè một phần ảnh (Apply Patch)**: Cắt một góc ảnh từ mod dán đè lên một vị trí trong sprite sheet của game.

### 2. Nạp tài nguyên trong code (`IModHelper`)
- **`helper.ModContent.Load<Texture2D>("assets/halo.png")`**: Nạp file ảnh nằm bên trong thư mục mod của bạn để đưa vào RAM sử dụng.
- **`helper.GameContent.Load<Texture2D>("LooseSprites/Cursors")`**: Lấy ra hình ảnh có sẵn của chính tựa game để tái sử dụng (ví dụ lấy icon con trỏ, icon trái tim).

### 3. Lưu trữ trạng thái tùy biến (`ModData` & Save Data)
- **`ModData`**: Từ bản 1.6, mọi đối tượng trong game (`Farmer`, `NPC`, `Item`, `GameLocation`) đều có sẵn một từ điển dữ liệu chuỗi `modData`. Mod có thể gắn thẻ dữ liệu trực tiếp vào nhân vật mà không sợ làm hỏng file save game:
  ```csharp
  Game1.player.modData["YourName.ModId/HasGodBuff"] = "true";
  ```
- **File cấu hình (`config.json`)**: Dùng `helper.ReadConfig<ModConfig>()` để cho phép người chơi tự bật/tắt tính năng hoặc đổi màu sắc mà không cần sửa code.

### 4. Can thiệp sâu bằng Harmony (`Harmony Patch`)
Khi tính năng bạn muốn không có sẵn Event trong SMAPI (ví dụ: muốn sửa logic tính toán sát thương khi chém trúng quái, hoặc thay đổi quy tắc giật cần câu cá):
- **Prefix**: Chạy một đoạn mã *ngay trước khi* hàm gốc của game thực thi (có thể chặn không cho hàm gốc chạy).
- **Postfix**: Chạy một đoạn mã *ngay sau khi* hàm gốc của game hoàn tất (có thể sửa lại kết quả trả về).

---

## PHẦN 3: TỪ ĐIỂN THUẬT NGỮ STARDEW VALLEY (DÀNH CHO VIBECODING)

Hãy dùng các thuật ngữ chuẩn này khi ra lệnh cho AI để AI gọi đúng hàm và biến của game:

| Thuật ngữ | Tên mã nguồn C# | Ý nghĩa & Vị trí trong game |
| :--- | :--- | :--- |
| **Người chơi** | `Game1.player` (`Farmer`) | Nhân vật chính bạn điều khiển. Chứa máu, năng lượng, túi đồ. |
| **Dân làng** | `NPC` | Các nhân vật NPC trong thị trấn (Robin, Haley, Pierre...). |
| **Nông trại / Khu vực** | `GameLocation` | Bản đồ hiện tại (`Farm`, `Town`, `MineShaft`, `FarmHouse`). |
| **Ô đất** | `Tile` / `Vector2` | Mỗi ô vuông trên mặt đất (kích thước chuẩn là 64x64 pixel). |
| **Ống kính / Camera** | `Game1.viewport` | Vùng không gian game đang hiển thị vừa vặn trên màn hình điện thoại. |
| **Máu** | `player.health` / `maxHealth` | Chỉ số sinh mệnh (thanh màu đỏ góc dưới bên phải). |
| **Thể lực** | `player.stamina` / `maxStamina`| Năng lượng hoạt động (thanh màu xanh lá). |
| **Hiệu ứng tăng cường** | `Buff` (`StardewValley.Buffs`) | Tăng tốc độ chạy (`Speed`), may mắn (`Luck`), hút đồ (`MagneticRadius`). |
| **Túi đồ / Balo** | `player.Items` (`Inventory`) | Danh sách 12, 24 hoặc 36 ô chứa vật phẩm. |
| **Thanh công cụ** | `Toolbar` (HUD) | Dãy 12 ô vật phẩm hiển thị trực tiếp trên màn hình cảm ứng. |
| **Menu / Cửa sổ** | `IClickableMenu` | Các bảng giao diện che màn hình: hòm đồ, cửa hàng, bảng kỹ năng. |
| **Bàn phím ảo Android** | `TitleTextInputMenu` | Bắt buộc dùng để kích hoạt bàn phím ảo gõ chữ trên Cinderbox Android. |
| **Dữ liệu vật phẩm** | `Data/Objects` | File dữ liệu trung tâm định nghĩa tên, giá bán, công dụng của toàn bộ item. |
| **Dữ liệu cửa hàng** | `Data/Shops` | Danh sách hàng hóa được bày bán ở các shop trong game. |

---

## PHẦN 4: NGHỆ THUẬT PROMPTING CHO VIBECODING

### 1. Vì sao những câu lệnh chung chung thường thất bại?
- **Prompt tồi**: *"Làm cho tôi mod câu cá dễ hơn"*
  - **Hậu quả**: AI không biết bạn muốn gì. Nó có thể viết code xóa minigame, hoặc sửa thanh trượt câu cá, hoặc dùng phím C-Sharp trên PC mà Android không thể bấm được.
- **Prompt chuẩn**: *"Hãy làm mod EasyFishing: Khi người chơi vào minigame câu cá (`BobberBar`), tự động giữ thanh bắt cá luôn nằm chính giữa con cá và thanh tiến trình câu không bao giờ bị tụt."*
  - **Kết quả**: AI gọi đúng lớp `BobberBar`, xử lý đúng biến và hoạt động hoàn hảo 100%.

---

### 2. Công thức cấu trúc Prompt 4 phần (The 4-Pillar Formula)

Mỗi khi ra lệnh cho AI viết mod, hãy điền theo 4 thành phần sau:

```text
1. [TÊN MOD & MỤC TIÊU]: Tên mod là gì, ý tưởng chính là gì?
2. [THỜI ĐIỂM KÍCH HOẠT]: Khi nào tính năng chạy (Sự kiện: ngủ dậy, chạm màn hình, chuyển map, vào mỏ)?
3. [TÁC ĐỘNG MÃ NGUỒN]: Sửa biến nào, vẽ ở tầng nào (HUD hay World), có can thiệp Asset nào không?
4. [RÀNG BUỘC ANDROID CINDERBOX]: .NET 10.0, thao tác chạm cảm ứng, không dùng phím cứng PC.
```

---

### 3. Các Prompt Blueprint thực chiến theo từng nhóm mod

#### Blueprint 1: Mod Can Thiệp Dữ Liệu & Cửa Hàng (Data / AssetRequested)
> "Tạo cho tôi mod **SeedDiscount**:
> - Sử dụng sự kiện `helper.Events.Content.AssetRequested` để can thiệp vào tài nguyên `Data/Shops`.
> - Tìm cửa hàng của Pierre (`Game1.shop_generalStore`), giảm 50% giá vàng của tất cả các loại hạt giống vào mùa xuân.
> - Đảm bảo mod tương thích Stardew Valley 1.6 và nền tảng Cinderbox .NET 10.0."

#### Blueprint 2: Mod Đồ Họa & Hiệu Ứng Bám Theo Nhân Vật (World Render)
> "Tạo cho tôi mod **HaloGlowMod**:
> - Tạo hiệu ứng vòng tròn ánh sáng trắng phát quang (glow) lơ lửng ngay trên đầu người chơi.
> - Đăng ký sự kiện vẽ tại `Display.RenderedWorld`.
> - Bắt buộc dùng hàm `Game1.GlobalToLocal(Game1.viewport, vi_tri_dau_nhan_vat)` để tính tọa độ vẽ, đảm bảo vòng sáng bám chặt vào đầu nhân vật khi di chuyển, không bị trôi lệch khi camera cuộn.
> - Tối ưu hiệu năng, giải phóng sprite hợp lý mỗi khung hình."

#### Blueprint 3: Mod Giao Diện Cảm Ứng & Nút Bấm Trên Màn Hình (HUD & Touch Input)
> "Tạo cho tôi mod **MobileTeleportButton**:
> - Vẽ một nút bấm cảm ứng hình tròn màu xanh lam ở góc trên bên phải màn hình tại sự kiện `Display.RenderedHud` (kích thước vùng chạm 64x64 pixel để ngón tay dễ bấm).
> - Lắng nghe sự kiện chạm màn hình qua `Input.ButtonPressed`: Nếu người chơi chạm vào vùng nút bấm, hiển thị một thông báo xác nhận và dịch chuyển tức thời nhân vật về cửa nhà nông trại (`FarmHouse`).
> - Luôn kiểm tra `Context.IsWorldReady` và `Context.IsPlayerFree` trước khi thực thi dịch chuyển."

#### Blueprint 4: Mod Tự Động Hóa Nông Trại (Game Events & Farming)
> "Tạo cho tôi mod **AutoWaterMorning**:
> - Khi người chơi vừa thức dậy bắt đầu ngày mới (`GameLoop.DayStarted`), nếu nhân vật đang ở nông trại (`Farm`), tự động duyệt qua danh sách các ô đất trồng trọt (`HoeDirt`) trong nông trại.
> - Chuyển trạng thái của tất cả các ô đất có cây trồng sang trạng thái đã tưới nước (`state.Value = HoeDirt.watered`).
> - In một thông báo nhỏ lên góc màn hình (`Game1.addHUDMessage`) thông báo số lượng ô đất đã được tưới tự động."

---

## PHẦN 5: CẨM NANG SỬA LỖI (DEBUG PROMPTING KHI GẶP SỰ CỐ)

Khi bạn test mod mà gặp lỗi, đừng nói chung chung *"mod bị lỗi rồi"*. Hãy dùng các câu lệnh sau để AI sửa trong 1 nốt nhạc:

### 1. Khi mod build bị báo lỗi đỏ trong Terminal
> *"Lệnh `stardew-mod build` báo lỗi biên dịch sau đây: `[Dán toàn bộ đoạn mã lỗi CSxxxx vào đây]`. Hãy phân tích nguyên nhân, sửa trực tiếp vào `ModEntry.cs` và build lại cho tôi."*

### 2. Khi mod build thành công nhưng vào game không thấy hiện tượng gì
> *"Mod đã cài thành công vào game nhưng khi thực hiện thao tác thì không thấy hiệu ứng gì xảy ra. Hãy kiểm tra lại:
> 1. Đã kiểm tra `Context.IsWorldReady` đúng chỗ chưa?
> 2. Sự kiện đăng ký lắng nghe (Event Hook) có bị bỏ sót không?
> 3. Hãy thêm các dòng `this.Monitor.Log('...', LogLevel.Info)` vào từng bước logic để tôi kiểm tra bằng lệnh `stardew-mod logs`."*

### 3. Khi hình vẽ bị lệch / trôi khỏi nhân vật khi di chuyển
> *"Hình ảnh đang bị lỗi trôi khỏi màn hình khi nhân vật di chuyển ra ngoài nông trại. Hãy kiểm tra lại tầng vẽ: chuyển sự kiện vẽ sang `Display.RenderedWorld` và dùng `Game1.GlobalToLocal(Game1.viewport, ...)` để quy đổi tọa độ thế giới sang tọa độ camera màn hình."*
