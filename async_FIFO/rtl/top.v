
module top( 
    input clk_wr,
    input clk_rd,

    input rst_wr,
    input rst_rd,

    input write_en,
    input read_en,

    input [7:0] data_in,
    output [7:0] data_out,

    output full,
    output empty
);

    wire [3:0] async_wr_gptr, async_read_gptr, sync_rd_gptr, sync_wr_gptr;
    wire full_con,empty_con;

    write_ptr write_pointer (
        .wr_clk(clk_wr),
        .wr_rst_n(rst_wr),

        .write_en(write_en),
        .rd_gptr(sync_read_gptr),

        .write_addr(write_addr),
        .wr_gptr(async_wr_gptr),
        .full(full_con)
    );
   
    read_ptr read_pointer (
        .rd_clk(clk_rd),
        .rd_rst_n(rst_rd),

        .read_en(read_en),
        .wr_gptr(sync_wr_gptr),

        .read_addr(read_addr),
        .rd_gptr(async_read_gptr),
        .empty(empty_con)
    );

    FF_sync sync_write (
        .dest_clk(clk_rd),
        .rst_n(rst_rd),

        .ptr(async_wr_gptr),
        .sync_ptr(sync_wr_gptr)
    );

    FF_sync sync_read (
        .dest_clk(clk_wr),
        .rst_n(rst_wr),

        .ptr(async_read_gptr),
        .sync_ptr(sync_rd_gptr)
    );

    fifo_mem fifo_memory (
        .wr_addr(write_addr),
        .rd_addr(read_addr),

        .write_en(write_en),
        .read_en(read_en),

        .data_in(data_in),
        .data_out(data_out),

        .full(full_con),
        .empty(empty_con)
    );

    assign full = full_con;
    assign empty = empty_con;


endmodule