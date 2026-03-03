`timescale 1ns/100ps

module LED_Shining_tb;

parameter CLK_PERIOD = 40;
reg sys_clk;

initial	sys_clk = 1'b0;

always sys_clk = #(CLK_PERIOD/2)~sys_clk;

reg sys_rst_n;

initial begin
	sys_rst_n = 1'b0;
	#200;
	sys_rst_n = 1'b1;
end

wire [1:0] led;

LED_Shining #
(
	.CLK_DIV_PERIOD(4'd12)
)
LED_Shining_inst
(
	.clk(sys_clk),
	.rst_n(sys_rst_n),
	.led(led)
);

endmodule