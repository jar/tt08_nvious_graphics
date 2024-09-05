`ifndef GRADIENT_ROM_H
`define GRADIENT_ROM_H

// Gradient lookup table

module gradient_rom(
	input wire [6:0] y,
	input wire [1:0] x,
	output wire pixel
);
	reg [3:0] g[127:0];
	assign pixel = g[y][x];

	initial begin
		g[  0] = 4'b0000;
		g[  1] = 4'b0000;
		g[  2] = 4'b0000;
		g[  3] = 4'b0000;
		g[  4] = 4'b0100;
		g[  5] = 4'b0000;
		g[  6] = 4'b0000;
		g[  7] = 4'b0000;
		g[  8] = 4'b0100;
		g[  9] = 4'b0000;
		g[ 10] = 4'b0001;
		g[ 11] = 4'b0000;
		g[ 12] = 4'b0100;
		g[ 13] = 4'b0000;
		g[ 14] = 4'b0001;
		g[ 15] = 4'b0000;
		g[ 16] = 4'b0100;
		g[ 17] = 4'b0000;
		g[ 18] = 4'b0101;
		g[ 19] = 4'b0000;
		g[ 20] = 4'b0100;
		g[ 21] = 4'b0000;
		g[ 22] = 4'b0101;
		g[ 23] = 4'b0000;
		g[ 24] = 4'b0100;
		g[ 25] = 4'b0000;
		g[ 26] = 4'b0101;
		g[ 27] = 4'b0000;
		g[ 28] = 4'b0101;
		g[ 29] = 4'b0000;
		g[ 30] = 4'b0101;
		g[ 31] = 4'b0000;
		g[ 32] = 4'b0101;
		g[ 33] = 4'b0000;
		g[ 34] = 4'b0101;
		g[ 35] = 4'b0010;
		g[ 36] = 4'b0101;
		g[ 37] = 4'b0000;
		g[ 38] = 4'b0101;
		g[ 39] = 4'b0010;
		g[ 40] = 4'b0101;
		g[ 41] = 4'b1000;
		g[ 42] = 4'b0101;
		g[ 43] = 4'b0010;
		g[ 44] = 4'b0101;
		g[ 45] = 4'b1000;
		g[ 46] = 4'b0101;
		g[ 47] = 4'b0010;
		g[ 48] = 4'b0101;
		g[ 49] = 4'b1010;
		g[ 50] = 4'b0101;
		g[ 51] = 4'b0010;
		g[ 52] = 4'b0101;
		g[ 53] = 4'b1010;
		g[ 54] = 4'b0101;
		g[ 55] = 4'b0010;
		g[ 56] = 4'b0101;
		g[ 57] = 4'b1010;
		g[ 58] = 4'b0101;
		g[ 59] = 4'b1010;
		g[ 60] = 4'b0101;
		g[ 61] = 4'b1010;
		g[ 62] = 4'b0101;
		g[ 63] = 4'b1010;
		g[ 64] = 4'b0101;
		g[ 65] = 4'b1010;
		g[ 66] = 4'b0101;
		g[ 67] = 4'b1110;
		g[ 68] = 4'b0101;
		g[ 69] = 4'b1010;
		g[ 70] = 4'b0101;
		g[ 71] = 4'b1110;
		g[ 72] = 4'b0101;
		g[ 73] = 4'b1011;
		g[ 74] = 4'b0101;
		g[ 75] = 4'b1110;
		g[ 76] = 4'b0101;
		g[ 77] = 4'b1011;
		g[ 78] = 4'b0101;
		g[ 79] = 4'b1110;
		g[ 80] = 4'b0101;
		g[ 81] = 4'b1111;
		g[ 82] = 4'b0101;
		g[ 83] = 4'b1110;
		g[ 84] = 4'b0101;
		g[ 85] = 4'b1111;
		g[ 86] = 4'b0101;
		g[ 87] = 4'b1110;
		g[ 88] = 4'b0101;
		g[ 89] = 4'b1111;
		g[ 90] = 4'b0101;
		g[ 91] = 4'b1111;
		g[ 92] = 4'b0101;
		g[ 93] = 4'b1111;
		g[ 94] = 4'b0101;
		g[ 95] = 4'b1111;
		g[ 96] = 4'b0101;
		g[ 97] = 4'b1111;
		g[ 98] = 4'b0101;
		g[ 99] = 4'b1111;
		g[100] = 4'b0111;
		g[101] = 4'b1111;
		g[102] = 4'b0101;
		g[103] = 4'b1111;
		g[104] = 4'b0111;
		g[105] = 4'b1111;
		g[106] = 4'b1101;
		g[107] = 4'b1111;
		g[108] = 4'b0111;
		g[109] = 4'b1111;
		g[110] = 4'b1101;
		g[111] = 4'b1111;
		g[112] = 4'b0111;
		g[113] = 4'b1111;
		g[114] = 4'b1111;
		g[115] = 4'b1111;
		g[116] = 4'b0111;
		g[117] = 4'b1111;
		g[118] = 4'b1111;
		g[119] = 4'b1111;
		g[120] = 4'b0111;
		g[121] = 4'b1111;
		g[122] = 4'b1111;
		g[123] = 4'b1111;
		g[124] = 4'b1111;
		g[125] = 4'b1111;
		g[126] = 4'b1111;
		g[127] = 4'b1111;
	end

endmodule

`endif
