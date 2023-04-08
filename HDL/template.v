//
// LDST system template
//
module LDST_SYSTEM (
    input   clock,
    input   reset,

`ifdef LDST_DEBUG
    output  [15:0]  instruction_bus_address,
    input   [12:0]  instruction_bus_data
`endif
);

    //
    // Sequencer
    //
    reg             sequencer_enable;
    wire    [15:0]  instruction_bus_address;
    wire    [12:0]  instruction_bus_data_in;
    wire    [7:0]   io_bus_address;
    wire    [7:0]   io_bus_data_out;
    reg     [7:0]   io_bus_data_in;
    wire            io_bus_out;
    wire            io_bus_in;

    always @(posedge clock, posedge reset) begin
        if (reset)
            sequencer_enable    <= 1'b0;
        else
            sequencer_enable    <= ~sequencer_enable;
    end

    LDST_SEQUENCER u_SEQUENCER (
        .clock                      (clock),
        .clock_enable               (sequencer_enable),
        .reset                      (reset),
        .instruction_bus_address    (instruction_bus_address),
        .instruction_bus_data       (instruction_bus_data_in),
        .io_bus_address             (io_bus_address),
        .io_bus_data_out            (io_bus_data_out),
        .io_bus_data_in             (io_bus_data_in),
        .io_bus_out                 (io_bus_out),
        .io_bus_in                  (io_bus_in)
    );

    // ROM
    LDST_PROGRAM_ROM u_ROM (
        .clock                      (clock),
        .address                    (instruction_bus_address),
        .data_out                   (instruction_bus_data_in)
    );

    // Chip Select
    wire    io_write            = sequencer_enable & io_bus_out;
    wire    io_read             = io_bus_in;
    wire    select_reg1         = io_bus_address == 8'b00000100;
    wire    select_reg2         = io_bus_address == 8'b00000101;


    //
    // Registers
    //
    reg     [7:0]   reg1;
    reg     [7:0]   reg2;

    always @(posedge clock, posedge reset) begin
        if (reset)
            reg1    <= 8'h00;
        else if (io_write & select_reg1)
            reg1    <= io_bus_data_out;
        else
            reg1    <= reg1;
    end

    always @(posedge clock, posedge reset) begin
        if (reset)
            reg2    <= 8'h00;
        else if (io_write & select_reg2)
            reg2    <= io_bus_data_out;
        else
            reg2    <= reg2;
    end


    //
    // Back to sequencer
    //
    always @(*) begin
        if (~io_read)
            io_bus_data_in  = 8'h00;
        else if (select_reg1)
            io_bus_data_in  = reg1;
        else if (select_reg2)
            io_bus_data_in  = reg2;
        else
            io_bus_data_in  = 8'h00;
    end

endmodule

