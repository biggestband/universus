class_name Unit

extends Node3D

# System vars
var _unitID: int = -1
var _targetID: int = -1

# Signals
signal OnRequireTarget(id: int)
signal OnDie()

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func Setup(id: int, battleStart: Signal) -> void:
	_unitID = id
	battleStart.connect(_onBattleBegin)

#region Targeting

func SetTarget(id: int, onTargetDie: Signal) -> void:
	_targetID = id

func ClearTarget() -> void:
	_targetID = -1

func GetTargetID() -> int:
	return _targetID

func UpdateTarget() -> void:
	OnRequireTarget.emit(_unitID)
#endregion

#region Signal Methods

func _onBattleBegin() -> void:
	OnRequireTarget.emit(_unitID)
	
func _onTargetDie() -> void:
	OnRequireTarget.emit(_unitID)
#endregion

# Increments enemy state each time function is called
func TakeDamage() -> void:
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Injured):
		OnDie.emit()
