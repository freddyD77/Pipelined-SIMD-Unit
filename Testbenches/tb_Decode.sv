module tb_decode();
	logic			clk, reset;
	logic [127:0]		ALUOutWB;
	logic [24:0]		instructionIF, instructionWB;
	logic [127:0]		rs1, rs2, rs3;
	logic [24:0]		instructionEXE;


	instr_decode U0(
		.clk	(clk),
		.reset (reset),
		.ALUOutWB (ALUOutWB),
		.instructionIF (instructionIF), 
		.instructionWB (instructionWB),
		.rs1 (rs1),
		.rs2 (rs2),
		.rs3 (rs3),
		.instructionEXE (instructionEXE));

	initial begin
		clk = 0;
		reset = 0;
		instructionIF = 25'b1100001001011000000101101;	//184b02d
		#5 reset = 1;
		#10 reset = 0;
		#15 ALUOutWB = 4978;
		#15 instructionWB = 25'b1100001001011000000101101;
	end

	always begin
		#1 clk = !clk;
	end

	initial begin
		#100;
		$finish;
	end
	
endmodule
