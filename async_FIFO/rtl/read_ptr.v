module read_ptr (
    input rd_clk,
    input rd_rst_n,

    input read_en,
    input wr_gptr,
    
    output [2:0] read_addr,
    output reg [3:0]rd_gptr,
    output empty
);

reg [3:0] rd_ptr;

always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n)begin 
        rd_ptr <= 4'b0;
        rd_gptr <= 4'b0;
    end
    else begin
        if(read_en && (!empty)) begin
            rd_ptr <= rd_ptr + 1;
            //gray logic
            rd_gptr <= (rd_ptr >> 1) ^ (rd_ptr);
        end
    end
end

assign empty = rd_gptr == wr_gptr;
assign read_addr = rd_ptr[2:0];

endmodule