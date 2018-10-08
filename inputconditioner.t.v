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
    // Your Test Code
    // Be sure to test each of the three conditioner functions:
    // Synchronization, Debouncing, Edge Detection
    // 200 nanoseconds
    $dumpfile("inputconditioner.vcd");
    $dumpvars();
    pin=0; #200
    pin=1; #25
    pin=0; #200
    pin=1; #200
    pin=0; #25
    pin=1; #200
    pin=0; #200
    // if(conditioned != 1'b0)
    // $display("ADD test 1 - carryout: %h, expected: 0", carryout);
    // end
    $finish();
    end
endmodule
