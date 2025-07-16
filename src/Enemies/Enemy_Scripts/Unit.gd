class_name Unit

extends Node3D

# --- System vars ---

# Signals
signal OnDie(unitID: int, isArmyA: bool)

# Components
@onready var mesh: Node3D = $Mesh

# Knockback
@export var _knockbackDur: float = .4
var _isTweening: bool = false
var _lerpStartPos: Vector3
var _lerpEndPos: Vector3
var _lerpTimer: float
var _lerpValXZ: float
var _lerpValY: float

# State
var _unitID: int = -1
var _isArmyA: bool

var _isUnitActive: bool = false
var _targetID: int = -1
enum HealthState { Healthy, Dazed, Injured, Dead }
var currentState = HealthState.Healthy

func _process(delta: float) -> void:
	if(_isTweening && _lerpTimer <= _knockbackDur):
		_lerpTimer += delta
		var scaledLerp: float = _lerpTimer * (1 / _knockbackDur)
		_lerpValY = easeOutInCubic(scaledLerp)
		_lerpValXZ = easeOutCubic(scaledLerp)
		var horiz: Vector3 = lerp(_lerpStartPos, _lerpEndPos, _lerpValXZ)
		var vert: float = _lerpEndPos.y + (_lerpValY * 2)
		self.position = Vector3(horiz.x, vert, horiz.z)
		if(_lerpTimer >= _knockbackDur):
			_isTweening = false
			_lerpTimer = 0
			_lerpValXZ = 0.0
			_lerpValY = 0.0
			
			# Ticks health state
			currentState += 1
			
			# Kill unit after lerp
			if(currentState == HealthState.Dead):
				_die()

#region State

func GetUnitActive() -> bool:
	return _isUnitActive

func IsArmyA() -> bool:
	return _isArmyA

# Should be called when a unit is first created
func SetupNode(unitID: int, isArmyA: bool) -> void:
	ResetNode()
	_unitID = unitID
	_isArmyA = isArmyA

# Should be called when a unit is being sent into battle
func InitNode() -> void:
	_isUnitActive = true
	currentState = HealthState.Healthy
	
	mesh.show()
	process_mode = 1

func ResetNode() -> void:
	_isUnitActive = false
	mesh.hide()
	process_mode = 0
	
	# Reset system vars related to knockback tweening
	_isTweening = false
	_lerpTimer = 0.0
	_lerpValXZ = 0.0
	_lerpValY = 0.0
	_lerpStartPos = Vector3.ZERO
	_lerpEndPos = Vector3.ZERO
	
	# Reset state vars
	_targetID = -1

#region

#region Targeting

func GetTargetID() -> int:
	return _targetID

func SetTarget(targetID: int) -> void:
	_targetID = targetID

#endregion

#region Combat

# Increments enemy state each time function is called
func TakeDamage(endPosition: Vector2) -> void:
	
	if(currentState == HealthState.Dead):
		return
	
	_isTweening = true
	_lerpStartPos = self.position;
	_lerpEndPos = Vector3(endPosition.x, 1, endPosition.y)

func _die() -> void:
	ResetNode()
	
	await get_tree().process_frame
	OnDie.emit(_unitID, _isArmyA)

#endregion

#region Tweening

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
