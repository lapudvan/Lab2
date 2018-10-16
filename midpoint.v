`timescale 1 ns / 1 ps
// `include "inputconditioner.v"
// `include "shiftregister.v"
// `include "basicbuildingblocks.v"

//-----------------------------------------------------------------------------
// Midpoint wrapper module
//   Interfaces with switches, buttons, and LEDs on ZYBO board. Allows for two
//   4-bit operands to be stored, and two results to be alternately displayed
//   to the LEDs.
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
    mux2 #(4) output_select(.in0(pdout[3:0]), .in1(pdout[7:4]), .sel(res_sel), .out(led));

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
