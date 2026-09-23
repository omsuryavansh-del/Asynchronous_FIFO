`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

`uvm_analysis_imp_decl(_wr)   // declares a new type: uvm_analysis_imp_wr#(T, scoreboard)
`uvm_analysis_imp_decl(_rd)   // declares: uvm_analysis_imp_rd#(T, scoreboard)

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp_wr #(item_wr, scoreboard) export_wr;
    uvm_analysis_imp_rd #(item_rd, scoreboard) export_rd;
    
    logic [7:0] fifo [$];
    logic [7:0] expected;
    int pass = 0;
    int fail = 0;
    int full_mismatch = 0;
    int empty_mismatch = 0;
    int full = 0;
    int empty = 0;

    function new(string name = "scoreboard",uvm_component parent = null);
        super.new(name,parent);
        export_wr = new("export_wr", this);
        export_rd = new("export_rd", this);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void write_wr(item_wr req);
    int did_push = 0;
        $display("write transaction recieved from monitor rst_n = %0b || w_en = %0b || data_in = %0d || data_out = %0d",
                    req.wr_rst_n,req.write_en,req.data_in,req.data_out);
        if(!req.wr_rst_n) begin
            fifo.delete();
            full_mismatch = 0;
        end
        else 
        begin                
            if(req.write_en && !req.full) begin
                fifo.push_back(req.data_in);
            end
            
            if((fifo.size() < 8) && req.full) begin 
                full_mismatch++;
                if(full_mismatch > 3) begin
                    `uvm_error("SCB", $sformatf("full stuck asserted for %0d cycles after room available!", full_mismatch))
                end
            else
                full_mismatch = 0;   
            end     
        end
    endfunction
        
    virtual function void write_rd(item_rd req);
        bit did_pop = 0;   
        $display("read transaction recieved from monitor rst_n = %0b || rd_en = %0b || data_in = %0d || data_out = %0d",
                    req.rd_rst_n,req.read_en,req.data_in,req.data_out);
        if(!req.rd_rst_n) begin
            fifo.delete();
            empty_mismatch = 0;
        end
        else
        begin                 
            if(req.read_en && !req.empty)begin
                expected = fifo.pop_front();
                did_pop = 1;
            end

            if((fifo.size() > 0) && req.empty) begin 
                empty_mismatch++;
                if(empty_mismatch > 3) begin
                    `uvm_error("SCB", $sformatf("empty stuck asserted for %0d cycles after data available!", empty_mismatch))
                end
            else
                empty_mismatch = 0;   
            end

            if(did_pop) begin
                if(expected !== req.data_out) begin
                    `uvm_info("RESuLT",$sformatf("uvm_read test failed time = %0t || rd_rst_n = %0b | expected = %0d || data_in = %0d ||  rd_en = %0b || data_out = %0d ",
                                $time, req.rd_rst_n, expected, req.data_in, req.read_en, req.data_out),UVM_HIGH)
                    $display("test failed time = %0t || rd_rst_n = %0b | expected = %0d || data_in = %0d ||  rd_en = %0b || data_out = %0d ",
                                $time, req.rd_rst_n, expected, req.data_in, req.read_en, req.data_out);
                    $display("\n=========================================\n");
                    fail++;
                end
                else begin 
                    `uvm_info("RESULT",$sformatf("test passed expected :: %0d || data out = %0d ",expected,req.data_out),UVM_HIGH)
                    $display("test passed expected :: %0d || data out = %0d ",expected,req.data_out);
                    $display("\n=========================================\n");
                    pass++;
                end
            end   
        end            
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCOREBOARD_REPORT",
            $sformatf("TEST DONE : PASS = %0d, FAIL = %0d", pass, fail), UVM_NONE)
        if (fail == 0)
            `uvm_info("SCOREBOARD_REPORT", "*** TEST PASSED ***", UVM_NONE)
        else
            `uvm_error("SCOREBOARD_REPORT", "*** TEST FAILED ***")
    endfunction
endclass