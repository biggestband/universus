class_name Vfx3D extends Node3D

@export var emitters: Array[GPUParticles3D]


func _ready() -> void:
	if len(emitters) <= 0:
		queue_free()
	
	var longestEmitter: GPUParticles3D = emitters.get(0)
	for e in emitters: 
		e.emitting = true
		
		if e.lifetime > longestEmitter.lifetime:
			longestEmitter = e
	
	# Delete when longest lifetime is finished
	longestEmitter.finished.connect(queue_free)
