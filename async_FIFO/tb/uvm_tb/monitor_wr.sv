`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class monitor_wr extends uvm_monitor;
    `uvm_component_utils(monitor_wr)
    uvm_analysis_port #(item_wr) item_collected_port;
    virtual a_fif f_if;
    
    function new(string name = "monitor_wr ",uvm_component parent = null);
        super.new(name,parent);
        item_collected_port = new("item_collected_port",this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!(uvm_config_db#(virtual a_fif)::get(this,"","a_fif",f_if))) 
        `uvm_fatal("MON","config db vif not found anywhere");
    endfunction

task run_phase(uvm_phase phase);
    super.run_phase(phase);
        forever begin
            item_wr tr = item_wr::type_id::create("tr");
            @(posedge f_if.clk_wr);
            #1;
            tr.wr_rst_n = f_if.wr_rst_n;
            if(f_if.wr_rst_n)begin
                tr.write_en = f_if.write_en; 
                tr.data_in = f_if.data_in; 
                tr.full = f_if.full; 
                tr.data_out = f_if.data_out; 
            end
            $display("item_wr sent to scoreboard wr_rst_n = %0b || w_en = %0b || data_in = %0b || data_out = %0b",
                    tr.wr_rst_n,tr.write_en,tr.data_in,tr.data_out);
            item_collected_port.write(tr);
        end
    endtask
endclass