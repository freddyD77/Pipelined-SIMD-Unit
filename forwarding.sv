module forwarding(instructionEX, instructionWB, rdWB, forward, passthrough);
    input [24:0]			instructionEX, instructionWB;
	input [127:0]			rdWB;
    output logic [2:0]		forward;
	output logic [127:0]	passthrough;
	logic [4:0]				rs1Addr, rs2Addr, rs3Addr, rdAddrEX, rdAddrWB;

    always_comb begin
		rs1Addr = instructionEX[9:5];				//Saving src reg addresses
		rs2Addr = instructionEX[14:10];
		rs3Addr = instructionEX[19:15];
		rdAddrEX = instructionEX[4:0];
		rdAddrWB = instructionWB[4:0];				//Saving dest reg addresses
		forward = 0;								//Default to no hazard detected
		if (!(instructionWB[24:23] == 3 && instructionWB[19:15] == 0) && instructionWB != 0)
													//If regWrite is asserted
			if (rdAddrWB == rs1Addr)				//Set forward to the number of
				forward = 1;						//the src reg causing hazard
			else if (rdAddrWB == rs2Addr)
				forward = 2;
			else if (rdAddrWB == rs3Addr)
				forward = 3;
			else if (rdAddrWB == rdAddrEX && instructionEX[24] == 0)
				forward = 4;
		if (forward != 0)							//If hazard detected, pass rd to ALU
			passthrough = rdWB;
	end
    
endmodule
