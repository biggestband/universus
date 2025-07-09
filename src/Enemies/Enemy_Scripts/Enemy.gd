extends Node

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

# Increments enemy state each time function is called
func _update_state():
	if currentState == HealthState.Healthy:
		currentState = HealthState.Dazed
	
 	if currentState == HealthState.Dazed:
		currentState = HealthState.Injured
		
	if currentState == Healthstate.Injured:
		# Add death logic