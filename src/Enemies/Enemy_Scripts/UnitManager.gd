class_name UnitManager

extends Node

var units : PackedVector2Array
var targets : PackedInt32Array
var unitNodes : Array[Node3D]

# Movement scalars
const _unitMoveSpeed : float = 2

# Offset scalars
const _unitSeparation : float = 2
const _offsetFromCenter : float = 3 

# Unit Prefabs
var _armyAUnit : Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")
var _armyBUnit : Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback_Unit.tscn")

# System vars
var armyASize: int

func _ready() -> void:
	
	# Get networked values from singleton
	armyASize = 256
	var armyBSize : int = 64
	var randSeed : int = 64
	
	# Init ECS arrays
	var totalUnits: int = armyASize + armyBSize
	
	units.clear()
	units.resize(totalUnits)
	
	targets.clear()
	targets.resize(totalUnits)
	
	unitNodes.clear()
	unitNodes.resize(totalUnits)
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_generateArmies(units.size())

func _process(delta: float) -> void:
	_calculateUnitPosition(delta)

func _generateArmies(armySize: int) -> void:
	var armyBSize := armySize - armyASize
	_spawnArmyGrid(armyASize, 1, 0)
	_spawnArmyGrid(armyBSize, -1, armyASize)

func _spawnArmyGrid(size: int, fieldSide: int, idOffset: int) -> void:
	var gridSize: int = ceil(sqrt(size))
	var zOffset : float = gridSize * 0.5
	var offsetFromCenter : float = _offsetFromCenter * fieldSide
	var id : int = 0
	
	for x in gridSize:
		for z in gridSize:
			if id < size:
				var position : Vector3 = Vector3(
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
	
	units[id] = Vector2(pos.x, pos.z)
	unitNodes[id] = instance

func _getRandOffset(pos: Vector3) -> Vector3:
	
	var offsetX : float = randf() * .5
	var offsetZ : float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)

func _onUnitRequireTarget(id: int)-> void:
	var closestTarget: int = _findClosestUnit(id)
	
	# Set closest target
	if ! _isDead(closestTarget):
		targets[id] = closestTarget
	
func _findClosestUnit(unitID: int) -> int:
	var start: int = armyASize if unitID < armyASize else 0
	var end: int = units.size() if unitID < armyASize else armyASize
	
	var closestUnit: int
	var min_distance : float
	
	for u in range(start, end):
		var dist: float = units[unitID].distance_to(units[u])
		if dist < min_distance:
			min_distance = dist
			closestUnit = u
	return closestUnit

func _isDead(id: int) -> bool:
	return false

func _calculateUnitPosition(time: float):
	# calculate positions
	for n in range(0, units.size()):
		var posfx : float = move_toward(units[n].x, 0, time)
		var posfy : float = move_toward(units[n].y, 0, time)
		var pos : Vector2 = Vector2(posfx, posfy)
		units[n] = pos
		
		# send position data to units (node)
	for n in range(0, units.size()):
		var pos : Vector2 = units[n]
		if unitNodes[n] == null:
			continue
		unitNodes[n].position = Vector3(pos.x, 0, pos.y)
