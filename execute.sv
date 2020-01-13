module execute(rs1, rs2, rs3, rd, forward, passthrough, instructionID, ALUOut, instructionWB);
    input [2:0]		forward;
    input [24:0]	instructionID;
    input [127:0]	rs1, rs2, rs3, rd, passthrough; 
    output logic [127:0] ALUOut;
    output logic [24:0]	instructionWB;
    logic [127:0] rs1var, rs2var, rs3var, rdvar;
    logic [2:0]		r4ALUop, load_index;
    logic [4:0]		r3ALUop;
    logic [1:0]		mode;
    logic [15:0]	immediate;
	logic [3:0]		imm4;

    ALU my_ALU(rs1var, rs2var, rs3var, ALUOut, r3ALUop, r4ALUop, mode, rdvar, load_index, immediate, imm4);


    always_comb begin
		r3ALUop = instructionID[22:15];
		r4ALUop = instructionID[22:20];
		mode = instructionID[24:23];
		instructionWB = instructionID;
		load_index = instructionID[23:21];
		immediate = instructionID[20:5];
		imm4 = instructionID[13:10];
		rs1var = rs1;
		rs2var = rs2;
		rs3var = rs3;
		rdvar = rd;
		case (forward)
			1: rs1var = passthrough;
			2: rs2var = passthrough;
			3: rs3var = passthrough;
			4: rdvar = passthrough;
		endcase
    end

    
endmodule

