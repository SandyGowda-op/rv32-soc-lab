#!/usr/bin/env bash
# asm2hex.sh: assemble one RISC-V program into a hex image for $readmemh.
#   usage: scripts/asm2hex.sh sw/tests/smoke.s build/smoke
#   makes: build/smoke.elf, build/smoke.hex (one word per line), build/smoke.dis
# Only binutils are needed (no gcc). Override the prefix if yours differs:
#   CROSS=riscv32-unknown-elf- scripts/asm2hex.sh ...
set -euo pipefail
CROSS=${CROSS:-riscv64-unknown-elf-}
src=$1
out=$2
mkdir -p "$(dirname "$out")"

"${CROSS}as" -march=rv32i -mabi=ilp32 "$src" -o "$out.o"
"${CROSS}ld" -m elf32lriscv -Ttext=0 --entry=0 "$out.o" -o "$out.elf"
"${CROSS}objcopy" -O binary -j .text "$out.elf" "$out.bin"
"${CROSS}objdump" -d -M no-aliases "$out.elf" > "$out.dis"

python3 - "$out.bin" "$out.hex" <<'PY'
import struct, sys
data = open(sys.argv[1], 'rb').read()
data += b'\0' * (-len(data) % 4)
words = [w for (w,) in struct.iter_unpack('<I', data)]
if len(words) > 1024:
    sys.exit(f"program is {len(words)} words, instruction memory holds 1024")
words += [0] * (1024 - len(words))          # pad so $readmemh fills all of memory
open(sys.argv[2], 'w').write(''.join(f'{w:08x}\n' for w in words))
PY
