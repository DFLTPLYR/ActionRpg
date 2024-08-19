extends AnimatedSprite


func _ready() -> void:
# warning-ignore:return_value_discarded
	self.connect("animation_finished", self, "_on_animation_finished")
	play("Animate")


func _on_animation_finished() -> void:
	queue_free()
