class_name Unit

extends Node3D

# Stats
const  _movementSpeed: float = 4

signal OnDie()

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

# Increments enemy state each time function is called
func _update_state():
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Injured):
		OnDie.emit()
	
