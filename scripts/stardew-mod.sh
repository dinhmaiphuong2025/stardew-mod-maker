#!/usr/bin/env bash
# ==============================================================================
# stardew-mod: Công cụ dòng lệnh hỗ trợ phát triển mod Stardew Valley Cinderbox
# Dành cho người không biết code & VibeCoding trên Android PRoot
# ==============================================================================

set -e

# Màu sắc
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

DOTNET_CMD="/root/.dotnet/dotnet"
WORKSPACE="/root/stardew-workspace"
GAME_DIR="/sdcard/StardewValley"
GAME_FILES="$GAME_DIR/desktop/GameFiles"
SMAPI_DIR="$GAME_DIR/smapi-internal"
MODS_DIR="$GAME_DIR/desktop/Mods"

usage() {
    echo -e "${CYAN}Stardew Mod CLI - Trợ thủ VibeCoding Cinderbox Android${NC}"
    echo -e "Cách dùng: ${GREEN}stardew-mod <lệnh> [tham số]${NC}\n"
    echo -e "Các lệnh khả dụng:"
    echo -e "  ${YELLOW}doctor${NC}             Kiểm tra kết nối game files, SMAPI và .NET SDK"
    echo -e "  ${YELLOW}new <TênMod>${NC}       Tạo nhanh một dự án mod mới từ template chuẩn"
    echo -e "  ${YELLOW}build${NC}              Biên dịch mod trong thư mục hiện tại"
    echo -e "  ${YELLOW}deploy${NC}             Cài đặt mod đã build thẳng vào thư mục Mods của game"
    echo -e "  ${YELLOW}help${NC}               Hiển thị hướng dẫn này\n"
}

cmd_doctor() {
    echo -e "${CYAN}--- KIỂM TRA MÔI TRƯỜNG CINDERBOX & MODDING ---${NC}"
    
    # 1. Kiểm tra .NET
    if [ -f "$DOTNET_CMD" ] && "$DOTNET_CMD" --version >/dev/null 2>&1; then
        echo -e "[OK] .NET SDK: $($DOTNET_CMD --version)"
    else
        echo -e "${RED}[LỖI] Không tìm thấy .NET SDK tại $DOTNET_CMD!${NC}"
    fi

    # 2. Kiểm tra bộ nhớ /sdcard
    if [ -d "/sdcard" ]; then
        echo -e "[OK] Mount /sdcard: Đã kết nối thành công"
    else
        echo -e "${RED}[LỖI] Chưa kết nối được /sdcard. Hãy kiểm tra lại cấu hình PRoot!${NC}"
    fi

    # 3. Kiểm tra game files
    if [ -f "$GAME_FILES/Stardew Valley.dll" ]; then
        echo -e "[OK] Stardew Valley.dll: Tìm thấy tại $GAME_FILES"
    else
        echo -e "${YELLOW}[CẢNH BÁO] Chưa thấy $GAME_FILES/Stardew Valley.dll${NC}"
        echo -e "  -> Hãy đảm bảo bạn đã cài Cinderbox và mở game lên ít nhất 1 lần để sinh file."
    fi

    # 4. Kiểm tra SMAPI
    if [ -f "$SMAPI_DIR/StardewModdingAPI.dll" ]; then
        echo -e "[OK] StardewModdingAPI.dll: Tìm thấy tại $SMAPI_DIR"
    elif [ -f "$GAME_FILES/StardewModdingAPI.dll" ]; then
        echo -e "[OK] StardewModdingAPI.dll: Tìm thấy tại $GAME_FILES"
    else
        echo -e "${YELLOW}[CẢNH BÁO] Chưa thấy StardewModdingAPI.dll.${NC}"
        echo -e "  -> Đảm bảo bạn đã cài SMAPI cho Cinderbox."
    fi

    # 5. Kiểm tra thư mục Mods
    if [ -d "$MODS_DIR" ]; then
        echo -e "[OK] Thư mục Mods: Sẵn sàng tại $MODS_DIR"
    else
        mkdir -p "$MODS_DIR" 2>/dev/null || true
        echo -e "[OK] Đã tạo thư mục Mods tại $MODS_DIR"
    fi

    echo -e "${CYAN}-----------------------------------------------${NC}"
}

