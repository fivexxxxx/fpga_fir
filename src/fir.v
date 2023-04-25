/*
fir 功能说明：
	FPGA产生正弦波，一路给DA通道1，一路经过滤波后给DA通道2。
	三个拨码开关控制8种频率
	key=0时，100K
	key=1时，200K
	。。。
	key=7时，800K
	FIR为低通滤波，截至频率600K，即大于600K时就会滤除...
	
	
*/
module fir(
	input				clk			,
	input				rst_n		,
	input[2:0]			key			,//							;	
	output				dac_mode	,
	output				dac_clka	,	
	output reg	[7:0]	dac_da		,
	output				dac_wra		,
	output				dac_sleep	,
	output				dac_clkb	,
	output reg  [7:0]	dac_db		,
	output				dac_wrb		
);

//计数器--0
reg	[31:0]			cnt0		;
wire				add_cnt0	;
wire				end_cnt0	;

//计数器--1
reg	[2:0]			cnt1		;
wire				add_cnt1	;
wire				end_cnt1	;

//计数器--2
reg	[1:0]			cnt2		;
wire				add_cnt2	;
wire				end_cnt2	;

//计数器--3
reg	[3:0]			cnt3		;
wire				add_cnt3	;
wire				end_cnt3	;

reg	[11:0]			x			;
wire[16:0]			addr_tmp	;
wire[6:0]			addr		;
reg	[7:0]			sin_date	;
wire[7:0]			fir_din		;
wire[7:0]			fir_dout	;
wire				fir_dout_vld;
wire[7:0]			fir_dout2	;


/////////////////////////////////////////////////////////////////////////////
//cnt0 计数经过多少个时钟周期
always @(posedge	clk	or	negedge	rst_n) begin
	if(!rst_n) begin
		cnt0	<=	0	;
	end
	else if(add_cnt0) begin
		if(end_cnt0)
			cnt0	<=	0	;
		else
			cnt0	<=	cnt0	+	1	;
	end
end
//计数器加1条件
assign	add_cnt0	=	1	;
//计数器计数结束条件							
assign	end_cnt0	=	0	;//add_cnt0	&&	cnt0	==	x	-	1	;	//x作为 每个点输出的间隔周期数

assign addr_tmp	=	x*cnt0	;
assign addr	=addr_tmp >>10	;
assign fir_din	=sin_date-128	;  //sin_date 是无符号的，-128变化为有符号

