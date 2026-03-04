// Commands for SSD1306
`define SSD1306_SETCONTRAST             8'h81
`define SSD1306_DISPLAYALLON_RESUME     8'hA4
`define SSD1306_DISPLAYALLON            8'hA5
`define SSD1306_NORMALDISPLAY           8'hA6
`define SSD1306_INVERTDISPLAY           8'hA7
`define SSD1306_DISPLAYOFF              8'hAE
`define SSD1306_DISPLAYON               8'hAF
`define SSD1306_SETDISPLAYOFFSET        8'hD3
`define SSD1306_SETCOMPINS              8'hDA
`define SSD1306_SETVCOMDETECT           8'hDB
`define SSD1306_SETDISPLAYCLOCKDIV      8'hD5
`define SSD1306_SETPRECHARGE            8'hD9
`define SSD1306_SETMULTIPLEX            8'hA8
`define SSD1306_SETLOWCOLUMN            8'h00
`define SSD1306_SETHIGHCOLUMN           8'h10
`define SSD1306_SETSTARTLINE            8'h40
`define SSD1306_MEMORYMODE              8'h20
`define SSD1306_COMSCANINC              8'hC0
`define SSD1306_COMSCANDEC              8'hC8
`define SSD1306_SEGREMAP                8'hA0
`define SSD1306_CHARGEPUMP              8'h8D
`define SSD1306_EXTERNALVCC             8'h01
`define SSD1306_INTERNALVCC             8'h02
`define SSD1306_SWITCHCAPVCC            8'h02

