extends Node

func _ready():
	# Get the MeshInstance3D child node
	var mesh_instance: MeshInstance3D = $SM_Peg_Instance_01 # Replace with your actual node path
	
	# Initialize the instance uniform

	mesh_instance.set_instance_shader_parameter("peg_brightness", 1.0)
	mesh_instance.set_instance_shader_parameter("peg_emission", 0.0)
	mesh_instance.set_instance_shader_parameter("peg_size", 1.0)
