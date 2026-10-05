#!/usr/bin/env bash
# ==============================================================================
# stardew-mod: Công cụ dòng lệnh hỗ trợ phát triển mod Stardew Valley Cinderbox
# Tuân thủ UI Style Shell (ui-style-shell) - Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tải thư viện UI style
if [ -f "/usr/local/bin/ui.sh" ]; then
    source "/usr/local/bin/ui.sh"
elif [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
elif [ -f "$HOME/stardew-workspace/scripts/ui.sh" ]; then
    source "$HOME/stardew-workspace/scripts/ui.sh"
fi

DOTNET_CMD="/opt/dotnet/dotnet"
[ ! -f "$DOTNET_CMD" ] && [ -f "/root/.dotnet/dotnet" ] && DOTNET_CMD="/root/.dotnet/dotnet"
[ ! -f "$DOTNET_CMD" ] && DOTNET_CMD="dotnet"

WORKSPACE="${STARDEW_WORKSPACE:-$HOME/stardew-workspace}"
GAME_DIR="/sdcard/StardewValley"
GAME_FILES="$GAME_DIR/desktop/GameFiles"
SMAPI_DIR="$GAME_DIR/smapi-internal"
MODS_DIR="$GAME_DIR/desktop/Mods"

cmd_doctor() {
    print_header "KIỂM TRA MÔI TRƯỜNG CINDERBOX"

    # 1. Kiểm tra .NET
    if command -v "$DOTNET_CMD" >/dev/null 2>&1 || [ -f "$DOTNET_CMD" ]; then
        local ver=$("$DOTNET_CMD" --version 2>/dev/null || echo "10.0")
        print_success ".NET SDK: Phiên bản $ver"
    else
        print_error ".NET SDK: Chưa tìm thấy bộ biên dịch dotnet."
    fi

    # 2. Kiểm tra bộ nhớ /sdcard
    if [ -d "/sdcard" ]; then
        print_success "Bộ nhớ /sdcard: Đã kết nối thành công"
    else
        print_error "Bộ nhớ /sdcard: Không thể truy cập."
    fi

    # 3. Kiểm tra game files
    if [ -f "$GAME_FILES/Stardew Valley.dll" ]; then
        print_success "Game Files: Tìm thấy Stardew Valley.dll"
    else
        print_warning "Chưa thấy $GAME_FILES/Stardew Valley.dll"
        print_info "Hãy mở game Cinderbox lên ít nhất 1 lần trên máy."
    fi

    # 4. Kiểm tra SMAPI
    if [ -f "$SMAPI_DIR/StardewModdingAPI.dll" ]; then
        print_success "SMAPI: Tìm thấy StardewModdingAPI.dll tại smapi-internal"
    elif [ -f "$GAME_FILES/StardewModdingAPI.dll" ]; then
        print_success "SMAPI: Tìm thấy StardewModdingAPI.dll tại GameFiles"
    else
        print_warning "Chưa thấy StardewModdingAPI.dll (Đảm bảo đã cài đặt SMAPI)"
    fi

    # 5. Kiểm tra thư mục Mods
    if [ -d "$MODS_DIR" ]; then
        print_success "Thư mục Mods: Sẵn sàng tại $MODS_DIR"
    else
        mkdir -p "$MODS_DIR" 2>/dev/null || true
        print_success "Đã tạo thư mục Mods tại $MODS_DIR"
    fi
}

cmd_new() {
    local mod_name="$1"
    if [ -z "$mod_name" ]; then
        printf "  Nhập tên mod (không dấu, viết liền, ví dụ SieuNongDan): "
        read -r mod_name
    fi

    if [ -z "$mod_name" ]; then
        print_error "Tên mod không được để trống."
        return 1
    fi

    local target_dir="$WORKSPACE/mods/$mod_name"
    if [ -d "$target_dir" ]; then
        print_error "Thư mục mod $target_dir đã tồn tại."
        return 1
    fi

    local template_dir="$WORKSPACE/templates/starter-mod"
    [ ! -d "$template_dir" ] && template_dir="/usr/local/share/stardew-template/templates/starter-mod"
    [ ! -d "$template_dir" ] && template_dir="/root/stardew-env/templates/starter-mod"
    [ ! -d "$template_dir" ] && template_dir="$SCRIPT_DIR/../templates/starter-mod"

    print_info "Đang tạo dự án mod: $mod_name..."
    mkdir -p "$target_dir"
    cp -r "$template_dir/"* "$target_dir/"

    mv "$target_dir/StarterMod.csproj" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/manifest.json" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/ModEntry.cs" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/deploy.sh" 2>/dev/null || true

    print_success "Khởi tạo mod mới thành công!"
    print_box "Vị trí: $target_dir"
    echo
    print_info "Hướng dẫn tiếp theo:"
    echo "  1. cd $target_dir"
    echo "  2. Dùng AI (opencode) hoặc sửa file ModEntry.cs theo ý thích"
    echo "  3. Chạy: stardew-mod build"
    echo "  4. Chạy: stardew-mod deploy"
}

cmd_build() {
    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Không tìm thấy file .csproj trong thư mục hiện tại."
        print_info "Hãy dùng lệnh 'cd' vào thư mục mod của bạn trước."
        return 1
    fi

    spin_task "Đang biên dịch dự án ($csproj)" "$DOTNET_CMD" build "$csproj" -c Release
}

cmd_deploy() {
    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Không tìm thấy file .csproj trong thư mục hiện tại."
        return 1
    fi

    local mod_name
    mod_name=$(basename "$csproj" .csproj)
    local target_mod_dir="$MODS_DIR/$mod_name"

    local dll_output
    dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    if [ -z "$dll_output" ]; then
        print_warning "Chưa tìm thấy bản build Release, đang tiến hành build tự động..."
        cmd_build || return 1
        dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    fi

    if [ -z "$dll_output" ]; then
        print_error "Không tìm thấy file ${mod_name}.dll sau khi build."
        return 1
    fi

    print_info "Đang triển khai file mod vào Cinderbox..."
    mkdir -p "$target_mod_dir"

    local out_dir
    out_dir=$(dirname "$dll_output")
    cp "$out_dir"/*.dll "$target_mod_dir/" 2>/dev/null || true
    cp "$out_dir"/*.pdb "$target_mod_dir/" 2>/dev/null || true

    [ -f "manifest.json" ] && cp manifest.json "$target_mod_dir/"
    [ -d "assets" ] && cp -r assets "$target_mod_dir/"

    print_success "Đã cài đặt mod '$mod_name' vào Cinderbox thành công!"
    print_box "Đường dẫn: $target_mod_dir"
}

# Menu tương tác khi không truyền tham số
interactive_menu() {
    while true; do
        clear_screen
        banner "STARDEW MOD MANAGER" "Công cụ hỗ trợ VibeCoding Mod Cinderbox"
        local menu_items=(
            "Kiểm tra môi trường (Doctor)"
            "Tạo dự án mod mới (New)"
            "Biên dịch mod hiện tại (Build)"
            "Triển khai vào game (Deploy)"
        )
        print_menu "${menu_items[@]}"

        local choice
        choice=$(get_choice)
        case "$choice" in
            1)
                echo
                cmd_doctor
                echo
                wait_for_enter
                ;;
            2)
                echo
                cmd_new
                echo
                wait_for_enter
                ;;
            3)
                echo
                cmd_build
                echo
                wait_for_enter
                ;;
            4)
                echo
                cmd_deploy
                echo
                wait_for_enter
                ;;
            0|q|Q)
                echo
                print_info "Tạm biệt!"
                break
                ;;
            *)
                print_warning "Lựa chọn không hợp lệ."
                sleep 1
                ;;
        esac
    done
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
    help|--help|-h)
        print_header "HƯỚNG DẪN LỆNH STARDEW-MOD"
        echo "  stardew-mod doctor        Kiểm tra game files và .NET SDK"
        echo "  stardew-mod new <TênMod>   Tạo dự án mod mới từ template chuẩn"
        echo "  stardew-mod build         Biên dịch mod trong thư mục hiện tại"
        echo "  stardew-mod deploy        Cài đặt mod vào thư mục game Mods/"
        print_line
        ;;
    "")
        interactive_menu
        ;;
    *)
        print_error "Lệnh không hợp lệ: $1"
        print_info "Chạy 'stardew-mod help' để xem các lệnh hỗ trợ."
        exit 1
        ;;
esac
