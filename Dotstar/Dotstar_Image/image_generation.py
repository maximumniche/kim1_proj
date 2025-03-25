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

# function to convert an image file to a dim x dim bgr 2D list
def img_to_bgr(image_directory, dim):
    # Open and resize the image to dimxdim
    img = Image.open(image_directory).resize((dim, dim), Image.LANCZOS)

    # convert to rgb list
    img = img.convert('RGB')

    # display the converted image
    img.show()

    # Convert to BGR using list comprehension
    bgr_values = [(b, g, r) for r, g, b in list(img.getdata())]

    # Convert to 2D list
    bgr_pixels = [bgr_values[i * dim:(i + 1) * dim] for i in range(dim)]

    return bgr_pixels


intensity = int(input("What intensity do you want (0-31)? ")) + 224
image_name = input("What image do you want? ")
num_leds = int(input("Enter the total number of LEDs: "))
leds_per_display = int(input("Enter the number of leds per dotstar display: "))

dim = int(math.sqrt(int(num_leds)))
dim_display = int(math.sqrt(int(leds_per_display)))

# Open, resize the image to dimxdim, convert to bgr list of tuples
img_directory = fr'C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\Dotstar_Image\{image_name}'
img_pixels = img_to_bgr(img_directory, dim)

# split and flatten into dotstar format, then reverse
formatted_img = split_and_flatten(img_pixels, dim_display)
formatted_img.reverse()

file = open(r"C:\Users\Imad\Documents\VSCode\kim1_proj\Dotstar\Dotstar_Image\image.txt", "w")

types = {
    0: "blueData",
    1: "greenData",
    2: "redData"
}

file.write("intensity: .byte " + str(hex(intensity)) + "\n\n")
file.write("numLEDs: .byte " + str(hex(num_leds-1)) + "\n\n")

for i in range(len(types)): # loop through colors

    file.write("\n\n" + types[i] + ":\n") # label for color
    for j in range(num_leds): # loop through leds
        file.write(".byte " + hex(int(formatted_img[j][i])) + "\n") # data for jth pixel's types[i]th color
