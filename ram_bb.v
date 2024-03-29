module ram_bb(

    clk,
    rst_n,
    data,

    clk_1023k,
    wren,

    data_ca,
    data_msg,

    fre_carrier0,
    fre_carrier1,
    fre_carrier2,
    fre_carrier3,
    fre_carrier4,
    fre_carrier5,
    fre_carrier6,
    fre_carrier7,
    pha_1023k0,
    pha_1023k1,
    pha_1023k2,
    pha_1023k3,
    pha_1023k4,
    pha_1023k5,
    pha_1023k6,
    pha_1023k7,
    fre_1023k0,
    fre_1023k1,
    fre_1023k2,
    fre_1023k3,
    fre_1023k4,
    fre_1023k5,
    fre_1023k6,
    fre_1023k7,
	 clk_1k
);


localparam DATA_WIDTH_DELAY = 10;

input clk;
input rst_n;
input [31:0] data;

reg [31:0] delay_ca0;
reg [31:0] delay_ca1;
reg [31:0] delay_ca2;
reg [31:0] delay_ca3;
reg [31:0] delay_ca4;
reg [31:0] delay_ca5;
reg [31:0] delay_ca6;
reg [31:0] delay_ca7;

input [7:0] clk_1023k;
input [23:0] wren;

output [7:0] data_ca;
output [7:0] data_msg;
output reg[31:0] fre_carrier0;
output reg[31:0] fre_carrier1;
output reg[31:0] fre_carrier2;
output reg[31:0] fre_carrier3;
output reg[31:0] fre_carrier4;
output reg[31:0] fre_carrier5;
output reg[31:0] fre_carrier6;
output reg[31:0] fre_carrier7;
output reg[31:0] pha_1023k0;
output reg[31:0] pha_1023k1;
output reg[31:0] pha_1023k2;
output reg[31:0] pha_1023k3;
output reg[31:0] pha_1023k4;
output reg[31:0] pha_1023k5;
output reg[31:0] pha_1023k6;
output reg[31:0] pha_1023k7;
output reg[31:0] fre_1023k0=32'd2746095;
output reg[31:0] fre_1023k1=32'd2746095;
output reg[31:0] fre_1023k2=32'd2746095;
output reg[31:0] fre_1023k3=32'd2746095;
output reg[31:0] fre_1023k4=32'd2746095;
output reg[31:0] fre_1023k5=32'd2746095;
output reg[31:0] fre_1023k6=32'd2746095;
output reg[31:0] fre_1023k7=32'd2746095;
input clk_1k;
reg	[4:0] wraddress_ca;
reg	[4:0] wraddress_msg;
reg [8:0] wraddress_control;
wire	[9:0] rdaddress_ca [7:0];
reg	[9:0] rdaddress_msg [7:0];
reg [8:0] rdaddress_word[7:0];
wire [31:0] word_cache[7:0];

reg	[7:0]	wr_msg_state = 8'h00;
reg	[3:0]	wr_msg_count = 4'd0;
reg	[9:0] counter_ca [7:0];
reg [4:0] counter_msg [7:0];

initial
begin
    wraddress_ca= 5'd0;
    wraddress_msg= 5'd0;
    wraddress_control<=8'd0;

    rdaddress_msg[0] = 10'd0;
    rdaddress_msg[1] = 10'd0;
    rdaddress_msg[2] = 10'd0;
    rdaddress_msg[3] = 10'd0;
    rdaddress_msg[4] = 10'd0;
    rdaddress_msg[5] = 10'd0;
    rdaddress_msg[6] = 10'd0;
    rdaddress_msg[7] = 10'd0;

    rdaddress_word[0] = 9'd511;
    rdaddress_word[1] = 9'd511;
    rdaddress_word[2] = 9'd511;
    rdaddress_word[3] = 9'd511;
    rdaddress_word[4] = 9'd511;
    rdaddress_word[5] = 9'd511;
    rdaddress_word[6] = 9'd511;
    rdaddress_word[7] = 9'd511;


    counter_ca[0] = 10'd0;
    counter_ca[1] = 10'd0;
    counter_ca[2] = 10'd0;
    counter_ca[3] = 10'd0;
    counter_ca[4] = 10'd0;
    counter_ca[5] = 10'd0;
    counter_ca[6] = 10'd0;
    counter_ca[7] = 10'd0;

    counter_msg[0] = 5'd0;
    counter_msg[1] = 5'd0;
    counter_msg[2] = 5'd0;
    counter_msg[3] = 5'd0;
    counter_msg[4] = 5'd0;
    counter_msg[5] = 5'd0;
    counter_msg[6] = 5'd0;
    counter_msg[7] = 5'd0;
