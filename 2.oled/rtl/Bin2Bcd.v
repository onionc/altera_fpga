module Bin2Bcd
(
input                       rst_n,  //系统复位，低有效
input       [9:0]           bin_code,   //需要进行BCD转码的二进制数据
output  reg [15:0]          bcd_code    //转码后的BCD码型数据输出
);

reg     [25:0]      shift_reg;
always@(bin_code or rst_n)begin
    shift_reg = {15'h0,bin_code};
    if(!rst_n) bcd_code = 0;
    else begin
        repeat(10) begin //循环16次 
            //BCD码各位数据作满5加3操作，
            if (shift_reg[13:10] >= 5) shift_reg[13:10] = shift_reg[13:10] + 2'b11;
            if (shift_reg[17:14] >= 5) shift_reg[17:14] = shift_reg[17:14] + 2'b11;
            if (shift_reg[21:18] >= 5) shift_reg[21:18] = shift_reg[21:18] + 2'b11;
            if (shift_reg[25:22] >= 5) shift_reg[25:22] = shift_reg[25:22] + 2'b11;
            shift_reg = shift_reg << 1;
        end
        bcd_code = shift_reg[25:10];
    end 
end
 
endmodule