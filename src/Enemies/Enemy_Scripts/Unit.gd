class_name Unit

extends Node3D

# System vars
var _unitID: int = -1
var _targetID: int = -1
var _targetObj: Object = null

# Components
@onready var mesh: Node3D = $Mesh

# Signals
signal OnRequireTarget(id: int)
signal OnDie()

enum HealthState { Healthy, Dazed, Injured, Dead }
var currentState = HealthState.Healthy

func Setup(id: int, battleStart: Signal) -> void:
	_unitID = id
	battleStart.connect(_onBattleBegin)

#region Targeting

func SetTarget(targetID: int, targetObj: Object) -> void:
	_clearTarget()

	_targetID = targetID
	_targetObj = targetObj

	if _targetObj and _targetObj.has_signal("OnDie"):
		_targetObj.connect("OnDie", Callable(self, "_onTargetDie"))

func _clearTarget() -> void:
	if _targetObj and _targetObj.has_signal("OnDie"):
		var callable : Callable = Callable(self, "_onTargetDie")
		if _targetObj.is_connected("OnDie", callable):
			_targetObj.disconnect("OnDie", callable)

	_targetID = -1
	_targetObj = null

func GetTargetID() -> int:
	return _targetID

func UpdateTarget() -> void:
	OnRequireTarget.emit(_unitID)
#endregion

#region Signal Methods

func _onBattleBegin() -> void:
	OnRequireTarget.emit(_unitID)
	
func _onTargetDie() -> void:
	_clearTarget()
	
	OnRequireTarget.emit(_unitID)
#endregion

# Increments enemy state each time function is called
func TakeDamage() -> void:
	
	if(currentState == HealthState.Dead):
		print("Tried to kill a dead enemy")
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Dead):
		_die()

func _die() -> void:
	OnDie.emit()
	
	mesh.hide()
	process_mode = 0
