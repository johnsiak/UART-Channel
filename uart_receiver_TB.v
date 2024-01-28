`timescale 1ns / 1ps

module uart_receiver_TB();
reg clk_TB, reset_TB, Rx_EN_TB, RxD_TB;
reg [2:0] baud_select_TB;
wire Rx_FERROR_TB;
wire Rx_PERROR_TB;
wire Rx_VALID_TB;
wire [7:0] Rx_DATA_TB;
wire [3:0] sample_TB;
wire [7:0] Rx_DATA_temp_TB;

  uart_receiver DUT(reset_TB, clk_TB, baud_select_TB, Rx_EN_TB, RxD_TB, Rx_DATA_TB, Rx_FERROR_TB, Rx_PERROR_TB, Rx_VALID_TB, sample_TB, Rx_DATA_temp_TB);

initial begin
    clk_TB = 0; // our clock is initialy set to 0
	reset_TB = 1; // our reset signal is initialy set to 1
    baud_select_TB = 3'b111;
    Rx_EN_TB = 0;
    RxD_TB = 1;
    #100
    reset_TB = 0;
  	#100000 $finish;
end

always #10 clk_TB = ~ clk_TB;

initial
begin
    #100
    RxD_TB = 0; #8850 //start bit
    RxD_TB = 1; #8850 //LSB
    RxD_TB = 0; #8850
    RxD_TB = 1; #8850
    RxD_TB = 1; #4470 //there should be ferror
    RxD_TB = 0; #4380
    RxD_TB = 0; #8850
    RxD_TB = 1; #8850
    RxD_TB = 0; #8850
    RxD_TB = 1; #8850 //MSB
    RxD_TB = 0; #8850 //perror
    RxD_TB = 1;    //end bit
end


initial begin
    $monitor ("perror = %b, ferror = %b, valid = %b, data = %b, sample_TB = %b, Rx_DATA_temp_TB = %b", Rx_PERROR_TB, Rx_FERROR_TB, Rx_VALID_TB, Rx_DATA_TB, sample_TB, Rx_DATA_temp_TB);
    $dumpfile("dump.vcd");
    $dumpvars;
end

endmodule