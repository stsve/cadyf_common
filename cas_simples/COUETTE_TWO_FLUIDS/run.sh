#!/bin/sh

function sed_opt {
    sed -i "s/\($1[ ]*= \).*\( ! CHANGEME\)$/\1$2\2/gI" ${prefix}.amiral
}


prefix="couette"

sed_opt "cond_init"     "exacte"
sed_opt "demarrage_int" "exacte"
sed_opt "t_final"       "20.0d0"
comet ${prefix}
Makeall

amiral ${prefix} ${prefix}00
cadyf ${prefix}00 ${prefix} ${prefix}01
adapt ${prefix} ${prefix}00 ${prefix}01

sed_opt "cond_init"     "interpolation"
sed_opt "demarrage_int" "interpolation"
sed_opt "t_final"       "40.0d0"

amiral ${prefix} ${prefix}01 ${prefix}00
cadyf ${prefix}01 ${prefix} ${prefix}02
adapt ${prefix} ${prefix}01 ${prefix}02

gen_vtk_series
