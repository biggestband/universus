class_name Unit

extends Node3D

# System vars
var _targetID: int = -1

# Signals
signal OnRequireTarget()
signal OnDie()

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func SetTarget(id: int, node: Unit) -> void:
	_targetID = id
	
func ClearTarget() -> void:
	_targetID = -1

func GetTargetID() -> int:
	return _targetID

# Increments enemy state each time function is called
func TakeDamage() -> void:
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Injured):
		OnDie.emit()
