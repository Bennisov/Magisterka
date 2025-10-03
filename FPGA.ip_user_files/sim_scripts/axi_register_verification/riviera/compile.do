transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xilinx_vip
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/xil_defaultlib
vlib riviera/axi_vip_v1_1_21

vmap xilinx_vip riviera/xilinx_vip
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_vip_v1_1_21 riviera/axi_vip_v1_1_21

vlog -work xilinx_vip  -incr "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0  -incr -v2k5 "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"../../../bd/axi_register_verification/ip/axi_register_verification_axi_vip_0_0/sim/axi_register_verification_axi_vip_0_0_pkg.sv" \

vlog -work axi_vip_v1_1_21  -incr "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -incr "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"../../../bd/axi_register_verification/ip/axi_register_verification_axi_vip_0_0/sim/axi_register_verification_axi_vip_0_0.sv" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" -l xilinx_vip -l axi_infrastructure_v1_1_0 -l xil_defaultlib -l axi_vip_v1_1_21 \
"../../../bd/axi_register_verification/ipshared/9bbb/hdl/SimpleRegistersBank_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/axi_register_verification/ipshared/9bbb/hdl/SimpleRegistersBank.v" \
"../../../bd/axi_register_verification/ip/axi_register_verification_SimpleRegistersBank_0_0/sim/axi_register_verification_SimpleRegistersBank_0_0.v" \
"../../../bd/axi_register_verification/sim/axi_register_verification.v" \

vlog -work xil_defaultlib \
"glbl.v"

