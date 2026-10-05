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

clocking wr_mon_cb @(posedge clk_wr);
    default input #1step;
    input wr_rst_n, write_en, data_in, full;
endclocking

clocking rd_mon_cb @(posedge clk_rd);
    default input #1step;
    input rd_rst_n, read_en, empty;
    input #0 data_out;
endclocking

endinterface