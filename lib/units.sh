to_bytes() {
  x=$(echo ${1:-} | tr -d " ") # No spaces
  x="${x^^}" # Uppercased
  x="${x/I/i}" # Excluding lowercased 'i'
  x="${x%B}" # Without 'B' suffix
  [[ -n $x ]] && numfmt --from=auto $x 2> /dev/null
}


to_iec() {
  echo $1 | numfmt --to=iec-i --round=nearest --format="%.1f" --suffix=B \
    2> /dev/null
}
