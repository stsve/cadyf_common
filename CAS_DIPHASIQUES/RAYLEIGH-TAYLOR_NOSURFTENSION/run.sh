#!/bin/sh

function sed_opt {
    sed -i "s/\($1[ ]*= \).*\( ! CHANGEME\)$/\1$2\2/gI" ${prefix}.amiral
}

function itval {
    itv=($(python -c "v=${1}; print '{0:03d} {1:03d} {2:03d}'.format(v,v+1,v-1)"))
    itc=${itv[0]}; itn=${itv[1]}; itp=${itv[2]}
}


prefix="rt"
initit="${1:-"0"}"

if [ "${initit}" -eq 0 ]; then
    sed_opt "cond_init"     "nulle"
    sed_opt "demarrage_int" "basique"
    comet ${prefix}

    itval "${initit}"
    amiral ${prefix} ${prefix}${itc}; [ $? -ne 0 ] && exit 1
    cadyf ${prefix}${itc} ${prefix} ${prefix}${itn}; [ $? -ne 0 ] && exit 1
    #adapt ${prefix} ${prefix}${itc} ${prefix}${itn}; [ $? -ne 0 ] && exit 1

    initit="1"
fi

sed_opt "cond_init"     "interpolation"
sed_opt "demarrage_int" "interpolation"

for (( i = ${initit}; i <= 998; i++)); do
    itval "${i}"
    amiral ${prefix} ${prefix}${itc} ${prefix}${itp}; [ $? -ne 0 ] && exit 1
    cadyf ${prefix}${itc} ${prefix} ${prefix}${itn}; [ $? -ne 0 ] && exit 1
    #adapt ${prefix} ${prefix}${itc} ${prefix}${itn}; [ $? -ne 0 ] && exit 1
done

gen_vtk_series
