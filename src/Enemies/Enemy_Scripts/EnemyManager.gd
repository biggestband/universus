extends Node

# Hard cap army sizes for performance
const _maxArmySize : int = 256

var armyAEnemy : Resource = preload("res://Enemies/Enemy_Prefabs/EnemyA.tscn")
var armyBEnemy : Resource = preload("res://Enemies/Enemy_Prefabs/EnemyB.tscn")

func _ready() -> void:
	
	# Get networked values from signleton
	var armyASize : int = 64
	var armyBSize : int = 64
	var randSeed : int = 64
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(randSeed)
	
	_generateArmy(armyASize, true)
	_generateArmy(armyBSize, false)

func _process(delta: float) -> void:
	pass

func _generateArmy(armySize: int, isTeamA : bool) -> void:
	
	print("Generating army of : " + str(armySize) + " units")
	
	var fieldSide: int = 1 if isTeamA else -1
	var gridSize = ceil(sqrt(armySize))
	
	var id : int = 0
	for x in gridSize:
			for z in gridSize:
				if id <= armySize:
					_spawnUnit(id, _getRandOffset(Vector3(x * fieldSide,0 ,z)))
					id += 1

func _spawnUnit(id: int, pos: Vector3) -> void:
	var instance = armyAEnemy.instantiate()
	instance.position = pos
	add_child(instance)

func _getRandOffset(pos: Vector3) -> Vector3:
	return pos
