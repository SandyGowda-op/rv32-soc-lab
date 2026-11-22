`timescale 1ns/1ps
// Instruction memory: 1024 words (4 KB), asynchronous read.
// The testbench loads the program into `mem` (see tb/tb_top.sv), so there is no
// hard-coded file name here any more.
module instr_mem (
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem [0:1023];
    assign instr = mem[addr[11:2]];
endmodule
