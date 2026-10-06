#!/usr/bin/env bash
# ==============================================================================
# stardew-mod: Công cụ dòng lệnh & Agent CLI hỗ trợ phát triển mod Stardew Valley
# Tối ưu hóa cho AI Agents (OpenCode, Claude, Hermes) & Người dùng VibeCoding
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

# Tự động ánh xạ bộ nhớ Android vào home & workspace nếu chưa có
if [ -d "/sdcard" ]; then
    [ ! -e "$HOME/sdcard" ] && ln -sfn /sdcard "$HOME/sdcard" 2>/dev/null || true
    if [ -d "$WORKSPACE" ]; then
        [ ! -e "$WORKSPACE/game" ] && [ -d "$GAME_DIR" ] && ln -sfn "$GAME_DIR" "$WORKSPACE/game" 2>/dev/null || true
        [ ! -e "$WORKSPACE/installed-mods" ] && [ -d "$MODS_DIR" ] && ln -sfn "$MODS_DIR" "$WORKSPACE/installed-mods" 2>/dev/null || true
    fi
fi

# ------------------------------------------------------------------------------
# 1. DOCTOR: Kiểm tra môi trường hệ thống & game files
# ------------------------------------------------------------------------------
cmd_doctor() {
    local json_mode=0
    for arg in "$@"; do
        [ "$arg" = "--json" ] && json_mode=1
    done

    local has_dotnet=0 has_sdcard=0 has_game=0 has_smapi=0 has_mods=0
    local dotnet_ver="none"

    if command -v "$DOTNET_CMD" >/dev/null 2>&1 || [ -f "$DOTNET_CMD" ]; then
        has_dotnet=1
        dotnet_ver=$("$DOTNET_CMD" --version 2>/dev/null || echo "10.0")
    fi
    [ -d "/sdcard" ] && has_sdcard=1
    [ -f "$GAME_FILES/Stardew Valley.dll" ] && has_game=1
    ([ -f "$SMAPI_DIR/StardewModdingAPI.dll" ] || [ -f "$GAME_FILES/StardewModdingAPI.dll" ]) && has_smapi=1
    [ -d "$MODS_DIR" ] && has_mods=1

    if [ "$json_mode" -eq 1 ]; then
        cat << EOF
{
  "dotnet": $( [ $has_dotnet -eq 1 ] && echo "true" || echo "false" ),
  "dotnet_version": "$dotnet_ver",
  "sdcard": $( [ $has_sdcard -eq 1 ] && echo "true" || echo "false" ),
  "game_files": $( [ $has_game -eq 1 ] && echo "true" || echo "false" ),
  "smapi": $( [ $has_smapi -eq 1 ] && echo "true" || echo "false" ),
  "mods_dir": $( [ $has_mods -eq 1 ] && echo "true" || echo "false" ),
  "workspace": "$WORKSPACE"
}
EOF
        return 0
    fi

    print_header "KIỂM TRA MÔI TRƯỜNG CINDERBOX"
    if [ "$has_dotnet" -eq 1 ]; then
        print_success ".NET SDK: Phiên bản $dotnet_ver"
    else
        print_error ".NET SDK: Chưa tìm thấy bộ biên dịch dotnet."
    fi

    if [ "$has_sdcard" -eq 1 ]; then
        print_success "Bộ nhớ /sdcard: Đã kết nối thành công"
    else
        print_error "Bộ nhớ /sdcard: Không thể truy cập."
    fi

    if [ "$has_game" -eq 1 ]; then
        print_success "Game Files: Tìm thấy Stardew Valley.dll"
    else
        print_warning "Chưa thấy $GAME_FILES/Stardew Valley.dll (Hãy mở game Cinderbox lên 1 lần)."
    fi

    if [ "$has_smapi" -eq 1 ]; then
        print_success "SMAPI: Tìm thấy StardewModdingAPI.dll"
    else
        print_warning "Chưa thấy StardewModdingAPI.dll (Đảm bảo đã cài đặt SMAPI trên Android)."
    fi

    if [ "$has_mods" -eq 1 ]; then
        print_success "Thư mục Mods: Sẵn sàng tại $MODS_DIR"
    else
        mkdir -p "$MODS_DIR" 2>/dev/null || true
        print_success "Đã tạo thư mục Mods tại $MODS_DIR"
    fi
}

