class_name UnitManager

extends Node

# Simulation variables
const _maxActiveUnitsPerTeam: int = 16 # The max number of units per team that can be active
const _numPartitions: int = 4
const _partitionTick: float = .2

# Movement scalars
const _unitRotSpeed: float = .5
const _unitStopDist: float = 2

# Unit Placement
const _unitSeparation: float = 2
const _offsetFromCenter: float = 20

# --- System vars ---

# ECS
var _unitPositions: PackedVector2Array
var _prevUnitPositions: PackedVector2Array
var _unitNodes: Array[Unit]

# Unit Meshes
var _armyAUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit: Resource = preload("res://Enemies/Enemy_Prefabs/lord_Unit.tscn")

# The amount of units remaining
var _armyAReserves: int 
var _armyBReserves: int 

var _totalUnits: int
var _currentPartitionIndex: int
var _partitionSize: int
var _tickTimer: float = 0

#region State

# Should be called on ready. It creates all of the units and sets them up for later use
func _initUnitPool() -> void:
	# Init ECS arrays
	_partitionSize = _maxActiveUnitsPerTeam / floor(_numPartitions)
	_totalUnits = _maxActiveUnitsPerTeam * 2
	
	_unitPositions.clear()
	_unitPositions.resize(_totalUnits)
	
	_prevUnitPositions.clear()
	_prevUnitPositions.resize(_totalUnits)
	
	_unitNodes.clear()
	_unitNodes.resize(_totalUnits)
	
	# Generate the armies
	_spawnArmy(_maxActiveUnitsPerTeam, true, 0)
	_spawnArmy(_maxActiveUnitsPerTeam, false, _maxActiveUnitsPerTeam)
	_updateVisualalizedNodes()
	
	_startBattle()

# Should be called when a new battle is started
func _startBattle() -> void:
	_armyAReserves = 76
	_armyBReserves = 76
	
	# Get networked values from singleton
	var randSeed: int = 64
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
		# Start the first batch of troops
	for u in _unitNodes:
		_respawnUnit(u._unitID)

func _endBattle():
	pass

#endregion

#region Extensions

func _ready() -> void:
	_initUnitPool()

func _physics_process(delta: float) -> void:
	_stepUnitTargets(delta)
	_stepUnitPositions(delta)

func _process(_delta: float) -> void:
	_updateVisualalizedNodes()

#endregion

#region Army Generation

func _spawnArmy(size: int, isArmyA: bool, idOffset: int) -> void:	
	for i in size:
		_createUnitInstance(i + idOffset, isArmyA)

#endregion

#region Unit Management

# Creates a unit node
func _createUnitInstance(unitID: int, isArmyA: bool) -> void:
	
	# Find mesh
	var unitMesh: Resource = _armyAUnit if isArmyA else _armyBUnit
	
	# Spawn the unit node
	var instance: Unit = unitMesh.instantiate()
	_unitNodes[unitID] = instance
	
	# Choose field side
	var fieldSide: int = 1 if isArmyA else -1
	var offsetFromCenter: float = _offsetFromCenter * fieldSide
	var startPos: Vector2 = _getRandOffset(Vector2(offsetFromCenter, 1))
	_prevUnitPositions[unitID] = startPos
	_unitPositions[unitID] = startPos
	
	add_child(instance)
	instance.OnDie.connect(_respawnUnit)
	instance.SetupUnit(unitID, isArmyA)

# Resets a unit and moves it back to its teams spawn
func _respawnUnit(unitID: int) -> void:
	var unitNode: Unit = _unitNodes[unitID]
	var isArmyA: bool = unitNode.IsArmyA()
	var teamHealth: int = _armyAReserves if isArmyA else _armyBReserves
	
	# Replace the unit if the team has units in reserves
	if(teamHealth >= 1):
		
		# Choose field side
		var fieldSide: int = 1 if isArmyA else -1
		var offsetFromCenter: float = _offsetFromCenter * fieldSide
		var startPos: Vector2 = _getRandOffset(Vector2(offsetFromCenter, 1))
		_prevUnitPositions[unitID] = startPos
		_unitPositions[unitID] = startPos
		
		if(isArmyA):
			_armyAReserves = max(0, _armyAReserves - 1)
		else:
			_armyBReserves = max(0, _armyBReserves - 1)
		unitNode.InitUnit()

#endregion

#region Unit Simulation

