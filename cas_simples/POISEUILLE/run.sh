#!/bin/sh

prefix="poiseuille"

comet ${prefix}
amiral ${prefix} ${prefix}00
cadyf ${prefix}00 ${prefix} ${prefix}01
adapt ${prefix} ${prefix}00 ${prefix}01
