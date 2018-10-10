//------------------------------------------------------------------------
// Shift Register test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "shiftregister.v"

module testshiftregister();

    reg             clk;
    reg             peripheralClkEdge;
    reg             parallelLoad;
    wire[7:0]       parallelDataOut;
    wire            serialDataOut;
    reg[7:0]        parallelDataIn;
    reg             serialDataIn;

    // Instantiate with parameter width = 8
    shiftregister #(8) dut(.clk(clk),
    		           .peripheralClkEdge(peripheralClkEdge),
    		           .parallelLoad(parallelLoad),
    		           .parallelDataIn(parallelDataIn),
    		           .serialDataIn(serialDataIn),
    		           .parallelDataOut(parallelDataOut),
    		           .serialDataOut(serialDataOut));

    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    initial begin
    	// Your Test Code
        //$dumpfile("shiftregister.vcd");
        //$dumpvars();
        // parallelDataIn=8'b10001010; #5
        // serialDataIn=1; #5
        // peripheralClkEdge=0; #5
        //parallelLoad=1; #50
        $display("i am alive");
        //parallelDataIn=8'b10001010; serialDataIn=1; peripheralClkEdge=1; parallelLoad=0; #50
        //$finish();
    end

endmodule
