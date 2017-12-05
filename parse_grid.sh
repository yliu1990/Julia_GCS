#!/bin/sh
grep '^[^0-9]' $1 | (read; read; cat) | awk '/^julia/{a=$4;r=$5} /traning/{t=$4} /validation/{v=$4; print(a, r, t, v)}' | awk -F'[= ]' '{print $2,$4,$5,$6}'
