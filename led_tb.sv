`timescale 1 ns/1 ps

module Lightning_Testbench;
    reg clk;
    wire led_data_out;

    LedLightning UUT (.clk(clk), .led_data_out(led_data_output));

    always begin
        clk = 1'b1;
        #6.25; // 80 Mhz clock
        clk = 1'b0;
        #6.25;
     end
endmodule