# ------------------------------------------------------------------------------
# 2. NEW: Khởi tạo dự án mod mới (Non-interactive nếu có truyền tên)
# ------------------------------------------------------------------------------
cmd_new() {
    local mod_name="$1"
    if [ -z "$mod_name" ]; then
        printf "  Nhập tên mod (không dấu, viết liền, ví dụ: AutoForage): " >&2
        if [ -t 0 ]; then
            read -r mod_name || true
        elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
            read -r mod_name < /dev/tty 2>/dev/null || true
        fi
    fi

    mod_name=$(echo "$mod_name" | tr -d '[:space:]')
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

    mkdir -p "$target_dir"
    cp -r "$template_dir/"* "$target_dir/"

    mv "$target_dir/StarterMod.csproj" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/manifest.json" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/ModEntry.cs" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/deploy.sh" 2>/dev/null || true

    print_success "Đã tạo mod '$mod_name' tại: $target_dir"
    echo "$target_dir"
}

# ------------------------------------------------------------------------------
# 3. BUILD: Biên dịch mod (Hỗ trợ truyền đường dẫn hoặc chạy trong thư mục hiện tại)
# ------------------------------------------------------------------------------
cmd_build() {
    local target_dir="${1:-.}"
    if [ -d "$target_dir" ]; then
        cd "$target_dir"
    fi

    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Không tìm thấy file .csproj trong $(pwd)"
        return 1
    fi

    print_info "Đang biên dịch: $csproj..."
    if "$DOTNET_CMD" build "$csproj" -c Release; then
        print_success "Biên dịch thành công!"
        return 0
    else
        local err=$?
        print_error "Biên dịch thất bại (mã lỗi $err). Xem chi tiết lỗi ở trên."
        return "$err"
    fi
}

