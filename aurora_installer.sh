#!/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)
echo "${MAGENTA}${BOLD}"
echo ""
echo "   ------    ----    ---- -----------    --------   -----------     ------${RESET}"    
echo "${MAGENTA}${BOLD}  ********   ****    **** ***********   **********  ***********    ********${RESET}"   
echo "${MAGENTA} ----------  ----    ---- ----    ---  ----    ---- ----    ---   ----------${RESET}" 
echo "${MAGENTA}****    **** ****    **** *********    ***      *** *********    ****    ****${RESET}" 
echo "${BLUE}------------ ----    ---- ---------    ---      --- ---------    ------------${RESET}" 
echo "${BLUE}************ ************ ****  ****   ****    **** ****  ****   ************${RESET}" 
echo "${CYAN}----    ---- ------------ ----   ----   ----------  ----   ----  ----    ----${RESET}" 
echo "${CYAN}${BOLD}****    **** ************ ****    ****   ********   ****    **** ****    ****${RESET}"
echo ""
echo "${RESET}${CYAN}Run apps and games in Borealis using Flatpak, AppImages, git, gcc, python, + automated .tar extraction for signficantly higher performance than Crostini!${RESET}"
echo "${RESET}"
echo "${BLUE}0: Quit${RESET}"
echo "${MAGENTA}1: Download and install Aurora + Flatpak to ~/ and ~/opt${RESET}"
echo ""
fi
read -rp "Enter (0-1): " choice


case "$choice" in
    0)
        echo "Quit"
        ;;
    1)
echo ""
echo "${CYAN}${BOLD}About to start downloading Flatpak, Git, GCC, Python and their dependencies! Download can take up to 5 minutes.${RESET}"
sleep 5

sed -i '/\.flatpak\.env/d' "$HOME/.bashrc"
sed -i '/\.flatpak\.logic/d' "$HOME/.bashrc"

if grep -q "# Flatpak --user logic" "$HOME/.bashrc"; then
sed -i '/# Flatpak --user logic/,/^}/d' "$HOME/.bashrc"
echo "${CYAN}Removed Flatpak function from .bashrc${RESET}"
fi

 mkdir -p /usr/local/aurora/opt/flatpak
 mkdir -p /usr/local/aurora/opt/flatpak-deps
 mkdir -p /usr/local/aurora/opt/bin
 
export XDG_RUNTIME_DIR="$HOME/.xdg-runtime-dir"
mkdir -p "$XDG_RUNTIME_DIR"
chmod chronos "$XDG_RUNTIME_DIR"

export PATH="$HOME/opt/flatpak/usr/bin:$APPS/opt/flatpak-deps/usr/bin:/bin:/usr/bin:$PATH"
if [ ! -S "$XDG_RUNTIME_DIR/dbus-session" ]; then
  dbus-daemon --session \
    --address="unix:path=$XDG_RUNTIME_DIR/dbus-session" \
    --print-address=1 \
    --nopidfile \
    --nofork > "$XDG_RUNTIME_DIR/dbus-session.address" &
  sleep 1
fi
export DBUS_SESSION_BUS_ADDRESS=$(cat "$XDG_RUNTIME_DIR/dbus-session.address")

mkdir -p "$XDG_RUNTIME_DIR/doc/portal"
echo 3 > "$XDG_RUNTIME_DIR/doc/portal/version"
chmod +x "$APPS/opt/bin/aurora"
chmod +x "$APPS/opt/bin/starman"
echo "${MAGENTA}"
curl -L https://raw.githubusercontent.com/Terry-Stormchaser/Aurora/main/.flatpak.logic -o ~/opt/.flatpak.logic
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/Terry-Stormchaser/Aurora/main/aurora -o ~/opt/bin/aurora
echo "${RESET}${CYAN}"
curl -L https://raw.githubusercontent.com/Terry-Stormchaser/Aurora/main/starman -o ~/opt/bin/starman
echo "${RESET}${BLUE}"
curl -L https://raw.githubusercontent.com/Terry-Stormchaser/Aurora/main/version -o ~/opt/bin/version
echo "${RESET}${MAGENTA}"
curl -L https://raw.githubusercontent.com/Terry-Stormchaser/Aurora/main/.flatpak.env -o ~/opt/.flatpak.env
echo "${RESET}"
chmod +x ~/opt/bin/aurora
chmod +x ~/opt/bin/starman

