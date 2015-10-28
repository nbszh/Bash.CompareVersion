#!/bin/sh

VER_SPLIT_SED="s/\-/:/g;s/_/:/g;s/\./:/g"

# Compare with one segment of versions
ver_cmp_seg() {
  local s1 s2 prefixlen
  [[ "$1" == "$2" ]] && return 0
  if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -z "${1//[[:digit:]]/}" ]] && [[ -z "${2//[[:digit:]]/}" ]]; then
    # "Both $1 and $2 are numbers"
    [[ "$1" -gt "$2" ]] && return 1
    [[ "$1" -lt "$2" ]] && return 2
    return 0
  fi
  
  # "Either or both of '$1' '$2' are not numbers"
  if [[ "${#1}" -gt "${#2}" ]]; then
    prefixlen=$((${#1} - ${#2}))
    s1="$1"
    case "$2" in
    [0-9]*)
      s2="$(printf %0${prefixlen}d 0)${2}"
    ;;
    *)
      s2="$2"
    ;;
    esac
  elif [[ "${#1}" -lt "${#2}" ]]; then
    prefixlen=$((${#2} - ${#1}))
    s2="$2"
    case "$1" in
    [0-9]*)
      s1="$(printf %0${prefixlen}d 0)${1}"
    ;;
    *)
      s1="$1"
    ;;
    esac
  else
    s1="$1"
    s2="$2"
  fi
      
  [[ "$1" \> "$2" ]] && return 1
  [[ "$1" \< "$2" ]] && return 2

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
    if [[ $tmp == $ver1 ]]
    then
      ver1=''
    else
      ver1=$tmp
    fi

    tmp=${ver2#*:}
    if [[ $tmp == $ver2 ]]
    then
      ver2=''
    else
      ver2=$tmp
    fi

    if [[ -z "$ver1" ]] || [[ -z "$ver2" ]]
    then
      break
    fi
  done

  ver_cmp_seg ${ver1%%:*} ${ver2%%:*}
  return $?
}

ver_cmp "2.1.0" "2.0.0"

