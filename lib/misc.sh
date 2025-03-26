_increment_filename() {
  # Outputs the $file name with the integer suffix to make it unique if the
  # $file is already exists.

  local file="$1"

  if [[ -f "file" || -d "$file" ]]
  then

    local i=0

    while [[ -f "$file$i" || -d "$file$i" ]]
    do
      i=$((i+1))
    done

    echo $file$i
  else
    echo $file
  fi
}

