extends "res://Scenes/PickupObject/PickupObject.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	points = 30
	the_sprite = get_child(0)
	type="fruit_tree"
	
func _physics_process(_delta):
	_fruit_tree_animate()




func _fruit_tree_animate():	
	if empty == true:
		$AnimationPlayer.play("empty")
	else:
		$AnimationPlayer.play("full")



	
