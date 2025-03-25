numLEDs = int(input("Type number of LEDs: "))

file = open(r"C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\Dotstar_Gif\send_frame.txt", "w")

color = {
    0: "blue",
    1: "green",
    2: "red"
}

# loop through each led on dotstars
for i in range(numLEDs):

    file.write(f"loadled{str(i)}:\n") # write the led number as a label
    for j in range(3): # loop through all the bgr colors
        file.write(f"LDA {color[j]}{str(i)},Y\n") # write load instruction for color and its number, and offset
        file.write(f"STA {color[j]}Byte\n") # write store instruction for color
    file.write("JSR led_send\n\n")



