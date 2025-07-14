class_name UnitManager

extends Node

var _unitPositions: PackedVector2Array
var _unitStartingPositions: PackedVector2Array
var _prevUnitPositions: PackedVector2Array
var _unitNodes: Array[Unit]

# Movement scalars
const _unitMoveSpeed: float = 2
const _unitRotSpeed: float = .5
const _unitStopDist: float = .5

# Offset scalars
const _unitSeparation: float = 2
const _offsetFromCenter: float = 3 

# Partitions
var numPartitions : int = 4
var partitionTick : float = 1.5

# Unit Prefabs
var _armyAUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit: Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")

# Signals
signal OnBattleBegin

# System vars
var armyASize: int
var tickTimer: float = 0
var partitionSize : int = 0
var currentPartitionIndex : int = 0

#region Extensions
func _ready() -> void:
	
	# Get networked values from singleton
	armyASize = 512
	var armyBSize: int = 512
	var randSeed: int = 64
	
	# Init ECS arrays
	var totalUnits: int = armyASize + armyBSize
	
	_unitPositions.clear()
	_unitPositions.resize(totalUnits)
	
	_unitStartingPositions.clear()
	_unitStartingPositions.resize(totalUnits)
	
	_prevUnitPositions.clear()
	_prevUnitPositions.resize(totalUnits)
	
	_unitNodes.clear()
	_unitNodes.resize(totalUnits)
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_generateArmies(_unitNodes.size())
	partitionSize = _unitNodes.size() / numPartitions
	
	OnBattleBegin.emit()

func _physics_process(delta: float) -> void:
	_updateUnitPositions(delta)

func _process(delta: float) -> void:
	_updateUnitNodes()
	
	# Update unit targets in partitions
	tickTimer += delta
	if tickTimer > partitionTick:
		var start: int = partitionSize * currentPartitionIndex
		var end: int = _unitNodes.size() if currentPartitionIndex == numPartitions - 1 else start + partitionSize
		
		# Only update units in the current partition
		for u in range(start, end):
			var unit: Unit = _unitNodes[u]
			unit.UpdateTarget()
		
		# Advance partition
		currentPartitionIndex = (currentPartitionIndex + 1) % numPartitions
		tickTimer = 0
#endregion

#region Army Generation

func _generateArmies(armySize: int) -> void:
	var currentPartitionIndex : int= 0
	
	var armyBSize := armySize - armyASize
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

func _spawnUnit(id: int, pos: Vector3) -> void:
	
	# Find mesh
	var unitMesh:= _armyAUnit if id < armyASize else _armyBUnit
	
	# Spawn and initialize the unit
	var instance: Unit = unitMesh.instantiate()
	add_child(instance)
	instance.position = pos
	instance.Setup(id, OnBattleBegin)
	instance.OnRequireTarget.connect(_onUnitRequireTarget)
	
	_unitPositions[id] = Vector2(pos.x, pos.z)
	_unitStartingPositions[id] = Vector2(pos.x, pos.z)
	_unitNodes[id] = instance

#endregion

#region Unit Positioning

func _findClosestUnit(unitID: int) -> int:
	var start: int = armyASize if unitID < armyASize else 0
	var end: int = _unitPositions.size() if unitID < armyASize else armyASize
	
	var closestUnit: int
	var minDistance: float = INF
	
	for u in range(start, end):
		var dist_sq: float = _unitPositions[unitID].distance_squared_to(_unitPositions[u])
		if dist_sq < minDistance:
			minDistance = dist_sq
			closestUnit = u
	
	return closestUnit

func _updateUnitPositions(time: float) -> void:	
	# calculate the next position for each unit (step)
	for n in range(0, _unitPositions.size()):
		# Store previous unit positions
		_prevUnitPositions[n] = _unitPositions[n]
		
		# Get target position
		var targetID: int = _unitNodes[n].GetTargetID()
		
		# Step unit pos in the direction of its target over time
		if(!_isStopped(n)):
			var targetPos: Vector2 = _unitPositions[targetID]
			_unitPositions[n] += (targetPos - _unitPositions[n]).normalized() * _unitMoveSpeed * time

func _updateUnitNodes() -> void:
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

#region Signal Functions

func _onUnitRequireTarget(unitID: int)-> void:
	var unitNode: Unit = _unitNodes[unitID]
	
	var targetID: int = _findClosestUnit(unitID)
	
	unitNode.SetTarget(targetID, _unitNodes[targetID].OnDie)
#endregion

#region Helper Functions

func _isDead(id: int) -> bool:
	_unitPositions[id] = _unitStartingPositions[id]
	return false

func _isStopped(id: int) -> bool:
	var unit: Unit = _unitNodes[id]
	
	if unit.GetTargetID() >= 0:
		var sqr_dist: float = _unitPositions[id].distance_squared_to(_unitPositions[unit.GetTargetID()])
		return sqr_dist < _unitStopDist * _unitStopDist
	else: return false

func _getRandOffset(pos: Vector3) -> Vector3:
	
	var offsetX: float = randf() * .5
	var offsetZ: float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)
#endregion
