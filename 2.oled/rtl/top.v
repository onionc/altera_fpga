module top(
    input               clk,        //12MHz系统时钟
    input               rst_n,      //系统复位，低有效

  
    output  wire        oled_csn,   //OLCD液晶屏使能
    output  wire        oled_rst,   //OLCD液晶屏复位
    output  wire        oled_dcn,   //OLCD数据指令控制
    output  wire        oled_clk,   //OLCD时钟信号
    output  wire        oled_dat    //OLCD数据信号
);


reg [3:0] sw;
always @(*) begin
    sw = 4'hf;
end

Oled oled_inst(
    .clk     (clk     ), 
    .rst_n   (rst_n   ), 
    .sw      (sw      ),
    .oled_csn(oled_csn),
    .oled_rst(oled_rst),
    .oled_dcn(oled_dcn),
    .oled_clk(oled_clk),
    .oled_dat(oled_dat)
);

endmodule
