extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
var state = IDLE

onready var blinkanim = $AnimationPlayer
onready var sprite = $Sprite
onready var stats = $Stats
onready var hurtBox = $HurtBox
onready var wanderController = $WanderControl
onready var softCollision = $SoftCollision
onready var playerDetectionZone = $PlayerDetectionZone

func _ready() -> void:
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				randWander()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				randWander()
			accelerate_towards(wanderController.target_position,delta)
				
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				randWander()
				
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards(player.global_position, delta)
			else:
				state = IDLE
				
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	
	velocity = move_and_slide(velocity)

func randWander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func accelerate_towards(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 130
	hurtBox.start_invincibility(0.3)
	hurtBox.create_hit_effect(area)
	

func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_HurtBox_invincibility_ended() -> void:
	blinkanim.play("Stop")


func _on_HurtBox_invincibility_started() -> void:
	blinkanim.play("Start")
