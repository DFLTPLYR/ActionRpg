extends Camera2D

onready var TopLeft = $Limits/TopLeft
onready var BottomRight = $Limits/BottomRight


func _ready() -> void:
	limit_top = TopLeft.position.y
	limit_left = TopLeft.position.x
	limit_bottom = BottomRight.position.y
	limit_right = BottomRight.position.x
