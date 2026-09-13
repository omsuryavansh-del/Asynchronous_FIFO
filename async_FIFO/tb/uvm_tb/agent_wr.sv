`include "uvm_macros.svh"
import uvm_pkg::*;
import u_fpkg::*;

class agent_wr extends uvm_agent;
    `uvm_component_utils(agent_wr)
    uvm_analysis_port #(item_wr) items;
    
    driver_wr dr;
    monitor_wr mon;
    uvm_sequencer#(item_wr) sqr;

    
    function new(string name = "agent_wr", uvm_component parent = null);
        super.new(name,parent);                
        items = new("items",this);        
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        dr = driver_wr::type_id::create("dr", this);
        mon = monitor_wr::type_id::create("mon", this);
        sqr = uvm_sequencer#(item_wr)::type_id::create("sqr", this); 
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        dr.seq_item_port.connect(sqr.seq_item_export);
        mon.item_collected_port.connect(this.items);
    endfunction
endclass
