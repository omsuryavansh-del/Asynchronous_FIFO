create_clock -period 40.000 -name clk_rd -waveform {0.000 20.000} [get_ports clk_rd]
create_clock -period 10.000 -name clk_wr -waveform {0.000 5.000} [get_ports clk_wr]

set_max_delay -datapath_only -from [get_clocks clk_wr] -to [get_clocks clk_rd] 40.000
set_max_delay -datapath_only -from [get_clocks clk_rd] -to [get_clocks clk_wr] 10.000


