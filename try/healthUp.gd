extends RigidBody2D

var stats = PlayerStats
onready var animate = $AnimationPlayer

func _ready() -> void:
	animate.play("New Anim")

func _on_Area2D_body_entered(body: Node) -> void:
	if "Player" in body.name:
		if PlayerStats.health == 3:
			animate.play("shake")
		else:
			PlayerStats.health += 1
			queue_free()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "shake":
		animate.play("New Anim")
