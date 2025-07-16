class_name Vfx2D extends Node2D

@export var emitters: Array[CPUParticles2D]

func _ready() -> void:
	if len(emitters) <= 0:
		queue_free()
	
	var longestEmitter: CPUParticles2D = emitters.get(0)
	for e in emitters: 
		e.emitting = true
		
		if e.lifetime > longestEmitter.lifetime:
			longestEmitter = e
	
	# Delete when longest lifetime is finished
	longestEmitter.finished.connect(queue_free)
