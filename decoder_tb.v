`timescale 1ns / 1ps

module tb ();

reg clk_TB, reset_TB;
reg [3:0] character_TB; 
wire an3_TB, an2_TB, an1_TB, an0_TB;
wire a_TB, b_TB, c_TB, d_TB, e_TB, f_TB, g_TB;
wire state_clk_TB; //tbd
wire [3:0] counter_TB; //tbd
wire [6:0] LED_TB;

FourDigitLEDdriver DUT (reset_TB, clk_TB, character_TB, an3_TB, an2_TB,
an1_TB, an0_TB, a_TB, b_TB, c_TB, d_TB, e_TB, f_TB, g_TB, state_clk_TB, counter_TB);


LEDdecoder test (character_TB,LED_TB); // instatiate decoder test

//initialisation of DUT variables
initial begin
	character_TB = 4'b1111;
	clk_TB = 0; // our clock is initialy set to 0
	reset_TB = 1; // our reset signal is initialy set to 1

	#100; // after 100 timing units, i.e. ns
					
	reset_TB = 0; // set reset signal to 0
					
	#15000 $finish;	 // after 15000 timing units, i.e. ns, finish our simulation
end
	
always #10 clk_TB = ~ clk_TB; // create our clock, with a period of 20ns


always@(posedge clk_TB)
begin
  #100
	character_TB = 4'b0000; #1280
	character_TB = 4'b0001; #1280
	character_TB = 4'b0010; #1280
	character_TB = 4'b0011; #1280
	character_TB = 4'b0100; #1280
	character_TB = 4'b0101; #1280
	character_TB = 4'b0110; #1280
	character_TB = 4'b0111; #1280
	character_TB = 4'b1000; #1280
	character_TB = 4'b1001; #1280
	character_TB = 4'b1011; #1280
	character_TB = 4'b1100; 
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end


endmodule
