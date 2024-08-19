extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false

signal invincibility_ended
signal invincibility_started

onready var timer = $invincibleTimer
onready var collisionShape = $CollisionShape2D

func start_invincibility(value):
	$invincibleTimer.start(value)
	self.invincible = true
	if invincible == true:
		collisionShape.set_deferred("disabled", true)

func create_hit_effect(_area):
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	emit_signal("invincibility_started")
	main.add_child(effect)
	effect.global_position = global_position


func _on_Timer_timeout():
	invincible = true
	emit_signal("invincibility_ended")

func _on_HurtBox_invincibility_ended() -> void:
	collisionShape.set_deferred("disabled", false)
	
func _on_HurtBox_invincibility_started() -> void:
	collisionShape.set_deferred("disabled", true)
