#!/bin/bash

#shared setup run at the start of both the X11 (xfce) and Wayland (labwc)
#sessions, regardless of whether they were started via startx or lightdm

#disable accessibility features (sticky keys) - x11 only, no-op harmlessly under wayland
xkbset -a >/dev/null 2>&1

#sdl - default to pipewire
export SDL_AUDIODRIVER=pipewire

#load gpu settings
. "$HOME/bin/gpusettings"

#disable tearfree (x11 only)
if [ -n "$DISPLAY" ];then
	for device in $(xrandr |awk '{print $1}'|grep --color=never -v '^Screen'|grep --color=never -v '^[0-9]');do xrandr --output "$device" --set TearFree off >/dev/null 2>&1;done&
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

#disable compositor - it breaks things even if it can't actually composite (xfwm4/x11 only)
if [ -n "$DISPLAY" ];then
	(
	if hash xfconf-query >/dev/null 2>&1;then
		while :;do
			if pgrep -f xfconfd$ > /dev/null 2>&1;then
				xfconf-query -c xfwm4 -p /general/use_compositing -t bool -s false --create
				break
			else
				sleep 1
			fi
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

if [ ! -e "$HOME/.firstboot" ];then
	xfce4-terminal --geometry=0x0+100+100 &
	touch "$HOME/.firstboot"
fi
