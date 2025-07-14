class_name CrowdUnit extends Node3D

@export var ridgebackSprite: Sprite3D
@export var durhamSprite: Sprite3D

var isRidgeback := true
var currentSprite: Sprite3D

var sinAmplitude := 2.0
var sinSpeed := 0.01
var sinOffset: float


func _ready() -> void:
	sinOffset = randf_range(0, PI)


func _process(delta: float) -> void:
	position.y = abs(sin(Time.get_ticks_msec() * sinSpeed + sinOffset)) 


func setType(_isRidgeback: bool):
	isRidgeback = _isRidgeback
	if isRidgeback:
		currentSprite = ridgebackSprite
		durhamSprite.hide()
	else:
		currentSprite = durhamSprite
		ridgebackSprite.hide()
