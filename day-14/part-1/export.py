from PIL import Image, ImageDraw
import math

# Configuration
map_width = 101
map_height = 103
maps_per_row = 20  # Number of maps in a single row in the output image
scale_factor = 2  # Factor to shrink the maps (1 = full size, higher values for smaller maps)
input_file = "test.txt"
output_file = "maps_overview.png"

# Read the maps from the file
def read_maps(file_path):
    with open(file_path, "r") as file:
        data = file.read()
    # Split the data into individual maps
    maps = data.strip().split("\n")
    return [maps[i:i+map_height] for i in range(0, len(maps), map_height)]

# Create an overview image
def create_overview_image(maps, map_width, map_height, maps_per_row, scale_factor):
    num_maps = len(maps)
    rows = math.ceil(num_maps / maps_per_row)

    # Calculate the size of the overview image
    scaled_width = map_width // scale_factor
    scaled_height = map_height // scale_factor
    img_width = maps_per_row * scaled_width
    img_height = rows * scaled_height

    # Create the output image
    overview_image = Image.new("RGB", (img_width, img_height), "white")
    draw = ImageDraw.Draw(overview_image)

    for idx, single_map in enumerate(maps):
        # Calculate the position in the overview image
        row = idx // maps_per_row
        col = idx % maps_per_row
        x_offset = col * scaled_width
        y_offset = row * scaled_height

        # Create a single map image
        map_image = Image.new("RGB", (map_width, map_height), "white")
        map_draw = ImageDraw.Draw(map_image)
        
        for y, line in enumerate(single_map):
            for x, char in enumerate(line):
                if idx == 7671:  # Highlight the 7672nd map in red
                    color = (255, 0, 0) if char == '1' else (255, 255, 255)
                else:
                    color = (0, 0, 0) if char == '1' else (255, 255, 255)
                map_draw.point((x, y), fill=color)

        # Resize the map image
        map_image = map_image.resize((scaled_width, scaled_height), Image.NEAREST)

        # Paste it into the overview image
        overview_image.paste(map_image, (x_offset, y_offset))

    return overview_image

# Main function
def main():
    print("Reading maps from file...")
    maps = read_maps(input_file)
    print(f"Total maps found: {len(maps)}")

    print("Creating overview image...")
    overview_image = create_overview_image(maps, map_width, map_height, maps_per_row, scale_factor)

    print("Saving overview image...")
    overview_image.save(output_file)
    print(f"Overview image saved as {output_file}")

if __name__ == "__main__":
    main()
