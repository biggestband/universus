class_name BattleManager extends Node3D

# How many units are in each army
@export_category("Army")
@export var unitCountA := 100
@export var unitCountB := 100

@export_category("Crowd")
@export var crowdSize := 50
@export var crowdRadius := 10.0

@export_group("Nodes")
@export var objStupidUnit: PackedScene
@export var objCrowdUnit: PackedScene
@export var objUnitA: PackedScene
@export var objUnitB: PackedScene
@export var countLabelA: RichTextLabel
@export var countLabelB: RichTextLabel

var unitsA: Array
var unitsB: Array

# -- Crowds --
@export var crowdParentA: Node3D
@export var crowdParentB: Node3D



func _ready() -> void:
	createCrowds()
	debugCreateGuys()


func _process(delta: float) -> void:
	#var inst := objStupidUnit.instantiate()
	#add_child(inst)
	countLabelA.text = "x" + str(unitCountA)
	countLabelB.text = "x" + str(unitCountB)


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


func newStupidUnit() -> StupidUnit:
	# TODO
	return null


# -- Crowd control --
func createCrowds():
	var inst: CrowdUnit
	for i in range(crowdSize):
		createCrowdUnit(true, crowdParentA)
		createCrowdUnit(false, crowdParentB)


func createCrowdUnit(isRidgeback: bool, crowdParent: Node3D) -> CrowdUnit:
	var inst: CrowdUnit
	var xOffset := randf_range(0, crowdRadius)
	var zOffset := randf_range(-crowdRadius, crowdRadius) / 2
	
	inst = objCrowdUnit.instantiate()
	inst.setType(isRidgeback)
	inst.position = crowdParent.position + Vector3(xOffset, 0, zOffset)

	crowdParent.add_child(inst)
	return inst


func updateCrowd():
	# TODO
	pass
