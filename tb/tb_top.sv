`timescale 1ns/1ps
// =============================================================================
// tb_top: self-checking harness for the RV32 SoC Lab
//
// Plusargs (the Makefile sets these for you):
//   +hex=<file>        program image, one 32-bit word per line (required)
//   +exp=<file>        expected registers, lines like "x3 00000007" (optional)
//   +max_cycles=<n>    timeout, default 10000
//   +dump              print all 31 registers at the end
//   +vcd=<file>        write a waveform
//
// Exit convention: a program ends by storing anything to address 0x7FC.
// =============================================================================
module tb_top;

    localparam [31:0] EXIT_ADDR = 32'h0000_07FC;

    reg clk = 1'b0;
    reg rst = 1'b1;
    always #5 clk = ~clk;                       // 100 MHz

    riscv_pipeline dut (.clk(clk), .rst(rst));

    reg [8*256-1:0] hex_file, exp_file, vcd_file;
    integer max_cycles, cycles, i;
    reg have_exp;

    // -------------------------------------------------------------------------
    // Load the program, clear data memory, release reset
    // -------------------------------------------------------------------------
    initial begin
        if (!$value$plusargs("hex=%s", hex_file)) begin
            $display("TB ERROR: no program given. Use +hex=<file>");
            $finish(0);
        end
        have_exp = $value$plusargs("exp=%s", exp_file);
        if (!$value$plusargs("max_cycles=%d", max_cycles)) max_cycles = 10000;
        if ($value$plusargs("vcd=%s", vcd_file)) begin
            $dumpfile(vcd_file);
            $dumpvars(0, tb_top);
        end

        // Fill both memories with zeros first, so nothing reads as X
        for (i = 0; i < 1024; i = i + 1) begin
            dut.instr_mem_inst.mem[i] = 32'h0000_0000;
            dut.dmem.mem[i]           = 32'h0000_0000;
        end
        $readmemh(hex_file, dut.instr_mem_inst.mem);

        cycles = 0;
        repeat (4) @(posedge clk);
        #1 rst = 1'b0;
    end

    // -------------------------------------------------------------------------
    // Watch for the exit store, or give up after max_cycles
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin
            cycles = cycles + 1;

            if (dut.exmem_mem_write && dut.exmem_alu == EXIT_ADDR) begin
                // One more edge lets the instruction ahead of the store write
                // back. Waiting longer would let younger instructions write too.
                @(posedge clk); #1;
                finish_test();
            end

            if (cycles >= max_cycles) begin
                $display("FAIL timeout after %0d cycles (pc = %08h)", cycles, dut.pc_reg);
                $finish(0);
            end
        end
    end

    // -------------------------------------------------------------------------
    // Compare registers against the .exp file and print the verdict
    // -------------------------------------------------------------------------
    task finish_test;
        integer fd, r, n, errors, checked;
        reg [31:0] want, got;
        begin
            errors  = 0;
            checked = 0;

            if ($test$plusargs("dump")) begin
                for (r = 1; r < 32; r = r + 1)
                    $display("  x%-2d = %08h", r, dut.rf.regs[r]);
            end

            if (have_exp) begin
                fd = $fopen(exp_file, "r");
                if (fd == 0) begin
                    $display("TB ERROR: cannot open %0s", exp_file);
                    $finish(0);
                end
                // Each line: x<reg> <hex value>. Lines starting with # are comments.
                while (!$feof(fd)) begin
                    n = $fscanf(fd, " x%d %h", r, want);
                    if (n == 2) begin
                        got = (r == 0) ? 32'd0 : dut.rf.regs[r];
                        checked = checked + 1;
                        if (got !== want) begin
                            $display("  x%-2d got %08h, expected %08h", r, got, want);
                            errors = errors + 1;
                        end
                    end else begin
                        n = $fgetc(fd);                 // skip a comment character
                        while (n != "\n" && n != -1) n = $fgetc(fd);
                    end
                end
                $fclose(fd);
            end

            if (!have_exp)
                $display("DONE in %0d cycles (no .exp file, nothing checked)", cycles);
            else if (errors == 0)
                $display("PASS (%0d registers checked, %0d cycles)", checked, cycles);
            else
                $display("FAIL (%0d of %0d registers wrong, %0d cycles)", errors, checked, cycles);
            $finish(0);
        end
    endtask

endmodule
