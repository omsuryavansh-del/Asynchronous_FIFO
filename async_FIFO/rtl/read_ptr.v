module read_ptr #(parameter ptr_width = 3 ) (
    input rd_clk,
    input rd_rst_n,

    input read_en,
    input [ptr_width:0] wr_gptr,

    output [ptr_width - 1:0] read_addr,
    output reg [ptr_width:0]rd_gptr,
    output empty
);

reg [ptr_width:0] rd_ptr;

always @(posedge rd_clk or negedge rd_rst_n) begin
    if (!rd_rst_n)begin 
        rd_ptr <= {ptr_width + 1{1'b0}};
        rd_gptr <= {ptr_width + 1{1'b0}};
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
assign read_addr = rd_ptr[ptr_width-1:0];

endmodule