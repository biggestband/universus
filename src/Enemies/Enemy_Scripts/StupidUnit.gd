class_name StupidUnit extends Node3D

enum Type
{
	RIDGEBACK,
	DURHAM,
}

enum State
{
	ATTACKING,
	DYING,
}

@export_group("Nodes")
@export var sprRidgeback: Texture2D
@export var sprLordDurham: Texture2D
@export var ridgebackSprite: Sprite3D
@export var durhamSprite: Sprite3D
var battleManager: BattleManager

var type := Type.RIDGEBACK
var state := State.ATTACKING

# -- Attacking state --
var targetPos: Vector3
var moveTime := 1.0
var moveTw: Tween

# -- Dying state --
var gravity := 60.0
var velocity := Vector3.ZERO
var currentSprite: Sprite3D


func _ready() -> void:
	# Show correct sprite
	if type == Type.RIDGEBACK:
		durhamSprite.hide()
		currentSprite = ridgebackSprite
	elif type == Type.DURHAM:
		ridgebackSprite.hide()
		currentSprite = durhamSprite


func _process(delta: float) -> void:
	match state:
		State.ATTACKING:
			_stAttacking(delta)
		State.DYING:
			_stDying(delta)


func _stAttacking(delta: float):
	
	pass


func _stDying(delta: float):
	velocity.y -= gravity * delta
	position += velocity * delta
	
	if position.y < -50:
		print("destroyed guy")
		queue_free()


func decrementArmyCount():
	if type == Type.RIDGEBACK:
		battleManager.unitCountA -= 1
	else:
		battleManager.unitCountB -= 1


func die():
	decrementArmyCount()
	
	# Cancel tween and move to target
	if moveTw and moveTw.is_running():
		# Don't try to call this again...
		moveTw.finished.disconnect(startAttacking)
		
		moveTw.custom_step(99)
		moveTw.kill()
	
	# Add random force
	var force := randf_range(20, 35)
	var dir := Vector3(1, 1, 0).normalized()
	
	if type == Type.RIDGEBACK:
		dir.x *= -1
	
	velocity = force * dir
	state = State.DYING
	
	# Do flash tween
	currentSprite.modulate.r = 4
	var tw := create_tween()
	tw.tween_property(currentSprite, "modulate:r", 1.0, 0.2)
	tw.chain().tween_property(currentSprite, "modulate:a", 0.0, 0.4)
	tw.finished.connect(queue_free)
	
	#await tw.finished
	#queue_free()
	#print("Killed guy")


func startAttacking():
	state = State.ATTACKING
	
	moveTw = create_tween()
	moveTw.set_trans(Tween.TRANS_CUBIC)
	moveTw.set_ease(Tween.EASE_IN)
	moveTw.tween_property(self, "position", targetPos, moveTime)
	
	moveTw.finished.connect(die)
