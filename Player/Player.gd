extends KinematicBody2D

const PLAYERHURTSOUND = preload("res://Player/PlayerHurtSound.tscn")

export var MAX_SPEED = 80
export var ACCELERATION = 500
export var ROLLSPEED = 120
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var blinkAnim = $BlinkAnimation
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var swordHitbox = $HitBoxPivot/SwordHitBox
onready var hurtBox = $HurtBox
onready var animationState = animationTree.get("parameters/playback")


func _ready() -> void:
	randomize()
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x  = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y  = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
		
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_pressed("attack"):
		state = ATTACK

func roll_state(_delta):
	velocity =  roll_vector * ROLLSPEED
	animationState.travel("Roll")
	move()

func move():
	velocity = move_and_slide(velocity)

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()

func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity * 0.7
	state = MOVE

func _on_HurtBox_area_entered(area):
	hurtBox.start_invincibility(1)
	stats.health -= 1
	hurtBox.create_hit_effect(area)
	var playerHurtSounds = PLAYERHURTSOUND.instance()
	get_tree().current_scene.add_child(playerHurtSounds)

func _on_HurtBox_invincibility_ended() -> void:
	blinkAnim.play("Stop")

func _on_HurtBox_invincibility_started() -> void:
	blinkAnim.play("Start")