module ALU(rs1, rs2, rs3, result, r3ALUop, r4ALUop, mode, rd, load_index, immediate, imm4);
    input [4:0]			r3ALUop;
    input [2:0]			r4ALUop;
    input [1:0]			mode;
    input [127:0]		rs1, rs2, rs3, rd;
	input [3:0]			imm4;
    output logic signed [127:0] 	result;
    logic [5:0]			i;
    logic [15:0]			temp16a, temp16b, temp16c, temp16d;
    logic [7:0]			temp8a, temp8b, temp8c, temp8d;
    logic [3:0]			temp4a, temp4b, temp4c, temp4d;

    input [2:0]		load_index;
    input [15:0]	immediate;

    
    localparam signed [33:0] MAXVAL = 34'd32767; 
    localparam signed [33:0] MINVAL = -34'd32768;

    localparam signed [33:0] MAXVAL2 = 34'd2147483647; 
    localparam signed [33:0] MINVAL2 = -34'd2147483648;

    localparam signed [64:0] MAXVAL3 = 65'd2147483647;
    localparam signed [64:0] MAXVAL4 = 65'd4294967296; 
    

    always_comb begin
	case(mode)
	    2'b10:
		case(r4ALUop)
		    3'b000:	for (i=0; i<4; i=i+1) begin 	//Signed Integer Multiply-Add-Low 	
				    if(($signed(rs3[((2*i))*16 +:16]) * $signed(rs2[((2*i))*16 +:16])) + $signed(rs1[i*32 +:32]) > MAXVAL2)
				    	result[i*32 +:32] = 32'd2147483647;
				    else if(($signed(rs3[((2*i))*16 +:16]) * $signed(rs2[((2*i))*16 +:16])) + $signed(rs1[i*32 +:32]) < MINVAL2)
				    	result[i*32 +:32] = -32'd2147483648;
				    else
				    	result[i*32 +:32] = ((rs3[((2*i))*16 +:16]) * (rs2[((2*i))*16 +:16])) + $signed(rs1[i*32 +:32]);
				end
		    3'b001:	for (i=0; i<4; i=i+1) begin 	//Signed Integer Multiply-Add-High	
				    if(($signed(rs3[((2*i)+1)*16 +:16]) * $signed(rs2[((2*i)+1)*16 +:16])) + $signed(rs1[i*32 +:32]) > MAXVAL2)
				    	result[i*32 +:32] = 32'd2147483647;
				    else if(($signed(rs3[((2*i)+1)*16 +:16]) * $signed(rs2[((2*i)+1)*16 +:16])) + $signed(rs1[i*32 +:32]) < MINVAL2)
				    	result[i*32 +:32] = -32'd2147483648;
				    else
				    	result[i*32 +:32] = ((rs3[((2*i)+1)*16 +:16]) * (rs2[((2*i)+1)*16 +:16])) + $signed(rs1[i*32 +:32]);
				end
		    3'b010:	for (i=0; i<4; i=i+1) begin 	//Signed Integer Multiply-Sub-Low 	
				    if($signed(rs1[i*32 +:32]) - ($signed(rs3[((2*i))*16 +:16]) * $signed(rs2[((2*i))*16 +:16]))  > MAXVAL2)
				    	result[i*32 +:32] = 32'd2147483647;
				    else if($signed(rs1[i*32 +:32]) - ($signed(rs3[((2*i))*16 +:16]) * $signed(rs2[((2*i))*16 +:16])) < MINVAL2)
				    	result[i*32 +:32] = -32'd2147483648;
				    else
				    	result[i*32 +:32] = $signed(rs1[i*32 +:32]) - signed'(32'(rs3[((2*i))*16 +:16]) * 32'(rs2[((2*i))*16 +:16]));
				end
		    3'b011:	for (i=0; i<4; i=i+1) begin 	//Signed Integer Multiply-Sub-High 	
				    if($signed(rs1[i*32 +:32]) - ($signed(rs3[((2*i)+1)*16 +:16]) * $signed(rs2[((2*i)+1)*16 +:16]))  > MAXVAL2)
				    	result[i*32 +:32] = 32'd2147483647;
				    else if($signed(rs1[i*32 +:32]) - ($signed(rs3[((2*i)+1)*16 +:16]) * $signed(rs2[((2*i)+1)*16 +:16])) < MINVAL2)
				    	result[i*32 +:32] = -32'd2147483648;
				    else
				    	result[i*32 +:32] = $signed(rs1[i*32 +:32]) - signed'(32'(rs3[((2*i)+1)*16 +:16]) * 32'(rs2[((2*i)+1)*16 +:16]));
				end
		    3'b100:	for (i=0; i<2; i=i+1) begin 	//Signed Long Multiply-Add-Low 	
				    if(($signed(rs3[((2*i))*32 +:32]) * $signed(rs2[((2*i))*32 +:32])) + $signed(rs1[i*64 +:64]) > (MAXVAL3 * MAXVAL4)-1)
				    	result[i*64 +:64] = (MAXVAL3 * MAXVAL4)-1;
				    else if(($signed(rs3[((2*i))*32 +:32]) * $signed(rs2[((2*i))*32 +:32])) + $signed(rs1[i*64 +:64]) < -(MAXVAL3 * MAXVAL4))
				    	result[i*64 +:64] = -(MAXVAL3 * MAXVAL4);
				    else
				    	result[i*64 +:64] = ((rs3[((2*i))*32 +:32]) * (rs2[((2*i))*32 +:32])) + $signed(rs1[i*64 +:64]);
				end
		    3'b101:	for (i=0; i<2; i=i+1) begin 	//Signed Long Multiply-Add-High 	
				    if(($signed(rs3[((2*i)+1)*32 +:32]) * $signed(rs2[((2*i)+1)*32 +:32])) + $signed(rs1[i*64 +:64]) > (MAXVAL3 * MAXVAL4)-1)
				    	result[i*64 +:64] = (MAXVAL3 * MAXVAL4)-1;
				    else if(($signed(rs3[((2*i)+1)*32 +:32]) * $signed(rs2[((2*i)+1)*32 +:32])) + $signed(rs1[i*64 +:64]) < -(MAXVAL3 * MAXVAL4))
				    	result[i*64 +:64] = -(MAXVAL3 * MAXVAL4);
				    else
				    	result[i*64 +:64] = ((rs3[((2*i)+1)*32 +:32]) * (rs2[((2*i)+1)*32 +:32])) + $signed(rs1[i*64 +:64]);
				end
		    3'b110:	for (i=0; i<2; i=i+1) begin 	//Signed Long Multiply-Sub-Low 	
				    if($signed(rs1[i*64 +:64]) - ($signed(rs3[((2*i))*32 +:32]) * $signed(rs2[((2*i))*32 +:32])) > (MAXVAL3 * MAXVAL4)-1)
				    	result[i*64 +:64] = (MAXVAL3 * MAXVAL4)-1;
				    else if($signed(rs1[i*64 +:64]) - ($signed(rs3[((2*i))*32 +:32]) * $signed(rs2[((2*i))*32 +:32])) < -(MAXVAL3 * MAXVAL4))
				    	result[i*64 +:64] = -(MAXVAL3 * MAXVAL4);
				    else
				    	result[i*64 +:64] = $signed(rs1[i*64 +:64]) - signed'(64'(rs3[((2*i))*32 +:32]) * 64'(rs2[((2*i))*32 +:32]));
				end
		    3'b111:	for (i=0; i<2; i=i+1) begin 	//Signed Long Multiply-Sub-High 	
				    if($signed(rs1[i*64 +:64]) - ($signed(rs3[((2*i)+1)*32 +:32]) * $signed(rs2[((2*i)+1)*32 +:32])) > (MAXVAL3 * MAXVAL4)-1)
				    	result[i*64 +:64] = (MAXVAL3 * MAXVAL4)-1;
				    else if($signed(rs1[i*64 +:64]) - ($signed(rs3[((2*i)+1)*32 +:32]) * $signed(rs2[((2*i)+1)*32 +:32])) < -(MAXVAL3 * MAXVAL4))
				    	result[i*64 +:64] = -(MAXVAL3 * MAXVAL4);
				    else
				    	result[i*64 +:64] = $signed(rs1[i*64 +:64]) - signed'(64'(rs3[((2*i)+1)*32 +:32]) * 64'(rs2[((2*i)+1)*32 +:32]));
				end
		    default: 	result = 0;
		endcase

	    2'b11:
		case(r3ALUop)
		    5'b00001:	for (i=0; i<4; i=i+1) begin 	//A
				    result[i*32 +:32] = rs1[i*32 +:32] + rs2[i*32 +:32];
				end
		    5'b00010: 	for (i=0; i<8; i=i+1) begin	//AH
		    		    result[i*16 +:16] = rs1[i*16 +:16] + rs2[i*16 +:16];
				end
		    5'b00011: 	for (i=0; i<8; i=i+1) begin	//AHS	needs more testing
				    if($signed(rs1[i*16 +:16]) + $signed(rs2[i*16 +:16]) > $signed(MAXVAL))
				    	result[i*16 +:16] = 16'd32767;
				    else if($signed(rs1[i*16 +:16]) + $signed(rs2[i*16 +:16]) < $signed(MINVAL))
				    	result[i*16 +:16] = -16'd32768;
				    else
				    	result[i*16 +:16] = rs1[i*16 +:16] + rs2[i*16 +:16];
				end
		    5'b00100:	begin 				//AND
				    result = rs1 & rs2;
				end
		    5'b00101:	for (i=0; i<4; i=i+1) begin	//BCW
				    result[i*32 +:32] = rs1[31:0];
				end
		    5'b00110:	begin				//CLZ
			    	    
				    if(rs1[31:0] == 0)
					result[31:0] = 32;
				    else begin
					result[4] = (rs1[31:16] == 16'b0);
					temp16a     = result[4] ? rs1[15:0] : rs1[31:16];
					result[3] = (temp16a[15:8] == 8'b0);
					temp8a      = result[3] ? temp16a[7:0] : temp16a[15:8];
					result[2] = (temp8a[7:4] == 4'b0);
					temp4a      = result[2] ? temp8a[3:0] : temp8a[7:4];
					result[1] = (temp4a[3:2] == 2'b0);
					result[0] = result[1] ? ~temp4a[1] : ~temp4a[3];
					result[31:5] = 0;
				    end

				    if(rs1[63:32] == 0)
					result[63:32] = 32;
				    else begin
					result[36] = (rs1[63:48] == 16'b0);
					temp16b     = result[36] ? rs1[47:32] : rs1[63:48];
					result[35] = (temp16b[15:8] == 8'b0);
					temp8b      = result[35] ? temp16b[7:0] : temp16b[15:8];
					result[34] = (temp8b[7:4] == 4'b0);
					temp4b      = result[34] ? temp8b[3:0] : temp8b[7:4];
					result[33] = (temp4b[3:2] == 2'b0);
					result[32] = result[33] ? ~temp4b[1] : ~temp4b[3];
					result[63:37] = 0;
				    end

				    if(rs1[95:64] == 0)
					result[95:64] = 32;
				    else begin
					result[68] = (rs1[95:80] == 16'b0);
					temp16c     = result[68] ? rs1[79:64] : rs1[95:80];
					result[67] = (temp16c[15:8] == 8'b0);
					temp8c      = result[67] ? temp16c[7:0] : temp16c[15:8];
					result[66] = (temp8c[7:4] == 4'b0);
					temp4c      = result[66] ? temp8c[3:0] : temp8c[7:4];
					result[65] = (temp4c[3:2] == 2'b0);
					result[64] = result[65] ? ~temp4c[1] : ~temp4c[3];
					result[95:69] = 0;
				    end

				    if(rs1[127:96] == 0)
					result[127:96] = 32;
				    else begin
					result[100] = (rs1[127:112] == 16'b0);
					temp16d     = result[100] ? rs1[111:96] : rs1[127:112];
					result[99] = (temp16d[15:8] == 8'b0);
					temp8d      = result[99] ? temp16d[7:0] : temp16d[15:8];
					result[98] = (temp8d[7:4] == 4'b0);
					temp4d      = result[98] ? temp8d[3:0] : temp8d[7:4];
					result[97] = (temp4d[3:2] == 2'b0);
					result[96] = result[97] ? ~temp4d[1] : ~temp4d[3];
					result[127:101] = 0;
				    end
				    
				end
		    5'b00111:	begin				//MAX
				    for (i=0; i<4; i=i+1) begin
					if($signed(rs1[i*32 +:32]) > $signed(rs2[i*32 +:32]))	
				    	    result[i*32 +:32] = rs1[i*32 +:32];
					else
					    result[i*32 +:32] = rs2[i*32 +:32];
				    end
				end
		    5'b01000:	begin				//MIN
				    for (i=0; i<4; i=i+1) begin
					if($signed(rs1[i*32 +:32]) < $signed(rs2[i*32 +:32]))	
				    	    result[i*32 +:32] = rs1[i*32 +:32];
					else
					    result[i*32 +:32] = rs2[i*32 +:32];
				    end
				end
		    5'b01001:	for (i=0; i<4; i=i+1) begin	//MSGN
				    if(rs2[i*32 +:32] == 0)
					result[i*32 +:32] = 0;
				    else if(rs2[(i*32)+31] == 1) begin
					if(rs1[i*32 +:32] == -32'd2147483648)
					     result[i*32 +:32] = 32'd2147483647;	
				    	else
					     result[i*32 +:32] = $signed(rs1[i*32 +:32])*-1;
				    end
				    else
					result[i*32 +:32] = rs1[i*32 +:32];
				end
		    5'b01010:	begin				//MPYU
				    for (i=0; i<4; i=i+1) begin 	
				    	result[i*32 +:32] = rs1[2*i*16 +:16] * rs2[2*i*16 +:16];
				    end
				end
		    5'b01011:	begin				//OR
				    result = rs1 | rs2;
				end
		    5'b01100:	begin				//POPCNTH
				    for (i=0; i<8; i=i+1) begin
					result[(i*16) +:16] = rs1[(i*16)]+rs1[(i*16)+1]+rs1[(i*16)+2]+rs1[(i*16)+3]+rs1[(i*16)+4]+rs1[(i*16)+5]+
								rs1[(i*16)+6]+rs1[(i*16)+7]+rs1[(i*16)+8]+rs1[(i*16)+9]+rs1[(i*16)+10]+
								rs1[(i*16)+11]+rs1[(i*16)+12]+rs1[(i*16)+13]+rs1[(i*16)+14]+rs1[(i*16)+15];
				    end
				end
		    5'b01101:	begin 				//ROT
				    result = (rs1 >> rs2[6:0]) | (rs1 << (128-rs2[6:0]));
				end
		    5'b01110:	begin				//ROTW
				    for (i=0; i<4; i=i+1) begin 	
				    	result[i*32 +:32] = (rs1[i*32 +:32] >> rs2[i*32 +:5])
					    | (rs1[i*32 +:32] << (32-rs2[i*32 +:5]));
				    end
				end
		    5'b01111:	begin				//SHLHI
				    for (i=0; i<8; i=i+1) begin 	
				    	result[i*16 +:16] = rs1[i*16 +:16] << imm4;
				    end
				end
		    5'b10000:	for (i=0; i<8; i=i+1) begin 	//SFH	
				    result[i*16 +:16] = rs2[i*16 +:16] - rs1[i*16 +:16];
				end
		    5'b10001:	for (i=0; i<4; i=i+1) begin 	//SFW	
				    result[i*32 +:32] = rs2[i*32 +:32] - rs1[i*32 +:32];
				end
		    5'b10010:	for (i=0; i<8; i=i+1) begin 	//SFHS	needs 
				    if($signed(rs2[i*16 +:16]) - $signed(rs1[i*16 +:16]) > $signed(MAXVAL))
				    	result[i*16 +:16] = 16'd32767;
				    else if($signed(rs2[i*16 +:16]) - $signed(rs1[i*16 +:16]) < $signed(MINVAL))
				    	result[i*16 +:16] = -16'd32768;
				    else
				    	result[i*16 +:16] = rs2[i*16 +:16] - rs1[i*16 +:16];
				end
		    5'b10011:	begin				//XOR
				    result = rs1 ^ rs2;
				end			

		    default: 	result = 0;
		endcase


	    default:	begin
				if(load_index == 0) begin
				    result[0 +:16] = immediate;
				    result[16 +:112] = rd[127:16];
				end
				if(load_index == 1) begin
				    result[16 +:16] = immediate;
				    result[32 +:96] = rd[127:32];
				    result[0 +:16] = rd[15:0];
				end
				if(load_index == 2) begin
				    result[32 +:16] = immediate;
				    result[48 +:80] = rd[127:48];
				    result[0 +:32] = rd[31:0];
				end
				if(load_index == 3) begin
				    result[48 +:16] = immediate;
				    result[64 +:64] = rd[127:64];
				    result[0 +:48] = rd[47:0];
				end
				if(load_index == 4) begin
				    result[64 +:16] = immediate;
				    result[80 +:48] = rd[127:80];
				    result[0 +:64] = rd[63:0];
				end
				if(load_index == 5) begin
				    result[80 +:16] = immediate;
				    result[96 +:32] = rd[127:96];
				    result[0 +:80] = rd[79:0];
				end
				if(load_index == 6) begin
				    result[96 +:16] = immediate;
				    result[112 +:16] = rd[127:112];
				    result[0 +:96] = rd[95:0];
				end
				if(load_index == 7) begin
				    result[112 +:16] = immediate;
				    result[0 +:112] = rd[111:0];
				end
			end

	endcase
    end 
endmodule




