`timescale 1ns/1ps

module top_tb;
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 8;

    reg clk_wr = 1'b0;
    reg clk_rd = 1'b0;
    reg rst_wr = 1'b0;
    reg rst_rd = 1'b0;
    reg write_en = 1'b0;
    reg read_en = 1'b0;
    reg [DATA_WIDTH-1:0] data_in_top = {DATA_WIDTH{1'b0}};

    wire [DATA_WIDTH-1:0] data_out_top;
    wire full;
    wire empty;

    reg [DATA_WIDTH-1:0] expected [0:DEPTH-1];
    integer errors = 0;
    integer i;

    top #(
        .data_width(DATA_WIDTH),
        .depth(DEPTH)
    ) dut (
        .clk_wr(clk_wr),
        .clk_rd(clk_rd),
        .rst_wr(rst_wr),
        .rst_rd(rst_rd),
        .write_en(write_en),
        .read_en(read_en),
        .data_in_top(data_in_top),
        .data_out_top(data_out_top),
        .full(full),
        .empty(empty)
    );

    always #5 clk_wr = ~clk_wr;
    always #7 clk_rd = ~clk_rd;

    task check_flag;
        input actual;
        input expected_value;
        input [8*32-1:0] name;
        begin
            if (actual !== expected_value) begin
                $display("ERROR: %0s expected %b, got %b at %0t",
                         name, expected_value, actual, $time);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Hold both domains in reset before starting traffic.
        #20;
        rst_wr = 1'b1;
        rst_rd = 1'b1;
        repeat (4) @(posedge clk_wr);
        repeat (4) @(posedge clk_rd);

        check_flag(full, 1'b0, "full after reset");
        check_flag(empty, 1'b1, "empty after reset");

        // Fill the FIFO with a known sequence.
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk_wr);
            expected[i] = i + 8'h10;
            data_in_top = expected[i];
            write_en = 1'b1;
        end
        @(negedge clk_wr);
        write_en = 1'b0;

        repeat (3) @(posedge clk_wr);
        check_flag(full, 1'b1, "full after filling");

        // A write while full must not change the FIFO contents.
        @(negedge clk_wr);
        data_in_top = 8'hee;
        write_en = 1'b1;
        @(posedge clk_wr);
        @(negedge clk_wr);
        write_en = 1'b0;

        // Allow the write pointer to cross into the read clock domain.
        repeat (3) @(posedge clk_rd);

        // Drain the FIFO and verify ordering.
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge clk_rd);
            read_en = 1'b1;
            @(posedge clk_rd);
            #1;
            if (data_out_top !== expected[i]) begin
                $display("ERROR: read %0d expected %h, got %h at %0t",
                         i, expected[i], data_out_top, $time);
                errors = errors + 1;
            end
        end
        @(negedge clk_rd);
        read_en = 1'b0;

        // The read pointer must synchronize back into the write clock domain
        // before the empty flag reflects the final read.
        repeat (3) @(posedge clk_wr);
        check_flag(empty, 1'b1, "empty after draining");

        // A read while empty must not change the last output.
        if (data_out_top !== expected[DEPTH-1]) begin
            $display("ERROR: empty read changed output to %h", data_out_top);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: asynchronous FIFO basic test completed");
        else
            $display("FAIL: asynchronous FIFO basic test found %0d error(s)", errors);

        $finish;
    end
endmodule
