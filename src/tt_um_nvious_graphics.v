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

	wire [9:0] hx0 = x - 511;
	wire [9:0] hy0 = 439 - y;
	wire [9:0] hx1 = 512 - x;
	wire [9:0] hy1 = y - 440;
	wire hq0 = (hy0[4:0] < (circle[{hx0[4:0],2'b00}][6:2])) & (hx0 < 32) & (hy0 < 32);
	wire hq1 = (hy0[4:0] < (circle[{hx1[4:0],2'b00}][6:2])) & (hx1 < 32) & (hy0 < 32);
	wire hq2 = (hy1[4:0] < (circle[{hx0[4:0],2'b00}][6:2])) & (hx0 < 32) & (hy1 < 32);
	wire hq3 = (hy1[4:0] < (circle[{hx1[4:0],2'b00}][6:2])) & (hx1 < 32) & (hy1 < 32);
	wire h = hq0 | hq1 | hq2 | hq3;

	wire [9:0] sx0 = x - 320;
	wire [9:0] sy0 = 239 - y;
	wire [9:0] sx1 = 319 - x;
	wire [9:0] sy1 = y - 240;
	wire sq0 = (sy0[6:0] < (circle[sx0[6:0]])) & (sx0 < 128) & (sy0 < 128);
	wire sq1 = (sy0[6:0] < (circle[sx1[6:0]])) & (sx1 < 128) & (sy0 < 128);
	wire sq2 = (sy1[6:0] < (circle[sx0[6:0]])) & (sx0 < 128) & (sy1 < 64);//128);
	wire sq3 = (sy1[6:0] < (circle[sx1[6:0]])) & (sx1 < 128) & (sy1 < 64);//128);
	wire s = sq0 | sq1 | sq2 | sq3;

	wire [5:0] black  = 6'b000000;
	wire [5:0] gray   = 6'b010101;
	wire [5:0] cyan   = 6'b101111;
	wire [5:0] red    = 6'b110001;
	wire [5:0] orange = 6'b110101;
	wire [5:0] yellow = 6'b111101;
	wire [5:0] pink   = 6'b110111;
	wire [5:0] dark_purple = 6'b100010;
	wire [5:0] dark_blue = 6'b000001;

	wire mask = a | b | c | d | e | f | g | h;

	wire xor0 = x[0] ^ y[0];
	wire xor1 = (~x[0] & ~y[0]) & (x[1] & y[1]);

	wire bg0 = y < 50;
	wire bg1 = y < 75 & xor1;
	wire bg2 = y < 100 & xor0;
	wire bg3 = y > 99 & y < 125 & xor1;

	// gradient
	wire gsky; // gradient sky
	gradient_rom gradient_sky(
		.y(y[6:0]),
		.x(x[1:0]),
		.pixel(gsky)
	);

	wire gsun; // gradient of sun
	gradient_rom gradient_sun(
		.y(sy1[6:0]),
		.x(x[1:0]),
		.pixel(gsun)
	);

	// background (sky)
	//wire [5:0] bg = (x[3] ^ y[3]) ? gray : black;
	//wire [5:0] bg = bg0 ? dark_purple : (bg1 ? dark_purple : (bg2 ? dark_purple : (bg3 ? dark_purple : black)));
	//wire [5:0] bg = (y < 112) ? (gsun ? black : dark_purple) : (y < 200) ? black : ((y < 256) ? (gsky ? pink : black) : black);
	//wire [5:0] bg = (y < 112) ? (gsun ? black : dark_blue) : ((y > 200 && sy1 < 64) ? (gsun ? 6'b100010 : black) : black);
	//wire [5:0] bg = (y < 128) ? (gsky ? dark_blue : black) : ((y > 200 && sy1 < 64) ? (gsun ? 6'b100010 : dark_blue) : dark_blue);
	wire [5:0] bg = (y < 128) ? (gsky ? dark_blue : black) : ((y > 200 && sy1 < 64) ? (gsun ? 6'b100010 : dark_blue) : (y > sy1) ? black: dark_blue);
	// c-ground (stars)
	wire [5:0] cg = ((x[6]^y[6]) & (x[5:0]==32 & y[5:0]==32) & (y < sy1) ) ? cyan : bg;
	// d-ground (sun)
	wire [5:0] dg = s ? ((sy1 < 128) ? (gsun ? red : orange) : (gsun ? orange : yellow)) : cg;
	// e-ground
	//wire [5:0] eg = mask & xor1 ? cyan : dg;
/*
	wire[10:0] ey = (y > 10'd303) ? (y - 10'd303) : 11'd0;
	wire [2:0] eb = {2'b00, ey[0]} + {2'b00, ey[1]} + {2'b00, ey[2]} + {2'b00, ey[3]} + {2'b00, ey[4]} + {2'b00, ey[5]} + {2'b00, ey[6]} + {2'b00, ey[7]};
	wire [5:0] eg = (ey > 0 & eb == 1) ? pink : dg;
*/
	wire ey0 = y == 10'd304;
	wire ey1 = (y > 10'd304) & (y == 10'd305 + {9'd0, counter[6]});
	wire ey2 = (y > 10'd306) & (y == 10'd307 + {8'd0, counter[6:5]});
	wire ey3 = (y > 10'd310) & (y == 10'd311 + {7'd0, counter[6:4]});
	wire ey4 = (y > 10'd318) & (y == 10'd319 + {6'd0, counter[6:3]});
	wire ey5 = (y > 10'd334) & (y == 10'd335 + {5'd0, counter[6:2]});
	wire ey6 = (y > 10'd366) & (y == 10'd367 + {4'd0, counter[6:1]});
	wire ey7 = (y > 10'd430) & (y == 10'd431 + {3'd0, counter[6:0]});
	wire [5:0] eg = ey0 | ey1 | ey2 | ey3 | ey4 | ey5 | ey6 | ey7 ? pink : dg;
	// foreground
	wire [5:0] fg = cyan;
	assign RGB = video_active ? (((a & led[0]) | (b & led[1]) | (c & led[2]) | (d & led[3]) | (e & led[4]) | (f & led[5]) | (g & led[6]) | (h & led[7])) ? fg : eg) : black;

	always @(posedge vsync) begin
		if (~rst_n) begin
			show <= 0;
			counter <= 0;
		end else begin
			show <= show | ui_in[0] | ui_in[1] | ui_in[2] | ui_in[3] | ui_in[4] | ui_in[5] | ui_in[6] | ui_in[7];
			counter <= counter + 1;
		end
	end

	reg [6:0] circle[0:127];
	initial begin
		circle[  0] = 7'd127;
		circle[  1] = 7'd127;
		circle[  2] = 7'd127;
		circle[  3] = 7'd127;
		circle[  4] = 7'd127;
		circle[  5] = 7'd127;
		circle[  6] = 7'd127;
		circle[  7] = 7'd127;
		circle[  8] = 7'd127;
		circle[  9] = 7'd127;
		circle[ 10] = 7'd127;
		circle[ 11] = 7'd127;
		circle[ 12] = 7'd127;
		circle[ 13] = 7'd127;
		circle[ 14] = 7'd127;
		circle[ 15] = 7'd126;
		circle[ 16] = 7'd126;
		circle[ 17] = 7'd126;
		circle[ 18] = 7'd126;
		circle[ 19] = 7'd126;
		circle[ 20] = 7'd126;
		circle[ 21] = 7'd126;
		circle[ 22] = 7'd125;
		circle[ 23] = 7'd125;
		circle[ 24] = 7'd125;
		circle[ 25] = 7'd125;
		circle[ 26] = 7'd125;
		circle[ 27] = 7'd124;
		circle[ 28] = 7'd124;
		circle[ 29] = 7'd124;
		circle[ 30] = 7'd124;
		circle[ 31] = 7'd123;
		circle[ 32] = 7'd123;
		circle[ 33] = 7'd123;
		circle[ 34] = 7'd123;
		circle[ 35] = 7'd122;
		circle[ 36] = 7'd122;
		circle[ 37] = 7'd122;
		circle[ 38] = 7'd121;
		circle[ 39] = 7'd121;
		circle[ 40] = 7'd121;
		circle[ 41] = 7'd120;
		circle[ 42] = 7'd120;
		circle[ 43] = 7'd120;
		circle[ 44] = 7'd119;
		circle[ 45] = 7'd119;
		circle[ 46] = 7'd119;
		circle[ 47] = 7'd118;
		circle[ 48] = 7'd118;
		circle[ 49] = 7'd117;
		circle[ 50] = 7'd117;
		circle[ 51] = 7'd116;
		circle[ 52] = 7'd116;
		circle[ 53] = 7'd116;
		circle[ 54] = 7'd115;
		circle[ 55] = 7'd115;
		circle[ 56] = 7'd114;
		circle[ 57] = 7'd114;
		circle[ 58] = 7'd113;
		circle[ 59] = 7'd113;
		circle[ 60] = 7'd112;
		circle[ 61] = 7'd111;
		circle[ 62] = 7'd111;
		circle[ 63] = 7'd110;
		circle[ 64] = 7'd110;
		circle[ 65] = 7'd109;
		circle[ 66] = 7'd109;
		circle[ 67] = 7'd108;
		circle[ 68] = 7'd107;
		circle[ 69] = 7'd107;
		circle[ 70] = 7'd106;
		circle[ 71] = 7'd105;
		circle[ 72] = 7'd105;
		circle[ 73] = 7'd104;
		circle[ 74] = 7'd103;
		circle[ 75] = 7'd102;
		circle[ 76] = 7'd102;
		circle[ 77] = 7'd101;
		circle[ 78] = 7'd100;
		circle[ 79] = 7'd99;
		circle[ 80] = 7'd99;
		circle[ 81] = 7'd98;
		circle[ 82] = 7'd97;
		circle[ 83] = 7'd96;
		circle[ 84] = 7'd95;
		circle[ 85] = 7'd94;
		circle[ 86] = 7'd93;
		circle[ 87] = 7'd92;
		circle[ 88] = 7'd91;
		circle[ 89] = 7'd91;
		circle[ 90] = 7'd90;
		circle[ 91] = 7'd88;
		circle[ 92] = 7'd87;
		circle[ 93] = 7'd86;
		circle[ 94] = 7'd85;
		circle[ 95] = 7'd84;
		circle[ 96] = 7'd83;
		circle[ 97] = 7'd82;
		circle[ 98] = 7'd81;
		circle[ 99] = 7'd79;
		circle[100] = 7'd78;
		circle[101] = 7'd77;
		circle[102] = 7'd75;
		circle[103] = 7'd74;
		circle[104] = 7'd73;
		circle[105] = 7'd71;
		circle[106] = 7'd70;
		circle[107] = 7'd68;
		circle[108] = 7'd67;
		circle[109] = 7'd65;
		circle[110] = 7'd63;
		circle[111] = 7'd61;
		circle[112] = 7'd60;
		circle[113] = 7'd58;
		circle[114] = 7'd56;
		circle[115] = 7'd54;
		circle[116] = 7'd51;
		circle[117] = 7'd49;
		circle[118] = 7'd47;
		circle[119] = 7'd44;
		circle[120] = 7'd41;
		circle[121] = 7'd38;
		circle[122] = 7'd35;
		circle[123] = 7'd31;
		circle[124] = 7'd27;
		circle[125] = 7'd22;
		circle[126] = 7'd15;
		circle[127] = 7'd0;
	end
endmodule
