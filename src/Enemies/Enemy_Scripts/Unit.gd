class_name Unit

extends Node3D

const _knockbackDur: float = .5
const _stunDur: float = .75
const _attackCooldown: float = .3
const _maxMoveSpeed: float = 9
const _acceleration: float = 12

# --- System vars ---

# Signals
signal OnDie(unitID: int, isArmyA: bool)

# Components
@onready var mesh: Node3D = $Mesh

# Knockback
var _isTweening: bool = false
var _lerpStartPos: Vector3 = Vector3.ZERO
var _lerpEndPos: Vector3 = Vector3.ZERO
var _lerpStartRot: Vector3 = Vector3.ZERO
var _lerpEndRot: Vector3 = Vector3.ZERO
var _knockbackTimer: float = 0
var _lerpValXZ: float = 0
var _lerpValY: float = 0

# State
var _unitID: int = -1
var _isArmyA: bool
var _stunTimer: float = 0
var _cooldownTimer: float = 0
var _moveSpeed: float = 0

var _isUnitActive: bool = false
var _isCoolingDown: bool = false
var _targetID: int = -1
enum HealthState { Healthy, Dazed, Injured, Dead }
var currentState = HealthState.Healthy

func _process(delta: float) -> void:
	if(_isTweening):
		# Knockback timer
		if(_knockbackTimer <= _knockbackDur):
			# Scale to duration
			_knockbackTimer += delta
			var scaledLerp: float = _knockbackTimer * (1 / _knockbackDur)
			_lerpValY = easeOutInCubic(scaledLerp)
			_lerpValXZ = easeOutCubic(scaledLerp)
			
			# Pos interpolation
			var horiz: Vector3 = lerp(_lerpStartPos, _lerpEndPos, _lerpValXZ)
			var vert: float = _lerpEndPos.y + (_lerpValY * 2)
			self.position = Vector3(horiz.x, vert, horiz.z)
			
			# Rot interpolation
			if(currentState == HealthState.Injured):
				var new_rot: Vector3 = lerp(_lerpStartRot, _lerpEndRot, _lerpValXZ)
				self.rotation = new_rot
			
			if(_knockbackTimer >= _knockbackDur):
				VfxManager._spawnParticle3D.emit(VfxManager.VFX3D.Dizzy, Vector3(self.position.x, 2, self.position.z))
		
		# Stun Timer
		if(_isTweening && _knockbackTimer >= _knockbackDur && _stunTimer <= _stunDur):
			_stunTimer += delta
			
			# Stop tweening
			if(_stunTimer >= _stunDur):
				_isTweening = false
				_knockbackTimer = 0
				_stunTimer = 0
				_lerpValXZ = 0.0
				_lerpValY = 0.0
				
				# Ticks health state
				currentState += 1
			
				# Kill unit after lerp
				if(currentState == HealthState.Dead):
					_die()
	else : if(_isUnitActive && _moveSpeed <= _maxMoveSpeed):
		_moveSpeed = min(_moveSpeed + (_acceleration * delta), _maxMoveSpeed)
	
	if(_isCoolingDown && _cooldownTimer > 0):
		_cooldownTimer -= delta
		if(_cooldownTimer <= 0):
			_isCoolingDown = false

#region State

func GetUnitActive() -> bool:
	return _isUnitActive

func IsArmyA() -> bool:
	return _isArmyA

func GetMovementSpeed() -> float:
	return _moveSpeed

func GetCoolingDown() -> bool:
	return _isCoolingDown

# Should be called when a unit is first created
func SetupUnit(unitID: int, isArmyA: bool) -> void:
	ResetUnit()
	_unitID = unitID
	_isArmyA = isArmyA

# Should be called when a unit is being sent into battle
func InitUnit() -> void:
	_isUnitActive = true
	currentState = HealthState.Healthy
	
	mesh.show()
	process_mode = 1
	
	await get_tree().process_frame
	VfxManager._spawnParticle3D.emit(VfxManager.VFX3D.SpawnOTU if _isArmyA else VfxManager.VFX3D.SpawnDurham, self.position)

func ResetUnit() -> void:
	_isUnitActive = false
	mesh.hide()
	process_mode = 0
	self.rotation = Vector3(0,0,0)
	
	_moveSpeed = 0
	
	# Reset system vars related to knockback tweening
	_isTweening = false
	_knockbackTimer = 0.0
	_stunTimer = 0.0
	_cooldownTimer = 0.0
	_isCoolingDown = false
	_lerpValXZ = 0.0
	_lerpValY = 0.0
	_lerpStartPos = Vector3.ZERO
	_lerpEndPos = Vector3.ZERO
	_lerpStartRot = Vector3.ZERO
	_lerpEndRot = Vector3.ZERO
	
	# Reset state vars
	_targetID = -1
#endregion

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
	
	_moveSpeed = 0
	_isTweening = true
	_lerpStartPos = self.position;
	_lerpEndPos = Vector3(endPosition.x, 1, endPosition.y)
	_lerpStartRot = self.rotation
	_lerpEndRot = _lerpStartRot + Vector3(1, 0, 0) * deg_to_rad(90)

# Should be called when a unit attempts to attack another
func Attack(attackPosition: Vector3) -> void:
	_isCoolingDown = true
	_moveSpeed = 0
	_cooldownTimer = _attackCooldown
	VfxManager._spawnParticle3D.emit(VfxManager.VFX3D.Hit, attackPosition)

func _die() -> void:
	ResetUnit()
	OnDie.emit(_unitID)
	
	await get_tree().process_frame	
	VfxManager._spawnParticle3D.emit(VfxManager.VFX3D.DeathOTU if _isArmyA else VfxManager.VFX3D.DeathDurham, self.position)

#endregion

#region Helper Methods

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
