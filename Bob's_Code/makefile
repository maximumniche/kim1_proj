# Makefile for VASM 6502 display_bit_banging.asm

# Build rule to generate the output file
generate_output:
	vasm -Fihex -o bobs_code.hex -L bobs_code.lst bobs_code.asm 

# Clean up generated files
clean:
	rm -f bobs_code.hex

# Phony targets (not real files)
.PHONY: clean