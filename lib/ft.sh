# Using:
#
#  ft <emphasis> <foreground> <background> "<message>"
#
# E.g.:
#
#  ft norm norm norm "Default text formatting"
#  ft bold red norm "Bold red text"
#
# NOTE: the `ftn` is the same as `ft` but without EOL.
# NOTE: the "i" prefix of a color name is the "intensive" or bright color.


set -u
set -o pipefail


ft_set="\033["
ft_reset="${ft_set}0m"

declare -A ft_foreground_colors
ft_foreground_colors["norm"]=39
ft_foreground_colors["black"]=30
ft_foreground_colors["red"]=31
ft_foreground_colors["green"]=32
ft_foreground_colors["yellow"]=33
ft_foreground_colors["blue"]=34
ft_foreground_colors["purple"]=35
ft_foreground_colors["cyan"]=36
ft_foreground_colors["white"]=37
ft_foreground_colors["ired"]=91
ft_foreground_colors["igreen"]=92
ft_foreground_colors["iyellow"]=93
ft_foreground_colors["iblue"]=94
ft_foreground_colors["ipurple"]=95
ft_foreground_colors["icyan"]=96
ft_foreground_colors["iwhite"]=97

declare -A ft_background_colors
ft_background_colors["norm"]=49
ft_background_colors["black"]=40
ft_background_colors["red"]=41
ft_background_colors["green"]=42
ft_background_colors["yellow"]=43
ft_background_colors["blue"]=44
ft_background_colors["purple"]=45
ft_background_colors["cyan"]=46
ft_background_colors["white"]=47
ft_background_colors["iblack"]=100
ft_background_colors["ired"]=101
ft_background_colors["igreen"]=102
ft_background_colors["iyellow"]=103
ft_background_colors["iblue"]=104
ft_background_colors["ipurple"]=105
ft_background_colors["icyan"]=106
ft_background_colors["iwhite"]=107

declare -A ft_emphasis
ft_emphasis["norm"]=0
ft_emphasis["bold"]=1
ft_emphasis["italic"]=3
ft_emphasis["underline"]=4
ft_emphasis["blink"]=5
ft_emphasis["reverse"]=7


ft_escaped_line() {
  local emphasis=${ft_emphasis[$1]}
  local foreground=${ft_foreground_colors[$2]}
  local background=${ft_background_colors[$3]}
  local line=$4
  echo "${ft_set}${emphasis};${foreground};${background}m${line}${ft_reset}"
}


ft() {
  echo -e `ft_escaped_line $1 $2 $3 "$4"`
}


ftn() {
  echo -en `ft_escaped_line $1 $2 $3 "$4"`
}
