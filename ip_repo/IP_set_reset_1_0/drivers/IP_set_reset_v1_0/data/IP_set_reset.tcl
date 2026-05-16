

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "IP_set_reset" "NUM_INSTANCES" "DEVICE_ID"  "C_ip_setreset_BASEADDR" "C_ip_setreset_HIGHADDR"
}