echo ""

download_and_extract()
{
    local url="$1"
    local target_dir="$2"
    local FILE SAFE_FILE

    echo "${MAGENTA}"
    echo "Downloading: $url"

    env -i PATH="$PATH" wget --content-disposition --trust-server-names "$url"

    echo "${RESET}${BLUE}"

    if [[ -f "download" ]]; then
        FILE="download"
    else
        FILE=$(ls -t *.pkg.tar.zst 2>/dev/null | head -n 1)
    fi

    SAFE_FILE="${FILE//:/}"
    if [[ "$FILE" != "$SAFE_FILE" ]]; then
        mv "$FILE" "$SAFE_FILE"
        FILE="$SAFE_FILE"
    fi
    echo "Extracting $FILE to $target_dir"

    env -i PATH="$PATH" tar --use-compress-program=unzstd -xvf "$FILE" -C "$target_dir"

    rm -f "$FILE"
    chmod +x "$target_dir/usr/bin"/* 2>/dev/null
    chmod +x "$HOME/opt/usr/bin"/* 2>/dev/null
    chmod +x "$HOME/opt/usr/share"/* 2>/dev/null
    echo "${RESET}${CYAN}${FILE} extracted.${RESET}"

    export LD_LIBRARY_PATH="$target_dir/usr/lib:$APPS/opt/usr/lib:$LD_LIBRARY_PATH"
    export FLATPAK_USER_DIR="$APPS/.local/share/flatpak"
    sleep 1
}

# Flatpak Core
URL="https://archlinux.org/packages/extra/x86_64/flatpak/download"
download_and_extract "$URL" "$APPS/opt/flatpak"

URL="https://archlinux.org/packages/extra/x86_64/ostree/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/libxml2/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libmalcontent/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/core/x86_64/gpgme/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/libsodium/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/composefs/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/bubblewrap/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-dbus-proxy/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

URL="https://archlinux.org/packages/extra/x86_64/xdg-desktop-portal-gtk/download"
download_and_extract "$URL" "$APPS/opt/flatpak-deps"

############################################################## 
# Fastfetch
URL="https://archlinux.org/packages/extra/x86_64/fastfetch/download"
download_and_extract "$URL" "$APPS/opt/"

URL="https://archlinux.org/packages/extra/x86_64/yyjson/download"
download_and_extract "$URL" "$APPS/opt/"

############################################################## 
# Nano
URL="https://archlinux.org/packages/core/x86_64/nano/download"
download_and_extract "$URL" "$APPS/opt/"


#xfce4
#URL"https://archlinux.org/packages/extra/x86_64/exo/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/garcon/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-session/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfconf/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4util/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4ui/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-panel/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfdesktop/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/gvfs/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxfce4windowing/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/gdk-pixbuf2/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/glib2/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/util-linux-libs/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/sqlite/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/gtk3/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libdisplay-info/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libwnck3/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libx11/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/gobject-introspection/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-dev-tools/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/any/gtk-doc/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-xephyr/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libepoxy/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/libtirpc/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/krb5/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/e2fsprogs/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/libldap/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/core/x86_64/keyutils/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libunwind/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxau/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxdmcp/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxshmfence/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/pixman/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-server-common/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/any/xkeyboard-config/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-setxkbmap/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xorg-xkbcomp/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-wm/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-keysyms/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-image/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxcb/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util-renderutil/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/any/xorgproto/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/any/xcb-proto/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xcb-util/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/gtk-layer-shell/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/startup-notification/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxres/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfce4-settings/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxklavier/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libnotify/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/xfwm4/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/libxpresent/download"
#download_and_extract "$URL" "$HOME/opt/"

#URL"https://archlinux.org/packages/extra/x86_64/thunar/download"
#download_and_extract "$URL" "$HOME/opt/"

chmod +x "$APPS/opt/usr/bin/fastfetch"
chmod +x "$APPS/opt/usr/bin/nano"
touch "$APPS/.starman_flatpak_cache"
echo ""

if file "$XDG_RUNTIME_DIR/dbus-session" | grep -q socket; then
  export DBUS_SESSION_BUS_ADDRESS=$(grep -E '^unix:' "$XDG_RUNTIME_DIR/dbus-session.address")
  grep -v '^export DBUS_SESSION_BUS_ADDRESS=' "$APPS/opt/.flatpak.env" > "$APPS/opt/.flatpak.env.tmp"
  echo "export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" >> "$APPS/opt/.flatpak.env.tmp"
  mv "$HOME/opt/.flatpak.env.tmp" "$APPS/opt/.flatpak.env"
else
  echo "dbus socket not found."
fi

[ -f "$HOME/.bashrc" ] || touch "$HOME/.bashrc"

FLATPAK_ENV_LINE='[ -f "$HOME/opt/.flatpak.env" ] && . "$HOME/opt/.flatpak.env"'
FLATPAK_LOGIC_LINE='[ -f "$HOME/opt/.flatpak.logic" ] && . "$HOME/opt/.flatpak.logic"'

grep -Fxq "$FLATPAK_ENV_LINE" "$HOME/.bashrc" || echo "$FLATPAK_ENV_LINE" >> "$HOME/.bashrc"
grep -Fxq "$FLATPAK_LOGIC_LINE" "$HOME/.bashrc" || echo "$FLATPAK_LOGIC_LINE" >> "$HOME/.bashrc"


if [ ! -f "$APPS/opt/flatpak-deps/usr/lib/libostree-1.so.1" ]; then
  echo "libostree-1.so.1 missing from deps!"
  exit 1
fi

"$APPS/opt/flatpak/usr/bin/flatpak" --version
sleep 3

NPM_BASE="$APPS/opt/usr/lib/node_modules/npm"
NVM_DIR="$APPS/opt/usr/share/nvm"
BIN_DIR="$APPS/opt/usr/bin"

mkdir -p "$BIN_DIR"
mkdir -p ~/opt/etc/xdg/xfce4/xfwm4

rm -f "$BIN_DIR/npm" "$BIN_DIR/npx"

ln -s "$NPM_BASE/bin/npm-cli.js" "$BIN_DIR/npm"
ln -s "$NPM_BASE/bin/npx-cli.js" "$BIN_DIR/npx"

chmod +x "$NPM_BASE/bin/"*.js

unset -f yay 2>/dev/null
unset -f paru 2>/dev/null
unset -f pacaur 2>/dev/null
unset -f pacman 2>/dev/null

ln -sf "$APPS/opt/bin/starman" "$APPS/opt/bin/yay"
ln -sf "$APPS/opt/bin/starman" "$APPS/opt/bin/paru"
ln -sf "$APPS/opt/bin/starman" "$APPS/opt/bin/pacaur"
ln -sf "$APPS/opt/bin/starman" "$APPS/opt/bin/pacman"


echo ""

export LD_LIBRARY_PATH="$APPS/opt/flatpak-deps/usr/lib:$LD_LIBRARY_PATH"


sleep 3
echo "${RESET}${MAGENTA}"
echo "╔═══════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                       ${RESET}${BOLD}${MAGENTA}DOWNLOAD COMPLETE!${RESET}${MAGENTA}                                      ║"
echo "║           ${RESET}${BLUE}${BOLD}Open a new Crosh tab and run ${RESET}${BOLD}${CYAN}vsh borealis${RESET}${BLUE}${BOLD} to continue setting up Flatpak${RESET}${MAGENTA}            ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════════════════════╝"
echo "${RESET}"
echo ""

        ;;
    *)
        echo "${RED}Invalid option.$RESET"
        exit 1
        ;;
esac
exit 0

