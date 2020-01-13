module tb_pipeline();
	logic			clk, reset;
	integer f;

	logic [24:0]	instructionOutIF;

	//ID Nets
	logic [127:0]	ALUOutWB;
	logic [24:0]	instructionInWB;
	logic [127:0]	rs1ID, rs2ID, rs3ID, rdID;
	logic [24:0]	instructionOutID;
	
	//EX Nets
	logic [2:0]	forwardEX;
	logic [24:0]	instructionInEX;
	logic [127:0]	rs1EX, rs2EX, rs3EX, rdEX, passthroughEX; 
	logic [127:0]	ALUOutEX;
	logic [24:0]	instructionOutEX;

	//FW Nets
	logic [2:0]	forwardFW;
	logic [127:0]	passthroughFW;

	logic [5:0]		i;
	logic [6:0]		PCount;
	reg [127:0] expected [0:31];

	pipeline U0(.clk (clk),
		.reset (reset),
		.instructionOutIF (instructionOutIF),
		.rs1EX (rs1EX),
		.rs2EX (rs2EX),
		.rs3EX (rs3EX),
		.rdEX (rdEX),
		.instructionOutID (instructionOutID),
		.ALUOutEX (ALUOutEX),
		.forwardEX (forwardEX),
		.instructionOutEX (instructionOutEX),
		.ALUOutWB (ALUOutWB),
		.instructionInWB (instructionInWB),
		.passthroughEX (passthroughEX));
	
	initial begin
		f = $fopen("results.txt", "w+");
		clk = 0;
		reset = 1;
		#3 reset = 0;
	end

	always
		#1 clk = !clk;

	always_ff @(posedge clk) begin
		$fwrite(f, "\n\nCycle %d\n", PCount);
		$fwrite(f, "===Instruction Fetch===\n");
		$fwrite(f, "Instruction: %b\n", instructionOutIF);
		$fwrite(f, "\n===Instruction Decode===\n");
		if (instructionOutID == 0 || (instructionOutID[24:23] == 3 && instructionOutID[19:15] == 0))
			$fwrite(f, "NO OPERATION\n");
		else casez (instructionOutID[24:23])
			2'b0?:	begin
					$fwrite(f, "Load Index: %d\n", instructionOutID[23:21]);
					$fwrite(f, "Immediate: %d\n", instructionOutID[20:5]);
					$fwrite(f, "rd: $%d\n", instructionOutID[4:0]);
				end
			2'b10:	begin
					$fwrite(f, "R4-Opcode: %b\n", instructionOutID[22:20]);
					$fwrite(f, "rd: $%d\n", instructionOutID[4:0]);
					$fwrite(f, "rs3: $%d\n", instructionOutID[19:15]);
					$fwrite(f, "rs2: $%d\n", instructionOutID[14:10]);
					$fwrite(f, "rs1: $%d\n", instructionOutID[9:5]);
				end
			2'b11:	begin
					$fwrite(f, "R3-Opcode: %b\n", instructionOutID[19:15]);
					$fwrite(f, "rd: $%d\n", instructionOutID[4:0]);
					$fwrite(f, "rs2: $%d\n", instructionOutID[14:10]);
					$fwrite(f, "rs1: $%d\n", instructionOutID[9:5]);
				end
		endcase
		$fwrite(f, "\n===Execution===\n");
		if (instructionOutEX == 0 || (instructionOutEX[24:23] == 3 && instructionOutEX[19:15] == 0))
			$fwrite(f, "NO OPERATION\n");
		else casez (instructionOutEX[24:23])
			2'b0?:	begin
					$fwrite(f, "Load Index: %d\n", instructionOutEX[23:21]);
					$fwrite(f, "Immediate = %h\n", instructionOutEX[20:5]);
					$fwrite(f, "rd = %h\n", rdEX);
					if (forwardEX != 0) begin
						if (forwardEX == 4)
							$fwrite(f, "Forward: rd\n");
						else
							$fwrite(f, "Forward: rs%d\n", forwardEX);
						$fwrite(f, "New Value = %h\n", passthroughEX);
					end
				end
			2'b10:	begin
					$fwrite(f, "R4-Opcode: %b\n", instructionOutEX[22:20]);
					$fwrite(f, "rs3 = %h\n", rs3EX);
					$fwrite(f, "rs2 = %h\n", rs2EX);
					$fwrite(f, "rs1 = %h\n", rs1EX);
					if (forwardEX != 0) begin
						if (forwardEX == 4)
							$fwrite(f, "Forward: rd");
						else
							$fwrite(f, "Forward: rs%d\n", forwardEX);
						$fwrite(f, "New Value = %h\n", passthroughEX);
					end
				end
			2'b11:	begin
					$fwrite(f, "R3-Opcode: %b\n", instructionOutEX[19:15]);
					$fwrite(f, "rs2 = %h\n", rs2EX);
					$fwrite(f, "rs1 = %h\n", rs1EX);
					if (forwardEX != 0) begin
						if (forwardEX == 4)
							$fwrite(f, "Forward: rd");
						else
							$fwrite(f, "Forward: rs%d\n", forwardEX);
						$fwrite(f, "New Value = %h\n", passthroughEX);
					end
				end
		endcase
		$fwrite(f, "\n===Write Back===\n");
		if (instructionInWB == 0 || (instructionInWB[24:23] == 3 && instructionInWB[19:15] == 0))
			$fwrite(f, "NO OPERATION\n");
		else
			$fwrite(f, "rd: $%d\nData In = %h\n", instructionInWB[4:0], ALUOutWB);
		if(reset == 1) begin
			PCount <= 0;
		end 
		else begin
			PCount <= PCount + 1;
		end
	end

	initial begin
		#85;
		$fclose(f);
		$readmemh("registers.txt", expected);
		for (i = 0; i < 32; i = i + 1)
			if (expected[i] != U0.ID.RegFile.registers[i])
				$display("ERROR: Register %d does not match expected result!", i);
		$finish;
	end
endmodule

