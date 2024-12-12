import numpy as np
from PIL import Image

# 512 x 256 for start
# 256 x 128 for other screens

def image_to_bitmap(image_path, output_file, width=512, height=256):
    img = Image.open(image_path).convert('L')  # Convert to grayscale

    img_resized = img.resize((width, height), Image.Resampling.LANCZOS)

    binary_img = np.array(img_resized) < 128

    with open(output_file, 'w') as f:
        for y in range(height):
            binary_row = ''.join(['1' if binary_img[y, x] else '0' for x in range(width)])
            f.write(f"main[{y}] = {width}'b{binary_row};\n")
    print(f"Conversion complete. Output size: {height} rows x {width} columns.")
    print(len(binary_row))

# image_to_bitmap('game_over.png', 'sprite_bitmap.txt')

# image_to_bitmap('Level1_Win.png', 'sprite_bitmap.txt')

# image_to_bitmap('Level2_Win.png', 'sprite_bitmap.txt')

image_to_bitmap('start_screen.png', 'sprite_bitmap.txt')