end 

ram_ca ram_ca0(
    .data(data),
    .rdaddress(rdaddress_ca[0]),
    .rdclock(clk_1023k[0]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[0]),
    .q(data_ca[0]));

ram_ca ram_ca1(
    .data(data),
    .rdaddress(rdaddress_ca[1]),
    .rdclock(clk_1023k[1]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[1]),
    .q(data_ca[1]));

ram_ca ram_ca2(
    .data(data),
    .rdaddress(rdaddress_ca[2]),
    .rdclock(clk_1023k[2]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[2]),
    .q(data_ca[2]));

ram_ca ram_ca3(
    .data(data),
    .rdaddress(rdaddress_ca[3]),
    .rdclock(clk_1023k[3]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[3]),
    .q(data_ca[3]));

ram_ca ram_ca4(
    .data(data),
    .rdaddress(rdaddress_ca[4]),
    .rdclock(clk_1023k[4]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[4]),
    .q(data_ca[4]));

ram_ca ram_ca5(
    .data(data),
    .rdaddress(rdaddress_ca[5]),
    .rdclock(clk_1023k[5]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[5]),
    .q(data_ca[5]));

ram_ca ram_ca6(
    .data(data),
    .rdaddress(rdaddress_ca[6]),
    .rdclock(clk_1023k[6]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[6]),
    .q(data_ca[6]));

ram_ca ram_ca7(
    .data(data),
    .rdaddress(rdaddress_ca[7]),
    .rdclock(clk_1023k[7]),
    .wraddress(wraddress_ca),
    .wrclock(clk),
    .wren(wren[7]),
    .q(data_ca[7]));



ram_msg ram_msg0(
    .data(data),
    .rdaddress(rdaddress_msg[0]),
    .rdclock(clk_1023k[0]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[8]),
    .q(data_msg[0]));

ram_msg ram_msg1(
    .data(data),
    .rdaddress(rdaddress_msg[1]),
    .rdclock(clk_1023k[1]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[9]),
    .q(data_msg[1]));

ram_msg ram_msg2(
    .data(data),
    .rdaddress(rdaddress_msg[2]),
    .rdclock(clk_1023k[2]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[10]),
    .q(data_msg[2]));

ram_msg ram_msg3(
    .data(data),
    .rdaddress(rdaddress_msg[3]),
    .rdclock(clk_1023k[3]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[11]),
    .q(data_msg[3]));

ram_msg ram_msg4(
    .data(data),
    .rdaddress(rdaddress_msg[4]),
    .rdclock(clk_1023k[4]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[12]),
    .q(data_msg[4]));

ram_msg ram_msg5(
    .data(data),
    .rdaddress(rdaddress_msg[5]),
    .rdclock(clk_1023k[5]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[13]),
    .q(data_msg[5]));

ram_msg ram_msg6(
    .data(data),
    .rdaddress(rdaddress_msg[6]),
    .rdclock(clk_1023k[6]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[14]),
    .q(data_msg[6]));

ram_msg ram_msg7(
    .data(data),
    .rdaddress(rdaddress_msg[7]),
    .rdclock(clk_1023k[7]),
    .wraddress(wraddress_msg),
    .wrclock(clk),
    .wren(wren[15]),
    .q(data_msg[7]));

ram_controlword ram_word0(
    .data(data),
    .rdaddress(rdaddress_word[0]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[16]),
    .q(word_cache[0])
);

ram_controlword ram_word1(
    .data(data),
    .rdaddress(rdaddress_word[1]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[17]),
    .q(word_cache[1])
);


ram_controlword ram_word2(
    .data(data),
    .rdaddress(rdaddress_word[2]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[18]),
    .q(word_cache[2])
);


ram_controlword ram_word3(
    .data(data),
    .rdaddress(rdaddress_word[3]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[19]),
    .q(word_cache[3])
);


