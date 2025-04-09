from PIL import Image
import math

# function to split and flatten an nxn matrix made up of mxm squares into a sequence
# of their values from left to right, top to bottom order
def split_and_flatten(matrix, m):
    n = len(matrix)  # Matrix size (assumes square matrix)
    result = []
    
    # First loop over square rows, then square columns
    for square_row in range(0, n, m):
        for square_col in range(0, n, m):
            # Flatten each m x m square starting from top left to bottom right
            square = [matrix[i][j] 
                      for i in range(square_row, square_row + m) 
                      for j in range(square_col, square_col + m)]
            result.extend(square)
    
    return result

# function to convert an gif file to a dim x dim bgr list of 2D lists of multiple frames
def gif_to_bgr(image_directory, dim):

    # Open the gif
    gif = Image.open(image_directory)

    frames = []
    frame_count = gif.n_frames

    if frame_count > 255:
        print("More than 75 frames not possible. Truncated to 70 frames")
        frame_count = 255

    for frame_num in range(frame_count):

        # get ith frame of gif
        gif.seek(frame_num)

        # resize convert to rgb list
        # gif_frame = gif.resize((dim, dim), Image.LANCZOS)
        gif_frame = gif.resize((dim, dim))
        gif_frame = gif_frame.convert('RGB')

        # display the converted frame
        #gif_frame.show()

        # Convert to BGR using list comprehension
        bgr_values = [(b, g, r) for r, g, b in list(gif_frame.getdata())]

        # Convert to 2D list
        bgr_pixels = [bgr_values[i * dim:(i + 1) * dim] for i in range(dim)]

        frames.append(bgr_pixels)

    return frames, frame_count

# function to convert bgr values to monochrome based comparing their luminosity values to a threshold
def bgr_to_monochrome(bgr, threshold):
    luminosity = 0.2126*bgr[2]+0.7152*bgr[1]+0.0722*bgr[0]

    if luminosity > threshold:
        return 1
    else:
        return 0


intensity = int(input("What intensity do you want (0-31)? ")) + 224
image_name = input("What image do you want? ")
num_leds = int(input("Enter the total number of LEDs: "))
leds_per_display = int(input("Enter the number of leds per display: "))

dim = int(math.sqrt(int(num_leds)))
dim_display = int(math.sqrt(int(leds_per_display)))

# Open, resize the image to dimxdim, convert to bgr list of tuples
gif_directory = fr'C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\monochrome\{image_name}'
frames_pixels, num_frames = gif_to_bgr(gif_directory, dim)

# split and flatten every frame into dotstar format
formatted_frames = []
for frame_num in range(len(frames_pixels)):
    formatted_frame = split_and_flatten(frames_pixels[frame_num], dim)
    # formatted_frame.reverse()
    formatted_frames.append(formatted_frame)

# data organization:
# formatted_frames[frame_num][pixel_num][led_num]

# change every bgr to a 0 or 1 based on threshold luminosity
for frame_num in range(len(formatted_frames)):
    for pixel_num in range(len(formatted_frames[frame_num])):
        formatted_frames[frame_num][pixel_num] = bgr_to_monochrome(formatted_frames[frame_num][pixel_num], 128)
        print(formatted_frames[frame_num][pixel_num])

file = open(r"C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\monochrome\frames.txt", "w")

types = {
    0: "blue",
    1: "green",
    2: "red"
}

file.write("intensity: .byte " + str(hex(intensity)) + "\n\n")
file.write("numLEDs: .byte " + str(hex(num_leds-1)) + "\n\n")
file.write("numFrames: .byte " + str(hex(num_frames)) + "\n\n")

bits_in_byte = 8

for led_num in range(num_leds): # loop through each led

    file.write(f"\nled{str(led_num)}: \n") # write the led number to file

    for color_num in range(len(types)): # loop through 3 colors types, blue, green, red

        file.write(f"{types[color_num]}{str(led_num)}: \n") # write the color and led number

        for frame_num in range(0, len(frames_pixels), bits_in_byte): # loop through number of frames

            file.write(f".byte {hex(formatted_frames[frame_num:frame_num+bits_in_byte][led_num])}\n") # write the value at that led and 8 corresponding frame numbers and that color

# what you get from this code is list of data in format:
# led(led number): 
# blue(led number):
# blue data for pixel led_number for every frame across numLEDs rows
# green(led number)
# green data for pixel led_number for every frame across numLEDs rows
# red(led number)
# red data for pixel led_number for every frame across numLEDs rows
# repeated for the number of LEDs the display has

file = open(r"C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\monochrome\send_frame.txt", "w")

color = {
    0: "blue",
    1: "green",
    2: "red"
}

# code for send_frame.txt
# loop through each led on dotstars
for i in range(num_leds):

    file.write(f"loadled{str(i)}:\n") # write the led number as a label
    for j in range(3): # loop through all the bgr colors
        file.write(f"LDA {color[j]}{str(i)},Y\n") # write load instruction for color and its number, and offset
        file.write(f"STA {color[j]}Byte\n") # write store instruction for color
    file.write("JSR led_send\n\n")