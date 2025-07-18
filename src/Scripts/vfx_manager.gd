extends Node

#signals
signal _spawnParticle3D(particle: VFX3D, pos: Vector3)
signal _spawnParticle2D(particle: VFX2D, pos: Vector2)

#variables
enum VFX3D { DeathDurham, DeathOTU, Spark, Hit, Dizzy}
enum VFX2D { DurhamConfetti, OTUConfetti }

@export var particles3D: Dictionary[VFX3D, PackedScene]
@export var particles2D: Dictionary[VFX2D, PackedScene]

func _spawnParticles3D(particle: VFX3D, _pos: Vector3) -> void:
	if particles3D.is_empty(): return
	
	# Add particles to scene
	var particle_3d = particles3D[particle].instantiate()
	add_child(particle_3d)
	particle_3d.position = _pos

func _spawnParticles2D(particle: VFX2D, _pos: Vector2) -> void:
	if particles2D.is_empty(): return
	
	# Add particles to scene
	var particle_2d = particles2D[particle].instantiate()
	add_child(particle_2d)
	particle_2d.position = _pos
