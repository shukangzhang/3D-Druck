import subprocess
from datetime import datetime
from itertools import product

# class for holding infos for one parameter
# start -> start of the range, including start
# end -> end of the parameter range, including end.
# steps -> number of values to generate from the range. If one then start is taken
class param:
	def __init__(self, start, end, steps, name=None, cast_to_int=False):
		assert steps > 0
		self.start = start
		self.end = end
		self.steps = steps
		if name is not None:
			self.name = name
		self.cast_to_int = cast_to_int
	def generate_range(self, exclude_endpoint=False):
		return_array = []
		if self.steps == 1:
			return_array = [self.start]
		elif self.steps == 2:
			return_array = [self.start, self.end]
		elif exclude_endpoint:
			return_array = [self.start + a*(self.end-self.start)/(self.steps) for a in range(self.steps)]
		else:
			return_array = [self.start + a*(self.end-self.start)/(self.steps-1) for a in range(self.steps)]
		if self.cast_to_int:
			return_array = [int(a) for a in return_array]
		return return_array
# Create pictures from model
openscad_file_path = "C:/Users/Ja/Downloads/OpenSCAD-2019.05-x86-64/openscad-2019.05/openscad.exe"
scad_file_name = "model_file.scad"
number_of_images = 4

bridge_thickness = param(1, 4, 3)
structure_height = param(100, 100, 1)
structure_twist = param(90, 135, 3)
ring_1 = param(12, 24, 4, cast_to_int=True)
ring_2 = param(0, 12, 2, cast_to_int=True)
ring_3 = param(4, 8, 3, cast_to_int=True)
params = [bridge_thickness, structure_height, structure_twist, ring_1, ring_2, ring_3]
param_sets = list(product(*[param.generate_range() for param in params]))

print("[" + str(datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "] Start creating STLs with OpenSCAD")
for param_set in param_sets[:5]:
	parameter_string = (
	" -D bridge_thickness={bridge_thickness} " +
	"-D structure_height={structure_height} " +
	"-D strucutre_twist={structure_twist} " +
	"-D ring_structure=[[{ring_1},45,2,10],[{ring_2},36,2],[{ring_3},20,2],[1,0,3]]").format(
			bridge_thickness=param_set[0],
			structure_height=param_set[1],
			structure_twist=param_set[2],
			ring_1=param_set[3],
			ring_2=param_set[4],
			ring_3=param_set[5],
	)
	output_file_name = "mf_" + str(param_set).replace(" ", "") + ".stl"
	command_string = openscad_file_path + " -o " + output_file_name + parameter_string + " " + scad_file_name
	#print(command_string)
	print("[" + str(datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "] Creating " + output_file_name)
	subprocess.check_output(command_string)

print("[" + str(datetime.now().strftime("%Y-%m-%d %H:%M:%S")) + "] Finished creating STLs with OpenSCAD")