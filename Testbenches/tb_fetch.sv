// This is a very small testbench for you to check that you have the right
// idea for the input/output timing.

// This should not be your only test -- it's simply a basic way to make
// sure you have the right idea.

module tb_fetch();

   logic clk, reset;

   instruction_fetch dut(.clk(clk), .reset(reset));

   initial clk = 0;
   always #1 clk = ~clk;

   initial begin

      // Before first clock edge, initialize
      reset = 1;
      @(posedge clk);
      #1 reset = 0; 
   end // initial begin

   initial begin
      #100;
      $finish;
   end

endmodule // tb_part2_mac
