class_name UnitManager

extends Node

# ECS
var _unitPositions: PackedVector2Array
var _prevUnitPositions: PackedVector2Array
var _unitNodes: Array[Unit]

# Simulation variables
const _maxUnitsPerTeam: int = 32
const numPartitions: int = 4
const partitionTick: float = .2

# Movement scalars
const _unitRotSpeed: float = .5
const _unitStopDist: float = 2

# Generation
var _armyAUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit: Resource = preload("res://Enemies/Enemy_Prefabs/lord_Unit.tscn")
const _unitSeparation: float = 2
const _offsetFromCenter: float = 15

# System vars
var armyAStartSize: int

# The amount of units remaining
var _armyAHealth: int
var _armyBHealth: int 

 # The amount of troops on the field
var _armyAActiveUnits: int
var _armyBActiveUnits: int

var currentPartitionIndex: int
var partitionSize: int
var tickTimer: float = 0

# Should be called on start. It creates all of the units and sets them up for later use
func _initUnitPool() -> void:
	# Get networked values from singleton
	armyAStartSize = 64
	var armyBStartSize: int  = 128
	var randSeed: int = 64
	
	# Init ECS arrays
	var totalUnits: int = armyAStartSize + armyBStartSize
	partitionSize = totalUnits / numPartitions
	
	_unitPositions.clear()
	_unitPositions.resize(totalUnits)
	
	_prevUnitPositions.clear()
	_prevUnitPositions.resize(totalUnits)
	
	_unitNodes.clear()
	_unitNodes.resize(totalUnits)
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_spawnArmy(armyAStartSize, true, 0)
	_spawnArmy(armyBStartSize, false, armyAStartSize)
	_armyAHealth = armyAStartSize
	_armyBHealth = armyBStartSize
	
	# Start the first batch of troops
	for u in armyAStartSize:
		_requestUnit(true)
	for u in armyBStartSize:
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

func _spawnArmy(size: int, isArmyA: bool, idOffset: int) -> void:
	var gridSize: int = ceil(sqrt(size))
	var id: int = 0
	
	for x in gridSize:
		for z in gridSize:
			if id < size:
				_spawnUnit(id + idOffset, isArmyA)
				id += 1

#endregion

#region Unit Management

# Creates a unit node
func _spawnUnit(id: int, isArmyA: bool) -> void:
	
	# Find mesh
	var unitMesh: Resource = _armyAUnit if isArmyA else _armyBUnit
	
	# Spawn the unit node
	var instance: Unit = unitMesh.instantiate()
	_unitNodes[id] = instance
	
	# Setup node instance
	add_child(instance)
	instance.SetupNode(id, isArmyA)
	instance.OnDie.connect(_onUnitDie)

# Attempts to pull a unit node from the pool and initiate them
func _requestUnit(isArmyA: bool) -> void:
	var teamHealth: int = _armyAHealth if isArmyA else _armyBHealth
	var activeUnits: int = _armyAActiveUnits if isArmyA else _armyBActiveUnits
	if(teamHealth > 0 && activeUnits < _maxUnitsPerTeam):
		var start: int = 0 if isArmyA else armyAStartSize
		var end: int = armyAStartSize if isArmyA else _unitPositions.size()
		
		# Find the first inactive unit from the team
		for nodeID in range(start, end):
			if(_isUnitSimulated(nodeID)):
				continue
			var unitNode: Unit = _unitNodes[nodeID]
			
			# Choose field side
			var fieldSide: int = 1 if isArmyA else -1
			var offsetFromCenter: float = _offsetFromCenter * fieldSide
			var startPos: Vector2 = _getRandOffset(Vector2(offsetFromCenter, 1))
			_prevUnitPositions[nodeID] = startPos
			_unitPositions[nodeID] = startPos
			unitNode.position = Vector3(startPos.x, 0, startPos.y)
			
			unitNode.InitNode()
			
			if(isArmyA):
				_armyAActiveUnits += 1
			else: 
				_armyBActiveUnits += 1
			break

# Resets a unit node and adds them back to the pool
func _resetUnit(id: int) -> void:
	var unitNode: Unit = _unitNodes[id]
	unitNode.ResetNode()

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
		for unitID in range(start, end):
			
			if(!_isUnitSimulated(unitID)):
				continue
			var unit: Unit = _unitNodes[unitID]
			var targetID: int = _findClosestTarget(unitID, unit.IsArmyA())
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

#region Signals

func _onUnitDie(unitID: int, isArmyA: bool) -> void:
	# Return the unit to the pool
	_resetUnit(unitID)
	
	# Request a replacemnt
	if(isArmyA):
		_armyAHealth -= 1
		_armyAActiveUnits -= 1
		print("Army A Health:" + str(_armyAHealth))
		print("Army A Active Units:" + str(_armyAActiveUnits))
	else:
		_armyBHealth -= 1
		_armyBActiveUnits -= 1
		print("Army B Health:" + str(_armyBHealth))
		print("Army B Active Units:" + str(_armyBActiveUnits))
	
	_requestUnit(isArmyA)
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

func _findClosestTarget(unitID: int, isArmyA: bool) -> int:
	var start: int = armyAStartSize if isArmyA else 0
	var end: int = _unitPositions.size() if isArmyA else armyAStartSize
	
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
	var offsetX: float = randf() * 2
	var offsetY: float = randf() * 2
	return pos + Vector2(offsetX, offsetY)
#endregion
