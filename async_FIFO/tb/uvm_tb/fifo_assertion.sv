`include "uvm_macros.svh"
import uvm_pkg::*;

module fifo_assertion(
    input clk, rst_n,
    input write_en, read_en,
    input full, empty
    );

    property no_full_and_empty;
        @(posedge clk) disable iff (!rst_n)
        !(full && empty);
    endproperty
  
    property write_while_full ;
        @(posedge clk) disable iff (!rst_n)
        (write_en && full && (!read_en)) |-> (full); 
    endproperty

    property reset_clears_fifo;
        @(posedge clk)
        $rose(rst_n) |-> empty;
    endproperty

    property no_unknown_flags;
        @(posedge clk) disable iff (!rst_n)
        !$isunknown({full, empty});
    endproperty
   
    
    assert property (no_full_and_empty)
    else `uvm_error("ASSERT","full and empty asserted simultaneously!")
        
    assert property (write_while_full)
    else `uvm_error("ASSERT","write happenned on fifo full")      
            
    assert property (reset_clears_fifo)
    else `uvm_error("ASSERT","FIFO not empty immediately after reset deasserted!")

    assert property (no_unknown_flags)
    else `uvm_error("ASSERT","full or empty is X/Z!")

endmodule