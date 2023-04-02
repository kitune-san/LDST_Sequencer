
`define TB_CYCLE        20
`define TB_FINISH_COUNT 20000

module tb();

    timeunit        1ns;
    timeprecision   10ps;

    //
    // Generate wave file to check
    //
`ifdef IVERILOG
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
`endif

    //
    // Generate clock
    //
    logic   clock;
    initial clock = 1'b1;
    always #(`TB_CYCLE / 2) clock = ~clock;

    //
    // Generate reset
    //
    logic reset;
    initial begin
        reset = 1'b1;
            # (`TB_CYCLE * 10)
        reset = 1'b0;
    end

    //
    // Cycle counter
    //
    logic   [31:0]  tb_cycle_counter;
    always_ff @(negedge clock, posedge reset) begin
        if (reset)
            tb_cycle_counter <= 32'h0;
        else
            tb_cycle_counter <= tb_cycle_counter + 32'h1;
    end

    always_comb begin
        if (tb_cycle_counter == `TB_FINISH_COUNT) begin
            $display("***** SIMULATION TIMEOUT ***** at %d", tb_cycle_counter);
`ifdef IVERILOG
            $finish;
`elsif  MODELSIM
            $stop;
`else
            $finish;
`endif
        end
    end

    //
    // Module under test
    //
    logic           clock_enable;
    logic   [15:0]  instruction_bus_address;
    logic   [12:0]  instruction_bus_data;

    logic   [7:0]   io_bus_address;
    logic   [7:0]   io_bus_data_out;
    logic   [7:0]   io_bus_data_in;
    logic           io_bus_out;
    logic           io_bus_in;


    LDST_SEQUENCER u_LDST_SEQUENCER(.*);

    //
    // Task : Initialization
    //
    task TASK_INIT();
    begin
        #(`TB_CYCLE * 0);
        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h00};
        io_bus_data_in          = 8'h00;
        #(`TB_CYCLE * 12);
    end
    endtask

    //
    // Test pattern
    //
    initial begin
        TASK_INIT();

        #(`TB_CYCLE * 1);
        $display("***** TEST REG A ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hAA};     // LD #AAH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h00};     // LD A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST REG B ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h55};     // LD #55H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h01};     // LD B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST FLAGS ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hFF};     // LD #FFH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h02};     // LD FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST EXT BUS ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h55};     // LD #55H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h23};     // ST 23H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h23};     // LD 23H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        io_bus_data_in          = 8'hAA;
        #(`TB_CYCLE * 1);
        io_bus_data_in          = 8'h00;

        $display("***** TEST ALU AND ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h0F};     // LD #0FH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h55};     // LD #55H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #AND
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU NAND ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h04};     // LD #NAND
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU OR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h20};     // LD #OR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU NOR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h24};     // LD #NOR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST ALU NOT ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h2C};     // LD #NOT
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST ALU XOR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h40};     // LD #XOR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU XNOR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h44};     // LD #XNOR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU ADD ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h80};     // LD #ADD
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h02};     // LD #02H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hFF};     // LD #FFH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        $display("***** TEST ALU ADC ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h02};     // LD #02H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h81};     // LD #ADC
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU SUB ***** at %d", tb_cycle_counter);
        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h70};     // LD #70H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h05};     // LD #05H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h82};     // LD #SUB
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST ALU SBC ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h02};     // LD #02H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h02};     // LD #02H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h01};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h83};     // LD #SBC
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU OVERFLOW ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h80};     // LD #80H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h01};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h01};     // ST B
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h82};     // LD #SUB
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU SHL ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hAA};     // LD #AAH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hA0};     // LD #SHL
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU SHCL ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hA0};     // LD #A0H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hA1};     // LD #SHCL
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST ALU SHR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h55};     // LD #55H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hC0};     // LD #SHR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST ALU SHCR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h05};     // LD #05H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hC1};     // LD #SHCR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST ALU SAR ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h55};     // LD #55H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hE0};     // LD #SAR
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h03};     // ST ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hAA};     // LD #AAH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h00};     // ST A
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0000, 8'h03};     // LD ALU
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        $display("***** TEST CALL ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hAB};     // LD #ABH
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0100, 8'hCD};     // CALL #CDH  (#ABCD)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'hE0};     // LD #E0H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0100, 8'hF0};     // CALL #F0H  (#E0F0)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST RET ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0101, 8'h00};     // RET
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0101, 8'h00};     // RET
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST JZ ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h01};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1001, 8'h02};     // JZ #02H  (#0102)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h01};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h01};     // LD #01H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1001, 8'h02};     // JZ #02H  (#0102)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST JC ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h03};     // LD #03H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1010, 8'h04};     // JC #04H  (#0304)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);



        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h02};     // LD #02H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h03};     // LD #03H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1010, 8'h04};     // JC #04H  (#0304)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST JO ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h00};     // LD #00H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h05};     // LD #05H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1100, 8'h06};     // JO #06H  (#0506)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);


        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h04};     // LD #04H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0001, 8'h02};     // ST FLAGS
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h05};     // LD #05H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1100, 8'h06};     // JO #06H  (#0506)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        $display("***** TEST JMP ***** at %d", tb_cycle_counter);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b0010, 8'h07};     // LD #07H
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        instruction_bus_data    = {4'b1000, 8'h08};     // JO #08H  (#0708)
        #(`TB_CYCLE * 1);
        clock_enable            = 1'b1;
        #(`TB_CYCLE * 1);

        clock_enable            = 1'b0;
        #(`TB_CYCLE * 12);

        // End of simulation
`ifdef IVERILOG
        $finish;
`elsif  MODELSIM
        $stop;
`else
        $finish;
`endif
    end
endmodule

