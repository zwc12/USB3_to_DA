module NCO_bb(

	clk,
	rst_n,

	fre_1023k0,
	pha_1023k0,
	fre_carrier0,
	
	fre_1023k1,
	pha_1023k1,
	fre_carrier1,
	
	fre_1023k2,
	pha_1023k2,
	fre_carrier2,
	
	fre_1023k3,
	pha_1023k3,
	fre_carrier3,
	
	fre_1023k4,
	pha_1023k4,
	fre_carrier4,
	
	fre_1023k5,
	pha_1023k5,
	fre_carrier5,
	
	fre_1023k6,
	pha_1023k6,
	fre_carrier6,
	
	fre_1023k7,
	pha_1023k7,
	fre_carrier7,
	
	clk_1023k,
	clk_carrier
);

	input clk;
	input rst_n;
	
	output reg [7:0] clk_1023k;
	output reg [7:0] clk_carrier;
	
	localparam DATA_WIDTH = 28;

	input [DATA_WIDTH-1:0] fre_1023k0;
	input [DATA_WIDTH-1:0] pha_1023k0;
	input [DATA_WIDTH-1:0] fre_carrier0;
	
	input [DATA_WIDTH-1:0] fre_1023k1;
	input [DATA_WIDTH-1:0] pha_1023k1;
	input [DATA_WIDTH-1:0] fre_carrier1;
	
	input [DATA_WIDTH-1:0] fre_1023k2;
	input [DATA_WIDTH-1:0] pha_1023k2;
	input [DATA_WIDTH-1:0] fre_carrier2;
	
	input [DATA_WIDTH-1:0] fre_1023k3;
	input [DATA_WIDTH-1:0] pha_1023k3;
	input [DATA_WIDTH-1:0] fre_carrier3;
	
	input [DATA_WIDTH-1:0] fre_1023k4;
	input [DATA_WIDTH-1:0] pha_1023k4;
	input [DATA_WIDTH-1:0] fre_carrier4;
	
	input [DATA_WIDTH-1:0] fre_1023k5;
	input [DATA_WIDTH-1:0] pha_1023k5;
	input [DATA_WIDTH-1:0] fre_carrier5;
	
	input [DATA_WIDTH-1:0] fre_1023k6;
	input [DATA_WIDTH-1:0] pha_1023k6;
	input [DATA_WIDTH-1:0] fre_carrier6;
	
	input [DATA_WIDTH-1:0] fre_1023k7;
	input [DATA_WIDTH-1:0] pha_1023k7;
	input [DATA_WIDTH-1:0] fre_carrier7;
	
//channel 1
NCO nco_c1(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier0),
	.pha_chtr(28'd0),
	.sin(clk_carrier0));

NCO nco_m1(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k0),
	.pha_chtr(pha_1023k0),
	.sin(clk_1023k0));


//channel 2
NCO nco_c2(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier1),
	.pha_chtr(28'd0),
	.sin(clk_carrier1));

NCO nco_m2(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k1),
	.pha_chtr(pha_1023k1),
	.sin(clk_1023k1));


//channel 3
NCO nco_c3(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier2),
	.pha_chtr(28'd0),
	.sin(clk_carrier2));

NCO nco_m3(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k2),
	.pha_chtr(pha_1023k2),
	.sin(clk_1023k2));


//channel 4
NCO nco_c4(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier3),
	.pha_chtr(28'd0),
	.sin(clk_carrier3));

NCO nco_m4(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k3),
	.pha_chtr(pha_1023k3),
	.sin(clk_1023k3));


//channel 5
NCO nco_c5(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier4),
	.pha_chtr(28'd0),
	.sin(clk_carrier4));

NCO nco_m5(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k4),
	.pha_chtr(pha_1023k4),
	.sin(clk_1023k4));


//channel 6
NCO nco_c6(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier5),
	.pha_chtr(28'd0),
	.sin(clk_carrier5));

NCO nco_m6(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k5),
	.pha_chtr(pha_1023k5),
	.sin(clk_1023k5));


//channel 7
NCO nco_c7(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier6),
	.pha_chtr(28'd0),
	.sin(clk_carrier6));

NCO nco_m7(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k6),
	.pha_chtr(pha_1023k6),
	.sin(clk_1023k6));


//channel 8
NCO nco_c8(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_carrier7),
	.pha_chtr(28'd0),
	.sin(clk_carrier7));

NCO nco_m8(
	.clk(CLK_100M),
	.rst_n(RESET_N),
	.fre_chtr(fre_1023k7),
	.pha_chtr(pha_1023k7),
	.sin(clk_1023k7));


endmodule
