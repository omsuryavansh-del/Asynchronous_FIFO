module FF_sync #(parameter width = 3) (
    input dest_clk,
    input rst_n,

    input [width:0] ptr,
    output [width:0] sync_ptr

);
reg [width-1:0] sync_ff1 , sync_ff2;
always @(posedge dest_clk or negedge rst_n) begin 
    if (!rst_n) begin 
        sync_ff1 = 0;
        sync_ff2 = 0;
    end
    else begin 
        sync_ff1 <= ptr;
        sync_ff2 <= sync_ff1;
    end
end

assign sync_ptr = sync_ff2;
endmodule 