//例化FIR
my_fir u_fir(
	.clk				(clk				)	,
	.reset_n			(rst_n				)	,
	.ast_sink_data		(fir_din			)	,
	.ast_sink_valid		(end_cnt1			)	,//参考CNT1的说明
	.ast_sink_error		(2'b0				)	,
	.ast_source_data	(fir_dout			)	,
	.ast_source_valid	(fir_dout_vld		)	,
	.ast_source_error	(				)	
	
);

//cnt1, 类似分频。因为输入时钟50M，，采样频率12.5M，因此计数4次，采样时钟有效1次。
always @(posedge	clk	or	negedge	rst_n) begin
	if(!rst_n) begin
		cnt1	<=	0	;
	end
	else if(add_cnt1) begin
		if(end_cnt1)
			cnt1	<=	0	;
		else
			cnt1	<=	cnt1	+	1	;
	end
end
//计数器加1条件
assign	add_cnt1	=	1	;
//计数器计数结束条件							
assign	end_cnt1	=	add_cnt1	&&	cnt1	==	4	-	1	;	//

//有符号，变为无符号再。
assign	fir_dout2=fir_dout+128	;

//时序逻辑//将信号数据送DA
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		dac_da	<=0		;
	end
	else if(fir_dout_vld)begin
		dac_da	<=	255-fir_dout2	;
	end
end
/*
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		dac_da	<=	0	;
	end
	else begin
		dac_da	<=	255	-	sin_date	;
	end 	
end
*/
//组合逻辑--always---sin_date的值表
//共128个值...
always @(*)begin
	case(addr)
		0:sin_date		=	8'h7F	;
		1:sin_date		=	8'h85   ;
		2:sin_date		=	8'h8C   ;
		3 :sin_date		=	8'h92   ;
		4 :sin_date		=	8'h98   ;
		5:sin_date		=	8'h9E   ;
		6  :sin_date	=	8'hA4   ;
		7  :sin_date	=	8'hAA   ;
		8  :sin_date	=	8'hB0   ;
		9  :sin_date	=	8'hB6   ;
		10  :sin_date	=	8'hBC   ;
		11  :sin_date	=	8'hC1   ;
		12  :sin_date	=	8'hC6   ;
		13  :sin_date	=	8'hCB   ;
		14  :sin_date	=	8'hD0   ;
		15  :sin_date	=	8'hD5   ;
		16  :sin_date	=	8'hDA   ;
		17  :sin_date	=	8'hDE   ;
		18  :sin_date	=	8'hE2   ;
		19  :sin_date	=	8'hE6   ;
		20  :sin_date	=	8'hEA   ;
		21:sin_date		=	8'hED   ;
		22:sin_date		=	8'hF0   ;
		23:sin_date		=	8'hF3   ;
		24:sin_date		=	8'hF5   ;
		25:sin_date		=	8'hF7   ;
		26:sin_date		=	8'hF9   ;
		27:sin_date		=	8'hFB   ;
		28:sin_date		=	8'hFC   ;
		29:sin_date		=	8'hFD   ;
		30:sin_date		=	8'hFE   ;
		31 :sin_date	=	8'hFE   ;
		32 :sin_date	=	8'hFE   ;
		33 :sin_date	=	8'hFE   ;
		34 :sin_date	=	8'hFE   ;
		35 :sin_date	=	8'hFD   ;
		36 :sin_date	=	8'hFC   ;
		37 :sin_date	=	8'hFA   ;
		38 :sin_date	=	8'hF8   ;
		39 :sin_date	=	8'hF6   ;
		40  :sin_date	=	8'hF4   ;
		41  :sin_date	=	8'hF1   ;
		42  :sin_date	=	8'hEF   ;
		43  :sin_date	=	8'hEB   ;
		44  :sin_date	=	8'hE8   ;
		45  :sin_date	=	8'hE4   ;
		46  :sin_date	=	8'hE0   ;
		47  :sin_date	=	8'hDC   ;
		48  :sin_date	=	8'hD8   ;
		49  :sin_date	=	8'hD3   ;
		50  :sin_date	=	8'hCE   ;
		51  :sin_date	=	8'hC9   ;
		52  :sin_date	=	8'hC4   ;
		53  :sin_date	=	8'hBE   ;
		54  :sin_date	=	8'hB9   ;
		55  :sin_date	=	8'hB3   ;
		56  :sin_date	=	8'hAD   ;
		57  :sin_date	=	8'hA7   ;
		58  :sin_date	=	8'hA1   ;
		59  :sin_date	=	8'h9B   ;
		60  :sin_date	=	8'h95   ;
		61  :sin_date	=	8'h8F   ;
		62  :sin_date	=	8'h89   ;
		63  :sin_date	=	8'h82   ;
		64  :sin_date	=	8'h7D   ;
		65  :sin_date	=	8'h77   ;
		66  :sin_date	=	8'h70   ;
		67  :sin_date	=	8'h6A   ;
		68  :sin_date	=	8'h64   ;
		69  :sin_date	=	8'h5E   ;
		70  :sin_date	=	8'h58   ;
		71  :sin_date	=	8'h52   ;
		72  :sin_date	=	8'h4C   ;
		73  :sin_date	=	8'h46   ;
		74  :sin_date	=	8'h41   ;
		75  :sin_date	=	8'h3C   ;
		76  :sin_date	=	8'h36   ;
		77  :sin_date	=	8'h31   ;
		78  :sin_date	=	8'h2C   ;
		79  :sin_date	=	8'h28   ;
		80  :sin_date	=	8'h23   ;
		81  :sin_date	=	8'h1F   ;
		82  :sin_date	=	8'h1B   ;
		83  :sin_date	=	8'h17   ;
		84  :sin_date	=	8'h14   ;
		85  :sin_date	=	8'h11   ;
		86  :sin_date	=	8'hE   ;
		87  :sin_date	=	8'hB   ;
		88  :sin_date	=	8'h9   ;
		89  :sin_date	=	8'h7   ;
		90  :sin_date	=	8'h5   ;
		91  :sin_date	=	8'h3   ;
		92  :sin_date	=	8'h2   ;
		93  :sin_date	=	8'h1   ;
		94  :sin_date	=	8'h1   ;
		95  :sin_date	=	8'h1   ;
		96  :sin_date	=	8'h1   ;
		97  :sin_date	=	8'h1   ;
		98  :sin_date	=	8'h2   ;
		99  :sin_date	=	8'h3   ;
		100  :sin_date	=	8'h4   ;
		101  :sin_date	=	8'h6   ;
		102  :sin_date	=	8'h7   ;
		103  :sin_date	=	8'hA   ;
		104  :sin_date	=	8'hC   ;
		105  :sin_date	=	8'hF   ;
		106  :sin_date	=	8'h12   ;
		107  :sin_date	=	8'h15   ;
		108  :sin_date	=	8'h19   ;
		109  :sin_date	=	8'h1D   ;
		110  :sin_date	=	8'h21   ;
		111  :sin_date	=	8'h25   ;
		112  :sin_date	=	8'h2A   ;
		113  :sin_date	=	8'h2E   ;
		114  :sin_date	=	8'h33   ;
		115  :sin_date	=	8'h38   ;
		116  :sin_date	=	8'h3E   ;
		117  :sin_date	=	8'h43   ;
		118  :sin_date	=	8'h49   ;
		119  :sin_date	=	8'h4E   ;
		120  :sin_date	=	8'h54   ;
		121  :sin_date	=	8'h5A   ;
		122  :sin_date	=	8'h60   ;
		123  :sin_date	=	8'h67   ;
		124  :sin_date	=	8'h6D   ;
		125  :sin_date	=	8'h73   ;
		126  :sin_date	=	8'h79   ;
		127  :sin_date	=	8'h7F   ;
	endcase
end 


always @(*)begin
	if(key==0)begin
		x	=	262	;
	end
	else if(key==1)begin
		x	=	524	;
	end
	else if(key==2)begin
		x	=	786	;
	end
	else if(key==3)begin
		x	=	1029	;
	end
	else if(key==4)begin
		x	=	1311	;
	end
	else if(key==5)begin
		x	=	1573	;
	end
	else if(key==6)begin
		x	=	1835	;
	end
	else begin
		x	=	2097	;
	end
end 

assign	dac_mode	=	1		;
assign	dac_sleep	=	0		;
assign	dac_clka	=	~clk	;
assign	dac_wra		=dac_clka	;
//DB

//时序逻辑
always @(posedge	clk	or	negedge	rst_n)	begin
	if(!rst_n)	begin
		dac_db	<=	0		;
	end
	else begin
		dac_db	<= 255 - sin_date	;
	end	
end
assign	dac_clkb	=	~clk	;
assign	dac_wrb		=dac_clkb	;
//DB

endmodule