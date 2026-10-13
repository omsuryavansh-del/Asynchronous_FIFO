`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class monitor_rd extends uvm_monitor;
    `uvm_component_utils(monitor_rd)
    uvm_analysis_port #(item_rd) item_collected_port;
    virtual a_fif f_if;
    
    function new(string name = "monitor_rd",uvm_component parent = null);
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
            item_rd tr = item_rd::type_id::create("tr");

            @(f_if.rd_mon_cb);

            tr.rd_rst_n = f_if.rd_mon_cb.rd_rst_n;           
            tr.read_en = f_if.rd_mon_cb.read_en; 
            tr.data_out = f_if.rd_mon_cb.data_out; 
            tr.empty = f_if.rd_mon_cb.empty; 
            
            $display("item_rd sent to scoreboard rd_rst_n = %0b || rd_en = %0b || data_out = %0d",
            tr.rd_rst_n,tr.read_en,tr.data_out);
            item_collected_port.write(tr);
        end
    endtask
endclass