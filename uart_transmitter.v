`include "baud_controller.v"

module uart_transmitter(reset, clk, Tx_DATA, baud_select, Tx_WR, Tx_EN, TxD, Tx_BUSY);
input clk, reset;
input [7:0] Tx_DATA;
input [2:0] baud_select;
input Tx_EN;
input Tx_WR;
output TxD;
output Tx_BUSY;

reg [7:0] tx_data_reg; //when TX_WR = 1, data are saved here (so that even if Tx_DATA changes outside of module, it won't change inside)
reg parity_bit;
reg [3:0] counter_sample; //counts the times tx_sample_enable is 1
reg [3:0] counter; //counts the times counter_sample is 4'b1111 (tx_sample is 1 16 times)
reg reset_baud;
wire tx_sample_enable;
reg TxD, Tx_BUSY;

baud_controller baud_controller_tx_instance(reset_baud, clk, baud_select, tx_sample_enable);

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin 
        counter_sample = 4'b0000;
        counter = 4'b0000;
        reset_baud = 1;
    end
    else begin
      if(tx_sample_enable && Tx_EN)
        begin
            if(counter_sample == 4'b1111) 
            begin
                counter_sample = 4'b0000;
                counter = counter + 1; //because sample_enable has been 1 16 times
            end
            else counter_sample = counter_sample + 1'b1; 
        end
    end
end

always @(posedge clk)
begin
    case(counter)
        4'b0000: TxD = 0; //start bit
        4'b0001: TxD = tx_data_reg[0]; //1st bit - LSB
        4'b0010: TxD = tx_data_reg[1]; //2nd bit
        4'b0011: TxD = tx_data_reg[2]; //3rd bit
        4'b0100: TxD = tx_data_reg[3]; //4th bit
        4'b0101: TxD = tx_data_reg[4]; //5th bit
        4'b0110: TxD = tx_data_reg[5]; //6th bit
        4'b0111: TxD = tx_data_reg[6]; //7th bit
        4'b1000: TxD = tx_data_reg[7]; //8th bit - MSB
        4'b1001: TxD = parity_bit; //parity bit
        4'b1010: TxD = 1; //stop bit
        //default: TxD = 1'b1 //stop bit
    endcase
end

always @(posedge clk or posedge reset) 
begin
    if (reset) 
    begin
        tx_data_reg = 8'b0000_0000;
        Tx_BUSY = 0;
        TxD = 1; //stop bit 
    end 
    else begin
        if (Tx_EN)
        begin
            if (Tx_WR)
            begin
                reset_baud = 0;
                counter_sample = 4'b0000;
                tx_data_reg = Tx_DATA;
                parity_bit = ^Tx_DATA; //parity bit is 1 for odd number of 1s on my data (we do that using bitwise XOR)
                Tx_BUSY = 1;
            end
            else if (Tx_BUSY == 1 && counter == 4'b1011) //finished
            begin
                Tx_BUSY = 0;
                reset_baud = 1;
                TxD = 1;
            end
        end
    end
end

endmodule