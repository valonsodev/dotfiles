uptime=$(uptime -p | sed -e 's/up //g')

DIR=~/.config/rofi/powermenu
rofi_command="rofi -theme $DIR/powermenu.rasi"

# Options
shutdown=" 󰐥 "
reboot=" 󰜉 "
lock=" 󰌾 "
suspend=" 󰒲 "
logout=" 󰍃 "

# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
		hyprlock -c ~/.config/hypr/hyprlock.conf
        ;;
    $suspend)
		mpc -q pause
		amixer set Master mute
		systemctl suspend
        ;;
    $logout)
		hyprctl --instance 0 dispatch exit
        ;;
esac
