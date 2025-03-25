# Makefile for VASM 6502 display_bit_banging.asm

# Build rule to generate the output file
generate_output:
	vasm -Fihex -o image_bit_banging.hex -L image_bit_banging.lst image_bit_banging.asm 

# Clean up generated files
clean:
	rm -f image_bit_banging.hex

# Phony targets (not real files)
.PHONY: clean