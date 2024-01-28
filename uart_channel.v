`timescale 1ns / 1ps
`include "uart_transmitter.v"
`include "uart_receiver.v"

module uart_channel(reset, clk, data_in, baud_select, data_out);
    input reset, clk;
    input [15:0] data_in;
    input baud_select;
    output [15:0] data_out;

    reg Tx_EN;
    reg Tx_WR;
    reg Rx_EN;
    reg reset_TR;
    wire Rx_FERROR, Rx_PERROR, Rx_VALID;
    wire data_bit;
    wire TxBUSY;
    wire [7:0] Rx_DATA;
    reg [7:0] packet;
    reg packets_sent;

 
    uart_transmitter transmitter(reset, clk, packet, baud_select, Tx_WR, Tx_EN, data_bit, Tx_BUSY);
    uart_receiver receiver(reset, clk, baud_select, Rx_EN, data_bit, Rx_DATA, Rx_FERROR, Rx_PERROR, Rx_VALID);

    always@(posedge reset or posedge clk)
    begin
        if(reset)
        begin
            reset_TR = 1;
            packets_sent = 0;
            Tx_EN = 0;
            Rx_EN = 0;
        end
        else begin
            case(packets_sent): 
                0: begin
                    packet <= data_in[15:8];
                    Tx_EN = 1;
                    if (Tx_BUSY == 0) Tx_WR = 1;
                    if(Tx_BUSY == 1) begin
                        Tx_WR = 0;
                        if(Rx_VALID == 0) data_out = 15'b1100110011001100;
                        else if (Rx_VALID == 1) 
                    end
                end
                1: begin
                    reset_TR <= ~Tx_EN;
                    packet <= data_in[7:0];
                    Tx_EN = 1;
                end

                default:

            endcase
        end
    end
    

    

    if (...) data_out = Rx_DATA;

endmodule