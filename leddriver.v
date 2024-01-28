`timescale 1ns / 1ps
`include "decoder.v"

module FourDigitLEDdriver(reset, clk, character, an3, an2,
 an1, an0, a, b, c, d, e, f, g, state_clk, counter);

input clk, reset;
input [3:0] character; 
output an3, an2, an1, an0; // our anodes
output a, b, c, d, e, f, g;	//	our signals
output state_clk; //tbd
output [3:0] counter; //tbd

//		    a
//   	 ------
//    f |	   |  b
//	    |   g  |
//	  	 ------
//      |      |
//	  e |	   |  c
//	     ------ 
//			d

reg state_clk;
reg a,b,c,d,e,f,g,dp;
reg an0,an1,an2,an3;
wire [6:0] LED;

reg [3:0] char; // based on your received message, use this 4bit signal to drive our decoder
reg [3:0] counter; // state of fsm
reg [3:0] state_counter; // counter to compute the time that the anodes will be active

initial begin
	a = 1; b = 1; c = 1; d = 1; e = 1; f = 1; g = 1; dp = 1;
	char = 4'b1111;	
end

//////////////////////////////////////////////////
//		Counter for the 16 states of anodes		//
//////////////////////////////////////////////////
always@(posedge state_clk or posedge reset)
begin
	if (reset)
	begin
		counter = 4'b0001; 
	end
	else
	begin
    	if (counter == 4'b0000)
		begin
			counter = 4'b1111;
		end
		else
		begin
			counter = counter - 1;
		end
	end
end

//////////////////////////
//		Anodes Set		//
//////////////////////////
always@(posedge state_clk or posedge reset)
begin
	if (reset)
	begin
		an3 = 1;
		an2 = 1;
		an1 = 1;
		an0 = 1;
	end
 	else if (counter == 4'b1110)
	begin
		an3 = 0;
		an2 = 1;
		an1 = 1;
		an0 = 1;
	end
  	else if (counter == 4'b1010)
	begin
		an3 = 1;
		an2 = 0;
		an1 = 1;
		an0 = 1;
	
	end
  	else if (counter == 4'b0110)
	begin
		an3 = 1;
		an2 = 1;
		an1 = 0;
		an0 = 1;
	
	end
  	else if (counter == 4'b0010)
	begin
		an3 = 1;
		an2 = 1;
		an1 = 1;
		an0 = 0;
	end
	else
	begin
		an3 = 1;
		an2 = 1;
		an1 = 1;
		an0 = 1;
	end
end


////////////////////////////////
//	Decoder	Instantiation	  //
////////////////////////////////
LEDdecoder LEDdecoderINSTANCE (.char(char),.LED(LED));

/////////////////////////////////////////////////////////////////////		
//	Set char values to present them at the correct anode at a time //
/////////////////////////////////////////////////////////////////////	
always@(posedge state_clk or posedge reset)
begin
	if (reset)
		begin
			char = 4'b1111; //so decoder will go on default case in switch, display will be empty
		end
	else if (counter == 4'b0000 || counter == 4'b0100 || counter == 4'b1000 || counter == 4'b1100)
		begin
			char = character; //we store the character 2 states before the anode
		end
	else if (counter == 4'b0010 || counter == 4'b0110 || counter == 4'b1010 || counter == 4'b1110)
		begin
			a = LED[6]; b = LED[5]; c = LED[4]; d = LED[3]; e = LED[2]; f = LED[1]; g = LED[0]; dp = 1;
		end
end

always@(posedge clk or posedge reset)
begin
	if (reset)
	begin
		state_counter = 4'b0000;
		state_clk = 0;
	end
	else if (state_counter == 4'b1111)
	begin
		state_counter = 4'b0000;
		state_clk = 1;
	end
	else
	begin
		state_counter = state_counter + 1;
		state_clk = 0;
	end
end


endmodule
