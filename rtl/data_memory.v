`timescale 1ns/1ps
module data_memory (
    input  wire        clk,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] mem [0:1023]; // 4KB
    // Contents are loaded by the testbench (tb/tb_top.sv).
    always @(posedge clk) begin
        if (mem_write) mem[addr[11:2]] <= write_data;
    end
    // Continuous assign instead of always @(*): an @* block over a memory is
    // re-evaluated whenever ANY of the 1024 words changes, which slows simulation.
    assign read_data = mem_read ? mem[addr[11:2]] : 32'd0;
endmodule
