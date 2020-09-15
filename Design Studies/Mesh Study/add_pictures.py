import sys, os
from PIL import Image, ImageFont, ImageDraw

def return_name(val):
    return int(val.name[7:])

design_study_path = "S:\\Team A\\Design Studies\\Mesh Study base size 3-30 mm, min surface 5, 10\\mesh_study\\"

design_study_directory = os.scandir(design_study_path)

design_study_subdirectories = sorted([a for a in list(design_study_directory) if "Design_" in a.name and a.is_dir()], key=return_name)
print(design_study_subdirectories)

design_1 = design_study_subdirectories[0]

design_1_pictures = [a.name[0:-4] for a in list(os.scandir(design_1)) if str(a.name).lower().endswith(".png")]
print(design_1_pictures)

for image in design_1_pictures:
    file_list = []
    for ds in design_study_subdirectories:
        dir_contents = os.scandir(ds)
        for file in dir_contents:
            if file.name[0:-4] == image:
                file_list.append((ds.name, Image.open(file.path)))
                print("Opened", file.path)
                break
    print("file_list for", image, ":", file_list)
    widths, heights = zip(*(i[1].size for i in file_list))

    total_width = sum(widths)
    max_height = max(heights)

    new_im = Image.new('RGB', (total_width, max_height))

    x_offset = 0
    for im in file_list:
        draw = ImageDraw.Draw(im[1])
        font = ImageFont.truetype("arial.ttf", 30, encoding="unic")
        draw.text((5, max_height - 40), im[0], (0, 0, 0), font=font)
        new_im.paste(im[1], (x_offset,0))
        x_offset += im[1].size[0]

    image_name = image + '_all.png'
    new_im.save(image_name)
    print("Finished " + image_name)