`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

`uvm_analysis_imp_decl(_wr)   // declares a new type: uvm_analysis_imp_wr#(T, coverage)
`uvm_analysis_imp_decl(_rd)   // declares: uvm_analysis_imp_rd#(T, coverage)

class coverage extends uvm_component;
    `uvm_component_utils(coverage)
    uvm_analysis_imp_wr #(item_wr, coverage) item_collected_wr;
    uvm_analysis_imp_rd #(item_rd, coverage) item_collected_rd;

    item_wr tr_wr;
    item_rd tr_rd;

    covergroup cg;
        write :coverpoint  tr_wr.write_en {
            bins write1 = {1};
            bins write0 = {0};
        }

        read :coverpoint tr_rd.read_en {
            bins read0 = {0};
            bins read1 = {1};
        }

        full :coverpoint tr_wr.full {
            bins full0 = {0};
            bins full1 = {1};
        } 

        empty :coverpoint tr_rd.empty {
            bins empty0 = {0};
            bins empty1 = {1};
        }

        full_empty :cross full,empty {
            bins full0_empty0 = binsof(full.full0) && binsof(empty.empty0);
            illegal_bins full1_empty1 = binsof(full.full1) && binsof(empty.empty1);
        }
    endgroup

    function new(string name = "coverage", uvm_component parent = null);
        super.new(name,parent);
        item_collected_wr = new("item_collected_wr",this);
        item_collected_rd = new("item_collected_rd",this);  
        tr_wr = item_wr::type_id::create("tr_wr");
        tr_rd = item_rd::type_id::create("tr_rd");
        cg = new();
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write_wr(item_wr req);
        tr_wr = req;
        cg.sample();
    endfunction

    virtual function void write_rd(item_rd req);
        tr_rd = req;
        cg.sample();
    endfunction

endclass
