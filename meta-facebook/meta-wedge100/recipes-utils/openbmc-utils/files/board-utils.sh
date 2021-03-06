# Copyright 2015-present Facebook. All Rights Reserved.

SYSCPLD_SYSFS_DIR=$(i2c_device_sysfs_abspath 12-0031)
FANCPLD_SYSFS_DIR=$(i2c_device_sysfs_abspath 8-0033)
COME_SYSFS_DIR=$(i2c_device_sysfs_abspath 4-0033)

PWR_MAIN_SYSFS="${SYSCPLD_SYSFS_DIR}/pwr_main_n"
PWR_USRV_SYSFS="${SYSCPLD_SYSFS_DIR}/pwr_usrv_en"
PWR_USRV_BTN_SYSFS="${SYSCPLD_SYSFS_DIR}/pwr_usrv_btn_en"
SLOTID_SYSFS="${SYSCPLD_SYSFS_DIR}/slotid"

wedge_iso_buf_enable() {
    # TODO, no isolation buffer
    return 0
}

wedge_iso_buf_disable() {
    # TODO, no isolation buffer
    return 0
}

wedge_is_us_on() {
    local val n retries prog
    if [ $# -gt 0 ]; then
        retries="$1"
    else
        retries=1
    fi
    if [ $# -gt 1 ]; then
        prog="$2"
    else
        prog=""
    fi
    if [ $# -gt 2 ]; then
        default=$3              # value 0 means defaul is 'ON'
    else
        default=1
    fi
    val=$(cat $PWR_USRV_SYSFS 2> /dev/null | head -n 1)
    if [ -z "$val" ]; then
        return $default
    elif [ "$val" == "0x1" ]; then
        return 0            # powered on
    else
        return 1
    fi
}

wedge_board_type() {
    echo 'WEDGE100'
}

wedge_slot_id() {
    printf "%d\n" $(cat $SLOTID_SYSFS)
}

wedge_board_rev() {
    local val0 val1 val2
    val0=$(gpio_get_value BOARD_REV_ID0)
    val1=$(gpio_get_value BOARD_REV_ID1)
    val2=$(gpio_get_value BOARD_REV_ID2)
    echo $((val0 | (val1 << 1) | (val2 << 2)))
}

# Should we enable OOB interface or not
wedge_should_enable_oob() {
    # wedge100 uses BMC MAC since beginning
    return -1
}

wedge_power_on_board() {
    local val
    # power on main power, uServer power, and enable power button
    val=$(cat $PWR_MAIN_SYSFS | head -n 1)
    if [ "$val" != "0x1" ]; then
        echo 1 > $PWR_MAIN_SYSFS
        sleep 2
    fi
    val=$(cat $PWR_USRV_BTN_SYSFS | head -n 1)
    if [ "$val" != "0x1" ]; then
        echo 1 > $PWR_USRV_BTN_SYSFS
        sleep 1
    fi
}

#
# Helper function to check if AC PSU (#1 or #2) is present/plugged by
# reading syscpld "psu1|2_present" sysfs node.
#
# $1 - PSU ID/Index (1 or 2)
#
wedge_psu_is_present() {
    psu_id="$1"
    pathname="${SYSCPLD_SYSFS_DIR}/psu${psu_id}_present"

    # Return false if the according syscpld register is not accessible
    if ! val=$(head -n 1 "$pathname"); then
        return 1
    fi

    # Note: 0 means the PSU is present.
    if [ "$val" = "0x0" ]; then
        return 0
    fi

    return 1
}
