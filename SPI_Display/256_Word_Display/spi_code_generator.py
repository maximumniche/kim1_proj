numDisplays = int(input("Type in the number of sequential displays you want (1-256): "))
limit = str(hex(numDisplays))

intensityInput = hex(int(input("Type the intensity of the displays (0-15): ")))

symbols = {
    "0": "0b01111110",
    "1": "0b00110000",
    "2": "0b01101101",
    "3": "0b01111001",
    "4": "0b00110011",
    "5": "0b01011011",
    "6": "0b01011111",
    "7": "0b01110000",
    "8": "0b01111111",
    "9": "0b01111011",

    "-": "0b00000001",
    " ": "0b00000000",
    ".": "0b10000000",

    "a": "0b01110111",
    "b": "0b00011111",
    "c": "0b01001110",
    "d": "0b00111101",
    "e": "0b01001111",
    "f": "0b01000111",
    "g": "0b01111011",
    "h": "0b00010111",
    "i": "0b00110000",
    "j": "0b00111000",
    "k": "0b00000111",
    "l": "0b00001110",
    "m": "0b01010100",
    "n": "0b01110110",
    "o": "0b01111110",
    "p": "0b01100111",
    "q": "0b01110011",
    "r": "0b01000110",
    "s": "0b01011011",
    "t": "0b00001111",
    "u": "0b00111110",
    "v": "0b00011100",
    "w": "0b00101010",
    "x": "0b00110111",
    "y": "0b00111011",
    "z": "0b01101101"
}

displays = []

intensity = str(intensityInput)

print("Type the 8 digit sequence you want: ")

for i in range(numDisplays):
    sequence = input().lower()

    while True:
        if len(sequence) > 8:
            print("Wrong sequence length. Try again.\n")
            sequence = input("\n")
        elif len(sequence) < 8:
            for i in range(8 - len(sequence)):
                sequence = " " + sequence
            break
        else:
            break
    
    displays.append(sequence)

print("Your displays are:")
for display in displays:
    print(display)

file = open("C:/Users/Imad/Documents/VSCode/kim1_proj/SPI_Display/256_Word_Display/displays.txt", "w")

file.write("intensity: .byte " + intensity + "\n\n")

file.write("limit: .byte " + limit + "\n\n")

for i in range(8):

    file.write("data_input" + str(i) + ": \n")

    for j in range(numDisplays):
        file.write(".byte " + symbols[displays[j][i]] + "\n")

    file.write("\n")

file.close()

print("Written to txt file as well.")

