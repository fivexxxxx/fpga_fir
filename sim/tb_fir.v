`timescale 1ns/1ns
module	tb_fir;

reg				clk				;
reg				rst_n			;
reg[2:0]		key				;

wire			dac_mode		;
wire			dac_clka		;	
wire	[7:0]	dac_da			;
wire			dac_wra			;
wire			dac_sleep		;
wire	[7:0]	dac_db			;
wire			dac_clkb		;	
wire			dac_wrb			;	
//时钟周期，单位 ns	可在这里修改周期
parameter	CYCLE		=	20	;	
//例化--TIME_1S强制数100个周期,减小仿真时间
//fir#(.TIME_1S(100)) fir_inst(
fir fir_inst(
	input				clk			(clk					),
	input				rst_n		(rst_n					),
	input[2:0]			key			(key					),//							;	
	output				dac_mode	(dac_mode				),
	output				dac_clka	(dac_clka				),	
	output reg	[7:0]	dac_da		(dac_da					),
	output				dac_wra		(dac_wra				),
	output				dac_sleep	(dac_sleep				),
	output				dac_clkb	(dac_clkb				),
	output reg  [7:0]	dac_db		(dac_db					),
	output				dac_wrb		(dac_wrb				)
);

//时钟和复位
initial	begin
	clk	=	0	;
	forever#(CYCLE/2)begin
	clk	=	~clk	;
	end
end
//生成复位信号
initial	begin	
	#1;
	rst_n	=	0	;
	#(CYCLE*10)
	rst_n	=	1	;	
	key=0		;
	#(CYCLE*262)	;
	key=1		;
	#(CYCLE*524)	;
	key=2		;
	#(CYCLE*786)	;
	key=3		;
	#(CYCLE*1029)	;
	key=4		;
	#(CYCLE*1311)	;
	key=5		;
	#(CYCLE*1573)	;
	key=6		;
	#(CYCLE*1835)	;
	key=7		;
	#(CYCLE*2097)	;
end



endmodule
