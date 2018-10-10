`timescale 1 ns / 1 ps
// `include "inputconditioner.v"
// `include "shiftregister.v"

//-----------------------------------------------------------------------------
// Basic building block modules
//-----------------------------------------------------------------------------

// D flip-flop with parameterized bit width (default: 1-bit)
// Parameters in Verilog: http://www.asic-world.com/verilog/para_modules1.html
module dff #( parameter W = 1 )
(
    input trigger,
    input enable,
    input      [W-1:0] d,
    output reg [W-1:0] q
);
    always @(posedge trigger) begin
        if(enable) begin
            q <= d;
        end
    end
endmodule

// JK flip-flop
module jkff1
(
    input trigger,
    input j,
    input k,
    output reg q
);
    always @(posedge trigger) begin
        if(j && ~k) begin
            q <= 1'b1;
        end
        else if(k && ~j) begin
            q <= 1'b0;
        end
        else if(k && j) begin
            q <= ~q;
        end
    end
endmodule

// Two-input MUX with parameterized bit width (default: 1-bit)
module mux2 #( parameter W = 1 )
(
    input[W-1:0]    in0,
    input[W-1:0]    in1,
    input           sel,
    output[W-1:0]   out
);
    // Conditional operator - http://www.verilog.renerta.com/source/vrg00010.htm
    assign out = (sel) ? in1 : in0;
endmodule

//-----------------------------------------------------------------------------
// Midpoint wrapper module
//   Interfaces with switches, buttons, and LEDs on ZYBO board. Allows for two
//   4-bit operands to be stored, and two results to be alternately displayed
//   to the LEDs.
//
//   You must write the FullAdder4bit (in your adder.v) to complete this module.
//   Challenge: write your own interface module instead of using this one.
//-----------------------------------------------------------------------------

module midpoint
(
    input        clk,
    input  [1:0] sw,
    input  [2:0] btn,
    output [3:0] led
);

    wire negedgebtn0;
    wire conditionedsw0;
    wire posedgesw1;
    wire[7:0] pdout;
    wire res_sel;
    wire conditionedbtn0, conditionedsw1;
    wire risingbtn0, risingsw0;
    wire fallingsw0, fallingsw1;
    wire serialDataOut;


    jkff1 src_sel(.trigger(clk), .j(btn[2]), .k(btn[1]), .q(res_sel));
    mux2 #(4) output_select(.in0(pdout[7:4]), .in1(pdout[3:0]), .sel(res_sel), .out(led));

    inputconditioner btn0sig(.clk(clk),
    			     .noisysignal(btn[0]),
			         .conditioned(conditionedbtn0),
			         .positiveedge(risingbtn0),
			         .negativeedge(negedgebtn0));

    inputconditioner sw0sig(.clk(clk),
                      .noisysignal(sw[0]),
                      .conditioned(conditionedsw0),
                      .positiveedge(risingsw0),
                      .negativeedge(fallingsw0));

    inputconditioner sw1sig(.clk(clk),
                       .noisysignal(sw[1]),
                  	   .conditioned(conditionedsw1),
                  	   .positiveedge(posedgesw1),
                  	   .negativeedge(fallingsw1));

    shiftregister #(8) shreg(.clk(clk),
                       .peripheralClkEdge(posedgesw1),
                       .parallelLoad(negedgebtn0),
                       .parallelDataIn(8'b01001101),
                       .serialDataIn(conditionedsw0),
                       .parallelDataOut(pdout),
                       .serialDataOut(serialDataOut));

endmodule
