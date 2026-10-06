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
        read_seq_low rdl = read_seq_low::type_id::create("rdl");

        phase.raise_objection(this);
            wseq.start_with(env.ag_wr.sqr, 8);
            rdl.start_with(env.ag_rd.sqr, 8);   
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
        write_seq_low wrtl = write_seq_low::type_id::create("wrtl");

        phase.raise_objection(this);
            rseq.start_with(env.ag_rd.sqr, 8);  
            wrtl.start_with(env.ag_rd.sqr, 8);
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
            begin
                write_seq w = write_seq::type_id::create("w"); w.start_with(env.ag_wr.sqr, n); 
            end
            begin
                read_seq  r = read_seq::type_id::create("r");  r.start_with(env.ag_rd.sqr, n);
            end
        join
    endtask

    task check_empty_pointer_sync();
        write_known_seq w;
        read_seq_low    rd_idle;
        read_seq        r;

        w = write_known_seq::type_id::create("write_a5");
        w.count = 1;
        w.first_data = 8'hA5;
        w.start_with(env.ag_wr.sqr, 1);

        // Keep read_en low for two read-clock cycles while the write pointer crosses.
        rd_idle = read_seq_low::type_id::create("wait_for_write_pointer");
        rd_idle.start_with(env.ag_rd.sqr, 2);

        // Read the single known word; scoreboard should match A5.
        r = read_seq::type_id::create("read_a5");
        r.start_with(env.ag_rd.sqr, 1);

        // Explicitly stop read requests.
        rd_idle = read_seq_low::type_id::create("stop_reading");
        rd_idle.start_with(env.ag_rd.sqr, 1);
    endtask


    task check_full_pointer_sync();
        write_known_seq w;
        write_seq_low   wr_idle;
        read_seq_low    rd_idle;
        read_seq        r;

        // Fill all eight entries with A0 through A7.
        w = write_known_seq::type_id::create("fill_fifo");
        w.count = 8;
        w.first_data = 8'hA0;
        w.start_with(env.ag_wr.sqr, 8);

        // Give the write-side monitor a cycle to observe full after the eighth write.
        wr_idle = write_seq_low::type_id::create("observe_full");
        wr_idle.start_with(env.ag_wr.sqr, 1);

        // Let the write pointer cross into the read domain, then remove one item.
        rd_idle = read_seq_low::type_id::create("wait_for_write_pointer");
        rd_idle.start_with(env.ag_rd.sqr, 2);

        r = read_seq::type_id::create("read_one_from_full");
        r.start_with(env.ag_rd.sqr, 1);

        // Stop reads, then allow the read pointer to cross into the write domain.
        rd_idle = read_seq_low::type_id::create("stop_reading");
        rd_idle.start_with(env.ag_rd.sqr, 1);

        wr_idle = write_seq_low::type_id::create("wait_for_read_pointer");
        wr_idle.start_with(env.ag_wr.sqr, 2);

        // This write should be allowed after full deasserts; it writes B0.
        w = write_known_seq::type_id::create("write_after_space_opens");
        w.count = 1;
        w.first_data = 8'hB0;
        w.start_with(env.ag_wr.sqr, 1);

        // Wait for B0 to become visible in the read domain, then drain A1..A7,B0.
        rd_idle = read_seq_low::type_id::create("wait_for_last_write");
        rd_idle.start_with(env.ag_rd.sqr, 2);

        r = read_seq::type_id::create("drain_fifo");
        r.start_with(env.ag_rd.sqr, 8);

        rd_idle = read_seq_low::type_id::create("stop_reading");
        rd_idle.start_with(env.ag_rd.sqr, 1);

        // Let the empty read pointer cross back before subsequent write tests.
        wr_idle = write_seq_low::type_id::create("wait_for_empty_pointer");
        wr_idle.start_with(env.ag_wr.sqr, 2);
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
        `uvm_info("ALL_TEST", "checking empty pointer synchronization", UVM_LOW)
            check_empty_pointer_sync();

        `uvm_info("ALL_TEST", "checking full pointer synchronization", UVM_LOW)
            check_full_pointer_sync();

        phase.drop_objection(this);
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("TEST_REPORT","all test done", UVM_NONE)
    endfunction
endclass