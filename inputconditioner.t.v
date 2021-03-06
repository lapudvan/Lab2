//------------------------------------------------------------------------
// Input Conditioner test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "inputconditioner.v"

module testConditioner();

    reg clk;
    reg pin;
    wire conditioned;
    wire rising;
    wire falling;

    inputconditioner dut(.clk(clk),
    			 .noisysignal(pin),
			 .conditioned(conditioned),
			 .positiveedge(rising),
			 .negativeedge(falling));


    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    initial begin
        $dumpfile("inputconditioner.vcd");
        $dumpvars();
        $dipslay("check gtkwave for test results");
        pin=0; #200
        pin=1; #25
        pin=0; #200
        pin=1; #200
        pin=0; #25
        pin=1; #200
        pin=0; #200
        $finish();
    end
endmodule
