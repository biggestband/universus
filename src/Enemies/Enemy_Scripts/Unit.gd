class_name Unit

extends CharacterBody3D

# Stats
const  _movementSpeed: float = 4

# Components
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

# Signals
signal OnTargetRequired(unit: Unit)
signal OnDie()

# System Vars
var ID : int
var _unitManager : UnitManager2

enum HealthState { Healthy, Dazed, Injured }
var currentState = HealthState.Healthy

func Setup(id: int, unitManager: UnitManager2) -> void:
	ID = id
	_unitManager = unitManager

# Called when this units target dies
func _targetKilled()-> void:
	OnTargetRequired.emit(self)

# Increments enemy state each time function is called
func _update_state():
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Injured):
		OnDie.emit()

func _process(delta: float) -> void:
	var pos : Vector2 = _unitManager.units[ID]
	position = Vector3(pos.x, 0, pos.y)
	
