`include "uvm_macros.svh"
import uvm_pkg::*;
import u_fpkg::*;

class coverage extends uvm_component;
    `uvm_component_utils(coverage)
    uvm_analysis_imp #(transaction,coverage) item_collected;
    transaction tr;

    covergroup cg;
        write :coverpoint  tr.write_en {
            bins write1 = {1};
            bins write0 = {0};
        }

        read :coverpoint tr.read_en {
            bins read0 = {0};
            bins read1 = {1};
        }

        full :coverpoint tr.full {
            bins full0 = {0};
            bins full1 = {1};
        } 

        empty :coverpoint tr.empty {
            bins empty0 = {0};
            bins empty1 = {1};
        }

        write_read :cross write,read {
            bins wr1_rd1 = binsof(write.write1) && binsof(read.read1);
            ignore_bins wr0_rd0 = binsof(write.write0) && binsof(read.read0);
        }

        full_empty :cross full,empty {
            bins full0_empty0 = binsof(full.full0) && binsof(empty.empty0);
            illegal_bins full1_empty1 = binsof(full.full1) && binsof(empty.empty1);
        }
    endgroup

    function new(string name = "coverage", uvm_component parent = null);
        super.new(name,parent);
        item_collected = new("item_collected",this);
        cg = new();
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void write(transaction req);
        tr = req;
        cg.sample();
    endfunction

endclass
