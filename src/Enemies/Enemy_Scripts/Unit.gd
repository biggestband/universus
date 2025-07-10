class_name Unit

extends CharacterBody3D

# Signals
signal OnTargetRequired(unit: Unit)
signal OnDie()

# System Vars
var IsTeamA : bool

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func Setup(isTeamA: bool, unitManager: UnitManager) -> void:
	IsTeamA = isTeamA
	unitManager.OnBattleStart.connect(_onBattleStart)

func _onBattleStart():
	OnTargetRequired.emit(self)

func SetTarget(target: Unit) -> void:
	target.OnDie.connect(_targetKilled)

func _targetKilled()-> void:
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

func _physics_process(delta: float) -> void:
	move_and_slide()
