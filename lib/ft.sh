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
# NOTE: the "i" color prefix means "intensive", i.e. bright.

set -u
set -o pipefail

__ft__ON="\033["
__ft__OFF="${__ft__ON}0m"

declare -A __ft__foreground
__ft__foreground["norm"]=39
__ft__foreground["black"]=30
__ft__foreground["red"]=31
__ft__foreground["green"]=32
__ft__foreground["yellow"]=33
__ft__foreground["blue"]=34
__ft__foreground["purple"]=35
__ft__foreground["cyan"]=36
__ft__foreground["white"]=37
__ft__foreground["ired"]=91
__ft__foreground["igreen"]=92
__ft__foreground["iyellow"]=93
__ft__foreground["iblue"]=94
__ft__foreground["ipurple"]=95
__ft__foreground["icyan"]=96
__ft__foreground["iwhite"]=97

declare -A __ft__background
__ft__background["norm"]=49
__ft__background["black"]=40
__ft__background["red"]=41
__ft__background["green"]=42
__ft__background["yellow"]=43
__ft__background["blue"]=44
__ft__background["purple"]=45
__ft__background["cyan"]=46
__ft__background["white"]=47
__ft__background["iblack"]=100
__ft__background["ired"]=101
__ft__background["igreen"]=102
__ft__background["iyellow"]=103
__ft__background["iblue"]=104
__ft__background["ipurple"]=105
__ft__background["icyan"]=106
__ft__background["iwhite"]=107

declare -A __ft__emphasis
__ft__emphasis["norm"]=0
__ft__emphasis["bold"]=1
__ft__emphasis["italic"]=3
__ft__emphasis["underline"]=4
__ft__emphasis["blink"]=5
__ft__emphasis["reverse"]=7


ft_style() {
  local emphasis=${__ft__emphasis[$1]}
  local foreground=${__ft__foreground[$2]}
  local background=${__ft__background[$3]}
  local line=$4
  echo "${__ft__ON}${emphasis};${foreground};${background}m${line}${__ft__OFF}"
}


ft() {
  echo -e `ft_style $1 $2 $3 "$4"`
}


ftn() {
  echo -en `ft_style $1 $2 $3 "$4"`
}
