# Hướng Dẫn Dành Cho AI Agent (OpenCode, Claude, Hermes)

Tài liệu này hướng dẫn cách AI Coding Agent sử dụng bộ công cụ `stardew-mod` để tự động hóa 100% quy trình tạo mod cho người dùng.

---

## 1. VAI TRÒ CỦA AGENT
Agent đóng vai trò là kỹ sư C# SMAPI chuyên nghiệp phát triển mod cho **Stardew Valley 1.6** trên nền tảng **Cinderbox Android** (.NET 10.0 aarch64).

Khi người dùng mô tả tính năng muốn tạo:
1. Agent tự khởi tạo dự án.
2. Agent tự viết mã nguồn C# SMAPI.
3. Agent tự gọi lệnh biên dịch và tự sửa lỗi nếu có.
4. Agent tự triển khai mod vào game.

---

## 2. BỘ LỆNH AGENT SỬ DỤNG (`stardew-mod`)

| Lệnh | Ý nghĩa | Cách Agent sử dụng |
|---|---|---|
| `stardew-mod doctor --json` | Kiểm tra môi trường | Lấy dữ liệu JSON về trạng thái game & .NET |
| `stardew-mod agent [TênAgent]` | Cài đặt AI Coding Agent | Cài đặt OpenCode, Antigravity (agy), Claude, Codex, Hermes |
| `stardew-mod new <TênMod>` | Tạo mod mới | Tự động sinh thư mục dự án và file mẫu |
| `stardew-mod build [ThưMục]` | Biên dịch dự án | Trả về log chi tiết (CSxxxx, số dòng) |
| `stardew-mod deploy [ThưMục]` | Cài đặt vào game | Đóng gói và copy trực tiếp vào `/sdcard/StardewValley/desktop/Mods/` |
| `stardew-mod logs [N]` | Đọc log SMAPI | Xem log game để gỡ lỗi crash |
| `stardew-mod list` | Liệt kê các mod | Xem danh sách mod hiện có |

### Bảng Phân Loại AI Coding Agent (Free vs Paid)

| Agent CLI | Lệnh Chạy | Phân Loại Chi Phí | Chi Tiết Sử Dụng |
|---|---|---|---|
| **OpenCode CLI** | `opencode` | **Miễn phí** (Open-Source) | Dùng được local Ollama miễn phí hoặc tự cấp API Key cá nhân giá rẻ (DeepSeek, OpenRouter) |
| **Antigravity CLI** | `agy` | **Miễn phí có hạn mức** (Google Tier) | Đăng nhập tài khoản Google, có quota miễn phí hàng ngày |
| **Claude Code** | `claude` | **Trả phí** (Subscription / API) | Yêu cầu gói Claude Pro ($20/tháng) hoặc Anthropic API Key tính theo token |
| **OpenAI Codex CLI** | `codex` | **Trả phí** (Paid API) | Yêu cầu OpenAI API Key tính theo lượng token dùng |
| **Hermes Agent CLI** | `hermes` | **Miễn phí** (Open-Source & BYOK) | 100% mã nguồn mở tự do, hỗ trợ 20+ provider và local models |

---

## 3. QUY TRÌNH TỰ ĐỘNG CỦA AGENT

Ví dụ khi người dùng yêu cầu: *"Tạo cho tôi mod tăng tốc độ chạy gấp đôi khi ở nông trại"*

```bash
# 1. Tạo dự án mới
stardew-mod new FarmSpeedMod
cd ~/stardew-workspace/mods/FarmSpeedMod

# 2. Cập nhật mã nguồn ModEntry.cs và manifest.json

# 3. Biên dịch và kiểm tra lỗi
stardew-mod build

# 4. Triển khai vào game Stardew Valley
stardew-mod deploy
```

---

## 4. CẤU TRÚC THƯ MỤC ÁNH XẠ (WORKSPACE MAP)

Hệ thống đã tự động liên kết các thư mục quan trọng ngay trong thư mục người dùng:
- `~/sdcard`: Ánh xạ trực tiếp toàn bộ bộ nhớ máy Android.
- `~/stardew-workspace/game`: Ánh xạ đến `/sdcard/StardewValley/` (thư mục game gốc).
- `~/stardew-workspace/installed-mods`: Ánh xạ đến `/sdcard/StardewValley/desktop/Mods/` (nơi game đọc mod).
- `~/stardew-workspace/mods/`: Nơi chứa mã nguồn các bản mod bạn và Agent đang phát triển.

---

## 5. NGUYÊN TẮC KỸ THUẬT CINDERBOX ANDROID
1. TargetFramework bắt buộc: `<TargetFramework>net10.0</TargetFramework>`
2. Không dùng `TextBox` (bàn phím ảo Android không mở). Dùng `TitleTextInputMenu`.
3. Kiểm tra nút bấm: kết hợp cả `e.Button.IsUseToolButton()` và `e.Button == SButton.MouseLeft`.
4. Vùng chạm cảm ứng hitbox: tối thiểu 48x48px.
