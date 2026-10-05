#!/usr/bin/env bash
# ==============================================================================
# stardew-mod: Công cụ dòng lệnh hỗ trợ phát triển mod Stardew Valley Cinderbox
# Tuân thủ UI Style Shell (ui-style-shell)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tải thư viện UI style
if [ -f "/usr/local/bin/ui.sh" ]; then
    source "/usr/local/bin/ui.sh"
elif [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
elif [ -f "/root/stardew-workspace/scripts/ui.sh" ]; then
    source "/root/stardew-workspace/scripts/ui.sh"
else
    RESET='\033[0m'   BOLD='\033[1m'    GRAY='\033[90m'
    RED='\033[1;31m'  GREEN='\033[1;32m' YELLOW='\033[1;33m'
    BLUE='\033[1;34m' CYAN='\033[1;36m'  WHITE='\033[1;37m'
    clear_screen() { printf "\033[2J\033[H"; }
    print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
    print_prompt() { printf "${GREEN}❯ ${RESET}"; }
    print_success() { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
    print_error() { printf "${RED}✗ %s${RESET}\n" "$1"; }
    print_warning() { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
    print_info() { printf "${BLUE}ℹ %s${RESET}\n" "$1"; }
    banner() {
        printf "      ${BOLD}${WHITE}%s${RESET}\n" "$1"
        [ -n "$2" ] && printf "      ${GRAY}%s${RESET}\n" "$2"
        print_line
    }
    print_header() {
        printf "${BOLD}== %s ==${RESET}\n" "$1"
        print_line
    }
    print_menu() {
        local items=("$@") idx=1
        for item in "${items[@]}"; do
            printf "  ${CYAN}[%d]${RESET} %s\n" "$idx" "$item"
            idx=$((idx + 1))
        done
        printf "  ${GRAY}[0]${RESET} Thoát\n"
        print_line
    }
    print_box() {
        local len=${#1} border=""
        for ((i=0; i<len+2; i++)); do border="${border}─"; done
        printf "  ${GRAY}┌%s┐${RESET}\n  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n  ${GRAY}└%s┘${RESET}\n" "$border" "$1" "$border"
    }
    get_choice() {
        local c
        printf "${GREEN}❯ ${RESET}"
        read -r c
        echo "$c"
    }
    wait_for_enter() {
        printf "${GRAY}Nhấn Enter để tiếp tục...${RESET}"
        read -r
    }
fi

DOTNET_CMD="/root/.dotnet/dotnet"
[ ! -f "$DOTNET_CMD" ] && DOTNET_CMD="dotnet"

WORKSPACE="/root/stardew-workspace"
GAME_DIR="/sdcard/StardewValley"
GAME_FILES="$GAME_DIR/desktop/GameFiles"
SMAPI_DIR="$GAME_DIR/smapi-internal"
MODS_DIR="$GAME_DIR/desktop/Mods"

cmd_doctor() {
    print_header "KIEM TRA MOI TRUONG CINDERBOX"
    
    # 1. Kiểm tra .NET
    if command -v "$DOTNET_CMD" >/dev/null 2>&1 || [ -f "$DOTNET_CMD" ]; then
        local ver=$("$DOTNET_CMD" --version 2>/dev/null || echo "10.0")
        print_success ".NET SDK: Phien ban $ver"
    else
        print_error ".NET SDK: Chua tim thay bo bien dich dotnet."
    fi

    # 2. Kiểm tra bộ nhớ /sdcard
    if [ -d "/sdcard" ]; then
        print_success "Bo nho /sdcard: Da ket noi thanh cong"
    else
        print_error "Bo nho /sdcard: Khong the truy cap."
    fi

    # 3. Kiểm tra game files
    if [ -f "$GAME_FILES/Stardew Valley.dll" ]; then
        print_success "Game Files: Tim thay Stardew Valley.dll"
    else
        print_warning "Chua thay $GAME_FILES/Stardew Valley.dll"
        print_info "Hay mo game Cinderbox len it nhat 1 lan tren may."
    fi

    # 4. Kiểm tra SMAPI
    if [ -f "$SMAPI_DIR/StardewModdingAPI.dll" ]; then
        print_success "SMAPI: Tim thay StardewModdingAPI.dll tai smapi-internal"
    elif [ -f "$GAME_FILES/StardewModdingAPI.dll" ]; then
        print_success "SMAPI: Tim thay StardewModdingAPI.dll tai GameFiles"
    else
        print_warning "Chua thay StardewModdingAPI.dll (Dam bao da cai dat SMAPI)"
    fi

    # 5. Kiểm tra thư mục Mods
    if [ -d "$MODS_DIR" ]; then
        print_success "Thu muc Mods: San sang tai $MODS_DIR"
    else
        mkdir -p "$MODS_DIR" 2>/dev/null || true
        print_success "Da tao thu muc Mods tai $MODS_DIR"
    fi
}

cmd_new() {
    local mod_name="$1"
    if [ -z "$mod_name" ]; then
        printf "Nhap ten mod (khong dau, viet lien, vi du SieuNongDan): "
        read -r mod_name
    fi

    if [ -z "$mod_name" ]; then
        print_error "Ten mod khong duoc de trong."
        return 1
    fi

    local target_dir="$WORKSPACE/mods/$mod_name"
    if [ -d "$target_dir" ]; then
        print_error "Thu muc mod $target_dir da ton tai."
        return 1
    fi

    local template_dir="$WORKSPACE/templates/starter-mod"
    [ ! -d "$template_dir" ] && template_dir="/root/stardew-env/templates/starter-mod"
    [ ! -d "$template_dir" ] && template_dir="$SCRIPT_DIR/../templates/starter-mod"

    print_info "Dang tao du an mod: $mod_name..."
    mkdir -p "$target_dir"
    cp -r "$template_dir/"* "$target_dir/"

    mv "$target_dir/StarterMod.csproj" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/${mod_name}.csproj" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/manifest.json" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/ModEntry.cs" 2>/dev/null || true
    sed -i "s/StarterMod/$mod_name/g" "$target_dir/deploy.sh" 2>/dev/null || true

    print_success "Tao mod moi thanh cong!"
    print_box "Vi tri: $target_dir"
    echo
    print_info "Huong dan tiep theo:"
    echo "  1. cd $target_dir"
    echo "  2. Dung AI hoac sua file ModEntry.cs theo y thich"
    echo "  3. Chay: stardew-mod build"
    echo "  4. Chay: stardew-mod deploy"
}

cmd_build() {
    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Khong tim thay file .csproj trong thu muc hien tai."
        print_info "Hay dung lenh 'cd' vao thu muc mod cua ban truoc."
        return 1
    fi

    print_info "Dang bien dich du an ($csproj)..."
    if "$DOTNET_CMD" build "$csproj" -c Release; then
        print_success "Bien dich hoan tat (Release build)."
    else
        print_error "Bien dich that bai! Hay kiem tra thong bao loi o tren."
        return 1
    fi
}

cmd_deploy() {
    local csproj
    csproj=$(find . -maxdepth 1 -name "*.csproj" 2>/dev/null | head -n 1)
    if [ -z "$csproj" ]; then
        print_error "Khong tim thay file .csproj trong thu muc hien tai."
        return 1
    fi

    local mod_name
    mod_name=$(basename "$csproj" .csproj)
    local target_mod_dir="$MODS_DIR/$mod_name"

    local dll_output
    dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    if [ -z "$dll_output" ]; then
        print_warning "Chua tim thay ban build, he thong se tu dong build..."
        cmd_build || return 1
        dll_output=$(find bin/Release/ -name "${mod_name}.dll" 2>/dev/null | head -n 1)
    fi

    if [ -z "$dll_output" ]; then
        print_error "Khong tim thay file ${mod_name}.dll sau khi build."
        return 1
    fi

    print_info "Dang copy file mod vao Cinderbox..."
    mkdir -p "$target_mod_dir"
    
    local out_dir
    out_dir=$(dirname "$dll_output")
    cp "$out_dir"/*.dll "$target_mod_dir/" 2>/dev/null || true
    cp "$out_dir"/*.pdb "$target_mod_dir/" 2>/dev/null || true
    
    [ -f "manifest.json" ] && cp manifest.json "$target_mod_dir/"
    [ -d "assets" ] && cp -r assets "$target_mod_dir/"

    print_success "Da cai dat mod '$mod_name' vao Cinderbox!"
    print_box "Duong dan: $target_mod_dir"
}

# Menu tuong tac khi khong truyen tham so
interactive_menu() {
    while true; do
        clear_screen
        banner "STARDEW MOD MANAGER" "Cong cu ho tro VibeCoding Mod Cinderbox"
        local menu_items=(
            "Kiem tra moi truong (Doctor)"
            "Tao du an mod moi (New)"
            "Bien dich mod hien tai (Build)"
            "Trien khai vao game (Deploy)"
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
                print_info "Tam biet!"
                break
                ;;
            *)
                print_warning "Lua chon khong hop le."
                sleep 1
                ;;
        esac
    done
}

# Dieu huong lenh
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
        print_header "HUONG DAN LENH STARDEW-MOD"
        echo "  stardew-mod doctor       Kiem tra game files va .NET SDK"
        echo "  stardew-mod new <TenMod>  Tao du an mod moi tu template chuan"
        echo "  stardew-mod build        Bien dich mod trong thu muc hien tai"
        echo "  stardew-mod deploy       Cai dat mod vao thu muc game Mods/"
        print_line
        ;;
    "")
        interactive_menu
        ;;
    *)
        print_error "Lenh khong hop le: $1"
        print_info "Chay 'stardew-mod help' de xem cac lenh ho tro."
        exit 1
        ;;
esac
