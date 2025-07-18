extends Node3D


var sinAmplitude := 2.0
var sinSpeed := 0.01
var sinOffset: float


func _ready() -> void:
	sinOffset = randf_range(0, PI)


func _process(delta: float) -> void:
	position.y = abs(sin(Time.get_ticks_msec() * sinSpeed + sinOffset)) 
