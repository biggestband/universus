class_name BattleManager extends Node3D

# How many units are in each army
@export var unitCountA := 100
@export var unitCountB := 100

@export_group("Nodes")
@export var objStupidUnit: PackedScene
@export var objUnitA: PackedScene
@export var objUnitB: PackedScene
@export var countLabelA: RichTextLabel
@export var countLabelB: RichTextLabel

@export var crowdParentA: Node3D
@export var crowdParentB: Node3D

var unitsA: Array
var unitsB: Array


func _ready() -> void:
	createCrowds()
	debugCreateGuys()


func _process(delta: float) -> void:
	#var inst := objStupidUnit.instantiate()
	#add_child(inst)
	countLabelA.text = "x" + str(unitCountA)
	countLabelB.text = "x" + str(unitCountB)


func createCrowds():
	
	pass


func debugCreateGuys(): 
	var startPos := Vector3(randf_range(10, 15), 0, randf_range(-6, 6))
	var targetPos := Vector3(randf_range(-1, 1), 0, startPos.z)
	var attackTime := randf_range(0.8, 1.4) * 0.6
	
	# Create ridgeback
	var inst: StupidUnit = objStupidUnit.instantiate()
	inst.type = StupidUnit.Type.RIDGEBACK
	inst.position = startPos
	inst.position.x *= -1
	inst.targetPos = targetPos
	inst.moveTime = attackTime
	inst.battleManager = self
	add_child(inst)
	inst.startAttacking()
	
	inst = objStupidUnit.instantiate()
	inst.type = StupidUnit.Type.DURHAM
	inst.position = startPos
	inst.targetPos = targetPos
	inst.moveTime = attackTime
	inst.battleManager = self
	add_child(inst)
	inst.startAttacking()
	
	await get_tree().create_timer(0.05).timeout
	debugCreateGuys()
