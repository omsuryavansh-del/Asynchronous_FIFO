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

class reset_test extends test;
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
endclass

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
    reset_test  rst_test            ;
    write_test  wr_test             ;
    read_test    rd_test            ;
    rd_aftr_wr  rd_wr_test          ;
    seq_rd_aftr_wr  seq_rd_wr       ;
    conc_continous  continous_test  ;
    full_bndry_wrprnd   full_test   ;
    empty_bndry_wrprnd   empty_test ;

    function new(string name = "all_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        rst_test = reset_test::type_id::create("rst_test");
        wr_test = write_test::type_id::create("wr_test");
        rd_test = read_test::type_id::create("rd_test");
        rd_wr_test = rd_aftr_wr::type_id::create("rd_wr_test");
        seq_rd_wr = seq_rd_aftr_wr::type_id::create("seq_rd_wr");
        continous_test = conc_continous::type_id::create("continous_test");
        full_test = full_bndry_wrprnd::type_id::create("full_test");
        empty_test = empty_bndry_wrprnd::type_id::create("empty_test");
    endfunction

    task run_phase(uvm_phase phase);

        begin 
            `uvm_info("ALL_TEST", "starting reset_test", UVM_LOW)
            rst_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "reset_test finished", UVM_LOW)

            `uvm_info("ALL_TEST", "starting write_seq", UVM_LOW)
            wr_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "write_seq finished", UVM_LOW)
        
            `uvm_info("ALL_TEST", "starting read_seq", UVM_LOW)
            rd_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "read_seq finished", UVM_LOW)
        
            `uvm_info("ALL_TEST", "starting rd_wr_test", UVM_LOW)
            rd_wr_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "rd_wr_test finished", UVM_LOW)

            `uvm_info("ALL_TEST", "starting seq_rd_wr", UVM_LOW)
            seq_rd_wr.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "seq_rd_wr finished", UVM_LOW)
        
            `uvm_info("ALL_TEST", "starting continous_test", UVM_LOW)
            continous_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "continous_test finished", UVM_LOW)
        
            `uvm_info("ALL_TEST", "starting full_test", UVM_LOW)
            full_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "full_test finished", UVM_LOW)
            
            `uvm_info("ALL_TEST", "starting empty_test", UVM_LOW)
            empty_test.run_phase(uvm_phase phase);
            `uvm_info("ALL_TEST", "empty_test finished", UVM_LOW)
        end
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST_REPORT","all test done", UVM_NONE)
    endfunction
endclass