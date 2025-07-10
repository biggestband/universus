extends Node

var _armyA : Array[RigidBody3D]
var _armyB : Array[RigidBody3D]

const _maxArmySize : int = 256 # Hard cap army sizes for performance
const _unitSeparation : float = 2
const _offsetFromCenter : float = 3 

var _armyAUnit : Resource = preload("res://Enemies/Enemy_Prefabs/ridgeback.tscn")
var _armyBUnit : Resource = preload("res://Enemies/Enemy_Prefabs/EnemyB.tscn")

func _ready() -> void:
	
	# Get networked values from signleton
	var armyASize : int = 256
	var armyBSize : int = 64
	var randSeed : int = 64
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	_generateArmy(armyASize, true)
	_generateArmy(armyBSize, false)
	
	print("Army A Length: " + str(len(_armyA)))
	print("Army B Length: " + str(len(_armyB)))

func _process(delta: float) -> void:
	pass

func _generateArmy(armySize: int, isTeamA : bool) -> void:
	
	print("Generating army of : " + str(armySize) + " units")
	
	# Determine army size as a grid on the field
	var fieldSide: int = 1 if isTeamA else -1
	var gridSize = ceil(sqrt(armySize))
	var offsetFromCenter = _offsetFromCenter * fieldSide
	var zOffset = gridSize * .5
	
	var armyArr := _armyA if isTeamA else _armyB
	
	# Create unit instances on each side of the field
	var id : int = 0
	for x in gridSize:
		for z in gridSize:
			if id <= armySize:
				_spawnUnit(id, 
				_getRandOffset(Vector3(offsetFromCenter + (x * _unitSeparation) * fieldSide, 1, (zOffset - z) * _unitSeparation)),
				armyArr)
					
				id += 1

func _spawnUnit(id: int, pos: Vector3, armyArr: Array[RigidBody3D]) -> void:
	var instance = _armyAUnit.instantiate()
	instance.position = pos
	add_child(instance)
	
	armyArr.push_back(instance)
	

func _getRandOffset(pos: Vector3) -> Vector3:
	var offsetX : float = randf() * .5
	var offsetZ : float = randf() * .5
	return pos + Vector3(offsetX, 0 , offsetZ)
