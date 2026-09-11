module FF_sync (
    input dest_clk,
    input rst_n,

    input ptr,
    output sync_ptr

);
reg sync_ff1 , sync_ff2;
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