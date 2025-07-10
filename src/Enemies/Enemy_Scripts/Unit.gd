class_name Unit

extends Node

signal OnTargetRequired

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func Setup(unitManager: UnitManager) -> void:
	OnTargetRequired.emit()

# Increments enemy state each time function is called
func _update_state():
	if currentState == HealthState.Healthy:
		currentState = HealthState.Dazed

	if currentState == HealthState.Dazed:
		currentState = HealthState.Injured
		
	if currentState == HealthState.Injured:
		# Add death logic
		pass
