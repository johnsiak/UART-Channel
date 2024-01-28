`timescale 1ns / 1ps

module baud_controller(reset, clk, baud_select, sample_ENABLE);
input reset, clk;
input [2:0] baud_select; //how speed baud rate
output sample_ENABLE;

reg sample_ENABLE;
reg[4:0] counter;
reg[8:0] count_reps; 

initial begin
    counter = 5'b00000;
    count_reps = 9'b0_0000_0000; 
end

always@(posedge clk) 
begin
    counter <= counter + 1'b1;
    if (counter == 5'b11011) 
    begin
        counter <= 5'b00000;
        count_reps <= count_reps + 1'b1;
    end
end

always@(posedge clk)
begin
    if(sample_ENABLE)
    begin
        sample_ENABLE = 1'b0;
        count_reps = 9'b0_0000_0000;
    end
end
  
always@(posedge clk or posedge reset)
begin
    if(reset)
    begin
        counter = 5'b00000;
        sample_ENABLE = 0;
    end
    else
    begin
        case(baud_select)
            3'b000:

              			if (count_reps == 9'b1_1000_0000) sample_ENABLE = 1'b1; //384

            3'b001:
                   
                        if (count_reps == 9'b0_0110_0000) sample_ENABLE = 1'b1; //96
                    
            3'b010: 
                    
                        if (count_reps == 9'b0_0001_1000) sample_ENABLE = 1'b1; //24
                    
            3'b011: 
                    
                        if (count_reps == 9'b0_0000_1100) sample_ENABLE = 1'b1; //12
                    
            3'b100: 
                    
                        if (count_reps == 9'b0_0000_0110) sample_ENABLE = 1'b1; //6
                    
            3'b101: 
                    
                        if (count_reps == 9'b0_0000_0011) sample_ENABLE = 1'b1; //3
                    
            3'b110: 
                    
                        if (count_reps == 9'b0_0000_0010) sample_ENABLE = 1'b1; //2
                    
            3'b111:
                    
                        if (count_reps == 9'b0_0000_0001) sample_ENABLE = 1'b1; //1
                   
        endcase
    end
end


endmodule