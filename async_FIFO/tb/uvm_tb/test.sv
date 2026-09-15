`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

class test extends uvm_test;
    `uvm_component_utils(test)
    environment env;
    function new(string name = "test", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env",this);
    endfunction

endclass

/*class reset_test extends test;
    `uvm_component_utils(reset_test)

    function new (string name = "reset_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        read_seq rseq = read_seq::type_id::create("rseq");

        phase.raise_objection(this);
            rseq.start_with(env.ag_rd.sqr, 1);   
        phase.drop_objection(this);
    endtask
endclass*/

class write_test extends test;
    `uvm_component_utils(write_test)

    function new (string name = "write_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_seq wseq = write_seq::type_id::create("wseq");

        phase.raise_objection(this);
            wseq.start_with(env.ag_wr.sqr, 8);   
        phase.drop_objection(this);
    endtask
endclass

class read_test extends test;
    `uvm_component_utils(read_test)

    function new (string name = "read_test",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        read_seq rseq = read_seq::type_id::create("rseq");

        phase.raise_objection(this);
            rseq.start_with(env.ag_rd.sqr, 8);   
        phase.drop_objection(this);
    endtask
endclass


class rd_aftr_wr extends test;
    `uvm_component_utils(rd_aftr_wr)

    function new (string name = "rd_aftr_wr",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_seq wseq = write_seq::type_id::create("wseq");
        read_seq rseq = read_seq::type_id::create("rseq");

        phase.raise_objection(this);
            wseq.start_with(env.ag_wr.sqr, 8);   
            rseq.start_with(env.ag_rd.sqr, 8);   
        phase.drop_objection(this);
    endtask
endclass

class seq_rd_aftr_wr extends test;
    `uvm_component_utils(seq_rd_aftr_wr)

    function new (string name = "seq_rd_aftr_wr",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_seq wseq = write_seq::type_id::create("wseq");
        read_seq rseq = read_seq::type_id::create("rseq");

        phase.raise_objection(this);
        fork
            wseq.start_with(env.ag_wr.sqr, 8);   
            rseq.start_with(env.ag_rd.sqr, 8);   
        join
        phase.drop_objection(this);
    endtask
endclass

class conc_continous extends test;
    `uvm_component_utils(conc_continous)

    function new (string name = "conc_continous",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_seq wseq = write_seq::type_id::create("wseq");
        read_seq rseq = read_seq::type_id::create("rseq");

        phase.raise_objection(this);
        fork
            wseq.start_with(env.ag_wr.sqr, 50);   
            rseq.start_with(env.ag_rd.sqr, 50);   
        join
        phase.drop_objection(this);
    endtask
endclass


class full_bndry_wrprnd extends test;
    `uvm_component_utils(full_bndry_wrprnd)

    function new (string name = "full_bndry_wrprnd",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        write_seq wseq = write_seq::type_id::create("seq");
        phase.raise_objection(this);
            wseq.start_with(env.ag_wr.sqr, 32);   
        phase.drop_objection(this);
    endtask
endclass

class empty_bndry_wrprnd extends test;
    `uvm_component_utils(empty_bndry_wrprnd)

    function new (string name = "empty_bndry_wrprnd",uvm_component parent = null);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        read_seq rseq = read_seq::type_id::create("rseq");
        phase.raise_objection(this);
            rseq.start_with(env.ag_rd.sqr, 32);   
        phase.drop_objection(this);
    endtask
endclass

class all_test extends test;
    `uvm_component_utils(all_test)

    function new(string name = "all_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task do_reset_check();
        read_seq rseq = read_seq::type_id::create("rseq");
        rseq.start_with(env.ag_rd.sqr, 1);
    endtask

    task do_write(int n);
        write_seq wseq = write_seq::type_id::create("wseq");
        wseq.start_with(env.ag_wr.sqr, n);
    endtask

    task do_read(int n);
        read_seq rseq = read_seq::type_id::create("rseq");
        rseq.start_with(env.ag_rd.sqr, n);
    endtask

    task do_concurrent(int n);
        fork
            begin write_seq w = write_seq::type_id::create("w"); w.start_with(env.ag_wr.sqr, n); end
            begin read_seq  r = read_seq::type_id::create("r");  r.start_with(env.ag_rd.sqr, n); end
        join
    endtask

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info("ALL_TEST", "starting reset_test", UVM_LOW)  do_reset_check();
        `uvm_info("ALL_TEST", "starting write_test",  UVM_LOW)  do_write(8);
        `uvm_info("ALL_TEST", "starting read_test",   UVM_LOW)  do_read(8);
        `uvm_info("ALL_TEST", "starting rd_aftr_wr",  UVM_LOW)  do_write(8); do_read(8);
        `uvm_info("ALL_TEST", "starting concurrent",  UVM_LOW)  do_concurrent(50);
        `uvm_info("ALL_TEST", "starting full bndry",  UVM_LOW)  do_write(32);
        `uvm_info("ALL_TEST", "starting empty bndry", UVM_LOW)  do_read(32);

        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST_REPORT","all test done", UVM_NONE)
    endfunction
endclass