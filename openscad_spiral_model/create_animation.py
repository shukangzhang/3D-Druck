import subprocess
import os

# Create pictures from model
openscad_file_path = "openscad.exe"
scad_file_name = "model_file.scad"
number_of_images = 100
print("Start creating images with OpenSCAD")
for time_step in range(1, number_of_images):
	time_variable = '%.4f' % (time_step/float(number_of_images))
	image_file_name = "image_" + str(time_step).zfill(6) + ".png"
	command_string = openscad_file_path + " -o " + image_file_name + " -D t=" + time_variable + " --viewall --preview --imgsize=1000,1000 --projection=ortho --quiet " + scad_file_name
	print("Creating " + image_file_name)
	subprocess.check_output(command_string)

# Combine picture to animates GIF with imagemagick
print("Combine pictures to animated GIF with imagemagick")
imagemagick_convert_file_path = "convert.exe" 
subprocess.check_output(imagemagick_convert_file_path + " -delay 20 -loop 0 image_*.png animation.gif")

# Delete image files
print("Deleting images")
for time_step in range(1, 100):
	image_file_name = "image_" + str(time_step).zfill(6) + ".png"
	if os.path.exists(image_file_name):
		os.remove(image_file_name)
		print(image_file_name + " deleted!")
