module LedLightning(input wire clk, // 80 MHz clock
                    output reg led_data_out);

    reg [7:0] led_data [1:0][2:0] = '{'{ 8'b11111111, 8'b00000000, 8'b11111111},'{ 8'b1111111, 8'b00000000, 8'b10000001}};

    parameter num_lights = 2'b10;

    //number of clock cycles to reach specified time on data sheet(all -4 because for leeway)
    parameter cycles_T0H = 31;
    parameter cycles_T0L = 67;
    parameter cycles_T1L = 35;
    parameter cycles_T1H = 63;
    parameter cycles_reset = 4400;

    reg [7:0] cycles_low;
    reg [7:0] cycles_high;

    reg machine_state = 1'b0;
    parameter DATA_CYCLE = 1'b0; 
    parameter RESET_STAGE = 1'b1;


    reg machine_state2 = 1'b0;
    parameter OUT_HIGH = 1'b0;
    parameter OUT_LOW = 1'b1;

    reg [6:0] cycle_counter = 7'b000_0000;
    reg [5:0] cycle_counter_counter = 6'b00_0000; //counts how many times have the cycle_counter get counted to max(used for cycles_reset due to it being too big)
    reg data_bit;
    reg [1:0] i = 2'b00; //change number of digits manually by num_lights
    reg [1:0] j = 2'b00;
    reg [3:0] k = 4'b0000;

    always @(posedge clk) begin
        case(machine_state)
            DATA_CYCLE: begin
                data_bit <= led_data[i][j][k];
                if (data_bit == 1'b0) begin
                    cycles_high <= cycles_T0H;
                    cycles_low <= cycles_T0L;
                end
                if (data_bit == 1'b1) begin
                    cycles_high <= cycles_T1H;
                    cycles_low <= cycles_T1L;
                end
                case(machine_state2)
                    OUT_HIGH: begin
                        led_data_out <= 1;
                        cycle_counter <= cycle_counter + 1;
                        if (cycle_counter == cycles_high) begin
                            cycle_counter <= 7'b000_0000;
                            machine_state2 <= 1'b1;
                        end
                    end
                    OUT_LOW: begin
                        led_data_out <= 0;
                        cycle_counter <= cycle_counter +1;
                        if (cycle_counter == cycles_low) begin
                            cycle_counter <= 7'b000_0000;
                            machine_state2 <= 1'b0;
                            k<=k+1;
                        end
                    end
                endcase

                 if (k==4'b1000) begin
                     j <= j+1;
                     k <= 0;
                 end
                 if (j==2'b11) begin
                     i <= i+1;
                     j <= 0;
                 end
                 if (i==num_lights) begin
                     machine_state <= 1'b1;
                     i <= 0;
                 end
             end
             
             RESET_STAGE: begin
                 led_data_out <=0;
                 cycle_counter <= cycle_counter+1;
                 if (cycle_counter == 7'b111_1111) begin
                     cycle_counter_counter <= cycle_counter_counter+1;
                 end
                
                 if (cycle_counter_counter == 6'b10_0100) begin
                     machine_state <= 1'b0;
                     cycle_counter <= 7'b000_0000;
                     cycle_counter_counter <= 6'b00_0000;

                 end
             end
         endcase
    end
endmodule
