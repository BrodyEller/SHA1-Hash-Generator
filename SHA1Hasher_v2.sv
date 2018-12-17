module SHA1Hasher_v2(input [9:0] SW, output [9:0] LEDR, output [7:0] HEX0, output [7:0] HEX1, output [7:0] HEX2, output [7:0] HEX3, output [7:0] HEX4, output [7:0] HEX5);
	assign LEDR = SW;
	
	logic [511:0] block;
	logic [12959:0] H = {32'h67452301, 32'hEFCDAB89, 32'h98BADCFE, 32'h10325476, 32'hC3D2E1F0, 12800'b0};
	logic [2559:0] W;
	sha1_pad end_block(SW, block);
	schedule m_schedule(block, W);
	
	genvar j;
	generate
		for (j=0; j<=79; j++) begin: round_of_compression
			sha1_compress #(j) compress(H[12959 - (32*j) -: 32], H[12959 - (32*(j+1)) -: 32], H[12959 - (32*(j+2)) -: 32], H[12959 - (32*(j+3)) -: 32], H[12959 - (32*(j+4)) -: 32], W[2559 - (32*j) -: 32], H[12959 - (160*(j+1)) -: 160]);
		end
	endgenerate
	
	binary_to_hex_display hex5(H[159 -:4], HEX5);
	binary_to_hex_display hex4(H[155 -:4], HEX4);
	binary_to_hex_display hex3(H[151 -:4], HEX3);
	binary_to_hex_display hex2(H[147 -:4], HEX2);
	binary_to_hex_display hex1(H[143 -:4], HEX1);
	binary_to_hex_display hex0(H[139 -:4], HEX0);
endmodule

module binary_to_hex_display(input logic [3:0] binary, output logic [7:0] display);
	always_comb
		begin
			case(binary)
				0: display = ~8'b00111111;
				1: display = ~8'b00000110;		
				2: display = ~8'b01011011;
				3: display = ~8'b01001111;
				4: display = ~8'b01100110;
				5: display = ~8'b01101101;
				6: display = ~8'b01111101;
				7: display = ~8'b00000111;
				8: display = ~8'b01111111;
				9: display = ~8'b01100111;
				10: display = ~8'b01110111;
				11: display = ~8'b01111100;
				12: display = ~8'b00111001;
				13: display = ~8'b01011110;
				14: display = ~8'b01111001;
				15: display = ~8'b01110001;
			endcase
		end
endmodule

//Pads 10 bits to 512
module sha1_pad(input [9:0] d, output [511:0] m);
	always_comb
		begin
			m = {d, 1'b1, 437'b0, 32'b0, 32'd10};
		end
endmodule

// Perform 1 round of compression
module sha1_compress(input [31:0] h0, input [31:0] h1, input [31:0] h2, input [31:0] h3, input [31:0] h4, input [31:0] w, output [159:0] H);
	parameter j = 0;
	
	logic [31:0] a, b, c, d, e, temp;
			
	always_comb
		begin	
			// Set a, b, c, d, and e to H0 to H4
			a = h0;
			b = h1;
			c = h2;
			d = h3;
			e = h4;
					
			//Perform the operations on temp
			if (j <= 19) begin
				temp = ((b & c) | (~b & d)) + 32'h5A827999 + w + e + rotl(a, 5);
			end else if (j <= 39) begin
				temp = (b ^ c ^ d) + 32'h6ED9EBA1 + w + e + rotl(a, 5);
			end else if (j <= 59) begin
				temp = ((b & c) | (b & d) | (c & d)) + 32'h8F1BBCDC + w + e + rotl(a, 5);
			end else begin
				temp = (b ^ c ^ d) + 32'hCA62C1D6 + w + e + rotl(a, 5);
			end
					
			// Scramble the output
			e = d;
			d = c;
			c = rotl(b, 30);
			b = a;
			a = temp;

			a += h0;
			b += h1;
			c += h2;
			d += h3;
			e += h4;
					
			// Compute the hash H
			H = {a, b, c, d, e};
		end
	
	
	function rotl(input d, input int rot);
		rotl = (d << rot) | (d >> ($bits(d) - rot));
	endfunction
endmodule


module schedule(input [511:0] data, output [2559:0] W);
	logic [2559:0] schedule;
	always_comb
		begin
			for(int j=0; j <= 79; j++) begin
				if (j < 16) begin
					schedule[2559 - (32*j) -: 32] = data[511 - (32*j) -: 32];
				end else begin
					schedule[2559 - (32*j) -: 32] = rotl(schedule[2559 - (32*(j-16)) -: 32] ^ schedule[2559 - (32*(j-14)) -: 32] ^ schedule[2559 - (32*(j-8)) -: 32] ^ schedule[2559 - (32*(j-3)) -: 32], 1);
				end
			end
			W = schedule;
		end
	function rotl(input d, input int rot);
		rotl = (d << rot) | (d >> ($bits(d) - rot));
	endfunction
endmodule
