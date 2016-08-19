#/bin/bash

fmt_field()
{
  local field="$*"

  printf '%s' "${field:1:$((${#field}-3))}"
}


fmt_str()
{
  local str="$*"

  printf '%s' "${str:1:$((${#str}-3))}"
}


fmt_val()
{
  local val="$*"

  printf '%s' ${val:0:$((${#val}-1))}
}


print_line()
{
  local field="$1"
  local value="$2"

  printf '%-8s\t%s\n' "$(fmt_field $field)": "$value"
}


print_body()
{
  while read -r field value
  do
    case "$field" in
      \"changed\":)
        print_line "$field" "$(fmt_val $value)"
        ;;
      \"rc\":)
        print_line "$field" "$(fmt_val $value)"
        ;;
      \"cmd\":)
        print_line "$field" "$(fmt_str $value)"
        ;;
      \"delta\":)
        print_line "$field" "$(fmt_str $value)"
        ;;
      \"end\":)
        print_line "$field" "$(fmt_str $value)"
        ;;
      \"start\":)
        print_line "$field" "$(fmt_str $value)"
        ;;
      \"stdout\":)
        printf "$(fmt_str $value)"
        ;;
      *)
        ;;
    esac
  done
}


print_fatal()
{
  local msg="$1"
 
  local colorClose="${msg##*\}}"
  local prefix="${msg%% \{*}$colorClose"
  local body="${msg#* => }"
  body="${body%$colorClose}"

  printf '%s\n' "$prefix"
  printf '%s' "$body" | python -mjson.tool | print_body
}


printf -v fatal '^\e\[0;31mfatal:'

while IFS= read -r
do
  if [[ "$REPLY" =~ $fatal ]]
  then
    print_fatal "$REPLY"
  else
    printf '%s\n' "$REPLY"
  fi
done
