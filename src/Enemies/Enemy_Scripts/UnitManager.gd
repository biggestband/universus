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
	_generateArmy(units.size())

func _process(delta: float) -> void:
	# calculate positions
	for n in range(0, units.size()):
		var posfx : float = move_toward(units[n].x, 0, delta * _unitMoveSpeed)
		var posfy : float = move_toward(units[n].y, 0, delta * _unitMoveSpeed)
		var pos : Vector2 = Vector2(posfx, posfy)
		units[n] = pos
	
	# send position data to units (node)
	for n in range(0, units.size()):
		var pos : Vector2 = units[n]
		if unitNodes[n] == null:
			continue
		unitNodes[n].position = Vector3(pos.x, 0, pos.y)

func _generateArmy(armySize: int) -> void:

	var armyBSize = armySize - armyASize
	
	# Determine army size as a grid on the field
	var gridASize: int = ceil(sqrt(armyASize))
	var gridBSize: int = ceil(sqrt(armyBSize))
	
	var aZOffset: float = gridASize * .5
	var bZOffset: float = gridBSize * .5
	
	var fieldSideA: int = 1 
	var fieldSideB: int = -1
	
	var offsetFromCenterA: float = _offsetFromCenter * fieldSideA
	var offsetFromCenterB: float = _offsetFromCenter * fieldSideB
	
	# Create unit instances on each side of the field
	var id : int = 0
	for x in gridASize:
		for z in gridASize:
			if id < armyASize:
				_spawnUnit(id,
				_getRandOffset(Vector3(offsetFromCenterA + (x * _unitSeparation) * fieldSideA, 1, (aZOffset - z) * _unitSeparation)),)
				id += 1
	id = 0
	for x in gridBSize:
		for z in gridBSize:
			if id < armyBSize:
				_spawnUnit(id + armyASize,
				_getRandOffset(Vector3(offsetFromCenterB + (x * _unitSeparation) * fieldSideB, 1, (bZOffset - z) * _unitSeparation)),)
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
