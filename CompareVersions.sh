#!/bin/sh

VER_SPLIT_SED="s/[\.\-_]/:/g;s/\([[:digit:]]\)\([^0-9:]\)/\1:\2/g;s/\([^0-9:]\)\([[:digit:]]\)/\1\:\2/g;"

# Compare with one segment of versions
ver_cmp_seg() {
  [[ "$1" == "$2" ]] && return 0
  if [[ -z "${1//[[:digit:]]/}" ]] && [[ -z "${2//[[:digit:]]/}" ]]; then
    # "Both $1 and $2 are numbers"
    [[ "$1" -gt "$2" ]] && return 1
    [[ "$1" -lt "$2" ]] && return 2
  else
    # "Either or both of '$1' '$2' are not numbers"
    [[ "$1" > "$2" ]] && return 1
    [[ "$1" < "$2" ]] && return 2
  fi
  return 0
}

ver_cmp() {
  local result ver1 ver2 tmp
  ver1=$(echo $1 | sed "$VER_SPLIT_SED")
  ver2=$(echo $2 | sed "$VER_SPLIT_SED")
  
  result=0
  while true
  do
    ver_cmp_seg ${ver1%%:*} ${ver2%%:*}
    result=$?
    [[ "x$result" != "x0" ]] && return $result

    tmp=${ver1#*:}
    if [ $tmp == $ver1 ]
    then
      ver1=''
    else
      ver1=$tmp
    fi

    tmp=${ver2#*:}
    if [ $tmp == $ver2 ]
    then
      ver2=''
    else
      ver2=$tmp
    fi

    if [ -z "$ver1" ] || [ -z "$ver2" ]
    then
      break
    fi
  done

  ver_cmp_seg ${ver1%%:*} ${ver2%%:*}
  return $?
}

ver_cmp "2.1.0" "2.0.0"

