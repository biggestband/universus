class_name Unit

extends Node

signal OnTargetRequired(unit: Unit)

var IsTeamA : bool

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func Setup(isTeamA: bool, unitManager: UnitManager) -> void:
	IsTeamA = isTeamA
	unitManager.OnBattleStart.connect(_onBattleStart)

func _onBattleStart():
	print("Unit Ready For Battle!")
	OnTargetRequired.emit(self)

# Increments enemy state each time function is called
func _update_state():
	if currentState == HealthState.Healthy:
		currentState = HealthState.Dazed

	if currentState == HealthState.Dazed:
		currentState = HealthState.Injured
		
	if currentState == HealthState.Injured:
		# Add death logic
		pass
