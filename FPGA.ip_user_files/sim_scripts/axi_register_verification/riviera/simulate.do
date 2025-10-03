transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+axi_register_verification  -L xil_defaultlib -L xilinx_vip -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_21 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.axi_register_verification xil_defaultlib.glbl

do {axi_register_verification.udo}

run 1000ns

endsim

quit -force
