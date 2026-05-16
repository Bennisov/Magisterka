

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "Reg_set_reset" "NUM_INSTANCES" "DEVICE_ID"  "C_set_reset_BASEADDR" "C_set_reset_HIGHADDR"
}