func _stepUnitPositions(delta: float) -> void:
	# calculate the next position for each unit (step)
	for n in range(0, _unitPositions.size()):
		
		# Store previous unit positions
		_prevUnitPositions[n] = _unitPositions[n]
		
		if(!_isUnitSimulated(n)):
			continue
		
		var unit: Unit = _unitNodes[n]
		var targetID: int = unit.GetTargetID()
		
		if(!_isUnitAtDestination(n)):
			# Step unit pos in the direction of its target over time
			var targetPos: Vector2 = _unitPositions[targetID]
			_unitPositions[n] += (targetPos - _unitPositions[n]).normalized() * 6 * delta
		else: if (_isUnitSimulated(targetID)): 
			_attackTarget(n, targetID)

func _stepUnitTargets(delta: float):
	# Update unit targets in partitions
	_tickTimer += delta
	if _tickTimer > _partitionTick:
		var start: int = _partitionSize * _currentPartitionIndex
		var end: int = _unitNodes.size() if _currentPartitionIndex == _numPartitions - 1 else start + _partitionSize
		
		# Only update units in the current partition
		for unitID in range(start, end):
			
			if(!_isUnitSimulated(unitID)):
				continue
			var unit: Unit = _unitNodes[unitID]
			var targetID: int = _findClosestTarget(unitID, unit.IsArmyA())
			# Set the units target to the closest unit
			if(unit.GetTargetID() != targetID):
				unit.SetTarget(targetID)
		
		# Advance partition
		_currentPartitionIndex = (_currentPartitionIndex + 1) % _numPartitions
		_tickTimer = 0

func _updateVisualalizedNodes() -> void:
	var fract: float = Engine.get_physics_interpolation_fraction()
	
	# send the step data to units and apply to position (node)
	for n in range(_unitPositions.size()):
		if _unitNodes[n] == null:
			continue
		var prev: Vector2 = _prevUnitPositions[n]
		var curr: Vector2 = _unitPositions[n]
		var interp: Vector2 = prev.lerp(curr, fract)
		
		# Set position
		var unit: Unit = _unitNodes[n]
		unit.position = Vector3(interp.x, 0, interp.y)
		
		# Set rotation
		var moveDir: Vector2 = (curr - prev).normalized()
		
		if moveDir.length() > 0.1:
			var targetDir: Vector3 = Vector3(moveDir.x, 0, moveDir.y)
			var unitTransform: Transform3D = unit.transform
			var targetBasis: Basis = Basis.looking_at(targetDir, Vector3.UP)
			unitTransform.basis = unitTransform.basis.slerp(targetBasis, fract * _unitRotSpeed)
			unit.transform = unitTransform
#endregion

#region Helper Functions

func _isUnitSimulated(unitID: int) -> bool:
	var unit: Unit = _unitNodes[unitID]
	var isActive: bool = unit.GetUnitActive()
	var isDead: bool = unit.currentState == Unit.HealthState.Dead
	return unitID != -1 && isActive && !isDead && !unit._isTweening

func _attackTarget(unitID: int, targetID) -> void:
	if(_isUnitSimulated(targetID)):
		var instegatorPos: Vector2 = _unitPositions[unitID]
		var victimPos: Vector2 = _unitPositions[targetID]
		var attackDir: Vector2 = (victimPos - instegatorPos).normalized()
	
		var instegator: Unit = _unitNodes[targetID]
		var victim: Unit = _unitNodes[targetID]
	
		var randKnockback: float = randf_range(4,7)
		var endPos2D: Vector2 = victimPos + (attackDir * randKnockback)
		var attackPos: Vector3 = instegator.position + Vector3(attackDir.x, 0, attackDir.y)
		instegator.Attack(attackPos)
		victim.TakeDamage(endPos2D)
		_prevUnitPositions[targetID] = endPos2D
		_unitPositions[targetID] = endPos2D

func _findClosestTarget(unitID: int, isArmyA: bool) -> int:
	var start: int = _maxActiveUnitsPerTeam if isArmyA else 0
	var end: int = _totalUnits if isArmyA else _maxActiveUnitsPerTeam
	
	var closestUnit: int = -1
	var minDistance: float = INF
	
	for n in range(start, end):

		if(!_isUnitSimulated(n)):
			continue
		
		var dist_sq: float = _unitPositions[unitID].distance_squared_to(_unitPositions[n])
		if dist_sq < minDistance:
			minDistance = dist_sq
			closestUnit = n
	
	return closestUnit

func _isUnitAtDestination(unitID: int) -> bool:
	var unitNode: Unit = _unitNodes[unitID]
	
	if unitNode.GetTargetID() >= 0:
		var sqr_dist: float = _unitPositions[unitID].distance_squared_to(_unitPositions[unitNode.GetTargetID()])
		return sqr_dist < _unitStopDist * _unitStopDist
	else: 
		return true

func _getRandOffset(pos: Vector2) -> Vector2:
	var offsetX: float = randf() * 10
	var offsetY: float = randf() * 10
	return pos + Vector2(offsetX, offsetY)
#endregion
