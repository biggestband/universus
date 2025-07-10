class_name UnitManager2

extends Node

signal OnBattleStart

var units : PackedVector2Array
var targets : PackedVector2Array
var armyASize: int

# Hard cap army size for performance
# This number *2 will be the max unit count on the field
const _maxArmySize : int = 256 

# Offset scalars
const _unitSeparation : float = 2
const _offsetFromCenter : float = 3 

var _armyAUnit : Resource = preload("res://Enemies/Enemy_Prefabs/Ridgeback_Unit.tscn")
var _armyBUnit : Resource = preload("res://Enemies/Enemy_Prefabs/Ridgeback_Unit.tscn")

func _ready() -> void:
	
	# Get networked values from signleton
	armyASize = 256
	var armyBSize : int = 64
	var randSeed : int = 64
	
	units.clear()
	units.resize(armyASize + armyBSize)
	
	targets.clear()
	targets.resize(armyASize + armyBSize)
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_generateArmy(units.size())
	
	# Start the battle
	OnBattleStart.emit()

func _process(delta: float) -> void:
	pass

func _generateArmy(armySize: int) -> void:
	
	print("Generating army of : " + str(armySize) + " units")
	
	var armyBSize = armySize - armyASize
	
	# Determine army size as a grid on the field
	var gridASize: int = ceil(sqrt(armyASize))
	var gridBSize: int = ceil(sqrt(armyBSize))
	var aZOffset: float = gridASize * .5
	var bZOffset: float = gridBSize * .5
	
	# Determine team
	var fieldSide: int = 1 if armyASize else -1
	var offsetFromCenter: float = _offsetFromCenter * fieldSide
	
	# Create unit instances on each side of the field
	var id : int = 0
	for x in gridASize:
		for z in gridASize:
			if id <= armyASize:
				_spawnUnit(id,
				_getRandOffset(Vector3(offsetFromCenter + (x * _unitSeparation) * fieldSide, 1, (aZOffset - z) * _unitSeparation)),)
					
				id += 1
	id = 0
	for x in gridBSize:
		for z in gridBSize:
			if id <= armyBSize:
				_spawnUnit(id,
				_getRandOffset(Vector3(offsetFromCenter + (x * _unitSeparation) * fieldSide, 1, (bZOffset - z) * _unitSeparation)),)
					
				id += 1

func _spawnUnit(id: int, pos: Vector3) -> void:
	
	# Find mesh
	var unitMesh:= _armyAUnit if id < armyASize else _armyBUnit
	
	# Spawn and initialize the unit
	var instance: Unit = unitMesh.instantiate()
	instance.position = pos
	instance.Setup(id, self)
	add_child(instance)
	
	instance.OnTargetRequired.connect(_onUnitRequireTarget)

func _getRandOffset(pos: Vector3) -> Vector3:
	
	var offsetX : float = randf() * .5
	var offsetZ : float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)

func _onUnitRequireTarget(unit: Unit)-> void:
	
	var closestTarget: int = _findClosestUnit(unit.ID)
	
	# Set closest target
	if !_isDead(closestTarget):
		unit.SetTarget(closestTarget)
	
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
