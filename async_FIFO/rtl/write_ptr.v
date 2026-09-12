module write_ptr #( parameter ptr_width = 3) (
    input wr_clk,
    input wr_rst_n,

    input write_en,
    input [ptr_width:0] rd_gptr,

    output [ptr_width - 1:0]write_addr,
    output reg [ptr_width:0] wr_gptr,
    output full
);
    
//gray counter
reg [ptr_width:0] wr_ptr;

always @(posedge wr_clk or negedge wr_rst_n) begin 
    if(!wr_rst_n) begin 
        wr_ptr <= {ptr_width + 1{1'b0}};
        wr_gptr <= {ptr_width + 1{1'b0}};
    end

    else begin 

        if (write_en && (!full)) begin  
                wr_ptr <= wr_ptr + 1;
                //binary to gray logic
                wr_gptr <= {((wr_ptr + 1) >> 1) ^ (wr_ptr + 1)};
        end
    end 
end

assign full = (wr_gptr[ptr_width] != rd_gptr[ptr_width]) && (wr_gptr[ptr_width-1] != rd_gptr[ptr_width-1]) && (wr_gptr[ptr_width-2:0] == rd_gptr[ptr_width-2:0]);
assign write_addr = wr_ptr[ptr_width-1:0];

endmodule