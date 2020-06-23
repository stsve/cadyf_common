#!/bin/sh

prefix="drop"

comet ${prefix}
amiral ${prefix} ${prefix}00
cadyf ${prefix}00 ${prefix} ${prefix}01
adapt ${prefix} ${prefix}00 ${prefix}01
gen_vtk_series
