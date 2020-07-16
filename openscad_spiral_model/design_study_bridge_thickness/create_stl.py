import subprocess
from datetime import datetime

# Create pictures from model
openscad_file_path = "openscad.exe"
scad_file_name = "mf_design.scad"
number_of_images = 4

print("Start creating STLs with OpenSCAD")
for wall_thickness in range(1, number_of_images+1):
	output_file_name = "mf_bridge_thickness_" + str(wall_thickness) + "_mm.stl"
	command_string = openscad_file_path + " -o " + output_file_name + " -D bridge_thickness=" + str(wall_thickness) + " --quiet " + scad_file_name
	print("[" + str(datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "] Creating " + output_file_name)
	subprocess.check_output(command_string)