module Oled
(
    input				clk,		//12MHz系统时钟
    input				rst_n,		//系统复位，低有效

    input       [3:0]   sw, // 显示信号
    output	reg			oled_csn,	//OLCD液晶屏使能
    output	reg			oled_rst,	//OLCD液晶屏复位
    output	reg			oled_dcn,	//OLCD数据指令控制
    output	reg			oled_clk,	//OLCD时钟信号
    output	reg			oled_dat	//OLCD数据信号
);
 
    localparam INIT_DEPTH = 16'd25; //LCD初始化的命令的数量
    localparam IDLE = 6'h1, MAIN = 6'h2, INIT = 6'h4, SCAN = 6'h8, WRITE = 6'h10, DELAY = 6'h20;
    localparam HIGH	= 1'b1, LOW = 1'b0;
    localparam DATA	= 1'b1, CMD = 1'b0;
 
    //reg [3:0] sw;
    reg [7:0] cmd [24:0];
    reg [39:0] mem [122:0];
    reg	[7:0]	y_p, x_ph, x_pl;
    reg	[(8*21-1):0] char;
    reg	[7:0]	num, char_reg;				//
    reg	[4:0]	cnt_main, cnt_init, cnt_scan, cnt_write;
    reg	[15:0]	num_delay, cnt_delay, cnt;
    reg	[5:0] 	state, state_back;
 
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt_main <= 1'b0; cnt_init <= 1'b0; cnt_scan <= 1'b0; cnt_write <= 1'b0;
            y_p <= 1'b0; x_ph <= 1'b0; x_pl <= 1'b0;
            num <= 1'b0; char <= 1'b0; char_reg <= 1'b0;
            num_delay <= 16'd5; cnt_delay <= 1'b0; cnt <= 1'b0;
            oled_csn <= HIGH; oled_rst <= HIGH; oled_dcn <= CMD; oled_clk <= HIGH; oled_dat <= LOW;
            state <= IDLE; state_back <= IDLE;
        end else begin
            case(state)
                IDLE:begin
                        cnt_main <= 1'b0; cnt_init <= 1'b0; cnt_scan <= 1'b0; cnt_write <= 1'b0;
                        y_p <= 1'b0; x_ph <= 1'b0; x_pl <= 1'b0;
                        num <= 1'b0; char <= 1'b0; char_reg <= 1'b0;
                        num_delay <= 16'd5; cnt_delay <= 1'b0; cnt <= 1'b0;
                        oled_csn <= HIGH; oled_rst <= HIGH; oled_dcn <= CMD; oled_clk <= HIGH; oled_dat <= LOW;
                        state <= MAIN; state_back <= MAIN;
                    end
                MAIN:begin
                        if(cnt_main >= 5'd12) cnt_main <= 5'd12;
                        else cnt_main <= cnt_main + 1'b1;
                        case(cnt_main)	//MAIN状态
                            5'd0:	begin state <= INIT; end
                            5'd1:	begin y_p <= 8'hb0; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd2:	begin y_p <= 8'hb1; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd3:	begin y_p <= 8'hb2; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd4:	begin y_p <= 8'hb3; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd5:	begin y_p <= 8'hb4; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd6:	begin y_p <= 8'hb5; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd7:	begin y_p <= 8'hb6; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
                            5'd8:	begin y_p <= 8'hb7; x_ph <= 8'h10; x_pl <= 8'h00; num <= 5'd16; char <= "OLED TEST       ";state <= SCAN; end
 
                            5'd9:	begin y_p <= 8'hb0; x_ph <= 8'h15; x_pl <= 8'h00; num <= 5'd 1; char <= sw; state <= SCAN; end
                            5'd10:	begin y_p <= 8'hb1; x_ph <= 8'h15; x_pl <= 8'h00; num <= 5'd 1; char <= sw; state <= SCAN; end
                            5'd11:	begin y_p <= 8'hb2; x_ph <= 8'h15; x_pl <= 8'h00; num <= 5'd 1; char <= sw; state <= SCAN; end
                            5'd12:	begin y_p <= 8'hb3; x_ph <= 8'h15; x_pl <= 8'h00; num <= 5'd 1; char <= sw; state <= SCAN; end
 
                            default: state <= IDLE;
                        endcase
                    end
                INIT:begin	//初始化状态
                        case(cnt_init)
                            5'd0:	begin oled_rst <= LOW; cnt_init <= cnt_init + 1'b1; end	//复位有效
                            5'd1:	begin num_delay <= 16'd25000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//延时大于3us
                            5'd2:	begin oled_rst <= HIGH; cnt_init <= cnt_init + 1'b1; end	//复位恢复
                            5'd3:	begin num_delay <= 16'd25000; state <= DELAY; state_back <= INIT; cnt_init <= cnt_init + 1'b1; end	//延时大于220us
                            5'd4:	begin 
                                        if(cnt>=INIT_DEPTH) begin	//当25条指令及数据发出后，配置完成
                                            cnt <= 1'b0;
                                            cnt_init <= cnt_init + 1'b1;
                                        end else begin	
                                            cnt <= cnt + 1'b1; num_delay <= 16'd5;
                                            oled_dcn <= CMD; char_reg <= cmd[cnt]; state <= WRITE; state_back <= INIT;
                                        end
                                    end
                            5'd5:	begin cnt_init <= 1'b0; state <= MAIN; end	//初始化完成，返回MAIN状态
                            default: state <= IDLE;
                        endcase
                    end
                SCAN:begin	//刷屏状态，从RAM中读取数据刷屏
                        if(cnt_scan == 5'd11) begin
                            if(num) cnt_scan <= 5'd3;
                            else cnt_scan <= cnt_scan + 1'b1;
                        end else if(cnt_scan == 5'd12) cnt_scan <= 1'b0;
                        else cnt_scan <= cnt_scan + 1'b1;
                        case(cnt_scan)
                            5'd 0:	begin oled_dcn <= CMD; char_reg <= y_p; state <= WRITE; state_back <= SCAN; end		//定位列页地址
                            5'd 1:	begin oled_dcn <= CMD; char_reg <= x_pl; state <= WRITE; state_back <= SCAN; end	//定位行地址低位
                            5'd 2:	begin oled_dcn <= CMD; char_reg <= x_ph; state <= WRITE; state_back <= SCAN; end	//定位行地址高位
 
                            5'd 3:	begin num <= num - 1'b1;end
                            5'd 4:	begin oled_dcn <= DATA; char_reg <= 8'h00; state <= WRITE; state_back <= SCAN; end	//将5*8点阵编程8*8
                            5'd 5:	begin oled_dcn <= DATA; char_reg <= 8'h00; state <= WRITE; state_back <= SCAN; end	//将5*8点阵编程8*8
                            5'd 6:	begin oled_dcn <= DATA; char_reg <= 8'h00; state <= WRITE; state_back <= SCAN; end	//将5*8点阵编程8*8
                            5'd 7:	begin oled_dcn <= DATA; char_reg <= mem[char[(num*8)+:8]][39:32]; state <= WRITE; state_back <= SCAN; end
                            5'd 8:	begin oled_dcn <= DATA; char_reg <= mem[char[(num*8)+:8]][31:24]; state <= WRITE; state_back <= SCAN; end
                            5'd 9:	begin oled_dcn <= DATA; char_reg <= mem[char[(num*8)+:8]][23:16]; state <= WRITE; state_back <= SCAN; end
                            5'd10:	begin oled_dcn <= DATA; char_reg <= mem[char[(num*8)+:8]][15: 8]; state <= WRITE; state_back <= SCAN; end
                            5'd11:	begin oled_dcn <= DATA; char_reg <= mem[char[(num*8)+:8]][ 7: 0]; state <= WRITE; state_back <= SCAN; end
                            5'd12:	begin state <= MAIN; end
                            default: state <= IDLE;
                        endcase
                    end
                WRITE:begin	//WRITE状态，将数据按照SPI时序发送给屏幕
                        if(cnt_write >= 5'd17) cnt_write <= 1'b0;
                        else cnt_write <= cnt_write + 1'b1;
                        case(cnt_write)
                            5'd 0:	begin oled_csn <= LOW; end	//9位数据最高位为命令数据控制位
                            5'd 1:	begin oled_clk <= LOW; oled_dat <= char_reg[7]; end	//先发高位数据
                            5'd 2:	begin oled_clk <= HIGH; end
                            5'd 3:	begin oled_clk <= LOW; oled_dat <= char_reg[6]; end
                            5'd 4:	begin oled_clk <= HIGH; end
                            5'd 5:	begin oled_clk <= LOW; oled_dat <= char_reg[5]; end
                            5'd 6:	begin oled_clk <= HIGH; end
                            5'd 7:	begin oled_clk <= LOW; oled_dat <= char_reg[4]; end
                            5'd 8:	begin oled_clk <= HIGH; end
                            5'd 9:	begin oled_clk <= LOW; oled_dat <= char_reg[3]; end
                            5'd10:	begin oled_clk <= HIGH; end
                            5'd11:	begin oled_clk <= LOW; oled_dat <= char_reg[2]; end
                            5'd12:	begin oled_clk <= HIGH; end
                            5'd13:	begin oled_clk <= LOW; oled_dat <= char_reg[1]; end
                            5'd14:	begin oled_clk <= HIGH; end
                            5'd15:	begin oled_clk <= LOW; oled_dat <= char_reg[0]; end	//后发低位数据
                            5'd16:	begin oled_clk <= HIGH; end
                            5'd17:	begin oled_csn <= HIGH; state <= DELAY; end	//
                            default: state <= IDLE;
                        endcase
                    end
                DELAY:begin	//延时状态
                        if(cnt_delay >= num_delay) begin
                            cnt_delay <= 16'd0; state <= state_back; 
                        end else cnt_delay <= cnt_delay + 1'b1;
                    end
                default:state <= IDLE;
            endcase
        end
    end
 
    //OLED配置指令数据
    always@(posedge rst_n)
        begin
            cmd[ 0] = {`SSD1306_DISPLAYON};
            cmd[ 1] = {`SSD1306_SETLOWCOLUMN}; 
            cmd[ 2] = {`SSD1306_SETHIGHCOLUMN}; 
            cmd[ 3] = {`SSD1306_SETLOWCOLUMN}; 
            cmd[ 4] = {8'hb0};                      // 选择页地址，第0页
            cmd[ 5] = {`SSD1306_SETCONTRAST};      // 对比度设置，最大0xff
            cmd[ 6] = {8'hff}; 
            cmd[ 7] = {8'ha1};                      // 段重映射，左右翻转
            cmd[ 8] = {8'ha6};                      // 正常显示模式，A7为反色模式
            cmd[ 9] = {`SSD1306_SETMULTIPLEX};      // 多路复用率（高度），0x1f为32,0x3f为64
            cmd[10] = {8'h3f}; 
            cmd[11] = {`SSD1306_COMSCANDEC};        // 屏幕方向：c0正常，c8水平翻转
            cmd[12] = {`SSD1306_SETDISPLAYOFFSET};  // 显示偏移：0
            cmd[13] = {8'h00};
            cmd[14] = {`SSD1306_SETDISPLAYCLOCKDIV};// 设置时钟分频：0x80 官方推荐值
            cmd[15] = {8'h80};
            cmd[16] = {`SSD1306_SETPRECHARGE};      // 预充电周期：0x1f 内部升压
            cmd[17] = {8'h1f};
            cmd[18] = {`SSD1306_SETCOMPINS};        // COM引脚配置（重要）：0x12(12864) 0x10(12832) 0x00(其他)
            cmd[19] = {8'h12};
            cmd[20] = {`SSD1306_SETVCOMDETECT};     // 电压
            cmd[21] = {8'h40};
            cmd[22] = {`SSD1306_CHARGEPUMP};        // 电荷泵设置
            cmd[23] = {8'h14};
            cmd[24] = {`SSD1306_DISPLAYON};
        end 
 
    //5*8点阵字库数据
    always@(posedge rst_n)
        begin
            mem[  0] = {8'h3E, 8'h51, 8'h49, 8'h45, 8'h3E};   // 48  0
            mem[  1] = {8'h00, 8'h42, 8'h7F, 8'h40, 8'h00};   // 49  1
            mem[  2] = {8'h42, 8'h61, 8'h51, 8'h49, 8'h46};   // 50  2
            mem[  3] = {8'h21, 8'h41, 8'h45, 8'h4B, 8'h31};   // 51  3
            mem[  4] = {8'h18, 8'h14, 8'h12, 8'h7F, 8'h10};   // 52  4
            mem[  5] = {8'h27, 8'h45, 8'h45, 8'h45, 8'h39};   // 53  5
            mem[  6] = {8'h3C, 8'h4A, 8'h49, 8'h49, 8'h30};   // 54  6
            mem[  7] = {8'h01, 8'h71, 8'h09, 8'h05, 8'h03};   // 55  7
            mem[  8] = {8'h36, 8'h49, 8'h49, 8'h49, 8'h36};   // 56  8
            mem[  9] = {8'h06, 8'h49, 8'h49, 8'h29, 8'h1E};   // 57  9
            mem[ 10] = {8'h7C, 8'h12, 8'h11, 8'h12, 8'h7C};   // 65  A
            mem[ 11] = {8'h7F, 8'h49, 8'h49, 8'h49, 8'h36};   // 66  B
            mem[ 12] = {8'h3E, 8'h41, 8'h41, 8'h41, 8'h22};   // 67  C
            mem[ 13] = {8'h7F, 8'h41, 8'h41, 8'h22, 8'h1C};   // 68  D
            mem[ 14] = {8'h7F, 8'h49, 8'h49, 8'h49, 8'h41};   // 69  E
            mem[ 15] = {8'h7F, 8'h09, 8'h09, 8'h09, 8'h01};   // 70  F
 
            mem[ 32] = {8'h00, 8'h00, 8'h00, 8'h00, 8'h00};   // 32  sp 
            mem[ 33] = {8'h00, 8'h00, 8'h2f, 8'h00, 8'h00};   // 33  !  
            mem[ 34] = {8'h00, 8'h07, 8'h00, 8'h07, 8'h00};   // 34  
            mem[ 35] = {8'h14, 8'h7f, 8'h14, 8'h7f, 8'h14};   // 35  #
            mem[ 36] = {8'h24, 8'h2a, 8'h7f, 8'h2a, 8'h12};   // 36  $
            mem[ 37] = {8'h62, 8'h64, 8'h08, 8'h13, 8'h23};   // 37  %
            mem[ 38] = {8'h36, 8'h49, 8'h55, 8'h22, 8'h50};   // 38  &
            mem[ 39] = {8'h00, 8'h05, 8'h03, 8'h00, 8'h00};   // 39  '
            mem[ 40] = {8'h00, 8'h1c, 8'h22, 8'h41, 8'h00};   // 40  (
            mem[ 41] = {8'h00, 8'h41, 8'h22, 8'h1c, 8'h00};   // 41  )
            mem[ 42] = {8'h14, 8'h08, 8'h3E, 8'h08, 8'h14};   // 42  *
            mem[ 43] = {8'h08, 8'h08, 8'h3E, 8'h08, 8'h08};   // 43  +
            mem[ 44] = {8'h00, 8'h00, 8'hA0, 8'h60, 8'h00};   // 44  ,
            mem[ 45] = {8'h08, 8'h08, 8'h08, 8'h08, 8'h08};   // 45  -
            mem[ 46] = {8'h00, 8'h60, 8'h60, 8'h00, 8'h00};   // 46  .
            mem[ 47] = {8'h20, 8'h10, 8'h08, 8'h04, 8'h02};   // 47  /
            mem[ 48] = {8'h3E, 8'h51, 8'h49, 8'h45, 8'h3E};   // 48  0
            mem[ 49] = {8'h00, 8'h42, 8'h7F, 8'h40, 8'h00};   // 49  1
            mem[ 50] = {8'h42, 8'h61, 8'h51, 8'h49, 8'h46};   // 50  2
            mem[ 51] = {8'h21, 8'h41, 8'h45, 8'h4B, 8'h31};   // 51  3
            mem[ 52] = {8'h18, 8'h14, 8'h12, 8'h7F, 8'h10};   // 52  4
            mem[ 53] = {8'h27, 8'h45, 8'h45, 8'h45, 8'h39};   // 53  5
            mem[ 54] = {8'h3C, 8'h4A, 8'h49, 8'h49, 8'h30};   // 54  6
            mem[ 55] = {8'h01, 8'h71, 8'h09, 8'h05, 8'h03};   // 55  7
            mem[ 56] = {8'h36, 8'h49, 8'h49, 8'h49, 8'h36};   // 56  8
            mem[ 57] = {8'h06, 8'h49, 8'h49, 8'h29, 8'h1E};   // 57  9
            mem[ 58] = {8'h00, 8'h36, 8'h36, 8'h00, 8'h00};   // 58  :
            mem[ 59] = {8'h00, 8'h56, 8'h36, 8'h00, 8'h00};   // 59  ;
            mem[ 60] = {8'h08, 8'h14, 8'h22, 8'h41, 8'h00};   // 60  <
            mem[ 61] = {8'h14, 8'h14, 8'h14, 8'h14, 8'h14};   // 61  =
            mem[ 62] = {8'h00, 8'h41, 8'h22, 8'h14, 8'h08};   // 62  >
            mem[ 63] = {8'h02, 8'h01, 8'h51, 8'h09, 8'h06};   // 63  ?
            mem[ 64] = {8'h32, 8'h49, 8'h59, 8'h51, 8'h3E};   // 64  @
            mem[ 65] = {8'h7C, 8'h12, 8'h11, 8'h12, 8'h7C};   // 65  A
            mem[ 66] = {8'h7F, 8'h49, 8'h49, 8'h49, 8'h36};   // 66  B
            mem[ 67] = {8'h3E, 8'h41, 8'h41, 8'h41, 8'h22};   // 67  C
            mem[ 68] = {8'h7F, 8'h41, 8'h41, 8'h22, 8'h1C};   // 68  D
            mem[ 69] = {8'h7F, 8'h49, 8'h49, 8'h49, 8'h41};   // 69  E
            mem[ 70] = {8'h7F, 8'h09, 8'h09, 8'h09, 8'h01};   // 70  F
            mem[ 71] = {8'h3E, 8'h41, 8'h49, 8'h49, 8'h7A};   // 71  G
            mem[ 72] = {8'h7F, 8'h08, 8'h08, 8'h08, 8'h7F};   // 72  H
            mem[ 73] = {8'h00, 8'h41, 8'h7F, 8'h41, 8'h00};   // 73  I
            mem[ 74] = {8'h20, 8'h40, 8'h41, 8'h3F, 8'h01};   // 74  J
            mem[ 75] = {8'h7F, 8'h08, 8'h14, 8'h22, 8'h41};   // 75  K
            mem[ 76] = {8'h7F, 8'h40, 8'h40, 8'h40, 8'h40};   // 76  L
            mem[ 77] = {8'h7F, 8'h02, 8'h0C, 8'h02, 8'h7F};   // 77  M
            mem[ 78] = {8'h7F, 8'h04, 8'h08, 8'h10, 8'h7F};   // 78  N
            mem[ 79] = {8'h3E, 8'h41, 8'h41, 8'h41, 8'h3E};   // 79  O
            mem[ 80] = {8'h7F, 8'h09, 8'h09, 8'h09, 8'h06};   // 80  P
            mem[ 81] = {8'h3E, 8'h41, 8'h51, 8'h21, 8'h5E};   // 81  Q
            mem[ 82] = {8'h7F, 8'h09, 8'h19, 8'h29, 8'h46};   // 82  R
            mem[ 83] = {8'h46, 8'h49, 8'h49, 8'h49, 8'h31};   // 83  S
            mem[ 84] = {8'h01, 8'h01, 8'h7F, 8'h01, 8'h01};   // 84  T
            mem[ 85] = {8'h3F, 8'h40, 8'h40, 8'h40, 8'h3F};   // 85  U
            mem[ 86] = {8'h1F, 8'h20, 8'h40, 8'h20, 8'h1F};   // 86  V
            mem[ 87] = {8'h3F, 8'h40, 8'h38, 8'h40, 8'h3F};   // 87  W
            mem[ 88] = {8'h63, 8'h14, 8'h08, 8'h14, 8'h63};   // 88  X
            mem[ 89] = {8'h07, 8'h08, 8'h70, 8'h08, 8'h07};   // 89  Y
            mem[ 90] = {8'h61, 8'h51, 8'h49, 8'h45, 8'h43};   // 90  Z
            mem[ 91] = {8'h00, 8'h7F, 8'h41, 8'h41, 8'h00};   // 91  [
            mem[ 92] = {8'h55, 8'h2A, 8'h55, 8'h2A, 8'h55};   // 92  .
            mem[ 93] = {8'h00, 8'h41, 8'h41, 8'h7F, 8'h00};   // 93  ]
            mem[ 94] = {8'h04, 8'h02, 8'h01, 8'h02, 8'h04};   // 94  ^
            mem[ 95] = {8'h40, 8'h40, 8'h40, 8'h40, 8'h40};   // 95  _
            mem[ 96] = {8'h00, 8'h01, 8'h02, 8'h04, 8'h00};   // 96  '
            mem[ 97] = {8'h20, 8'h54, 8'h54, 8'h54, 8'h78};   // 97  a
            mem[ 98] = {8'h7F, 8'h48, 8'h44, 8'h44, 8'h38};   // 98  b
            mem[ 99] = {8'h38, 8'h44, 8'h44, 8'h44, 8'h20};   // 99  c
            mem[100] = {8'h38, 8'h44, 8'h44, 8'h48, 8'h7F};   // 100 d
            mem[101] = {8'h38, 8'h54, 8'h54, 8'h54, 8'h18};   // 101 e
            mem[102] = {8'h08, 8'h7E, 8'h09, 8'h01, 8'h02};   // 102 f
            mem[103] = {8'h18, 8'hA4, 8'hA4, 8'hA4, 8'h7C};   // 103 g
            mem[104] = {8'h7F, 8'h08, 8'h04, 8'h04, 8'h78};   // 104 h
            mem[105] = {8'h00, 8'h44, 8'h7D, 8'h40, 8'h00};   // 105 i
            mem[106] = {8'h40, 8'h80, 8'h84, 8'h7D, 8'h00};   // 106 j
            mem[107] = {8'h7F, 8'h10, 8'h28, 8'h44, 8'h00};   // 107 k
            mem[108] = {8'h00, 8'h41, 8'h7F, 8'h40, 8'h00};   // 108 l
            mem[109] = {8'h7C, 8'h04, 8'h18, 8'h04, 8'h78};   // 109 m
            mem[110] = {8'h7C, 8'h08, 8'h04, 8'h04, 8'h78};   // 110 n
            mem[111] = {8'h38, 8'h44, 8'h44, 8'h44, 8'h38};   // 111 o
            mem[112] = {8'hFC, 8'h24, 8'h24, 8'h24, 8'h18};   // 112 p
            mem[113] = {8'h18, 8'h24, 8'h24, 8'h18, 8'hFC};   // 113 q
            mem[114] = {8'h7C, 8'h08, 8'h04, 8'h04, 8'h08};   // 114 r
            mem[115] = {8'h48, 8'h54, 8'h54, 8'h54, 8'h20};   // 115 s
            mem[116] = {8'h04, 8'h3F, 8'h44, 8'h40, 8'h20};   // 116 t
            mem[117] = {8'h3C, 8'h40, 8'h40, 8'h20, 8'h7C};   // 117 u
            mem[118] = {8'h1C, 8'h20, 8'h40, 8'h20, 8'h1C};   // 118 v
            mem[119] = {8'h3C, 8'h40, 8'h30, 8'h40, 8'h3C};   // 119 w
            mem[120] = {8'h44, 8'h28, 8'h10, 8'h28, 8'h44};   // 120 x
            mem[121] = {8'h1C, 8'hA0, 8'hA0, 8'hA0, 8'h7C};   // 121 y
            mem[122] = {8'h44, 8'h64, 8'h54, 8'h4C, 8'h44};   // 122 z
        end
 
endmodule