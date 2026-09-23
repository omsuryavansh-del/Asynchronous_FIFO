`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class driver_wr extends uvm_driver #(item_wr);
    `uvm_component_utils(driver_wr)
    virtual a_fif f_if;

    function new(string name = "driver_wr",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if(!uvm_config_db#(virtual a_fif)::get(this,"","a_fif",f_if))
            `uvm_fatal("DRV","virtual interface config db not found")
    endfunction

    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        f_if.wr_rst_n  = 0;
        f_if.write_en  = 0;
        f_if.read_en   = 0;
        f_if.data_in   = 0;
        repeat(2) @(posedge f_if.clk_wr);
        f_if.wr_rst_n = 1;
        phase.drop_objection(this);
    endtask

    task run_phase (uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
                @(posedge f_if.clk_wr)
                if(f_if.wr_rst_n) begin
                    f_if.write_en = req.write_en;
                    f_if.data_in = req.data_in;
                    $display("write transaction sent to dut wr_rst_n = %0b || w_en = %0b || data_in = %0d",
                              f_if.wr_rst_n, req.write_en, req.data_in);
                end
            seq_item_port.item_done();
        end
    endtask
endclass