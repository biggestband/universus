extends Node

# Hard cap army sizes for performance
const _maxArmySize : int = 256

var armyAEnemy : Resource = preload("res://Enemies/Enemy_Prefabs/EnemyA.tscn")
var armyBEnemy : Resource = preload("res://Enemies/Enemy_Prefabs/EnemyB.tscn")

func _ready() -> void:
	
	# Get networked values from signleton
	var armyASize : int = 64
	var armyBSize : int = 64
	var seed : int = 64
	
	# Set RNG seed to ensure spawns are the same across both clients
	seed(seed)
	
	_generateArmy(armyASize, true)
	_generateArmy(armyBSize, false)

func _process(delta: float) -> void:
	pass

func _generateArmy(armySize: int, isTeamA : bool) -> void:
	
	var fieldSide: int = 1 if isTeamA else -1
	
	var id : int = 0
	for x in _maxArmySize / 2 * fieldSide:
			for z in _maxArmySize / 2 * fieldSide:
				if id <= armySize:
					_spawnUnit(id, _getRandOffset(Vector2(x,z)))
					id += 1

func _spawnUnit(id: int, pos: Vector2) -> void:
	pass

func _getRandOffset(pos: Vector2) -> Vector2:
	return Vector2.ZERO