ram_controlword ram_word4(
    .data(data),
    .rdaddress(rdaddress_word[4]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[20]),
    .q(word_cache[4])
);


ram_controlword ram_word5(
    .data(data),
    .rdaddress(rdaddress_word[5]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[21]),
    .q(word_cache[5])
);


ram_controlword ram_word6(
    .data(data),
    .rdaddress(rdaddress_word[6]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[22]),
    .q(word_cache[6])
);


ram_controlword ram_word7(
    .data(data),
    .rdaddress(rdaddress_word[7]),
    .rdclock(clk),
    .wraddress(wraddress_control),
    .wrclock(clk),
    .wren(wren[23]),
    .q(word_cache[7])
);

always @(posedge clk or negedge rst_n)begin
    if(~rst_n)begin
        wr_msg_state<=8'h0;
        wraddress_msg<=5'd0;
        wr_msg_count<=4'd0;
    end
    else begin
        case(wr_msg_state)
            8'h01:begin
                if(wren==24'h000100) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
                    if(rdaddress_msg[0]>10'd19 && rdaddress_msg[0]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[0]>10'd339 && rdaddress_msg[0]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[0]>10'd659 && rdaddress_msg[0]<10'd961 )
                        wraddress_msg<=5'd10;
                end
            end
            8'h02:begin
                if(wren==24'h000200) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
                    if(rdaddress_msg[0]>10'd19 && rdaddress_msg[0]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[0]>10'd339 && rdaddress_msg[0]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[0]>10'd659 && rdaddress_msg[0]<10'd961 )
                        wraddress_msg<=5'd10;
                end
            end
            8'h04:begin
                if(wren==24'h000400) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
                    if(rdaddress_msg[2]>10'd19 && rdaddress_msg[2]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[2]>10'd339 && rdaddress_msg[2]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[2]>10'd659 && rdaddress_msg[2]<10'd961 )
                        wraddress_msg<=5'd10;
                end
            end
            8'h08:begin
                if(wren==24'h000800) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
                    if(rdaddress_msg[3]>10'd19 && rdaddress_msg[3]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[3]>10'd339 && rdaddress_msg[3]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[3]>10'd659 && rdaddress_msg[3]<10'd961 )
                        wraddress_msg<=5'd10;
                end
            end
            8'h10:begin
                if(wren==24'h001000) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
					 wraddress_msg<=5'd0;/*
                    if(rdaddress_msg[4]>10'd19 && rdaddress_msg[4]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[4]>10'd339 && rdaddress_msg[4]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[4]>10'd659 && rdaddress_msg[4]<10'd961 )
                        wraddress_msg<=5'd10;*/
                end
            end
            8'h20:begin
                if(wren==24'h002000) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
					 wraddress_msg<=5'd0;/*
                    if(rdaddress_msg[5]>10'd19 && rdaddress_msg[5]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[5]>10'd339 && rdaddress_msg[5]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[5]>10'd659 && rdaddress_msg[5]<10'd961 )
                        wraddress_msg<=5'd10;*/
                end
            end
            8'h40:begin
                if(wren==24'h004000) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
					 wraddress_msg<=5'd0;/*
                    if(rdaddress_msg[6]>10'd19 && rdaddress_msg[6]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[6]>10'd339 && rdaddress_msg[6]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[6]>10'd659 && rdaddress_msg[6]<10'd961 )
                        wraddress_msg<=5'd10;*/
                end
            end
            8'h80:begin
                if(wren==24'h008000) begin
                    wraddress_msg<=wraddress_msg+5'd1;
                    wr_msg_count<=4'd1;
                    wr_msg_state<=8'haa;
                end
                else begin
					 wraddress_msg<=5'd0;/*
                    if(rdaddress_msg[7]>10'd19 && rdaddress_msg[7]<10'd321 )
                        wraddress_msg<=5'd20;
                    if(rdaddress_msg[7]>10'd339 && rdaddress_msg[7]<10'd641 )
                        wraddress_msg<=5'd0;
                    if(rdaddress_msg[7]>10'd659 && rdaddress_msg[7]<10'd961 )
                        wraddress_msg<=5'd10;*/
                end
            end
            8'haa:begin
                wraddress_msg<=wraddress_msg+5'd1;
                if(wr_msg_count==4'd8) begin
                    wr_msg_state<=(wren[15:8]<<1'b1);
                end
                wr_msg_count<=wr_msg_count+4'd1;
            end	
            default:begin
                wr_msg_state<=8'h01;
                wraddress_msg<=5'd0;
                wr_msg_count<=4'd0;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wraddress_ca <= 5'd0;
   end
    else begin
        if((wren&{16'h0,8'hff})!=24'b0) begin
            wraddress_ca <= wraddress_ca + 1'b1;//閸娴兼俺鍤滃鍗炲綁閹
        end
        else begin 
            wraddress_ca <= 5'd0;
        end
    end
end

reg [3:0] control_state=4'd0;
reg [8:0] control_count=9'd0;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wraddress_control<=8'd0;
		  control_count<=9'd0;
		  control_state<=4'd0;
	 end
    else begin
		 case(control_state)
		 4'd0:begin
		  if(wren[23:16]==8'h1) begin
				if(control_count==9'd255) begin
					control_state<=4'd1;
				end
            wraddress_control <= wraddress_control + 9'b1;
				control_count<=control_count+9'b1;
        end
		  else begin
				wraddress_control<=(rdaddress_word[0]>9'd255)?9'd0:9'd256;
				control_count<=9'd0;
		  end
		 end
		 4'd1:begin
		  if(wren[23:16]==8'h2) begin
				if(control_count==9'd255) begin
					control_state<=4'd2;
				end
            wraddress_control <= wraddress_control + 9'b1;
				control_count<=control_count+9'b1;
        end
		  else begin
				wraddress_control<=(rdaddress_word[1]>9'd255)?9'd0:9'd256;
				control_count<=9'd0;
		  end
		 end
		 4'd2:begin
		  if(wren[23:16]==8'h4) begin
				if(control_count==9'd255) begin
					control_state<=4'd3;
				end
            wraddress_control <= wraddress_control + 9'b1;
				control_count<=control_count+9'b1;
        end
		  else begin
				wraddress_control<=(rdaddress_word[2]>9'd255)?9'd0:9'd256;
				control_count<=9'd0;
		  end
		 end
		 4'd3:begin
		  if(wren[23:16]==8'h8) begin
				if(control_count==9'd255) begin
					control_state<=4'd4;
				end
            wraddress_control <= wraddress_control + 9'b1;
				control_count<=control_count+9'b1;
        end
		  else begin
				wraddress_control<=(rdaddress_word[3]>9'd255)?9'd0:9'd256;
				control_count<=9'd0;
		  end
		 end
		 default:begin
		  wraddress_control<=8'd0;
		  control_count<=9'd0;
		  control_state<=4'd0;
		 end
		 endcase	  
    end
end


always @(posedge clk_1023k[0] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[0] <= 10'd1;
        rdaddress_msg[0] <= 10'd0;		  
		  counter_msg[0]<=5'd0;
    end
    else begin
        if (counter_ca[0] == 10'd1023)
            counter_ca[0] <= 10'd1;
        else
            counter_ca[0] <= counter_ca[0] + 1'b1;
       if (rdaddress_ca[0] == 10'd1023) begin
            if(counter_msg[0]>=5'd19) begin
                counter_msg[0]<=5'd0;
                case (rdaddress_msg[0])
                    10'd319:begin
                        rdaddress_msg[0] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[0] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[0] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[0] <= rdaddress_msg[0] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[0]<=counter_msg[0]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[1] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[1] <= 10'd1;
        rdaddress_msg[1] <= 10'd0;		  
		  counter_msg[1]<=5'd0;
    end
    else begin
        if (counter_ca[1] == 10'd1023)
            counter_ca[1] <= 10'd1;
        else
            counter_ca[1] <= counter_ca[1] + 1'b1;
        if (rdaddress_ca[1] == 10'd1023) begin
            if(counter_msg[1]>=5'd19) begin
                counter_msg[1]<=5'd0;
                case (rdaddress_msg[1])
                    10'd319:begin
                        rdaddress_msg[1] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[1] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[1] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[1] <= rdaddress_msg[1] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[1]<=counter_msg[1]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[2] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[2] <= 10'd1;
        rdaddress_msg[2] <= 10'd0;
		  counter_msg[2]<=5'd0;
    end
    else begin
        if (counter_ca[2] == 10'd1023)
            counter_ca[2] <= 10'd1;
        else
            counter_ca[2] <= counter_ca[2] + 1'b1;
        if (rdaddress_ca[2] == 10'd1023) begin
            if(counter_msg[2]>=5'd19) begin
                counter_msg[2]<=5'd0;
                case (rdaddress_msg[2])
                    10'd319:begin
                        rdaddress_msg[2] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[2] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[2] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[2] <= rdaddress_msg[2] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[2]<=counter_msg[2]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[3] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[3] <= 10'd1;
        rdaddress_msg[3] <= 10'd0;
		  counter_msg[3]<=5'd0;
    end
    else begin
        if (counter_ca[3] == 10'd1023)
            counter_ca[3] <= 10'd1;
        else
            counter_ca[3] <= counter_ca[3] + 1'b1;
       if (rdaddress_ca[3] == 10'd1023) begin
            if(counter_msg[3]>=5'd19) begin
                counter_msg[3]<=5'd0;
                case (rdaddress_msg[3])
                    10'd319:begin
                        rdaddress_msg[3] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[3] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[3] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[3] <= rdaddress_msg[3] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[3]<=counter_msg[3]+5'd1;
            end
        end
    end
end
/*
always @(posedge clk_1023k[4] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[4] <= 10'd1;
        rdaddress_msg[4] <= 10'd0;
    end
    else begin
        if (counter_ca[4] == 10'd1023)
            counter_ca[4] <= 10'd1;
        else
            counter_ca[4] <= counter_ca[4] + 1'b1;
		  rdaddress_ca[4] = (counter_ca[4] >=(delay_ca4[9:0]+1))?(counter_ca[4]-delay_ca4[9:0]):(10'd1023-delay_ca4[9:0]+counter_ca[4]);
        if (rdaddress_ca[4] == 10'd1023) begin
            if(counter_msg[4]>=5'd19) begin
                counter_msg[4]<=5'd0;
                case (rdaddress_msg[4])
                    10'd319:begin
                        rdaddress_msg[4] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[4] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[4] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[4] <= rdaddress_msg[4] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[4]<=counter_msg[4]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[5] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[5] <= 10'd1;
        rdaddress_msg[5] <= 10'd0;
    end
    else begin
        if (counter_ca[5] == 10'd1023)
            counter_ca[5] <= 10'd1;
        else
            counter_ca[5] <= counter_ca[5] + 1'b1;
		  rdaddress_ca[5] = (counter_ca[5] >=(delay_ca5[9:0]+1))?(counter_ca[5]-delay_ca5[9:0]):(10'd1023-delay_ca5[9:0]+counter_ca[5]);
        if (rdaddress_ca[5] == 10'd1023) begin
            if(counter_msg[5]>=5'd19) begin
                counter_msg[5]<=5'd0;
                case (rdaddress_msg[5])
                    10'd319:begin
                        rdaddress_msg[5] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[5] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[5] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[5] <= rdaddress_msg[5] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[5]<=counter_msg[5]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[6] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[6] <= 10'd1;
        rdaddress_msg[6] <= 10'd0;
    end
    else begin
        if (counter_ca[6] == 10'd1023)
            counter_ca[6] <= 10'd1;
        else
            counter_ca[6] <= counter_ca[6] + 1'b1;
		  rdaddress_ca[6] = (counter_ca[6] >=(delay_ca6[9:0]+1))?(counter_ca[6]-delay_ca6[9:0]):(10'd1023-delay_ca6[9:0]+counter_ca[6]);
        if (rdaddress_ca[6] == 10'd1023) begin
            if(counter_msg[6]>=5'd19) begin
                counter_msg[6]<=5'd0;
                case (rdaddress_msg[6])
                    10'd319:begin
                        rdaddress_msg[6] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[6] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[6] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[6] <= rdaddress_msg[6] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[6]<=counter_msg[6]+5'd1;
            end
        end
    end
end


always @(posedge clk_1023k[7] or negedge rst_n) begin
    if(~rst_n) begin
        counter_ca[7] <= 10'd1;
        rdaddress_msg[7] <= 10'd0;
    end
    else begin
        if (counter_ca[7] == 10'd1023)
            counter_ca[7] <= 10'd1;
        else
            counter_ca[7] <= counter_ca[7] + 1'b1;
		  rdaddress_ca[7] = (counter_ca[7] >=(delay_ca7[9:0]+1))?(counter_ca[7]-delay_ca7[9:0]):(10'd1023-delay_ca7[9:0]+counter_ca[7]);
        if (rdaddress_ca[7] == 10'd1023) begin
            if(counter_msg[7]>=5'd19) begin
                counter_msg[7]<=5'd0;
                case (rdaddress_msg[7])
                    10'd319:begin
                        rdaddress_msg[7] <= 10'd340;
                    end
                    10'd639:begin
                        rdaddress_msg[7] <= 10'd660;
                    end
                    10'd959:begin
                        rdaddress_msg[7] <= 10'd20;
                    end
                    default:begin
                        rdaddress_msg[7] <= rdaddress_msg[7] + 10'b1;
                    end
                endcase
            end
            else begin
                counter_msg[7]<=counter_msg[7]+5'd1;
            end
        end
    end
end
*/

reg [3:0]rd_w_state=4'd0;
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rdaddress_word[0]<=9'd511;
        rdaddress_word[1]<=9'd511;
        rdaddress_word[2]<=9'd511;
        rdaddress_word[3]<=9'd511;
        rdaddress_word[4]<=9'd511;
        rdaddress_word[5]<=9'd511;
        rdaddress_word[6]<=9'd511;
        rdaddress_word[7]<=9'd511;
		  fre_carrier0<=32'd124607739;
		  fre_carrier1<=32'd124607739;
		  fre_carrier2<=32'd124607739;
		  fre_carrier3<=32'd124607739;
		  fre_carrier4<=32'd124607739;
		  fre_carrier5<=32'd124607739;
		  fre_carrier6<=32'd124607739;
		  fre_carrier7<=32'd124607739;
		  fre_1023k0<=32'd2746095;
		  fre_1023k1<=32'd2746095;
		  fre_1023k2<=32'd2746095;
		  fre_1023k3<=32'd2746095;
		  fre_1023k4<=32'd2746095;
		  fre_1023k5<=32'd2746095;
		  fre_1023k6<=32'd2746095;
		  fre_1023k7<=32'd2746095;
		  pha_1023k0<=32'd0;
		  pha_1023k1<=32'd0;
		  pha_1023k2<=32'd0;
		  pha_1023k3<=32'd0;
		  pha_1023k4<=32'd0;
		  pha_1023k5<=32'd0;
		  pha_1023k6<=32'd0;
		  pha_1023k7<=32'd0;
		  delay_ca0<=32'd0;
		  delay_ca1<=32'd0;
		  delay_ca2<=32'd0;
		  delay_ca3<=32'd0;
		  delay_ca4<=32'd0;
		  delay_ca5<=32'd0;
		  delay_ca6<=32'd0;
		  delay_ca7<=32'd0;
        rd_w_state<=4'd0;
    end
    else begin
        case(rd_w_state)
            4'd0:begin
                if(clk_1k==1'b1) begin
                    rd_w_state<=rd_w_state+4'd1;
                    rdaddress_word[0]<=rdaddress_word[0]+9'd1;
                    rdaddress_word[1]<=rdaddress_word[1]+9'd1;
                    rdaddress_word[2]<=rdaddress_word[2]+9'd1;
                    rdaddress_word[3]<=rdaddress_word[3]+9'd1;
                    rdaddress_word[4]<=rdaddress_word[4]+9'd1;
                    rdaddress_word[5]<=rdaddress_word[5]+9'd1;
                    rdaddress_word[6]<=rdaddress_word[6]+9'd1;
                    rdaddress_word[7]<=rdaddress_word[7]+9'd1;
                end
            end
            4'd1:begin
                rd_w_state<=rd_w_state+4'd1;
                rdaddress_word[0]<=rdaddress_word[0]+9'd1;
                rdaddress_word[1]<=rdaddress_word[1]+9'd1;
                rdaddress_word[2]<=rdaddress_word[2]+9'd1;
                rdaddress_word[3]<=rdaddress_word[3]+9'd1;
                rdaddress_word[4]<=rdaddress_word[4]+9'd1;
                rdaddress_word[5]<=rdaddress_word[5]+9'd1;
                rdaddress_word[6]<=rdaddress_word[6]+9'd1;
                rdaddress_word[7]<=rdaddress_word[7]+9'd1;           
            end
            4'd2:begin
                fre_carrier0<=word_cache[0];
                fre_carrier1<=word_cache[1];
                fre_carrier2<=word_cache[2];
                fre_carrier3<=word_cache[3];
                fre_carrier4<=word_cache[4];
                fre_carrier5<=word_cache[5];
                fre_carrier6<=word_cache[6];
                fre_carrier7<=word_cache[7];
                rd_w_state<=rd_w_state+4'd1;
                rdaddress_word[0]<=rdaddress_word[0]+9'd1;
                rdaddress_word[1]<=rdaddress_word[1]+9'd1;
                rdaddress_word[2]<=rdaddress_word[2]+9'd1;
                rdaddress_word[3]<=rdaddress_word[3]+9'd1;
                rdaddress_word[4]<=rdaddress_word[4]+9'd1;
                rdaddress_word[5]<=rdaddress_word[5]+9'd1;
                rdaddress_word[6]<=rdaddress_word[6]+9'd1;
                rdaddress_word[7]<=rdaddress_word[7]+9'd1;
            end
            4'd3:begin
                fre_1023k0<=word_cache[0];
                fre_1023k1<=word_cache[1];
                fre_1023k2<=word_cache[2];
                fre_1023k3<=word_cache[3];
                fre_1023k4<=word_cache[4];
                fre_1023k5<=word_cache[5];
                fre_1023k6<=word_cache[6];
                fre_1023k7<=word_cache[7];
                rd_w_state<=rd_w_state+4'd1;
                rdaddress_word[0]<=rdaddress_word[0]+9'd1;
                rdaddress_word[1]<=rdaddress_word[1]+9'd1;
                rdaddress_word[2]<=rdaddress_word[2]+9'd1;
                rdaddress_word[3]<=rdaddress_word[3]+9'd1;
                rdaddress_word[4]<=rdaddress_word[4]+9'd1;
                rdaddress_word[5]<=rdaddress_word[5]+9'd1;
                rdaddress_word[6]<=rdaddress_word[6]+9'd1;
                rdaddress_word[7]<=rdaddress_word[7]+9'd1;           
            end
            4'd4:begin
                pha_1023k0<=word_cache[0];
                pha_1023k1<=word_cache[1];
                pha_1023k2<=word_cache[2];
                pha_1023k3<=word_cache[3];
                pha_1023k4<=word_cache[4];
                pha_1023k5<=word_cache[5];
                pha_1023k6<=word_cache[6];
                pha_1023k7<=word_cache[7];
                rd_w_state<=rd_w_state+4'd1;
            end
            4'd5:begin
                delay_ca0<=word_cache[0];
                delay_ca1<=word_cache[1];
                delay_ca2<=word_cache[2];
                delay_ca3<=word_cache[3];
                delay_ca4<=word_cache[4];
                delay_ca5<=word_cache[5];
                delay_ca6<=word_cache[6];
                delay_ca7<=word_cache[7];
                rd_w_state<=4'd0;
            end
        endcase
    end
end

assign rdaddress_ca[0] = (counter_ca[0]>=(delay_ca0[9:0]+1))?(counter_ca[0]-delay_ca0[9:0]):(10'd1023-delay_ca0[9:0]+counter_ca[0]);
assign rdaddress_ca[1] = (counter_ca[1]>=(delay_ca1[9:0]+1))?(counter_ca[1]-delay_ca1[9:0]):(10'd1023-delay_ca1[9:0]+counter_ca[1]);
assign rdaddress_ca[2] = (counter_ca[2]>=(delay_ca2[9:0]+1))?(counter_ca[2]-delay_ca2[9:0]):(10'd1023-delay_ca2[9:0]+counter_ca[2]);
assign rdaddress_ca[3] = (counter_ca[3]>=(delay_ca3[9:0]+1))?(counter_ca[3]-delay_ca3[9:0]):(10'd1023-delay_ca3[9:0]+counter_ca[3]);
 
endmodule
