`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class environment extends uvm_env;
    `uvm_component_utils(environment)

    agent_rd ag_rd;
    agent_wr ag_wr;

    scoreboard scb;
    coverage cov;

    function new(string name = "environment", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ag_rd = agent_rd::type_id::create("ag_rd",this);
        ag_wr = agent_wr::type_id::create("ag_wr",this);
        scb = scoreboard::type_id::create("scb",this);
        cov = coverage::type_id::create("cov",this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ag_rd.items.connect(scb.export_rd);
        ag_rd.items.connect(cov.item_collected_crd);
        ag_wr.items.connect(scb.export_wr);
        ag_wr.items.connect(cov.item_collected_cwr);
    endfunction

endclass