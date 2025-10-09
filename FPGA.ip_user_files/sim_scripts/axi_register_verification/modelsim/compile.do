vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xilinx_vip
vlib modelsim_lib/msim/axi_infrastructure_v1_1_0
vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/axi_vip_v1_1_21

vmap xilinx_vip modelsim_lib/msim/xilinx_vip
vmap axi_infrastructure_v1_1_0 modelsim_lib/msim/axi_infrastructure_v1_1_0
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap axi_vip_v1_1_21 modelsim_lib/msim/axi_vip_v1_1_21

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L xilinx_vip "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L xilinx_vip "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/axi_register_verification/ip/axi_register_verification_axi_vip_0_0/sim/axi_register_verification_axi_vip_0_0_pkg.sv" \

vlog -work axi_vip_v1_1_21 -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L xilinx_vip "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/f16f/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  -sv -L axi_vip_v1_1_21 -L xilinx_vip "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/axi_register_verification/ip/axi_register_verification_axi_vip_0_0/sim/axi_register_verification_axi_vip_0_0.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../FPGA.gen/sources_1/bd/axi_register_verification/ipshared/ec67/hdl" "+incdir+../../../../../../../../../Xilinx/2025.1/data/rsb/busdef" "+incdir+/storage/Xilinx/2025.1/Vivado/data/xilinx_vip/include" \
"../../../bd/axi_register_verification/ipshared/3442/hdl/SimpleRegistersBank_slave_lite_v1_0_S00_AXI.v" \
"../../../bd/axi_register_verification/ipshared/3442/hdl/SimpleRegistersBank.v" \
"../../../bd/axi_register_verification/ip/axi_register_verification_SimpleRegistersBank_0_0/sim/axi_register_verification_SimpleRegistersBank_0_0.v" \
"../../../bd/axi_register_verification/sim/axi_register_verification.v" \

vlog -work xil_defaultlib \
"glbl.v"

