# 🌾 Stardew Valley Cinderbox Modding Kit (PRoot Android)
### 🚀 Bộ Công Cụ & Môi Trường 1-Click Dành Cho Người Không Biết Code Tự VibeCoding Tạo Mod

[![Platform: Android](https://img.shields.io/badge/Platform-Android%20(Termux)-green.svg)](https://termux.dev)
[![Engine: PRoot Ubuntu](https://img.shields.io/badge/PRoot-Ubuntu%2024.04%20aarch64-orange.svg)](https://github.com/termux/proot-distro)
[![SDK: .NET 10.0](https://img.shields.io/badge/.NET-10.0%20SDK-purple.svg)](https://dotnet.microsoft.com)
[![Game: Stardew Valley 1.6 Cinderbox](https://img.shields.io/badge/Game-Stardew%20Valley%201.6%20Cinderbox-blue.svg)](https://stardewvalley.net)

---

## 💡 Giới Thiệu

Bạn muốn tự tạo ra những tính năng kỳ diệu cho game **Stardew Valley** chạy trên Android (thông qua Cinderbox) — ví dụ: tự động tưới nước, tăng tốc chạy, radar tìm kho báu, hay menu tùy biến — nhưng bạn **không biết một dòng code C# nào**?

Đây chính là bộ công cụ dành cho bạn! Dự án này thiết lập một môi trường lập trình Linux chuẩn (PRoot Ubuntu) ngay trên chiếc điện thoại Android của bạn, kết hợp hoàn hảo cùng các AI mạnh nhất hiện nay (ChatGPT, Claude, Gemini, DeepSeek) để bạn có thể **"VibeCode"** (chỉ cần mô tả ý tưởng bằng tiếng Việt, AI sẽ viết toàn bộ code mod cho bạn).

### ✨ Điểm Nổi Bật:
- **Zero-Config (Không cần cấu hình phức tạp):** Chỉ cần dán 1 dòng lệnh duy nhất vào Termux là xong từ A đến Z.
- **Không cần Root máy:** Hoạt động an toàn 100% trên mọi điện thoại Android thông qua PRoot.
- **Tự động Mount `/sdcard`:** Toàn bộ file game và mod được liên kết trực tiếp với bộ nhớ điện thoại. Bạn có thể dùng ZArchiver, MT Manager hoặc Acode để xem và sửa file như bình thường.
- **Đầy đủ .NET 10.0 SDK:** Sửa sạch hoàn toàn các lỗi thiếu thư viện bionic libc hay xung đột phiên bản `net6.0`/`net10.0` của Cinderbox.
- **Bộ lệnh bỏ túi `stardew-mod`:** Tạo mod mới, kiểm tra lỗi, build và deploy vào game chỉ bằng 1 từ khóa.
- **Sẵn sàng Prompt Template:** Tích hợp bộ quy chuẩn đặc biệt để AI không bao giờ viết sai API của Stardew 1.6 hay cơ chế chạm cảm ứng di động.

---

## ⚡ Cài Đặt Siêu Tốc (Chỉ 1 Bước)

Mở ứng dụng **Termux** (tải từ F-Droid hoặc GitHub) và dán lệnh sau:

```bash
pkg install -y git && git clone https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git && cd stardew-proot-vibecoding && bash install.sh
```

*(Hộp thoại cấp quyền bộ nhớ sẽ hiện lên, hãy chọn **CHO PHÉP / ALLOW** để môi trường có thể kết nối với thư mục game).*

---

## 🎮 Cách Sử Dụng Hàng Ngày

Sau khi cài đặt xong, bất cứ khi nào muốn làm mod, bạn chỉ cần mở Termux và gõ:

```bash
stardew-code
```

Bạn sẽ bước thẳng vào không gian làm việc. Tại đây, bạn có các lệnh trợ thủ sau:

| Lệnh | Ý nghĩa |
| :--- | :--- |
| `stardew-mod doctor` | Tự động kiểm tra file game Cinderbox và SMAPI đã sẵn sàng chưa |
| `stardew-mod new <TenMod>` | Tạo nhanh một bản mod mới hoàn chỉnh trong 1 giây |
| `stardew-mod build` | Biên dịch mã nguồn C# thành file mod `.dll` |
| `stardew-mod deploy` | Cài đặt mod vừa build thẳng vào thư mục `Mods/` của game |

---

## 🧙‍♂️ Quy Trình "VibeCoding" Tạo Mod Bằng AI

Bạn không cần học ngữ pháp C#. Hãy làm theo các bước sau:

1. **Tạo mod:**
   ```bash
   stardew-mod new NongDanSieuDang
   cd mods/NongDanSieuDang
   ```
2. **Mô tả ý tưởng cho AI:**
   Mở file [`VIBECODE_PROMPT_TEMPLATE.md`](./VIBECODE_PROMPT_TEMPLATE.md), copy toàn bộ nội dung mẫu đó vào ChatGPT / Claude / Gemini cùng với ý tưởng của bạn (ví dụ: *"Tôi muốn mỗi khi thức dậy, năng lượng của tôi đầy 100% và nhận thêm 1000 vàng"*).
3. **Dán code vào mod:**
   AI sẽ viết cho bạn mã nguồn hoàn chỉnh. Bạn dán vào file `ModEntry.cs` (bằng lệnh `nano ModEntry.cs` hoặc dùng app quản lý file trên điện thoại).
4. **Build & Thưởng thức:**
   ```bash
   stardew-mod build
   stardew-mod deploy
   ```
   Mở game Stardew Valley trên điện thoại lên và tận hưởng tính năng do chính bạn "vibe" ra!

---

## 📚 Tài Liệu Chi Tiết

Mọi thắc mắc và hướng dẫn chi tiết từng bước được chia nhỏ trong thư mục `docs/`:

- [**01. Hướng dẫn cài đặt Termux & Chuẩn bị**](./docs/01-chuan-bi-va-cai-dat.md): Dành cho người chưa từng dùng Termux.
- [**02. Cấu trúc Cinderbox & Vị trí thư mục game**](./docs/02-cau-truc-cinderbox.md): Bản đồ lưu trữ file game trên Android.
- [**03. Bí kíp VibeCoding tạo mod chi tiết**](./docs/03-bi-kip-vibecoding.md): Hướng dẫn ra lệnh cho AI, các mẹo sửa lỗi khi AI viết code sai.
- [**04. Sổ tay khắc phục lỗi thường gặp**](./docs/04-cac-loi-thuong-gap.md): Xử lý lỗi CS1705, thiếu DLL, lỗi cảm ứng màn hình, v.v.

---

## 📂 Cấu Trúc Thư Mục Dự Án

```
stardew-proot-vibecoding/
├── install.sh                     # Script 1-Click chạy ngoài Termux Host
├── README.md                      # Hướng dẫn tổng quan
├── VIBECODE_PROMPT_TEMPLATE.md    # Mẫu prompt thần thánh nạp cho AI
├── docs/                          # Hệ thống tài liệu tiếng Việt chi tiết
│   ├── 01-chuan-bi-va-cai-dat.md
│   ├── 02-cau-truc-cinderbox.md
│   ├── 03-bi-kip-vibecoding.md
│   └── 04-cac-loi-thuong-gap.md
├── scripts/
│   ├── setup-proot.sh             # Cấu hình Ubuntu & cài .NET 10.0
│   └── stardew-mod.sh             # Bộ công cụ dòng lệnh (doctor, new, build, deploy)
└── templates/
    └── starter-mod/               # Template mod mẫu C# SMAPI 1.6 chuẩn
        ├── StarterMod.csproj
        ├── manifest.json
        ├── ModEntry.cs
        ├── deploy.sh
        └── .gitignore
```

---

## 🤝 Lời Cảm Ơn & Giấy Phép

- Được phát triển bởi **Phoebe** & cộng đồng yêu thích Stardew Valley Modding trên Android.
- Giấy phép mã nguồn mở: **MIT License**. Bạn tự do sử dụng, chỉnh sửa và chia sẻ cho cộng đồng!
