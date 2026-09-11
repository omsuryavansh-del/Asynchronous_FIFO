
module fifo_mem(

//address
    input [2:0]wr_addr,
    input [2:0]rd_addr,
//enable signals
    input write_en,
    input read_en,

//data signals    
    input [7:0] data_in,
    output reg [7:0] data_out,

// flags
    input full,
    input empty
);

    reg [7:0] mem [7:0];
    
    always @(*) begin
        if(write_en && !full) mem[wr_addr] = data_in;
        if(read_en && !empty) data_out = mem[rd_addr];
    end

endmodule