extends TextureButton

export (PackedScene) var Unit

var unit_count = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
#func _unhandled_input(event):
#	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
#
#		var game = get_tree().root
#
#		var new_unit = Unit.instance()
#		unit_count+=1
#		new_unit.position = get_viewport().get_mouse_position()
#		if(unit_count%2==0):
#			new_unit.is_girl=true
#		else:
#			new_unit.is_girl=false
#			game.add_child(new_unit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
