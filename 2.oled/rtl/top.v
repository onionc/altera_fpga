module top(
    input               clk,        //12MHz系统时钟
    input               rst_n,      //系统复位，低有效

  
    output  wire        oled_csn,   //OLCD液晶屏使能
    output  wire        oled_rst,   //OLCD液晶屏复位
    output  wire        oled_dcn,   //OLCD数据指令控制
    output  wire        oled_clk,   //OLCD时钟信号
    output  wire        oled_dat,    //OLCD数据信号

    input               key,         // 按键

    // ad 采集
    input   [9:0]       ad_io,
    output  wire        ad_clk
);


reg [15:0] sw;
(*keep*) wire [15:0] bcd_code;
wire [15:0] vpp_code;
wire clk_24mhz,locked;
wire [9:0] signal_cnt;

wire key_result;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        sw <= 16'd0;
    else if(key_result==0) 
        sw <= bcd_code;
    else
        sw <= sw;
end


assign ad_clk = clk_24mhz;
wire [1:0] unit; // 单位：0-Hz 1KHz 2MHz
Oled oled_inst(
    .clk     (clk     ), 
    .rst_n   (rst_n   ), 
    .sw      (sw      ),
    .unit    (unit    ),
//    .vpp    (vpp_code),
    .oled_csn(oled_csn),
    .oled_rst(oled_rst),
    .oled_dcn(oled_dcn),
    .oled_clk(oled_clk),
    .oled_dat(oled_dat)
);


KeyDebounce key_inst(
    .clk        (clk),
    .rst_n      (rst_n),
    .key        (key),
    .key_filter (key_result)
);


Bin2Bcd bin2bcd_inst(
    .rst_n      (rst_n),
    .bin_code   (signal_cnt),
    .bcd_code   (bcd_code)
);/*
Bin2Bcd bin2bcd_inst2(
    .rst_n      (rst_n),
    .bin_code   (vpp),
    .bcd_code   (vpp_code)
);*/

PLL pll_inst
(
.areset				(!rst_n			), //pll模块的复位为高有效
.inclk0				(clk			), //12MHz系统时钟输入
.c0					(clk_24mhz		), //48MHz时钟输出
.locked				(locked			)  //pll lock信号输出
);



CheckSignal signal_inst(
    .clk(clk_24mhz),
    .rst_n(rst_n),
    .ad_val(ad_io),
    .ad_cnt(signal_cnt),
    .unit(unit)
    //.vpp(vpp)
);
endmodule
