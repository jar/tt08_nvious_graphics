/*
 * Copyright (c) 2024 James Ross
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_nvious_graphics(
	input  wire [7:0] ui_in,    // Dedicated inputs
	output wire [7:0] uo_out,   // Dedicated outputs
	input  wire [7:0] uio_in,   // IOs: Input path
	output wire [7:0] uio_out,  // IOs: Output path
	output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,      // always 1 when the design is powered, so you can ignore it
	input  wire       clk,      // clock
	input  wire       rst_n     // reset_n - low to reset
);

	// VGA signals
	wire hsync;
	wire vsync;
	wire [5:0] RGB;
	wire video_active;
	wire [9:0] x;
	wire [9:0] y;

	// TinyVGA PMOD
	assign uo_out = {hsync, RGB[0], RGB[2], RGB[4], vsync, RGB[1], RGB[3], RGB[5]};

	// Unused outputs assigned to 0.
	assign uio_out = 0;
	assign uio_oe  = 0;

	// Suppress unused signals warning
	wire _unused_ok = &{ena, uio_in};

	reg show;
	reg [10:0] counter;
	wire [7:0] led = show ? ui_in : counter[8:1];

	// VGA output
	hvsync_generator hvsync_gen(
		.clk(clk),
		.reset(~rst_n),
		.hsync(hsync),
		.vsync(vsync),
		.display_on(video_active),
		.hpos(x),
		.vpos(y)
	);

	wire [5:0] color = 6'b111111;

	wire a0 = y > 7;
	wire a1 = x < y + 392;
	wire a2 = 454 - x > y;
	wire a3 = y < 56;
	wire a4 = x > y + 185;
	wire a5 = x > 247 - y;
	wire a = a0 & a1 & a2 & a3 & a4 & a5;

	wire b0 = a1;
	wire b1 = x < 448;
	wire b2 = 662 - x > y;
	wire b3 = a4;
	wire b4 = x > 399;
	wire b5 = 455 - x < y;
	wire b = b0 & b1 & b2 & b3 & b4 & b5;

	wire c0 = x < y + 184;
	wire c1 = b1;
	wire c2 = 872 - x > y;
	wire c3 = x + 23 > y;
	wire c4 = b4;
	wire c5 = 663 - x < y;
	wire c = c0 & c1 & c2 & c3 & c4 & c5;

	wire d0 = y > 423;
	wire d1 = y > x + 24; 
	wire d2 = c2;
	wire d3 = y < 472;
	wire d4 = x > y - 232;
	wire d5 = c5;
	wire d = d0 & d1 & d2 & d3 & d4 & d5;

	wire e0 = d1;
	wire e1 = x < 240;
	wire e2 = b2;
	wire e3 = d4;
	wire e4 = x > 191;
	wire e5 = b5;
	wire e = e0 & e1 & e2 & e3 & e4 & e5;

	wire f0 = c0;
	wire f1 = e1;
	wire f2 = a2;
	wire f3 = c3;
	wire f4 = e4;
	wire f5 = a5;
	wire f = f0 & f1 & f2 & f3 & f4 & f5;

	wire g0 = y > 215;
	wire g1 = c0;
	wire g2 = b2;
	wire g3 = y < 262;
	wire g4 = f3;
	wire g5 = e5;
	wire g = g0 & g1 & g2 & g3 & g4 & g5;

	wire [9:0] hx0 = x - 512;
	wire [9:0] hy0 = 439 - y;
	wire [9:0] hx1 = 511 - x;
	wire [9:0] hy1 = y - 440;
	wire hq0 = (hy0[4:0] < circle[hx0[4:0]]) & (hx0 < 32) & (hy0 < 32);
	wire hq1 = (hy0[4:0] < circle[hx1[4:0]]) & (hx1 < 32) & (hy0 < 32);
	wire hq2 = (hy1[4:0] < circle[hx0[4:0]]) & (hx0 < 32) & (hy1 < 32);
	wire hq3 = (hy1[4:0] < circle[hx1[4:0]]) & (hx1 < 32) & (hy1 < 32);
	wire h = hq0 | hq1 | hq2 | hq3;

	wire mask = a | b | c | d | e | f | g | h;
	wire [5:0] bg = (x[3] ^ y[3]) ? 6'b010101 : 6'b000000;
	//wire [5:0] bg = mask ? ((x[0] ^ y[0]) ? 6'b010101 : ((x[3] ^ y[3]) ? 6'b010101 : 6'b000000)) : 6'b000000;
	//wire [5:0] fg = (x[0] ^ y[0]) ? 6'b111111 : bg;
	wire [5:0] mg = mask ? ((x[0] ^ y[0]) ? 6'b010101 : bg) : bg;
	wire [5:0] fg = 6'b111111;
	//assign RGB = video_active ? (a ? palette[0] : (b ? palette[1] : (c ? palette[2] : (d ? palette[3] : (e ? palette[4] : (f ? palette[5] : (g ? palette[6] : bg))))))) : 6'b000000;
	assign RGB = video_active ? (((a & led[0]) | (b & led[1]) | (c & led[2]) | (d & led[3]) | (e & led[4]) | (f & led[5]) | (g & led[6]) | (h & led[7])) ? fg : mg) : 6'b000000;
	//assign RGB = video_active ? (a?fg:(b?fg:(c?fg:(d?fg:(e?fg:(f?fg:(g?fg:(h?fg:bg)))))))):6'b000000;

	always @(posedge vsync) begin
		if (~rst_n) begin
			show <= 0;
			counter <= 0;
		end else begin
			show <= show | ui_in[0] | ui_in[1] | ui_in[2] | ui_in[3] | ui_in[4] | ui_in[5] | ui_in[6] | ui_in[7];
			counter <= counter + 1;
		end
	end

	// color palette (RRGGBB)
	reg [5:0] palette[0:7]; // RRGGBB
	initial begin
		palette[0] = 6'b000011;
		palette[1] = 6'b001100;
		palette[2] = 6'b001111;
		palette[3] = 6'b110000;
		palette[4] = 6'b110011;
		palette[5] = 6'b111100;
		palette[6] = 6'b111111;
		palette[7] = 6'b101010;
	end

	reg [4:0] circle[0:31];
	initial begin
		circle[ 0] = 5'd31;
		circle[ 1] = 5'd31;
		circle[ 2] = 5'd31;
		circle[ 3] = 5'd31;
		circle[ 4] = 5'd31;
		circle[ 5] = 5'd31;
		circle[ 6] = 5'd30;
		circle[ 7] = 5'd30;
		circle[ 8] = 5'd30;
		circle[ 9] = 5'd30;
		circle[10] = 5'd29;
		circle[11] = 5'd29;
		circle[12] = 5'd29;
		circle[13] = 5'd28;
		circle[14] = 5'd28;
		circle[15] = 5'd27;
		circle[16] = 5'd27;
		circle[17] = 5'd26;
		circle[18] = 5'd25;
		circle[19] = 5'd24;
		circle[20] = 5'd24;
		circle[21] = 5'd23;
		circle[22] = 5'd22;
		circle[23] = 5'd21;
		circle[24] = 5'd20;
		circle[25] = 5'd18;
		circle[26] = 5'd17;
		circle[27] = 5'd15;
		circle[28] = 5'd13;
		circle[29] = 5'd11;
		circle[30] = 5'd8;
		circle[31] = 5'd0;
	end

endmodule
