`timescale 1ns / 1ps

module baud_controller_TB();
reg reset_TB, clk_TB;
reg [2:0] baud_select_TB;
wire sample_ENABLE_TB;

baud_controller DUT(reset_TB, clk_TB, baud_select_TB, sample_ENABLE_TB);

initial begin
    clk_TB = 0; // our clock is initialy set to 0
	reset_TB = 1; // our reset signal is initialy set to 1

    #100

    reset_TB = 0;
    #290000 $finish;
end

always #10 clk_TB = ~ clk_TB;

//the counts of time below are calculated by the amounts of clock
//edges the counter needs to go up to the number we want
//so, its count_reps * 27 (max(counter)) * 20 (our clock)


always@(posedge clk_TB)
begin
    #100
    baud_select_TB = 3'b000; #207360
    baud_select_TB = 3'b001; #51840
    baud_select_TB = 3'b010; #12960
    baud_select_TB = 3'b011; #6480
    baud_select_TB = 3'b100; #3240
    baud_select_TB = 3'b101; #1620
    baud_select_TB = 3'b110; #1080
    baud_select_TB = 3'b111; #540;
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule