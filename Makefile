# RV32 SoC Lab: build and test
#   make test PROG=smoke     run one test, PASS/FAIL against sw/tests/smoke.exp
#   make all                 run every test in sw/tests and print a summary
#   make dump PROG=b1_ghost  run and print all registers
#   make trace PROG=...      run with every debug $display turned on
#   make wave PROG=...       write build/<prog>.vcd for GTKWave
#   make lint                Verilator lint (if installed)
#   make clean

PROG   ?= smoke
CROSS  ?= riscv64-unknown-elf-
BUILD  := build
TESTS  := $(sort $(basename $(notdir $(wildcard sw/tests/*.s))))
RTL    := $(wildcard rtl/*.v rtl/*.sv)
IVFLAGS = -g2012 -Wall -Wno-timescale -I rtl

.PHONY: test all dump trace wave lint clean

$(BUILD)/sim: $(RTL) tb/tb_top.sv | $(BUILD)
	iverilog $(IVFLAGS) -o $@ $(RTL) tb/tb_top.sv

$(BUILD)/sim_trace: $(RTL) tb/tb_top.sv | $(BUILD)
	iverilog $(IVFLAGS) -DTRACE -o $@ $(RTL) tb/tb_top.sv

$(BUILD)/%.hex: sw/tests/%.s scripts/asm2hex.sh | $(BUILD)
	CROSS=$(CROSS) bash scripts/asm2hex.sh $< $(BUILD)/$*

$(BUILD):
	mkdir -p $@

EXP = $(if $(wildcard sw/tests/$(PROG).exp),+exp=sw/tests/$(PROG).exp)

test: $(BUILD)/sim $(BUILD)/$(PROG).hex
	@echo "== $(PROG)"; vvp -n $(BUILD)/sim +hex=$(BUILD)/$(PROG).hex $(EXP) | grep -v '^VCD info'

dump: $(BUILD)/sim $(BUILD)/$(PROG).hex
	@vvp -n $(BUILD)/sim +hex=$(BUILD)/$(PROG).hex $(EXP) +dump

trace: $(BUILD)/sim_trace $(BUILD)/$(PROG).hex
	vvp -n $(BUILD)/sim_trace +hex=$(BUILD)/$(PROG).hex $(EXP)

wave: $(BUILD)/sim $(BUILD)/$(PROG).hex
	vvp -n $(BUILD)/sim +hex=$(BUILD)/$(PROG).hex $(EXP) +vcd=$(BUILD)/$(PROG).vcd
	@echo "open with: gtkwave $(BUILD)/$(PROG).vcd"

all: $(BUILD)/sim $(addprefix $(BUILD)/,$(addsuffix .hex,$(TESTS)))
	@pass=0; total=0; \
	for t in $(TESTS); do \
	  total=$$((total+1)); \
	  exp=""; [ -f sw/tests/$$t.exp ] && exp="+exp=sw/tests/$$t.exp"; \
	  out=$$(vvp -n $(BUILD)/sim +hex=$(BUILD)/$$t.hex $$exp); \
	  verdict=$$(echo "$$out" | grep -E '^(PASS|FAIL|DONE)' | head -1); \
	  printf '%-12s %s\n' $$t "$$verdict"; \
	  case "$$verdict" in PASS*) pass=$$((pass+1));; esac; \
	done; \
	echo "----"; echo "$$pass / $$total passed"

lint:
	verilator --lint-only -Wall -Irtl --top-module riscv_pipeline $(RTL)

clean:
	rm -rf $(BUILD)
