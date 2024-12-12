import numpy as np
from PIL import Image

def image_to_bitmap(image_path, output_file, width=256, height=128):
    # Open the image
    img = Image.open(image_path).convert('L')  # Convert to grayscale

    # Resize the image while maintaining the aspect ratio
    img_resized = img.resize((width, height), Image.Resampling.LANCZOS)

    # Threshold to binary (black/white)
    binary_img = np.array(img_resized) < 128

    # Write the output file
    with open(output_file, 'w') as f:
        for y in range(height):
            binary_row = ''.join(['1' if binary_img[y, x] else '0' for x in range(width)])
            f.write(f"main[{y}] = {width}'b{binary_row};\n")
    print(f"Conversion complete. Output size: {height} rows x {width} columns.")
    print(len(binary_row))

# Convert image
# image_to_bitmap('game_over.png', 'sprite_bitmap.txt')

# image_to_bitmap('Level1_Win.png', 'sprite_bitmap.txt')

image_to_bitmap('Level2_Win.png', 'sprite_bitmap.txt')

# image_to_bitmap('start_screen.png', 'sprite_bitmap.txt')