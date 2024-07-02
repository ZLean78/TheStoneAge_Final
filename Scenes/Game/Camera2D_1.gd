extends Camera2D

var its_raining = false

const MAX_CAMERA_DISTANCE = 50.0
const MAX_CAMERA_PERCENT = 0.1
const CAMERA_SPEED = 0.01



onready var select_draw = get_tree().root.get_child(0).find_node("Viewport/SelectDraw")



func _process(_delta):

	var the_children = get_tree().root.get_child(0).get_children()
	var unit
	
	var viewport = get_viewport()
	var viewport_center = viewport.size / 2.0
	var direction = viewport.get_mouse_position() - viewport_center
	var percent = (direction / viewport.size * 2.0).length()
	
	var camera_position = Vector2()

	for a_node in the_children:
		if "Unit" in a_node.name && a_node.selected:
			unit = a_node			
	
			if(unit.selected):				
				if percent < MAX_CAMERA_PERCENT:
					camera_position = unit.position + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
				else:
					camera_position = unit.position  + direction.normalized() * MAX_CAMERA_DISTANCE
		else:			
			if percent < MAX_CAMERA_PERCENT:
				camera_position = get_global_mouse_position()  + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
			else:
				camera_position = get_global_mouse_position()  + direction.normalized() * MAX_CAMERA_DISTANCE

	global_position = lerp(global_position, camera_position, CAMERA_SPEED)
	
	
func _set_its_raining(var _its_raining):
	its_raining = _its_raining
	
	if(its_raining):
		$AnimatedSprite.visible = true
		if(!$AnimatedSprite.playing):
			$AnimatedSprite.play("default")
	else:
		$AnimatedSprite.visible = false
		$AnimatedSprite.stop()
