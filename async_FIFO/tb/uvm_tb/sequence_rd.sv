`include "uvm_macros.svh"
import uvm_pkg::*;
import u_fpkg::*;

class base_seq extends uvm_sequence  item_rd);
    `uvm_object_utils(base_seq)
    int num_trans = 16;
     item_rd tr;

    function new(string name = "base_seq");
        super.new(name);
    endfunction

    task start_with(uvm_sequencer_base sqr, int n);
        num_trans = n;
        this.start(sqr);   // internally calls body() with no args
    endtask
endclass

class read_seq_high extends base_seq;
    `uvm_object_utils(read_seq_high)
     item_rd tr;

    function new (string name = "read_seq_high");
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

class read_seq_low extends base_seq;
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