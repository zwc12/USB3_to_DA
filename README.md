通信协议
===
为了方便数据的转存，采用单独的数据包标识下一个数据包的属性。

## 标识方法

在32个字的前31个字中全部填上32'haaaaaaaa,最后一个字填上{8'hff,16'h标识符,8'haa}的数据，表示下一个数据的性质，其中标示位对应下表:

| 标识位     | 16'h0000 | 16'h000a | 16'h00aa | 16'h0aaa | 16'haaaa |
| :----------: | :-----: | :-----: | :-----: | :-----: | :-----: |
| 下一个包内容 | C/A码 | 导航电文 | 频率字相位字以及C/A延迟 | 待用 | 待用 |


#### 1."C/A码"
 - 一个包同时传输八个信道的数据，每个信道长度1024bits，即32个字。
 - 包的第i=int(n/32)个字为第i个信道的数据。
 - 由于C/A码长度为1023，每一路的第1个bit位为有效位，1'b1表示有效。

#### 2."导航电文"
 - 一个包同时传输八个信道的数据，每个信道长度320bits，即10个字。
 - 包的第i=int(n/10)个字为第i个信道的数据。
 - 数据如下
 	1. 电文数据前20bits用于表示信道编号以及电文有效性
	> 电文信道编号分配为：16'h00xx，x表示数据有效性，16'h00aa为有效，对于无效的数据，导航电文无须更新。接下来的4bits代表对应的信道编号，有效值为16进制的0~7
  	2. 后300bits为导航电文一个完整的子帧。
  	3. 一个包后面剩余的5632bits(176个字)用0补齐。

#### 3."频率字相位字以及C/A延迟"

 - 每个标示位之后传递8个完整的包，按照顺序依次对应8个信道的控制参数。
 - 频率字、相位字以及C/A码延迟数每次传输64组数据(每64ms传输一次)
 - 按照信道依次打包，因此每个信道正好对应1024字节的数据。每个信道数据依次如下
	1. 64组UINT32载波频率字
	1. 64组UINT32伪码频率字
	1. 64组UINT32相位字
	1. 64组UINT32延迟数 
  
所有数据都放在总线的低位，空缺的高位用0补齐。