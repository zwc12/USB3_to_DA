module stream(
	input clk,
	input rst_n,
	input FLAGA,
	input FLAGB,
	input DATA_DIR,
	
	output reg SLCS,
	output reg SLOE,
	output reg SLRD,
	output reg SLWR,
	output reg A1,
	output reg A0,
	output reg [13:0] usb_rd_cnt,
	output reg [31:0] usb_wr_cnt,
	output reg [2:0] usb_rd_state,
	output reg [2:0] usb_wr_state
);

reg FLAGB1;

always@(posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
	//usb interface
		SLCS <= 1'b1;
		SLOE <= 1'b1;
		SLRD <= 1'b1;
		SLWR <= 1'b1;
		A0 <= 1'b1;
		A1 <= 1'b1;
		
	//fifo interface
//		wrreq <= 1'b0;
//		rdreq <= 1'b0;
		
	//status
		usb_rd_state <= 3'b000;
		usb_wr_state <= 3'b000;
		usb_rd_cnt <= 14'd0;
		usb_wr_cnt <= 32'd0;
		
	end
	else begin
		SLCS <= 1'b1;
		SLOE <= 1'b1;
		SLRD <= 1'b1;
		SLWR <= 1'b1;
//		wrreq <= 1'b0;
//		rdreq <= 1'b0;
		if (DATA_DIR==1'b0) begin
			A0 <= 1'b1;
			A1 <= 1'b1;
			FLAGB1 <= FLAGB;
			case (usb_rd_state)
				3'b000, 3'b001, 3'b010, 3'b011: begin
					usb_rd_state <= usb_rd_state + 3'b1;
					usb_rd_cnt <= 14'd0;
				end
				3'b100: begin
					usb_rd_state <= usb_rd_state + 3'b1;
					SLCS <= 1'b0;
				end
				3'b101:	begin
					usb_rd_state <= usb_rd_state + 3'b1;
					SLCS <= 1'b0;
					SLOE <= 1'b0;
				end
				3'b110: begin
					SLCS <= 1'b0;
					SLOE <= 1'b0;
					if (FLAGA==1'b1) begin
						if(FLAGB1==1'b1) begin
							SLRD <= 1'b0;
//							wrreq	<=	1'b1;
							usb_rd_cnt <= usb_rd_cnt + 14'b1;
						end
					end
					else begin
						usb_rd_cnt <= 14'b0;
					end
				end
				default:	begin
					usb_rd_state <= 3'b0;
				end
			endcase
		end
		else begin
			A0 <= 1'b0;
			A1 <= 1'b0;
			case (usb_wr_state)
				3'b000, 3'b001, 3'b010, 3'b011: begin
					usb_wr_state <= usb_wr_state + 3'b1;
					usb_wr_cnt <= 31'd0;
				end
				3'b100: begin
					usb_wr_state <= usb_wr_state + 3'b1;
					SLCS <= 1'b0;
				end
				3'b101:	begin
					usb_wr_state <= usb_wr_state + 3'b1;
					SLCS <= 1'b0;
				end
				3'b110: begin
					SLCS <= 1'b0;
					SLWR <= 1'b0;
					if (FLAGA==1'b1) begin
						SLWR <= 1'b0;
						usb_wr_cnt <= usb_wr_cnt + 32'b1;
					end
					if (usb_wr_cnt >= 1024) begin
						usb_wr_cnt <= 32'b0;
						usb_wr_state <= usb_wr_state + 3'b1;
					end
				end
				default:	begin
					usb_wr_state <= 3'b0;
				end
			endcase
		end
	end
end

endmodule
