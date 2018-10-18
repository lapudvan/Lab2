//------------------------------------------------------------------------
// SPI Memory test bench
//------------------------------------------------------------------------
`timescale 1 ns / 1 ps
`include "spimemory.v"

module testSPIMemory();

    reg clk;
    reg sclk_pin;
    reg cs_pin;
    wire miso_pin;
    reg mosi_pin;

    spiMemory dut(.clk(clk),
    			 .sclk_pin(sclk_pin),
			 .cs_pin(cs_pin),
			 .miso_pin(miso_pin),
			 .mosi_pin(mosi_pin));

    // Generate clock (50MHz)
    initial clk=0;
    always #10 clk=!clk;    // 50MHz Clock

    initial begin
        $dumpfile("spiMemory.vcd");
        $dumpvars();

        cs_pin = 1; mosi_pin = 0;                               // initialize
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        // GOOD WRITE TEST -----------------------------------------------------
        $display("GOOD WRITE TEST STARTING");

        cs_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip select
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // addr
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 1 getting address", dut.fsm.state);

        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // write

        $display("state: %d, expected: 2 got address", dut.fsm.state);
        $display("address: %b, expected: 0110001", dut.addrlatch.q);
        $display("r/w? %b, expected: 0 write", dut.fsm.shiftreg_out);

        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // data
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000

        $display("state: %d, expected: 3 writing", dut.fsm.state);
        $display("data memory: %b, expected: 10110010", dut.datamem.dataOut);

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip deselect
        $display("state: %d, expected: 6 done", dut.fsm.state);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        // GOOD READ TEST ------------------------------------------------------
        $display("GOOD READ TEST STARTING");

        cs_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip select
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // addr
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 1 getting address", dut.fsm.state);

        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // read

        $display("state: %d, expected: 2 got address", dut.fsm.state);
        $display("address: %b, expected: 0110001", dut.addrlatch.q);
        $display("r/w? %b, expected: 1 read", dut.fsm.shiftreg_out);

        sclk_pin = 0; #1000 sclk_pin = 1; #1000                 // wait for spi to retrieve data
        $display("state: %d, expected: 4 reading retrieving", dut.fsm.state);

        sclk_pin = 0; #1000 sclk_pin = 1; #1000                 // clock to display data
        $display("miso_pin data[0]: %b, expected: 1", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[1]: %b, expected: 0", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[2]: %b, expected: 1", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[3]: %b, expected: 1", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[4]: %b, expected: 0", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[5]: %b, expected: 0", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[6]: %b, expected: 1", miso_pin);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("miso_pin data[7]: %b, expected: 0", miso_pin);

        $display("state: %d, expected: 5 reading displaying", dut.fsm.state);

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip deselect
        $display("state: %d, expected: 6 done", dut.fsm.state);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);


        // CHIP SELECT HIGH WRITE TEST -----------------------------------------------------
        $display("CHIP SELECT HIGH WRITE TEST STARTING");

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip select
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // addr
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // write

        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // data
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000

        $display("state: %d, expected: 0 idle", dut.fsm.state);

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip deselect
        $display("state: %d, expected: 0 idle", dut.fsm.state);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        // CHIP SELECT HIGH READ TEST ------------------------------------------------------
        $display("CHIP SELECT HIGH READ TEST STARTING");

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip select
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // addr
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 0; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        mosi_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000   // read

        $display("state: %d, expected: 0 idle", dut.fsm.state);

        sclk_pin = 0; #1000 sclk_pin = 1; #1000                 // wait for spi to retrieve data
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        sclk_pin = 0; #1000 sclk_pin = 1; #1000                 // clock to display data
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        cs_pin = 1; sclk_pin = 0; #1000 sclk_pin = 1; #1000     // chip deselect
        $display("state: %d, expected: 0 idle", dut.fsm.state);
        sclk_pin = 0; #1000 sclk_pin = 1; #1000
        $display("state: %d, expected: 0 idle", dut.fsm.state);

        $finish();
    end

endmodule
