# Makefile for VASM 6502 display_bit_banging.asm

# Build rule to generate the output file
generate_output:
	vasm -Fihex -o display_bit_banging.hex -L display_bit_banging.lst display_bit_banging.asm 

# Clean up generated files
clean:
	rm -f display_bit_banging.hex

# Phony targets (not real files)
.PHONY: clean