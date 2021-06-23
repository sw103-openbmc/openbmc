require recipes-bsp/u-boot/u-boot.inc
require u-boot-common.inc

DEPENDS += "bc-native dtc-native"

PV = "d2019.04"
OVERRIDES += ":bld-uboot"

SRCBRANCH = "openbmc/helium/delta"
SRC_URI = "git://github.com/sw103-openbmc/openbmc-uboot.git;branch=${SRCBRANCH};protocol=https"
