`include "uvm_macros.svh"
import uvm_pkg::*;

interface a_fif(input clk_wr ,input clk_rd);

logic wr_rst_n;
logic rd_rst_n;

logic write_en;
logic read_en;

logic [7:0] data_in;
logic [7:0] data_out;

logic full;
logic empty;

endinterface