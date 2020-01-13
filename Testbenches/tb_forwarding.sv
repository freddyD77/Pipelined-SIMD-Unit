module tb_forwarding();
    logic [24:0]	instructionEX, instructionWB;
	logic 			clk;
	logic [127:0]	rdWB;
    logic [1:0]		forward;
	logic [127:0]	passthrough;
	logic [4:0]		rs1Addr, rs2Addr, rs3Addr, rdAddr;
	
	forwarding U0(
	.instructionEX (instructionEX),
	.instructionWB (instructionWB),
	.rdWB (rdWB),
	.forward (forward),
	.passthrough (passthrough));

    initial begin
	clk = 0;
	rdWB = 127'h00000006000000060000000600000006;
	//Hazardless test
	instructionWB = 25'b1100000001011001000111001; // $25 = $17 + $12 
	instructionEX = 25'b1100010001100111110101000; //$8 = $29 - $19
	#25	//RS1 test
	instructionWB = 25'b1100000111011001000111001; // $25 = $17 MAX $12 
	instructionEX = 25'b1100001000010011100101000; //$8 = $9 MIN $25 (rs1)
	#25	//RS2 test
	instructionWB = 25'b1100001011001000110000001; // $1 = $4 | $12
	instructionEX = 25'b1100000100000010110000100; //$4 = $1 (rs2) & $12
	#25	//RS3 test
	instructionWB = 25'b1100001110001000110000001; // $1 = $4 ROTW $12
	instructionEX = 25'b1010000001000101000011110; //$30 = $1 (rs3) * $2 + $16
    end

    always begin
	#1 clk = !clk;
	rs1Addr = instructionEX[9:5];				//Saving src reg addresses
	rs2Addr = instructionEX[14:10];
	rs3Addr = instructionEX[19:15];
	rdAddr = instructionWB[4:0];
    end

    initial begin
	#100;
	$finish;
    end
    
endmodule