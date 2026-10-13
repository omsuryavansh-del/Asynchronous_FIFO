`include "uvm_macros.svh"
`include "../../rtl/top.v"
`include "a_fif.sv"
`include "fifo_assertion.sv"

import uvm_pkg::*;
import af_fpkg::*;


module top_tb;

    reg clk_wr, clk_rd;
    a_fif f_if(clk_wr, clk_rd);

    top #(8,8) dut(
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),

        .rst_wr(f_if.wr_rst_n),
        .rst_rd(f_if.rd_rst_n),

        .write_en(f_if.write_en),
        .read_en(f_if.read_en),

        .data_in_top(f_if.data_in),
        .data_out_top(f_if.data_out),

        .full(f_if.full),
        .empty(f_if.empty)
    );

    bind top fifo_assertion f_assert (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),

        .wr_rst_n(f_if.wr_rst_n),
        .rd_rst_n(f_if.rd_rst_n),

        .write_en(f_if.write_en),
        .read_en(f_if.read_en),

        .full(f_if.full),
        .empty(f_if.empty)          
    );

    always #5 clk_wr = ~clk_wr;
    always #10 clk_rd = ~clk_rd;

    initial begin
        clk_wr = 0;
        clk_rd = 0;
        uvm_config_db#(virtual a_fif)::set(null,"","a_fif",f_if);
        run_test("all_test");
    end

endmodule