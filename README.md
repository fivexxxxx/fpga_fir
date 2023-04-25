# fpga_fir
FIR FPGA

fir 功能说明：

	FPGA产生正弦波，一路给DA通道1，一路经过滤波后给DA通道2。
	三个拨码开关控制8种频率
	key=0时，100K
	key=1时，200K
	。。。
	key=7时，800K
	FIR为低通滤波，截至频率600K，即大于600K时就会滤除...
	
仿真结果：

![](https://github.com/fivexxxxx/fpga_fir/blob/master/doc/dac.png)

仿真步骤：

1 运行run_simulation.bat

2 查看波形
   选中dac_da,右键
   Radix->unsigned
   Format->Analog
  
