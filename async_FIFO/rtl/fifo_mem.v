
module fifo_mem #(parameter data_width = 8, depth = 8 ,ptr_width = $clog2(depth) ) (
//clock signals
    input wr_clk,
    input rd_clk,
    input wr_rst_n,
    input rd_rst_n,

//address
    input [ptr_width-1:0]wr_addr,
    input [ptr_width-1:0]rd_addr,

//enable signals
    input write_en,
    input read_en,

//data signals    
    input [data_width-1:0] data_in,
    output reg [data_width-1:0] data_out,

// flags
    input full,
    input empty
);

    reg [data_width-1:0] mem [0:depth - 1];
    
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if(!wr_rst_n) begin
            mem[wr_addr] <= 0;
            data_out <= 0;
        end
        else begin
            if(write_en && !full) mem[wr_addr] <= data_in;
        end
    end
    
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(!rd_rst_n) begin
            data_out <= 0;
        end
        else begin
            if(read_en && !empty) begin
                data_out <= mem[rd_addr];
            end
        end
    end
endmodule