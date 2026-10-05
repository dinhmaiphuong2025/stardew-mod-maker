using System;
using StardewModdingAPI;
using StardewModdingAPI.Events;
using StardewValley;

namespace StarterMod
{
    /// <summary>Lớp chính khởi chạy Mod Stardew Valley.</summary>
    public class ModEntry : Mod
    {
        /*********
        ** Phương thức công khai
        *********/
        /// <summary>Điểm khởi đầu của mod, được gọi ngay sau khi SMAPI tải mod vào game.</summary>
        /// <param name="helper">Cung cấp các API đơn giản hóa việc viết mod.</param>
        public override void Entry(IModHelper helper)
        {
            // Lắng nghe sự kiện bắt đầu một ngày mới trong game
            helper.Events.GameLoop.DayStarted += this.OnDayStarted;

            // Lắng nghe sự kiện người chơi bấm nút / chạm màn hình
            helper.Events.Input.ButtonPressed += this.OnButtonPressed;

            this.Monitor.Log("StarterMod: Mod mẫu Cinderbox đã được nạp thành công!", LogLevel.Info);
        }

        /*********
        ** Xử lý sự kiện riêng tư
        *********/
        /// <summary>Được gọi tự động mỗi khi một ngày mới bắt đầu.</summary>
        private void OnDayStarted(object? sender, DayStartedEventArgs e)
        {
            // Hiển thị thông báo góc màn hình (HUD Message) chào người chơi
            string greeting = $"Chào {Game1.player.Name}! Chúc bạn một ngày làm nông vui vẻ.";
            Game1.addHUDMessage(new HUDMessage(greeting, HUDMessage.achievement_type));

            this.Monitor.Log($"Đã gửi lời chào buổi sáng tới {Game1.player.Name}.", LogLevel.Info);
        }

        /// <summary>Được gọi khi người chơi bấm nút trên bàn phím hoặc chạm cảm ứng.</summary>
        private void OnButtonPressed(object? sender, ButtonPressedEventArgs e)
        {
            // Bỏ qua nếu người chơi chưa vào game (đang ở menu chính)
            if (!Context.IsWorldReady)
                return;

            // Nếu người chơi nhấn phím F5 (hoặc phím kích hoạt)
            if (e.Button == SButton.F5)
            {
                // Hồi phục 20 điểm năng lượng cho nhân vật
                Game1.player.Stamina = Math.Min(Game1.player.MaxStamina, Game1.player.Stamina + 20);
                Game1.addHUDMessage(new HUDMessage("Bạn vừa được hồi 20 Năng Lượng!", HUDMessage.stamina_type));
            }
        }
    }
}
