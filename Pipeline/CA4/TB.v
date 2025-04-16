`timescale 1ns/1ns

module TB();
    reg clk = 0;
    reg rst = 1;

    proccesor UUT (
        .clk(clk),
        .rst(rst)
    );

    always begin
        #1000 clk = ~clk;
    end

    initial begin
        #10000 rst = 0;
        #1000000 $stop;
    end
endmodule

