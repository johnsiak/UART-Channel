`timescale 1ns / 1ps

module uart_transmitter_TB();
reg clk_TB, reset_TB, Tx_EN_TB, Tx_WR_TB;
reg [7:0] Tx_DATA_TB;
reg [2:0] baud_select_TB;
wire TxD_TB, Tx_BUSY_TB;

uart_transmitter DUT(reset_TB, clk_TB, Tx_DATA_TB, baud_select_TB, Tx_WR_TB, Tx_EN_TB, TxD_TB, Tx_BUSY_TB);

initial begin
  clk_TB = 0; // our clock is initialy set to 0
	reset_TB = 1; // our reset signal is initialy set to 1
  Tx_EN_TB = 0;
  Tx_WR_TB = 0;
  Tx_DATA_TB = 8'b1111_1111;
  baud_select_TB = 3'b111; 
  #100

  reset_TB = 0;
  #100000 $finish;
end

always #10 clk_TB = ~ clk_TB;

initial
begin
  #100
  Tx_DATA_TB = 8'b1100_1011;
  Tx_EN_TB = 1;
  Tx_WR_TB = 1; #20
  Tx_WR_TB = 0;  
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
end

endmodule