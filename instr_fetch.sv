module instruction_fetch (clk, reset, instructionID);
    input 		clk, reset;
    output logic [24:0] instructionID;
    logic [5:0]		PC;

    memoryI my_mem(PC, instructionID);


    always_ff @(posedge clk) begin
        if(reset == 1) begin
	    PC <= 0;
	end 
	else begin
	    PC <= PC + 1;
	end
    end

    
endmodule

module memoryI(PC, instructionID);
    input [5:0]		PC;
    output logic [24:0] instructionID;
    reg [24:0] mem [0:63];
    logic [5:0]		i;

    //initialize instructions with asserts
    initial begin
		for (i=0; i<63; i=i+1) begin
			mem[i] = 0;
		end
		mem[63] = 0;
		$readmemb("instructions.txt", mem); 
    end

    always_comb begin
	instructionID = mem[PC];

	
    end 
endmodule
		







