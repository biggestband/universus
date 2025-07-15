class_name UnitManager

extends Node

var _unitStartingPositions: PackedVector2Array
var _unitPositions: PackedVector2Array
var _prevUnitPositions: PackedVector2Array
var _unitNodes: Array[Unit]

# Movement scalars
const _unitRotSpeed: float = .5
const _unitStopDist: float = 2

# Generation
var _armyAUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit: Resource = preload("res://Enemies/Enemy_Prefabs/lord_Unit.tscn")
const _unitSeparation: float = 2
const _offsetFromCenter: float = 3 
var numPartitions : int = 4
var partitionTick : float = .2

# System vars
var armyASize: int
var tickTimer: float = 0
var partitionSize : int = 0
var currentPartitionIndex: int = 0

func _StartBattle() -> void:
	# Get networked values from singleton
	armyASize = 16
	var armyBSize: int = 16
	var randSeed: int = 64
	
	# Init ECS arrays
	var totalUnits: int = armyASize + armyBSize
	
	_unitStartingPositions.clear()
	_unitStartingPositions.resize(totalUnits)
	
	_unitPositions.clear()
	_unitPositions.resize(totalUnits)
	
	_prevUnitPositions.clear()
	_prevUnitPositions.resize(totalUnits)
	
	_unitNodes.clear()
	_unitNodes.resize(totalUnits)
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_generateArmies(_unitNodes.size())
	partitionSize = _unitNodes.size() / numPartitions
	
	for n in range(_unitNodes.size()):
		_unitNodes[n].SetTarget(_findClosestTarget(n))

#region Extensions

func _ready() -> void:
	_StartBattle()

func _physics_process(delta: float) -> void:
	_stepUnitTargets(delta)
	_stepUnitPositions(delta)

func _process(delta: float) -> void:
	_updateVisualalizedNodes()
#endregion

#region Army Generation

func _generateArmies(armySize: int) -> void:
	var armyBSize: int = armySize - armyASize
	_spawnArmyGrid(armyASize, 1, 0)
	_spawnArmyGrid(armyBSize, -1, armyASize)

func _spawnArmyGrid(size: int, fieldSide: int, idOffset: int) -> void:
	var gridSize: int = ceil(sqrt(size))
	var zOffset: float = gridSize * 0.5
	var offsetFromCenter: float = _offsetFromCenter * fieldSide
	var id: int = 0
	
	for x in gridSize:
		for z in gridSize:
			if id < size:
				var position: Vector3 = Vector3(
					offsetFromCenter + (x * _unitSeparation) * fieldSide,
					1,
					(zOffset - z) * _unitSeparation
				)
				_spawnUnit(id + idOffset, _getRandOffset(position))
				id += 1

#endregion

#region Unit Management

# Creates a unit node
func _spawnUnit(id: int, pos: Vector3) -> void:
	
	# Find mesh
	var unitMesh: Resource = _armyAUnit if id < armyASize else _armyBUnit
	
	# Spawn the unit node
	var instance: Unit = unitMesh.instantiate()
	add_child(instance)
	instance.position = pos
	instance.SetupNode(id)
	
	# Define start position
	_unitStartingPositions[id] = Vector2(pos.x, pos.z)
	_unitNodes[id] = instance

# Pulls a unit node from the pool and initiates them
func _initUnit(id: int, pos: Vector2) -> void:
	
	_prevUnitPositions[id] = Vector2(pos.x, pos.y)
	_unitPositions[id] = Vector2(pos.x, pos.y)
	
	var unit: Unit = _unitNodes[id]
	unit.InitNode()

# Resets a unit node and adds them back to the pool
func _resetUnit(id: int) -> void:
	
	var unit: Unit = _unitNodes[id]
	unit.ResetNode()
	
	var startPos: Vector2 = _unitStartingPositions[id]
	_prevUnitPositions[id] = Vector2(startPos.x, startPos.y)
	_unitPositions[id] = Vector2(startPos.x, startPos.y)
	pass

#endregion

#region Simulation

func _stepUnitPositions(delta: float) -> void:	
	# calculate the next position for each unit (step)
	for n in range(0, _unitPositions.size()):
		
		# Store previous unit positions
		_prevUnitPositions[n] = _unitPositions[n]
		
		if(!_isUnitSimulated(n)):
			continue
		
		var unit: Unit = _unitNodes[n]
		var targetID: int = unit.GetTargetID()
		var moveSpeed: float = unit.GetMovespeed()
		
		if(!_isUnitAtDestination(n)):
			# Step unit pos in the direction of its target over time
			var targetPos: Vector2 = _unitPositions[targetID]
			_unitPositions[n] += (targetPos - _unitPositions[n]).normalized() * moveSpeed * delta
		else: if (_isUnitSimulated(targetID)): 
			_attackTarget(n, targetID)

func _stepUnitTargets(delta: float):
	# Update unit targets in partitions
	tickTimer += delta
	if tickTimer > partitionTick:
		var start: int = partitionSize * currentPartitionIndex
		var end: int = _unitNodes.size() if currentPartitionIndex == numPartitions - 1 else start + partitionSize
		
		# Only update units in the current partition
		for n in range(start, end):
			
			if(!_isUnitSimulated(n)):
				continue
			
			var unit: Unit = _unitNodes[n]
			var targetID: int = _findClosestTarget(n)
			# Set the units target to the closest unit
			if(unit.GetTargetID() != targetID):
				unit.SetTarget(targetID)
		
		# Advance partition
		currentPartitionIndex = (currentPartitionIndex + 1) % numPartitions
		tickTimer = 0

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
			var targetBasis: Basis = Basis().looking_at(targetDir, Vector3.UP)
			unitTransform.basis = unitTransform.basis.slerp(targetBasis, fract * _unitRotSpeed)
			unit.transform = unitTransform
#endregion

#region Helper Functions

func _isUnitSimulated(unitID: int) -> bool:
	var unit: Unit = _unitNodes[unitID]
	var isDead: bool = unit.currentState == Unit.HealthState.Dead
	return !isDead && !unit.GetTweening()

func _attackTarget(unitID: int, targetID) -> void:
	if(_isUnitSimulated(targetID)):
		var instegatorPos: Vector2 = _unitPositions[unitID]
		var victimPos: Vector2 = _unitPositions[targetID]
		var attackDir: Vector2 = (victimPos - instegatorPos).normalized()
	
		var victim: Unit = _unitNodes[targetID]
	
		var randKnockback: float = randf_range(4,7)
		var endPos2D: Vector2 = victimPos + (attackDir * randKnockback)
		victim.TakeDamage(endPos2D)
		victim.SetTweening(true)
		_prevUnitPositions[targetID] = endPos2D
		_unitPositions[targetID] = endPos2D

func _findClosestTarget(unitID: int) -> int:
	var start: int = armyASize if unitID < armyASize else 0
	var end: int = _unitPositions.size() if unitID < armyASize else armyASize
	
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
	var unit: Unit = _unitNodes[unitID]
	
	if unit.GetTargetID() >= 0:
		var sqr_dist: float = _unitPositions[unitID].distance_squared_to(_unitPositions[unit.GetTargetID()])
		return sqr_dist < _unitStopDist * _unitStopDist
	else: 
		return true

func _getRandOffset(pos: Vector3) -> Vector3:
	
	var offsetX: float = randf() * .5
	var offsetZ: float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)
#endregion