# ------------------------------------------------------------------------------
# 4. DEPLOY: Đóng gói và copy trực tiếp vào thư mục game Stardew Valley
# ------------------------------------------------------------------------------
cmd_deploy() {
    local target_dir="${1:-.}"
    if [ -d "$target_dir" ]; then
        cd "$target_dir"
    fi

    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Không tìm thấy file .csproj trong $(pwd)"
        return 1
    fi

    local mod_name
    mod_name=$(basename "$csproj" .csproj)
    local target_mod_dir="$MODS_DIR/$mod_name"

    local dll_output
    dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    if [ -z "$dll_output" ]; then
        print_info "Chưa thấy bản build Release, tiến hành biên dịch..."
        cmd_build || return 1
        dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    fi

    if [ -z "$dll_output" ]; then
        print_error "Không tìm thấy file ${mod_name}.dll sau khi build."
        return 1
    fi

    mkdir -p "$target_mod_dir"
    local out_dir
    out_dir=$(dirname "$dll_output")

    cp "$out_dir"/*.dll "$target_mod_dir/" 2>/dev/null || true
    cp "$out_dir"/*.pdb "$target_mod_dir/" 2>/dev/null || true
    [ -f "manifest.json" ] && cp manifest.json "$target_mod_dir/"
    [ -d "assets" ] && cp -r assets "$target_mod_dir/"

    print_success "Đã cài đặt mod '$mod_name' vào game!"
    print_box "Đích: $target_mod_dir"
    echo "$target_mod_dir"
}

# ------------------------------------------------------------------------------
# 5. LOGS: Đọc log SMAPI gần nhất để debug lỗi khi chơi game
# ------------------------------------------------------------------------------
cmd_logs() {
    local lines="${1:-60}"
    local log_file=""
    if [ -f "$SMAPI_DIR/smapi-log.txt" ]; then
        log_file="$SMAPI_DIR/smapi-log.txt"
    elif [ -f "$GAME_DIR/ErrorLogs/smapi-crash.txt" ]; then
        log_file="$GAME_DIR/ErrorLogs/smapi-crash.txt"
    elif [ -f "$GAME_DIR/smapi-internal/smapi-crash.txt" ]; then
        log_file="$GAME_DIR/smapi-internal/smapi-crash.txt"
    fi

    if [ -n "$log_file" ] && [ -f "$log_file" ]; then
        print_header "SMAPI LOG ($log_file - $lines dòng gần nhất)"
        tail -n "$lines" "$log_file"
    else
        print_warning "Chưa tìm thấy file log SMAPI tại $SMAPI_DIR."
        print_info "Hãy mở game và vào mod ít nhất 1 lần để SMAPI sinh file log."
    fi
}

# ------------------------------------------------------------------------------
# 6. LIST: Liệt kê các mod hiện có trong workspace và trong game
# ------------------------------------------------------------------------------
cmd_list() {
    print_header "DANH SÁCH DỰ ÁN MOD TRONG WORKSPACE"
    if [ -d "$WORKSPACE/mods" ] && [ "$(ls -A "$WORKSPACE/mods" 2>/dev/null)" ]; then
        ls -1 "$WORKSPACE/mods"
    else
        print_info "Chưa có dự án mod nào trong $WORKSPACE/mods"
    fi

    echo
    print_header "DANH SÁCH MOD ĐÃ CÀI TRONG GAME (CINDERBOX)"
    if [ -d "$MODS_DIR" ] && [ "$(ls -A "$MODS_DIR" 2>/dev/null)" ]; then
        ls -1 "$MODS_DIR"
    else
        print_info "Thư mục $MODS_DIR đang trống."
    fi
}

# ------------------------------------------------------------------------------
# MENU TƯƠNG TÁC DÀNH CHO CON NGƯỜI (Nếu chạy trực tiếp không có đối số)
# ------------------------------------------------------------------------------
interactive_menu() {
    while true; do
        clear_screen
        banner "STARDEW MOD VIBECODING" "Công cụ phát triển Mod Cinderbox Android"
        local menu_items=(
            "Kiểm tra môi trường (Doctor)"
            "Tạo dự án mod mới (New)"
            "Biên dịch mod hiện tại (Build)"
            "Triển khai vào game (Deploy)"
            "Xem log game & SMAPI (Logs)"
            "Danh sách các mod (List)"
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
            5)
                echo
                cmd_logs
                echo
                wait_for_enter
                ;;
            6)
                echo
                cmd_list
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

# Điều hướng tham số
case "$1" in
    doctor)
        cmd_doctor "${@:2}"
        ;;
    new)
        cmd_new "$2"
        ;;
    build)
        cmd_build "$2"
        ;;
    deploy)
        cmd_deploy "$2"
        ;;
    logs|log)
        cmd_logs "$2"
        ;;
    list|ls)
        cmd_list
        ;;
    help|--help|-h)
        print_header "STARDEW-MOD CLI (Agent & Human Friendly)"
        echo "  stardew-mod doctor [--json]    Kiểm tra .NET SDK, game files & SMAPI"
        echo "  stardew-mod new <TênMod>        Khởi tạo dự án mod mới không cần hỏi lại"
        echo "  stardew-mod build [ĐườngDẫn]   Biên dịch dự án mod ra bản Release"
        echo "  stardew-mod deploy [ĐườngDẫn]  Đóng gói và copy trực tiếp vào game Mods/"
        echo "  stardew-mod logs [SốDòng]       Đọc log SMAPI để phân tích lỗi crash"
        echo "  stardew-mod list               Xem danh sách các mod trong workspace & game"
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
