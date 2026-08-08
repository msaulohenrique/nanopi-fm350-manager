#!/bin/bash

. device/friendlyelec/rk3528/base.mk

FRIENDLYWRT_FILES+=(custom/nanopi-fm350)
TARGET_SD_RAW_FILENAME="friendlywrt_${FRIENDLYWRT_VERSION:-current}_rk3528_nanopi_neo3_plus_fm350_surf_sd.img"
