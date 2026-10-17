#!/bin/bash

#shared setup run at the start of both the X11 (xfce) and Wayland (labwc)
#sessions, regardless of whether they were started via startx or lightdm.
#must be idempotent/safe to run more than once, since the startx fallback
#path (.xinitrc.real) and the xfce autostart entry can both invoke this.

lockfile="/tmp/.session-common-$(id -u).lock"
exec 9>"$lockfile"
if ! flock -n 9; then
	#already running for this user (e.g. invoked both via .xinitrc.real and
	#xfce autostart in the startx fallback path), skip the duplicate run
	exit 0
fi

#XDG_SESSION_TYPE is set reliably by logind/lightdm to "x11" or "wayland".
#$DISPLAY is not a reliable signal here: labwc also sets DISPLAY once
#XWayland starts, so checking DISPLAY would misidentify wayland as x11.
is_x11=0
[ "$XDG_SESSION_TYPE" = "x11" ] && is_x11=1

#disable accessibility features (sticky keys) - x11 only
if [ $is_x11 -eq 1 ];then
	xkbset -a >/dev/null 2>&1
fi

#sdl - default to pipewire
#written to a file rather than just exported here, since this script runs as
#an autostart child process and an export here would not reach the game
#process launched later from a terminal in the same session
mkdir -p "$HOME/.config/environment.d"
echo "SDL_AUDIODRIVER=pipewire" > "$HOME/.config/environment.d/50-quake-bootable.conf"
export SDL_AUDIODRIVER=pipewire

#load gpu settings
. "$HOME/bin/gpusettings"

#disable tearfree (x11 only, xrandr acts on XWayland's virtual outputs under
#wayland which isn't what we want here)
if [ $is_x11 -eq 1 ];then
	(
		while IFS= read -r device; do
			xrandr --output "$device" --set TearFree off >/dev/null 2>&1
		done < <(xrandr | awk '{print $1}' | grep --color=never -v '^Screen' | grep --color=never -v '^[0-9]')
	)&
fi

(pgrep -f pasystray >/dev/null 2>&1 || nice pasystray)&

#connman
(
	pkill -f connman-gtk >/dev/null 2>&1
	while :;do
	nice connman-gtk --tray
	sleep 1
	done
)&

#disable compositor - it breaks things even if it can't actually composite
#(xfwm4/x11 only - labwc has no compositing toggle of its own here)
if [ $is_x11 -eq 1 ];then
	(
		count=0
		if hash xfconf-query >/dev/null 2>&1;then
			while [ $count -lt 30 ];do
				if pgrep -f xfconfd$ > /dev/null 2>&1;then
					xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s false --create
					break
				fi
				let count=count+1
				sleep 1
			done
		fi
	)&
fi

#make sure something is registered for qw links
if ! grep 'qw=' "$HOME/.config/mimeapps.list" >/dev/null 2>&1; then
	if [ -e "$HOME/.local/share/applications/qw-url-handler.desktop" ];then
		xdg-mime default qw-url-handler.desktop x-scheme-handler/qw >/dev/null 2>&1
	fi
fi

#xfce only runs desktop launchers it trusts, mark ours (checksum must match the file)
for f in "$HOME/Desktop/"*.desktop;do
	[ -e "$f" ] && gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | cut -d" " -f1)" >/dev/null 2>&1
done

#wallpaper on every monitor, once (xfdesktop keys it per monitor name, unknown until runtime)
if [ $is_x11 -eq 1 ] && [ ! -e "$HOME/.wallpaper-set" ];then
	(
		sleep 3
		for mon in $(xrandr --listactivemonitors | awk 'NR>1{print $4}');do
			for ws in 0 1 2 3;do
				xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor$mon/workspace$ws/last-image" -t string -s /usr/share/backgrounds/quake-bootable.jpg --create
				xfconf-query -c xfce4-desktop -p "/backdrop/screen0/monitor$mon/workspace$ws/image-style" -t int -s 5 --create
			done
		done
		touch "$HOME/.wallpaper-set"
	)&
fi

if [ ! -e "$HOME/.firstboot" ];then
	if [ $is_x11 -eq 1 ];then
		xfce4-terminal --geometry=0x0+100+100 &
	fi
	touch "$HOME/.firstboot"
fi
