extends Viewport


var dragging = false
var selected = []
var drag_start = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()

onready var game_screen = get_tree().root.get_child(0).get_node("GameScreen")
onready var select_draw = $SelectDraw


func _input(event):

	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		if event.pressed:	
			for unit in selected:
				if(!unit.collider.is_erased):					
					unit.collider.deselect()	
				else:
					unit.collider.visible=false
					unit.collider.queue_free()
			selected = []
			dragging = true
			drag_start = $Camera2D_1.get_global_mouse_position()
		elif dragging:
			dragging = false
			select_draw.update_status(drag_start,$Camera2D_1.get_global_mouse_position(),dragging)
			var drag_end = $Camera2D_1.get_global_mouse_position()	
			select_rectangle.extents = (drag_end-drag_start)/2
			var space = get_world_2d().get_direct_space_state()
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0,(drag_end+drag_start)/2)
			selected = space.intersect_shape(query)
			for unit in selected:
				unit.collider.select()

	if dragging:
		if event is InputEventMouseMotion:
			#var drag_end=event.position
			select_draw.update_status(drag_start,$Camera2D_1.get_global_mouse_position(),dragging)

	if event is InputEventKey && event.scancode == KEY_C:
		var the_unit = get_tree().root.get_child(0).get_child(1)	
		the_unit.queue_free()



	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		if event.is_pressed():
			for unit in selected:
				if(unit.collider.selected):
					unit.collider.get_node("Mouse_Control").can_move = true
					unit.collider.target_position = $Camera2D_1.get_global_mouse_position()
					#print(str(unit.target_position.x))
					unit.collider.device_number = 2
				else:
					unit.collider.get_node("Mouse_Control").can_move = false







