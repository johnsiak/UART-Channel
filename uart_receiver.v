`include "baud_controller.v"

module uart_receiver(reset, clk, baud_select, Rx_EN, RxD, Rx_DATA, Rx_FERROR, Rx_PERROR, Rx_VALID, sample, Rx_DATA_temp);
input clk, reset;
input [2:0] baud_select;
input Rx_EN;
input RxD;
output [7:0] Rx_DATA;
output Rx_FERROR; // Framing Error //
output Rx_PERROR; // Parity Error //
output Rx_VALID; // Rx_DATA is Valid //
output [3:0] sample;
output [7:0] Rx_DATA_temp;


reg [3:0] sample; //my samples of each bit
reg [3:0] counter; //counts the number of times sample_enable is 1
reg [2:0] data_counter; //if my state is 'data' then data_counter tells us which one of the 8 bits we're reading
reg [7:0] Rx_DATA_temp;
reg [7:0] Rx_DATA;
reg Rx_FERROR, Rx_PERROR, Rx_VALID;
reg parity_bit;
reg Rx_FERROR_temp, Rx_PERROR_temp;
reg reset_baud;
wire rx_sample_enable;
reg [1:0] state, next_state;
parameter idle = 3'b000, start = 3'b001, data = 3'b010, parity = 3'b011, stop = 3'b100;


baud_controller baud_controller_rx_instance(reset_baud, clk, baud_select, rx_sample_enable); 


always@(posedge clk or posedge reset)
begin
    if(reset) counter = 4'b0000;
    else begin
        if(rx_sample_enable && Rx_EN)
        begin 
            if(counter == 4'b1111)
            begin
                counter = 4'b0000;
                if(state == data) data_counter = data_counter + 1;
            end
            else counter = counter + 1;
        end
    end
end


always@(posedge clk)
begin
    if(Rx_EN)
        case(state)
            idle :  begin
                    reset_baud = 1; //baud reset when we are in idle because we don't want to count sample enables in idle
                    //initialization
                    counter = 4'b0000;
                    data_counter = 3'b000;
                    sample = 4'bxxxx; 
                    
                    if(!RxD) //RxD is 0 (start bit)
                    begin
                        next_state = start;
                        reset_baud = 0; //we start to count sample enables
                    end
            end
                    
            start : begin
                    if(counter == 4'b0111) sample[0] = RxD; //first sample in the centre of T = 1/baud_rate
                    else if(counter == 4'b1000) sample[1] = RxD;
                    else if(counter == 4'b1001) sample[2] = RxD;
                    else if(counter == 4'b1010) sample[3] = RxD;
                    else if(counter == 4'b1111) //time for the next state
                    begin
                        next_state = data;
                        counter = 4'b0000;
                        if(sample != 4'b0000) Rx_FERROR_temp = 1'b1; //if all the samples of the start bit aren't 0 frame error = 1
                        sample = 4'bxxxx; 
                    end
            end
                    
            data:   begin
                    if(counter == 4'b0111) sample[0] = RxD; //first sample in the centre of T = 1/baud_rate
                    else if(counter == 4'b1000) sample[1] = RxD;
                    else if(counter == 4'b1001) sample[2] = RxD;
                    else if(counter == 4'b1010) sample[3] = RxD;
                    else if(counter == 4'b1111) 
                    begin
                        if(!(sample == 4'b0000 || sample == 4'b1111)) Rx_FERROR_temp = 1'b1; //if all the samples of the bit aren't the same then error
                                                                        //if they're not all 0 or they're not all 1
                                                                        
                        Rx_DATA_temp[data_counter] = sample[0]; //we're using the sample from the centre of T
                                                             //we use shift right to store each bit at a time
                        if(data_counter == 3'b111) next_state = parity; //we've read all our data
                    end
            end
                    
            parity: begin
                    if(counter == 4'b0111) sample[0] = RxD; //first sample in the centre of T = 1/baud_rate
                    else if(counter == 4'b1000) sample[1] = RxD;
                    else if(counter == 4'b1001) sample[2] = RxD;
                    else if(counter == 4'b1010) sample[3] = RxD;
                    else if(counter == 4'b1111) 
                    begin
                        next_state = stop;
                        if(!(sample == 4'b0000 || sample == 4'b1111)) Rx_FERROR_temp = 1'b1; //if all the samples of the bit aren't the same then error
                                                                                             //if they're not all 0 or they're not all 1
                                  
                        parity_bit = sample[0]; //we're using the sample from the centre of T
                        if(parity_bit != ^Rx_DATA_temp) Rx_PERROR_temp = 1; //if parity_bit from my sample isn't the same as the parity bit
                        sample = 4'bxxxx;                                            
                    end
            end
                    
            stop: begin
                    if(counter == 4'b0111) sample[0] <= RxD; //first sample in the centre of T = 1/baud_rate
                    else if(counter == 4'b1000) sample[1] <= RxD;
                    else if(counter == 4'b1001) sample[2] <= RxD;
                    else if(counter == 4'b1010) sample[3] <= RxD;
                    else if(counter == 4'b1111) 
                    begin
                        next_state = idle;
                        if(!(sample == 4'b1111)) Rx_FERROR_temp = 1'b1; //if all the samples of the stop bit aren't 1 frame error = 1
                    end
            end
        endcase
    else state = idle; //if enable is 0 then we go back to idle state
end
    

always @(posedge clk or posedge reset)
begin
    if(reset) begin
        state <= idle;
        sample <= 4'bxxxx;
        Rx_FERROR <= 0;
        Rx_PERROR <= 0;
        Rx_VALID <= 1; 
        Rx_DATA <= 8'b1111_1111;
        Rx_PERROR_temp <= 0;
        Rx_FERROR_temp <= 0;
        Rx_DATA_temp <= 8'b0000_0000;
    end
    else begin
        state <= next_state;
        if(next_state == idle) //we have read all the bits so we give values to our outputs
        begin
            Rx_FERROR <= Rx_FERROR_temp;
            Rx_PERROR <= Rx_PERROR_temp;
            Rx_VALID <= !(Rx_FERROR_temp || Rx_PERROR_temp); //if any of them is 1 then valid = 0 (error)
            Rx_DATA <= Rx_DATA_temp;
        end
    end
end

endmodule