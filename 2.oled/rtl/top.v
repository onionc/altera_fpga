module top(
    input               clk,        //12MHz系统时钟
    input               rst_n,      //系统复位，低有效

    input       [3:0]   sw,
    output	reg         oled_csn,   //OLCD液晶屏使能
    output	reg         oled_rst,   //OLCD液晶屏复位
    output	reg         oled_dcn,   //OLCD数据指令控制
    output	reg         oled_clk,   //OLCD时钟信号
    output	reg         oled_dat    //OLCD数据信号
);


Oled oled_inst(
    .clk     (clk     ), 
    .rst_n   (rst_n   ), 
    .oled_csn(oled_csn),
    .oled_rst(oled_rst),
    .oled_dcn(oled_dcn),
    .oled_clk(oled_clk),
    .oled_dat(oled_dat)
);

endmodule
