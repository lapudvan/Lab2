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
        $display("I am working :)");
        // Test 1: Testing parallel load
        parallelDataIn=8'b10001010; serialDataIn=1; peripheralClkEdge=0; parallelLoad=1; #50
        if(parallelDataOut != 8'b10001010) 
            $display("error in test #1 (parallelDataOut) Expected: 10001010) Got: %d", parallelDataOut);
        if(serialDataOut != 1) 
            $display("error in test #1 (serialDataOut) Expected: 1 Got: %d", serialDataOut);
        // Test 2: Testing Peripheral clk edge
        parallelDataIn=8'b10001010; serialDataIn=1; peripheralClkEdge=1; parallelLoad=0; #50 
        if(parallelDataOut != 8'b00010101) 
            $display("error in test #2 (parallelDataOut) Expected: 00010101) Got: %d", parallelDataOut);
        if(serialDataOut != 0) 
            $display("error in test #2 (serialDataOut) Expected: 0 Got: %d", serialDataOut);
        // Test 3: There is different parellel data in but we are not loading and are clocking.
        parallelDataIn=8'b00010101; serialDataIn=0; peripheralClkEdge=1; parallelLoad=0; #50 
        if(parallelDataOut != 8'b00101010) 
            $display("error in test #3 (parallelDataOut) Expected: 10011010) Got: %d", parallelDataOut);
        if(serialDataOut != 0) 
            $display("error in test #3 (serialDataOut) Expected: 1 Got: %d", serialDataOut);
        // Test 4: Clock edge and Parallel Load are both high
        parallelDataIn=8'b00010110; serialDataIn=0; peripheralClkEdge=1; parallelLoad=1; #50 
        if(parallelDataOut != 8'b00010110) 
            $display("error in test #4 (parallelDataOut) Expected: 00010110) Got: %d", parallelDataOut);
        if(serialDataOut != 0) 
            $display("error in test #4 (serialDataOut) Expected: 0 Got: %d", serialDataOut);
        // Test 5: Clock edge and Parallel Load are both low
        parallelDataIn=8'b00010110; serialDataIn=0; peripheralClkEdge=0; parallelLoad=0; #50 
        if(parallelDataOut != 8'b00010110) 
            $display("error in test #5 (parallelDataOut) Expected: 00010110) Got: %d", parallelDataOut);
        if(serialDataOut != 0) 
            $display("error in test #5 (serialDataOut) Expected: 0 Got: %d", serialDataOut);
        $finish();
    end
endmodule
