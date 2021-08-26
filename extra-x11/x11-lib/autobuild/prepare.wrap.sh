trap - ERR; trap "abdie" ERR; bash -n "$0"

export CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration"

trap - ERR
