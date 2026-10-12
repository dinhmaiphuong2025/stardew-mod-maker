using System;
using Microsoft.Xna.Framework;
using StardewModdingAPI;
using StardewModdingAPI.Events;
using StardewValley;

namespace StarterMod
{
    /// <summary>Cấu hình người dùng (tự động tạo config.json để đổi phím trên PC/Mobile).</summary>
    public class ModConfig
    {
        /// <summary>Phím kích hoạt trên bàn phím (PC/Laptop).</summary>
        public SButton ActivationKey { get; set; } = SButton.F5;

        /// <summary>Hiển thị nút cảm ứng ảo trên HUD cho màn hình cảm ứng di động.</summary>
        public bool ShowTouchButton { get; set; } = true;
    }

    /// <summary>Lớp chính khởi chạy Mod Stardew Valley tương thích đa nền tảng (PC 1.6 & Android Cinderbox 1.6).</summary>
    public class ModEntry : Mod
    {
        private ModConfig Config = null!;
        private MobileTouchButton? TouchButton;

        /// <summary>Điểm khởi đầu của mod, được gọi ngay sau khi SMAPI tải mod vào game.</summary>
        public override void Entry(IModHelper helper)
        {
            // Tải cấu hình từ config.json (nếu chưa có SMAPI sẽ tự tạo)
            this.Config = helper.ReadConfig<ModConfig>();

            // Khởi tạo nút cảm ứng HUD cho thiết bị di động (ở góc trên bên phải màn hình)
            if (this.Config.ShowTouchButton)
            {
                this.TouchButton = new MobileTouchButton(24, 260, 64, 64, "MOD", () =>
                {
                    this.ActivateModFeature();
                });
            }

            // Lắng nghe các sự kiện vòng đời game
            helper.Events.GameLoop.DayStarted += this.OnDayStarted;
            helper.Events.Input.ButtonPressed += this.OnButtonPressed;
            helper.Events.Display.RenderedHud += this.OnRenderedHud;

            this.Monitor.Log("StarterMod: Mod mẫu đa nền tảng Cinderbox & PC đã nạp thành công!", LogLevel.Info);
        }

        /// <summary>Được gọi tự động mỗi khi một ngày mới bắt đầu.</summary>
        private void OnDayStarted(object? sender, DayStartedEventArgs e)
        {
            string greeting = $"Chào {Game1.player.Name}! Chúc bạn một ngày làm nông vui vẻ.";
            Game1.addHUDMessage(new HUDMessage(greeting, HUDMessage.achievement_type));
        }

        /// <summary>Được gọi khi người chơi bấm nút trên bàn phím (PC) hoặc chạm cảm ứng (Mobile).</summary>
        private void OnButtonPressed(object? sender, ButtonPressedEventArgs e)
        {
            // Bỏ qua nếu người chơi đang ở menu hoặc đang xem cutscene
            if (!Context.IsWorldReady || !Context.IsPlayerFree)
                return;

            // 1. Kiểm tra phím bấm PC (từ config.json)
            if (e.Button == this.Config.ActivationKey)
            {
                this.ActivateModFeature();
                return;
            }

            // 2. Kiểm tra thao tác chạm màn hình cảm ứng (Mobile Cinderbox)
            if (this.TouchButton != null && this.TouchButton.TryHandleClick(e.Button))
            {
                // Nút cảm ứng đã được kích hoạt thành công
                return;
            }
        }

        /// <summary>Vẽ nút bấm cảm ứng HUD (không bị trôi camera theo nhân vật).</summary>
        private void OnRenderedHud(object? sender, RenderedHudEventArgs e)
        {
            if (!Context.IsWorldReady || !Context.IsPlayerFree)
                return;

            if (this.Config.ShowTouchButton && this.TouchButton != null)
            {
                this.TouchButton.Draw(e.SpriteBatch);
            }
        }

        /// <summary>Hàm thực thi tính năng cốt lõi của mod.</summary>
        private void ActivateModFeature()
        {
            // Ví dụ: Hồi phục 20 điểm năng lượng cho nhân vật
            Game1.player.Stamina = Math.Min(Game1.player.MaxStamina, Game1.player.Stamina + 20);
            Game1.addHUDMessage(new HUDMessage("Bạn vừa được hồi 20 Năng Lượng!", HUDMessage.stamina_type));
            this.Monitor.Log($"Người chơi đã kích hoạt tính năng mod.", LogLevel.Info);
        }
    }
}
