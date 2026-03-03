module LED_Shining
(
	input		clk,
	input		rst_n,
	output	[1:0] led
	
);

parameter CLK_DIV_PERIOD = 12_000_000;
reg clk_div = 0;

assign led[0] = clk_div;
assign led[1] = ~clk_div;

reg[24:0] cnt = 0;
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt <= 0;
		clk_div = 0;
	end else begin
		if(cnt == (CLK_DIV_PERIOD-1))
			cnt <= 0;
		else
			cnt <= cnt + 1'b1;
		if(cnt < (CLK_DIV_PERIOD>>1))
			clk_div <= 0;
		else
			clk_div <= 1'b1;
	end

end

endmodule