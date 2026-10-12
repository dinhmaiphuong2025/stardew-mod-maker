using System;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using StardewValley;
using StardewModdingAPI;

namespace StarterMod
{
    /// <summary>
    /// Helper xử lý nút bấm cảm ứng (Touch Button) trên HUD cho Stardew Valley Cinderbox Android.
    /// Tự động xử lý UI Scale, bắt sự kiện chạm MouseLeft/Touch, vẽ ở tầng RenderedHud không trôi camera.
    /// </summary>
    public class MobileTouchButton
    {
        public Rectangle Bounds { get; set; }
        public string Label { get; set; }
        public Color BackgroundColor { get; set; } = new Color(0, 0, 0, 160);
        public Color TextColor { get; set; } = Color.White;
        public Action? OnClick { get; set; }

        public MobileTouchButton(int x, int y, int width = 64, int height = 64, string label = "", Action? onClick = null)
        {
            this.Bounds = new Rectangle(x, y, width, height);
            this.Label = label;
            this.OnClick = onClick;
        }

        /// <summary>
        /// Kiểm tra xem điểm chạm trên màn hình có trúng nút hay không (đã quy đổi UI Scale).
        /// Gọi trong sự kiện Input.ButtonPressed (khi e.Button == SButton.MouseLeft).
        /// </summary>
        public bool Contains(int screenX, int screenY)
        {
            float uiScale = Game1.options.uiScale > 0 ? Game1.options.uiScale : 1f;
            int scaledX = (int)(screenX / uiScale);
            int scaledY = (int)(screenY / uiScale);
            return this.Bounds.Contains(scaledX, scaledY);
        }

        /// <summary>
        /// Xử lý sự kiện bấm nút. Trả về true nếu nút đã được kích hoạt.
        /// </summary>
        public bool TryHandleClick(SButton button)
        {
            if (button != SButton.MouseLeft)
                return false;

            int mouseX = Game1.getMouseX();
            int mouseY = Game1.getMouseY();

            if (this.Contains(mouseX, mouseY))
            {
                this.OnClick?.Invoke();
                return true;
            }
            return false;
        }

        /// <summary>
        /// Vẽ nút bấm trên màn hình cảm ứng HUD. Luôn gọi trong Display.RenderedHud.
        /// </summary>
        public void Draw(SpriteBatch b)
        {
            // Vẽ nền nút
            b.Draw(Game1.fadeToBlackRect, this.Bounds, this.BackgroundColor);

            // Vẽ viền nút
            DrawBorder(b, this.Bounds, Color.White * 0.8f, 2);

            // Vẽ chữ nhãn nếu có
            if (!string.IsNullOrEmpty(this.Label))
            {
                Vector2 textSize = Game1.smallFont.MeasureString(this.Label);
                Vector2 textPos = new Vector2(
                    this.Bounds.X + (this.Bounds.Width - textSize.X) / 2,
                    this.Bounds.Y + (this.Bounds.Height - textSize.Y) / 2
                );
                b.DrawString(Game1.smallFont, this.Label, textPos, this.TextColor);
            }
        }

        private static void DrawBorder(SpriteBatch b, Rectangle rect, Color color, int thickness)
        {
            b.Draw(Game1.fadeToBlackRect, new Rectangle(rect.X, rect.Y, rect.Width, thickness), color);
            b.Draw(Game1.fadeToBlackRect, new Rectangle(rect.X, rect.Bottom - thickness, rect.Width, thickness), color);
            b.Draw(Game1.fadeToBlackRect, new Rectangle(rect.X, rect.Y, thickness, rect.Height), color);
            b.Draw(Game1.fadeToBlackRect, new Rectangle(rect.Right - thickness, rect.Y, thickness, rect.Height), color);
        }
    }
}
