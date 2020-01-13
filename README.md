# Pipelined-SIMD-Unit
4 stage pipelined processor in Verilog. Stages include the following:

Instruction Fetch Stage:
  An instruction is sampled and the program counter is incremented on every clock. The instruction is passed as output.

Instruction Decode Stage:
  Values of the registers addressed by the instruction and the instruction are passed as output.

Execute Stage:
  The command is decoded from the instruction, and the command is executed, using the values of the addressed registers found   in the pipeline. The result of execution is passed as output.

Writeback Stage:
  The address of the register to be overwritten, and the value being stored are sent to the register file. This stage has no     explicit file, it is instead implemented by the combinational logic found in the execute.sv and Instr_Decode.sv files.
  
Forwarding:
  Although not an explicit stage in the pipeline, the forwarding.sv file handles hazards that result from certain command       sequences. This interacts with multiples stages in the pipeline.
  
The top-level file is Pipeline.sv which connects each of these stages and files. Note that the some parts of this code are not synthesizable. 
