`include "uvm_macros.svh"
import uvm_pkg::*;
import u_fpkg::*;

class base_seq extends uvm_sequence #(item_wr);
    `uvm_object_utils(base_seq)
    int num_trans = 10;
    item_wr tr;

    function new(string name = "base_seq");
        super.new(name);
    endfunction

    task start_with(uvm_sequencer_base sqr, int n);
        num_trans = n;
        this.start(sqr);   // internally calls body() with no args
    endtask
endclass

class write_seq extends base_seq;
    `uvm_object_utils(write_seq)
    item_wr tr;

    function new (string name = "write_seq");
        super.new(name);
    endfunction

    task body();
    repeat(num_trans) begin
        tr = item_wr::type_id::create("tr");
        start_item(tr);
            assert(tr.randomize() with {write_en == 1 ;})
                else `uvm_fatal ("GEN","randomization failed");
        finish_item(tr);
    end
    endtask
endclass

class write_seq_low extends base_seq;
    `uvm_object_utils(write_seq_low)
    item_wr tr;

    function new (string name = "write_seq_low");
        super.new(name);
    endfunction

    task body();
    repeat(num_trans) begin
        tr = item_wr::type_id::create("tr");
        start_item(tr);
            assert(tr.randomize() with {write_en == 0;})
                else `uvm_fatal ("GEN","randomization failed");
        finish_item(tr);
    end
    endtask
endclass
