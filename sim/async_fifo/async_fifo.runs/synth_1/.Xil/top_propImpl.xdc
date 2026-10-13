set_property SRC_FILE_INFO {cfile:F:/Asynchronous_FIFO/async_FIFO/sim/async_fifo/async_fifo.srcs/constrs_1/new/async_clocks.xdc rfile:../../../async_fifo.srcs/constrs_1/new/async_clocks.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:4 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_clocks clk_wr] -to [get_clocks clk_rd] 40.000
set_property src_info {type:XDC file:1 line:5 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_clocks clk_rd] -to [get_clocks clk_wr] 10.000
