module pipeline(clk, reset, instructionOutIF, rs1EX, rs2EX, rs3EX, rdEX, instructionOutID, ALUOutEX, forwardEX, instructionOutEX, ALUOutWB, instructionInWB, passthroughEX);

	//System inputs
	input		clk, reset;

	//IF Nets
	output logic [24:0]	instructionOutIF;

	//ID Nets
	output logic [127:0]	ALUOutWB;
	output logic [24:0]	instructionInWB;
	logic [24:0]	instructionInID;
	logic [127:0]	rs1ID, rs2ID, rs3ID, rdID;
	output logic [24:0]	instructionOutID;
	
	//EX Nets
	output logic [2:0]	forwardEX;
	logic [24:0]	instructionInEX;
	output logic [127:0]	rs1EX, rs2EX, rs3EX, rdEX;
	output logic [127:0]		passthroughEX; 
	output logic [127:0]	ALUOutEX;
	output logic [24:0]	instructionOutEX;

	//FW Nets
	logic [2:0]	forwardFW;
	logic [127:0]	passthroughFW;

	instruction_fetch IF(clk, reset, instructionOutIF);
	instr_decode ID(clk, reset, ALUOutWB, instructionInID, instructionInWB, rs1ID, rs2ID, rs3ID, rdID, instructionOutID);
	execute EX(rs1EX, rs2EX, rs3EX, rdEX, forwardEX, passthroughEX, instructionInEX, ALUOutEX, instructionOutEX);
	forwarding FW(instructionInEX, instructionInWB, ALUOutWB, forwardFW, passthroughFW);

	always_ff @(posedge clk) begin
		//IF/ID
		instructionInID <= instructionOutIF;
		
		//ID/EX
		instructionInEX <= instructionOutID;
		rs1EX <= rs1ID;
		rs2EX <= rs2ID;
		rs3EX <= rs3ID;
		rdEX <= rdID;
		
		//EX/WB
		instructionInWB <= instructionOutEX;
		ALUOutWB <= ALUOutEX;
	end

	always_comb begin
		forwardEX = forwardFW;
		passthroughEX = passthroughFW;
	end

	
endmodule

