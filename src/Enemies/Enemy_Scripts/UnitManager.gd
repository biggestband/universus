class_name UnitManager

extends Node

# ECS
var _unitStartingPositions: PackedVector2Array
var _unitPositions: PackedVector2Array
var _prevUnitPositions: PackedVector2Array
var _unitNodes: Array[Unit]
var _activeNodeIDs: Array[int]

# Simulation variables
const _maxUnitCount: float = 32 # the maximum count of units that can be present in the fight per side

# Movement scalars
const _unitRotSpeed: float = .5
const _unitStopDist: float = 2

# Generation
var _armyAUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit: Resource = preload("res://Enemies/Enemy_Prefabs/lord_Unit.tscn")
const _unitSeparation: float = 2
const _offsetFromCenter: float = 3 

# System vars
var armyAStartSize: int
var armyBStartSize: int
var curArmyASize: int
var curArmyBSize: int

var tickTimer: float = 0
var partitionTick: float = .2

# SHould be called on start. It creates all of the units and sets them up for later use
func _initUnitPool() -> void:
	# Get networked values from singleton
	armyAStartSize = 16
	armyBStartSize = 16
	var randSeed: int = 64
	
	# Init ECS arrays
	var totalUnits: int = armyAStartSize + armyBStartSize
	
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
	_spawnArmyGrid(armyAStartSize, 1, 0)
	_spawnArmyGrid(armyBStartSize, -1, armyAStartSize)
	curArmyASize = armyAStartSize
	curArmyBSize = armyBStartSize
	
	# Start the first batch of troops
	for u in curArmyASize:
		_requestUnit(true)
	for u in curArmyBSize:
		_requestUnit(false)

#region Extensions

func _ready() -> void:
	_initUnitPool()

func _physics_process(delta: float) -> void:
	_stepUnitTargets(delta)
	_stepUnitPositions(delta)

func _process(delta: float) -> void:
	_updateVisualalizedNodes()
#endregion

#region Army Generation

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
	var unitMesh: Resource = _armyAUnit if id < armyAStartSize else _armyBUnit
	
	# Spawn the unit node
	var instance: Unit = unitMesh.instantiate()
	add_child(instance)
	instance.position = pos
	instance.SetupNode(id, id < armyAStartSize)
	instance.OnDie.connect(_onUnitDie)
	
	# Define start position
	_unitStartingPositions[id] = Vector2(pos.x, pos.z)
	_unitNodes[id] = instance

# Attempts to pull a unit node from the pool and initiate them
func _requestUnit(isTeamA: bool) -> void:
	var remainingOnTeam: int = curArmyASize if isTeamA else curArmyBSize
	if(remainingOnTeam > 0):
		var start: int = armyAStartSize if !isTeamA else 0
		var end: int = _unitPositions.size() if !isTeamA else armyAStartSize
		
		# Find the first inactive unit from the team
		for n in range(start, end):
			if(_isUnitSimulated(n)):
				continue
			
			var unitNode: Unit = _unitNodes[n]
			var startPos: Vector2 = _unitStartingPositions[n]
			_prevUnitPositions[n] = startPos
			_unitPositions[n] = startPos
			unitNode.InitNode()
			
			if(isTeamA):
				curArmyASize += 1
			else: curArmyBSize += 1
			_activeNodeIDs.push_back(n)
			break

# Resets a unit node and adds them back to the pool
func _resetUnit(id: int) -> void:
	var unitNode: Unit = _unitNodes[id]
	unitNode.ResetNode()
	
	# Reset nodes position data and return to pool
	var startPos: Vector2 = _unitStartingPositions[id]
	_prevUnitPositions[id] = Vector2(startPos.x, startPos.y)
	_unitPositions[id] = Vector2(startPos.x, startPos.y)
	_activeNodeIDs.erase(id)
	
	# Request a replacement
	var isArmyA: int = unitNode.IsArmyA()
	if(isArmyA):
		curArmyASize -= 1
	else: curArmyBSize -= 1
	_requestUnit(isArmyA)

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
		# Only update units in the current partition
		for n: int in _activeNodeIDs:
			
			if(!_isUnitSimulated(n)):
				continue
			
			var unitNode: Unit = _unitNodes[n]
			var targetID: int = _findClosestTarget(n)
			# Set the units target to the closest unit
			if(unitNode.GetTargetID() != targetID):
				unitNode.SetTarget(targetID)
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

func _onUnitDie(unitID: int, isArmyA: bool) -> void:
	_resetUnit(unitID)
#endregion

#region Helper Functions

func _isUnitSimulated(unitID: int) -> bool:
	var unit: Unit = _unitNodes[unitID]
	var isActive: bool = unit.GetUnitActive()
	var isDead: bool = unit.currentState == Unit.HealthState.Dead
	return isActive && !isDead && !unit.GetTweening()

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
	var start: int = armyAStartSize if unitID < armyAStartSize else 0
	var end: int = _unitPositions.size() if unitID < armyAStartSize else armyAStartSize
	
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
