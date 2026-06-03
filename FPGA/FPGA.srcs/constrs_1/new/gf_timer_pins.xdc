# Clock
set_property -dict { LOC V7   IOSTANDARD LVCMOS12 } [get_ports { CLK } ]
create_clock -period 1000.000 -name CLK [get_ports CLK]

# waveform_out_0[5:0] - PMOD pins 1,2,3,4,7,8
set_property -dict { LOC AJ9  IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[0] } ]
set_property -dict { LOC L12  IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[1] } ]
set_property -dict { LOC AH9  IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[2] } ]
set_property -dict { LOC AJ10 IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[3] } ]
set_property -dict { LOC U11  IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[4] } ]
set_property -dict { LOC AH3  IOSTANDARD LVCMOS12 } [get_ports { waveform_out_0[5] } ]

# busy_out_0 - PMOD pin 9
set_property -dict { LOC AJ4  IOSTANDARD LVCMOS12 } [get_ports { busy_out_0 } ]

# ena_in_0 - PMOD pin 10
set_property -dict { LOC AK5  IOSTANDARD LVCMOS12 } [get_ports { ena_in_0 } ]

# PMOD direction control
set_property -dict { LOC P10  IOSTANDARD LVCMOS12 } [get_ports { PMOD_SHIFTER_DIR_12[0] } ]
set_property -dict { LOC P11  IOSTANDARD LVCMOS12 } [get_ports { PMOD_SHIFTER_DIR_34[0] } ]
set_property -dict { LOC AH4  IOSTANDARD LVCMOS12 } [get_ports { PMOD_SHIFTER_DIR_78[0] } ]
set_property -dict { LOC AC9  IOSTANDARD LVCMOS12 } [get_ports { PMOD_SHIFTER_DIR_910[0] } ]