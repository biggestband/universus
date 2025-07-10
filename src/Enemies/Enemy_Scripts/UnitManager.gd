class_name UnitManager

extends Node

signal OnBattleStart

var _armyA : Array[Unit]
var _armyB : Array[Unit]

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
	var armyASize : int = 256
	var armyBSize : int = 64
	var randSeed : int = 64
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	# Generate the armies
	_generateArmy(armyASize, true)
	_generateArmy(armyBSize, false)
	print("Army A Length: " + str(len(_armyA)))
	print("Army B Length: " + str(len(_armyB)))
	
	# Start the battle
	OnBattleStart.emit()

func _process(delta: float) -> void:
	pass

func _generateArmy(armySize: int, isTeamA : bool) -> void:
	
	print("Generating army of : " + str(armySize) + " units")
	
	#var poolSize: int = _maxArmySize * 2
	
	# Determine army size as a grid on the field
	var gridSize: int = ceil(sqrt(armySize))
	var zOffset: float = gridSize * .5
	
	# Determine team
	var fieldSide: int = 1 if isTeamA else -1
	var offsetFromCenter: float = _offsetFromCenter * fieldSide
	var armyArr := _armyA if isTeamA else _armyB
	
	# Create unit instances on each side of the field
	var id : int = 0
	for x in gridSize:
		for z in gridSize:
			if id <= armySize:
				_spawnUnit(isTeamA,
				_getRandOffset(Vector3(offsetFromCenter + (x * _unitSeparation) * fieldSide, 1, (zOffset - z) * _unitSeparation)),
				armyArr)
					
				id += 1

func _spawnUnit(isTeamA: bool, pos: Vector3, armyArr: Array[Unit]) -> void:
	
	# Find mesh
	var unitMesh:= _armyAUnit if isTeamA else _armyBUnit
	
	# Spawn and initialize the unit
	var instance: Unit = unitMesh.instantiate()
	instance.position = pos
	instance.Setup(isTeamA, self)
	add_child(instance)
	
	# Add the unit to the corresponding team array
	armyArr.push_back(instance)
	instance.OnTargetRequired.connect(_onUnitRequireTarget)

func _getRandOffset(pos: Vector3) -> Vector3:
	
	var offsetX : float = randf() * .5
	var offsetZ : float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)

func _onUnitRequireTarget(unit: Unit)-> void:
	
	# Find opposing army array
	var oppArmy := _armyA if unit.IsTeamA else _armyB
	var closestTarget: Unit = _findClosestUnit(unit, oppArmy)
	
	# Set closest target
	if closestTarget != null:
		unit.SetTarget(closestTarget)
	
func _findClosestUnit(currentUnit: Unit, oppArmy: Array[Unit]) -> Unit:
	var closestUnit: Unit = null
	var min_distance := INF
	
	for enemy in oppArmy:
		var distance = currentUnit.position.distance_to(enemy.position)
		if distance < min_distance:
			min_distance = distance
			closestUnit = enemy
	return closestUnit
