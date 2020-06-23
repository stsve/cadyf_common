#!/bin/sh

function sed_opt {
    sed -i "s/\($1[ ]*= \).*\( ! CHANGEME\)$/\1$2\2/gI" ${prefix}.amiral
}

function itval {
    itv=($(python -c "v=${1}; print '{0:03d} {1:03d} {2:03d}'.format(v,v+1,v-1)"))
    itc=${itv[0]}; itn=${itv[1]}; itp=${itv[2]}
}

function check_time {
    tfst=$(awk '{ print $1 }' ${prefix}${1}.final_state)
    flag=$(python -c "print ${tfst} >= ${tfin}")
    if [ "${flag}" == "True" ]; then
        echo "Reached Tmax = ${tfin}"
        end_exec
    fi
}

function end_exec {
    sig="${1:-"0"}"
    gen_vtk_series
    exit ${sig}
}


prefix="bubble"
tfin="3.0e0"
initit="${1:-"0"}"

if [ "${initit}" -eq 0 ]; then
    sed_opt "cond_init"     "nulle"
    sed_opt "demarrage_int" "basique"
    comet ${prefix}

    itval "${initit}"
    amiral ${prefix} ${prefix}${itc} > amiral${itc}.log; [ $? -ne 0 ] && end_exec 1
    cadyf ${prefix}${itc} ${prefix} ${prefix}${itn} > cadyf${itc}.log; [ $? -ne 0 ] && end_exec 1
    #adapt ${prefix} ${prefix}${itc} ${prefix}${itn} > adapt${itc}.log; [ $? -ne 0 ] && end_exec 1
    check_time ${itc}

    initit="1"
fi

sed_opt "cond_init"     "interpolation"
sed_opt "demarrage_int" "interpolation"

for (( i = ${initit}; i <= 998; i++)); do
    itval "${i}"
    amiral ${prefix} ${prefix}${itc} ${prefix}${itp} > amiral${itc}.log; [ $? -ne 0 ] && end_exec 1
    cadyf ${prefix}${itc} ${prefix} ${prefix}${itn} > cadyf${itc}.log; [ $? -ne 0 ] && end_exec 1
    #adapt ${prefix} ${prefix}${itc} ${prefix}${itn} > adapt${itc}.log; [ $? -ne 0 ] && end_exec 1
    check_time ${itc}
done

end_exec
