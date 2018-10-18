//------------------------------------------------------------------------
// SPI Memory
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "inputconditioner.v"
`include "shiftregister.v"
`include "basicbuildingblocks.v"
`include "finitestatemachine.v"
`include "datamemory.v"

module spiMemory
(
    input           clk,        // FPGA clock
    input           sclk_pin,   // SPI clock
    input           cs_pin,     // SPI chip select
    output          miso_pin,   // SPI master in slave out
    input           mosi_pin   // SPI master out slave in
);

    wire conditioned_mosi, rising_sclk, falling_sclk, conditioned_cs;           // wires from input conditioner
    wire rising_mosi, falling_mosi, conditioned_sclk, rising_cs, falling_cs;    // unused wires
    wire [7:0] datamem_out, shiftreg_out;
    wire [6:0] address;
    wire serial_out, dff_out;
    wire MISO_BUFE, DM_WE, ADDR_WE, SR_WE;

    inputconditioner mosi_cond(.clk(clk),
                    .noisysignal(mosi_pin),
                    .conditioned(conditioned_mosi),
                    .positiveedge(rising_mosi),         // unused
                    .negativeedge(falling_mosi));       // unused

    inputconditioner sclk_cond(.clk(clk),
                    .noisysignal(sclk_pin),
                    .conditioned(conditioned_sclk),     // unused
                    .positiveedge(rising_sclk),
                    .negativeedge(falling_sclk));

    inputconditioner cs_cond(.clk(clk),
                    .noisysignal(cs_pin),
                    .conditioned(conditioned_cs),
                    .positiveedge(rising_cs),           // unused
                    .negativeedge(falling_cs));         // unused

    shiftregister #(8) shiftreg(.clk(clk),
                    .peripheralClkEdge(rising_sclk),
                    .parallelLoad(SR_WE),
                    .parallelDataIn(datamem_out),
                    .serialDataIn(conditioned_mosi),
                    .parallelDataOut(shiftreg_out),
                    .serialDataOut(serial_out));

    datamemory datamem(.clk(clk),
                    .dataOut(datamem_out),
                    .address(address),
                    .writeEnable(DM_WE),
                    .dataIn(shiftreg_out));

    dff #(7) addrlatch(.trigger(clk),
                    .enable(ADDR_WE),
                    .d(shiftreg_out[7:1]),
                    .q(address));

    dff #(1) miso_dff(.trigger(clk),
                    .enable(falling_sclk),
                    .d(serial_out),
                    .q(dff_out));

    tri_buf miso_buf(.a(dff_out),
                    .b(miso_pin),
                    .enable(MISO_BUFE));

    finitestatemachine fsm(.rising_sclk(rising_sclk),
                    .conditioned_cs(conditioned_cs),
                    .shiftreg_out(shiftreg_out[0]),
                    .miso_bufe(MISO_BUFE),
                    .dm_we(DM_WE),
                    .addr_we(ADDR_WE),
                    .sr_we(SR_WE));

endmodule
