extends "res://Scenes/PickupObject/PickupObject.gd"






# Called when the node enters the scene tree for the first time.
func _ready():
	the_sprite = get_child(0)
	type = "puddle"




#func _on_Area2D_mouse_entered():
#	get_tree().root.get_child(0).emit_signal("is_hand")
#
#
#func _on_Area2D_mouse_exited():
#	get_tree().root.get_child(0).emit_signal("is_arrow")



