module instr_decode(clk, reset, ALUOutWB, instructionIF, instructionWB, rs1, rs2, rs3, rd, instructionEXE);
	input			clk, reset;
	input [127:0]		ALUOutWB;
	input [24:0]		instructionIF, instructionWB;
	output logic [127:0]	rs1, rs2, rs3, rd;
	output logic [24:0]	instructionEXE;

	memReg RegFile(clk, reset, ALUOutWB, instructionIF, instructionWB, rs1, rs2, rs3, rd);

	always_comb begin
		instructionEXE = instructionIF;
	end
endmodule

module memReg(clk, reset, ALUOutWB, instructionIF, instructionWB, rs1, rs2, rs3, rd);
	input			clk, reset;
	input [127:0]		ALUOutWB;
	input [24:0]		instructionIF, instructionWB;
	output logic [127:0]	rs1, rs2, rs3, rd;
	reg [127:0] registers [0:31];
    logic [5:0]		i;
    
	always_comb begin
		rs1 = registers[instructionIF[9:5]];		//loading from source registers
		rs2 = registers[instructionIF[14:10]];
		rs3 = registers[instructionIF[19:15]];
		rd = registers[instructionIF[4:0]];
	end

	always_ff @(posedge clk) begin
		if(reset == 1) begin
			registers[31] = 0;
			for (i=0; i<31; i=i+1) begin
           			registers[i] <= 0;
    			end
		end 
		else begin
			if ((instructionWB[24:23] != 3 || instructionWB[19:15] != 0) && instructionWB != 0) begin
				registers[instructionWB[4:0]] <= ALUOutWB;//write data to dest if regWrite asserted
			end
		end
	end

endmodule
