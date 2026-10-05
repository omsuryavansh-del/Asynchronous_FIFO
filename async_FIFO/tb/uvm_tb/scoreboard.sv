`include "uvm_macros.svh"
import uvm_pkg::*;
import af_fpkg::*;

`uvm_analysis_imp_decl(_wr)   // declares a new type: uvm_analysis_imp_wr#(T, scoreboard)
`uvm_analysis_imp_decl(_rd)   // declares: uvm_analysis_imp_rd#(T, scoreboard)

class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_imp_wr #(item_wr, scoreboard) export_wr;
    uvm_analysis_imp_rd #(item_rd, scoreboard) export_rd;
    
    logic [7:0] fifo [0:7];
    logic [7:0] expected;
    int pass = 0;
    int fail = 0;
    logic [4:0] b_wrptr = 0;
    logic [4:0] b_rdptr = 0;
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
    int rdptr1,rdptr2;
        $display("write transaction recieved from monitor rst_n = %0b || w_en = %0b || data_in = %0d || data_out = %0d",
                    req.wr_rst_n,req.write_en,req.data_in,req.data_out);
        if(!req.wr_rst_n) begin
            fifo = 8'b0;
            full_mismatch = 0;
        end
        else 
        begin                
            rdptr1 = b_rdptr;
            rdptr2 = rdptr1;

            full = ((b_wrptr[2:0] == rdptr2[2:0]) && (b_wrptr[3] != rdptr2[3])) ? 1 : 0;

            if(req.write_en && !full) begin
                fifo[b_wrptr[2:0]] = req.data_in;
                b_wrptr = b_wrptr + 1;
            end

            if(req.full && !full) begin 
                `uvm_error("SCB", $sformatf("full mismatch detected time = %0t || wr_rst_n = %0b || w_en = %0b || data_in = %0d || data_out = %0d",
                            $time, req.wr_rst_n, req.write_en, req.data_in, req.data_out))
            end

            if(full && req.full) begin 
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
        logic wrptr1,wrptr2;  

        $display("read transaction recieved from monitor rst_n = %0b || rd_en = %0b || data_in = %0d || data_out = %0d",
                    req.rd_rst_n,req.read_en,req.data_in,req.data_out);
        if(!req.rd_rst_n) begin
            fifo = 8'b0;
            empty_mismatch = 0;
        end
        else
        begin    
            wrptr1 = b_wrptr;
            wrptr2 = wrptr1;
       
            if(req.read_en && !empty) begin
                expected = fifo[b_rdptr[2:0]];
                b_rdptr = b_rdptr + 1;
                did_pop = 1;
            end
            
            empty = (b_rdptr[3:0] == wrptr2[3:0]);  
            
            if((empty) && req.empty) begin 
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