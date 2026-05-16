

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "Reg_reset_only" "NUM_INSTANCES" "DEVICE_ID"  "C_reset_only_BASEADDR" "C_reset_only_HIGHADDR"
}
