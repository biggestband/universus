class_name Unit

extends Node3D

# System vars

# Components
@onready var mesh: Node3D = $Mesh

# Signals
signal OnRequireTarget(id: int)

# Knockback
@export var _knockbackDur: float = .2
var _isTweening: bool = false
var _startPosition: Vector3
var _endPosition: Vector3
var _lerpTimer: float
var _lerpValXZ: float
var _lerpValY: float

# State
var _unitID: int = -1
var _targetID: int = -1
enum HealthState { Healthy, Dazed, Injured, Dead }
var currentState = HealthState.Healthy

func _process(delta: float) -> void:
	if(_isTweening && _lerpTimer <= _knockbackDur):
		_lerpTimer += delta
		var scaledLerp: float = _lerpTimer * (1 / _knockbackDur)
		_lerpValY = easeOutInCubic(scaledLerp)
		_lerpValXZ = easeOutCubic(scaledLerp)
		var horiz: Vector3 = lerp(_startPosition, _endPosition, _lerpValXZ)
		var vert: float = _endPosition.y + (_lerpValY * 2)
		self.position = Vector3(horiz.x, vert, horiz.z)
		if(_lerpTimer >= _knockbackDur):
			_isTweening = false
			_lerpTimer = 0

func Setup(id: int, battleStart: Signal) -> void:
	_unitID = id
	battleStart.connect(_onBattleBegin)

#region Targeting

func SetTarget(targetID: int) -> void:
	_targetID = targetID

func GetTargetID() -> int:
	return _targetID

func UpdateTarget() -> void:
	OnRequireTarget.emit(_unitID)
#endregion

#region Signal Methods

func _onBattleBegin() -> void:
	OnRequireTarget.emit(_unitID)

#endregion

# Increments enemy state each time function is called
func TakeDamage(endPosition: Vector2) -> void:
	_startPosition = self.position;
	_endPosition = Vector3(endPosition.x, 1, endPosition.y)
	
	if(currentState == HealthState.Dead):
		print("Tried to kill a dead enemy")
	
	# Ticks health state
	currentState += 1
	
	if(currentState == HealthState.Dead):
		_die()

func _die() -> void:
	mesh.hide()
	process_mode = 0

#region Tweening

func SetTweening(isTweening: bool) -> void:
	_isTweening = isTweening

func GetTweening() -> bool:
	return _isTweening

func easeOutInCubic(x: float) -> float:
	if x < 0.5:
		# Ease out cubic from 0 to 1
		return 1 - pow(1 - (x * 2), 3)
	else:
		# Mirror the curve back down to 0
		return 1 - pow((x - 0.5) * 2, 3)

func easeOutCubic(x: float) -> float:
	return 1 - pow(1 - x, 3);
#endregion
