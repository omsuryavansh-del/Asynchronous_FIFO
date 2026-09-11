module write_ptr (
    input wr_clk,
    input wr_rst_n,

    input write_en,
    input [3:0] rd_gptr,
    
    output [2:0]write_addr,
    output reg [3:0] wr_gptr,
    output full
);
    
//gray counter
reg [3:0] wr_ptr;

always @(posedge wr_clk or negedge wr_rst_n) begin 
    if(!wr_rst_n) begin 
        wr_ptr <= 0;
        wr_gptr <= 0;
    end

    else begin 

        if (write_en && (!full)) begin  
                wr_ptr <= wr_ptr + 1;
                //binary to gray logic
                wr_gptr <= {(wr_ptr >> 1) ^ wr_ptr};
        end
    end 
end

assign full = (wr_gptr[3] != rd_gptr[3]) && (wr_gptr[2] != rd_gptr[2]) && (wr_gptr[1:0] == rd_gptr[1:0]);
assign write_addr = wr_ptr[2:0];

endmodule