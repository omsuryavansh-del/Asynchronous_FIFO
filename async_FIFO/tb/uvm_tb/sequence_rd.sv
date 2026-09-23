`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class base_seq_rd extends uvm_sequence #(item_rd);
    `uvm_object_utils(base_seq_rd)
    int num_trans = 16;
    item_rd tr;

    function new(string name = "base_seq_rd");
        super.new(name);
    endfunction

    task start_with(uvm_sequencer_base sqr, int n);
        num_trans = n;
        this.start(sqr);   // internally calls body() with no args
    endtask
endclass

class read_seq extends base_seq_rd;
    `uvm_object_utils(read_seq)
    item_rd tr;

    function new (string name = "read_seq");
        super.new(name);
    endfunction

    task body ();
    repeat(num_trans) begin
        tr = item_rd::type_id::create("tr");
        start_item(tr);
            assert(tr.randomize() with {(read_en == 1) ;})
                else `uvm_fatal ("GEN","randomization failed");
        finish_item(tr);
    end
    endtask
endclass

class read_seq_low extends base_seq_rd;
    `uvm_object_utils(read_seq_low)
    item_rd tr;

    function new (string name = "read_seq_low");
        super.new(name);
    endfunction

    task body ();
    repeat(num_trans) begin
        tr = item_rd::type_id::create("tr");
        start_item(tr);
            assert(tr.randomize() with {(read_en == 0) ;})
                else `uvm_fatal ("GEN","randomization failed");
        finish_item(tr);
    end
    endtask
endclass