cmd_new() {
    MOD_NAME="$1"
    if [ -z "$MOD_NAME" ]; then
        echo -e "${RED}[!] Vui lòng nhập tên mod. Ví dụ: stardew-mod new SieuNongDan${NC}"
        exit 1
    fi

    TARGET_DIR="$WORKSPACE/mods/$MOD_NAME"
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${RED}[!] Thư mục $TARGET_DIR đã tồn tại! Vui lòng chọn tên khác.${NC}"
        exit 1
    fi

    TEMPLATE_DIR="$WORKSPACE/templates/starter-mod"
    if [ ! -d "$TEMPLATE_DIR" ]; then
        TEMPLATE_DIR="/root/stardew-env/templates/starter-mod"
    fi

    echo -e "${BLUE}Đang tạo dự án mod mới: $MOD_NAME...${NC}"
    mkdir -p "$TARGET_DIR"
    cp -r "$TEMPLATE_DIR/"* "$TARGET_DIR/"

    # Đổi tên file csproj
    mv "$TARGET_DIR/StarterMod.csproj" "$TARGET_DIR/${MOD_NAME}.csproj" 2>/dev/null || true

    # Thay thế tên trong code và manifest
    sed -i "s/StarterMod/$MOD_NAME/g" "$TARGET_DIR/${MOD_NAME}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$MOD_NAME/g" "$TARGET_DIR/manifest.json" 2>/dev/null || true
    sed -i "s/StarterMod/$MOD_NAME/g" "$TARGET_DIR/ModEntry.cs" 2>/dev/null || true
    sed -i "s/StarterMod/$MOD_NAME/g" "$TARGET_DIR/deploy.sh" 2>/dev/null || true

    echo -e "${GREEN}✓ Tạo mod thành công tại: $TARGET_DIR${NC}"
    echo -e "\n${YELLOW}Để bắt đầu chỉnh sửa và vibe code:${NC}"
    echo -e "  cd $TARGET_DIR"
    echo -e "  # Dùng AI hoặc sửa file ModEntry.cs theo ý thích"
    echo -e "  stardew-mod build"
    echo -e "  stardew-mod deploy\n"
}

cmd_build() {
    CSPROJ=$(find . -maxdepth 1 -name "*.csproj" | head -n 1)
    if [ -z "$CSPROJ" ]; then
        echo -e "${RED}[!] Không tìm thấy file .csproj trong thư mục hiện tại!${NC}"
        echo -e "Hãy đảm bảo bạn đang đứng trong thư mục của mod."
        exit 1
    fi

    echo -e "${BLUE}Đang biên dịch dự án ($CSPROJ)...${NC}"
    "$DOTNET_CMD" build "$CSPROJ" -c Release
    echo -e "${GREEN}✓ Biên dịch hoàn tất!${NC}"
}

cmd_deploy() {
    CSPROJ=$(find . -maxdepth 1 -name "*.csproj" | head -n 1)
    if [ -z "$CSPROJ" ]; then
        echo -e "${RED}[!] Không tìm thấy file .csproj trong thư mục hiện tại!${NC}"
        exit 1
    fi

    MOD_NAME=$(basename "$CSPROJ" .csproj)
    TARGET_MOD_DIR="$MODS_DIR/$MOD_NAME"

    # Nếu chưa build thì tự build
    DLL_OUTPUT=$(find bin/Release/ -name "${MOD_NAME}.dll" 2>/dev/null | head -n 1)
    if [ -z "$DLL_OUTPUT" ]; then
        echo -e "${YELLOW}Chưa thấy bản build Release, đang tiến hành build...${NC}"
        cmd_build
        DLL_OUTPUT=$(find bin/Release/ -name "${MOD_NAME}.dll" 2>/dev/null | head -n 1)
    fi

    if [ -z "$DLL_OUTPUT" ]; then
        echo -e "${RED}[!] Không tìm thấy file ${MOD_NAME}.dll sau khi build!${NC}"
        exit 1
    fi

    echo -e "${BLUE}Đang triển khai vào thư mục game: $TARGET_MOD_DIR...${NC}"
    mkdir -p "$TARGET_MOD_DIR"
    
    # Copy DLL và PDB
    OUT_DIR=$(dirname "$DLL_OUTPUT")
    cp "$OUT_DIR"/*.dll "$TARGET_MOD_DIR/" 2>/dev/null || true
    cp "$OUT_DIR"/*.pdb "$TARGET_MOD_DIR/" 2>/dev/null || true
    
    # Copy manifest và assets nếu có
    if [ -f "manifest.json" ]; then
        cp manifest.json "$TARGET_MOD_DIR/"
    fi
    if [ -d "assets" ]; then
        cp -r assets "$TARGET_MOD_DIR/"
    fi

    echo -e "${GREEN}✓ Đã cài đặt mod '$MOD_NAME' thành công vào Cinderbox!${NC}"
    echo -e "${YELLOW}Bây giờ bạn hãy mở game Stardew Valley để trải nghiệm mod nhé!${NC}"
}

# Điều hướng lệnh
case "$1" in
    doctor)
        cmd_doctor
        ;;
    new)
        cmd_new "$2"
        ;;
    build)
        cmd_build
        ;;
    deploy)
        cmd_deploy
        ;;
    help|--help|-h|"")
        usage
        ;;
    *)
        echo -e "${RED}Lệnh không hợp lệ: $1${NC}"
        usage
        exit 1
        ;;
esac
