//------------------------------------------------------------------------
// Data Memory
//   Positive edge triggered
//   dataOut always has the value mem[address]
//   If writeEnable is true, writes dataIn to mem[address]
//------------------------------------------------------------------------

module finitestatemachine
(
    input  rising_sclk,
    input  conditioned_cs,
    input  shiftreg_out,
    output reg miso_bufe,
    output reg dm_we,
    output reg addr_we,
    output reg sr_we
);

    parameter IDLE = 0, GETTING_ADDRESS = 1, GOT_ADDRESS = 2, WRITING = 3,
            READING_RETRIEVING = 4, READING_DISPLAYING = 5, DONE = 6;

    reg [2:0] state = IDLE;
    reg [2:0] addr_counter = 0, write_counter = 0, read_counter = 0;

    always @(state) begin
        case (state)
            IDLE:  begin
                miso_bufe <= 0; dm_we <= 0; addr_we <= 0; sr_we <= 0;
            end
            GETTING_ADDRESS:  begin
                miso_bufe <= 0; dm_we <= 0; addr_we <= 0; sr_we <= 0;
            end
            GOT_ADDRESS:  begin
                miso_bufe <= 0; dm_we <= 0; addr_we <= 1; sr_we <= 0;
            end
            WRITING:  begin
                miso_bufe <= 0; dm_we <= 1; addr_we <= 0; sr_we <= 0;
            end
            READING_RETRIEVING:  begin
                miso_bufe <= 0; dm_we <= 0; addr_we <= 0; sr_we <= 1;
            end
            READING_DISPLAYING:  begin
                miso_bufe <= 1; dm_we <= 0; addr_we <= 0; sr_we <= 0;
            end
            DONE:  begin
                miso_bufe <= 0; dm_we <= 0; addr_we <= 0; sr_we <= 0;
            end
        endcase
    end

    always @(posedge rising_sclk) begin
        case (state)
            IDLE: begin
                if (conditioned_cs == 0) begin
                    state <= GETTING_ADDRESS;
                end
                else if (conditioned_cs == 1) begin
                    state <= IDLE;
                    addr_counter <= 0; write_counter <= 0, read_counter <= 0;
                end
            end

            GETTING_ADDRESS: begin
                if (addr_counter == 7) begin
                    state <= GOT_ADDRESS;
                    addr_counter <= 0;
                end
                else if (addr_counter < 7) begin
                    state <= GETTING_ADDRESS;
                    addr_counter++;
                end
            end

            GOT_ADDRESS: begin
                if (shiftreg_out == 0) begin
                    state <= WRITING;
                end
                else if (shiftreg_out == 1) begin
                    state <= READING_RETRIEVING;
                end
            end

            WRITING: begin
                if (write_counter == 7) begin
                    state <= DONE;
                    write_counter <= 0;
                end
                else if (write_counter < 7) begin
                    state <= WRITING;
                    write_counter++;
                end
            end

            READING_RETRIEVING: begin
                state <= READING_DISPLAYING;
            end

            READING_DISPLAYING: begin
                if (read_counter == 7) begin
                    state <= DONE;
                    read_counter <= 0;
                end
                else if (read_counter < 7) begin
                    state <= READING_DISPLAYING;
                    read_counter++;
                end
            end

            DONE: begin
                if (conditioned_cs == 1) begin
                    state <= IDLE;
                end
            end
        endcase
    end

endmodule
