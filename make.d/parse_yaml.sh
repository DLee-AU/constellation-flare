#!/usr/bin/env sh

# https://stackoverflow.com/a/21189044
# Adjusted

# set -x

quote_if_needed() {
   local value="$1"

   # Don't quote if it's a simple number
   if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
      echo "$value"
      return
   fi

   # Don't quote if it's a boolean
   if [[ "$value" =~ ^(true|false|yes|no)$ ]]; then
      echo "$value"
      return
   fi

   # Quote if it contains spaces, special characters, or is a complex string
   if [[ "$value" =~ [[:space:]|[^a-zA-Z0-9_\.\-] ]] || [[ -n "$value" ]]; then
      printf '"%s"' "$value"
   else
      echo "$value"
   fi
}

function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "/^\($s\)x-[^:]*:/d" \
        -e "/^\($s\)  *x-[^:]*:/d" \
        -e "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s'\(.*\)'$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = toupper($2);
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         # Skip any variables originating from anchors
         if (toupper($2) ~ /^X_/) next;
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=%s\n", "'$prefix'",vn, toupper($2), quote_if_needed $3);
      }
   }'
}
