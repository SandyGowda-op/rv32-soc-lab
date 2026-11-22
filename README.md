# RV32 SoC Lab

A learning project: a 5-stage RV32I pipeline grown into a small system-on-chip.
Started from the `riscv_mmio` CPU, with the MMUL accelerator removed.

## Requirements

- Icarus Verilog 12 or newer (`iverilog`, `vvp`)
- RISC-V binutils (`riscv64-unknown-elf-as`, `-ld`, `-objcopy`, `-objdump`).
  A different prefix works too: `make all CROSS=riscv32-unknown-elf-`
- Python 3
- Optional: GTKWave for waveforms, Verilator for `make lint`

On Ubuntu: `sudo apt install iverilog binutils-riscv64-unknown-elf gtkwave`

## Layout

| Path | What |
| --- | --- |
| `rtl/` | The CPU. `trace.vh` switches debug prints on and off |
| `tb/tb_top.sv` | Self-checking testbench |
| `sw/tests/*.s` | Test programs; `*.exp` holds expected register values |
| `scripts/asm2hex.sh` | Assembles a `.s` into a `.hex` for the testbench |
| `build/` | Generated files (ignored by git) |

## Commands

```bash
make all                   # run every test, print a summary
make test PROG=smoke       # run one test
make dump PROG=b1_ghost    # also print all registers
make trace PROG=b1_ghost   # turn on every debug $display in the RTL
make wave PROG=b1_ghost    # write build/b1_ghost.vcd, then: gtkwave build/b1_ghost.vcd
make clean
```

`build/<prog>.dis` is the disassembly of what you actually assembled. Check it
whenever a result surprises you.

## Writing a test

1. Write `sw/tests/<name>.s`. End it with the exit sequence:
   ```asm
       addi x31, x0, 0x7FC    # exit address
       sw   x0, 0(x31)        # testbench sees this store and stops
   ```
2. Write `sw/tests/<name>.exp`, one register per line (`x3 00000007`).
   Lines starting with `#` are comments. List registers that must stay 0 as well.
3. `make test PROG=<name>`

The testbench stops one clock after the exit store reaches the MEM stage. That
edge lets the instruction ahead of the store finish writeback. If a program never
exits, it fails with a timeout after 10,000 cycles.

## Status

`smoke` passes. The `b*`/`f*` tests are the Phase 0 exercises and fail on
purpose until each bug is fixed.
