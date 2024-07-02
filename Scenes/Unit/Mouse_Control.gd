extends Node

var dragging = false
var selected = []
var drag_start = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()

#onready var select_draw = get_tree().root.get_child(0).get_child(3)

export (int) var speed = 200

onready var target = get_parent().position

var velocity = Vector2()

var can_move = false

#func _unhandled_input(event):
#	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
#		if event.is_pressed():
#			for unit in selected:
#				if(unit.collider.name!="TileMap"):
#					unit.collider.deselect()
#
#					if(!get_parent().selected):
#						can_move = false
#
#
#			selected = []
#			dragging = true
#			drag_start = event.position
#		elif dragging:
#			dragging = false
#			select_draw.update_status(drag_start,event.position,dragging)
#			var drag_end = event.position
#			select_rectangle.extents = (drag_end - drag_start) / 2
#			var space = get_parent().get_world_2d().direct_space_state
#			var query = Physics2DShapeQueryParameters.new()
#			query.set_shape(select_rectangle)
#			query.transform = Transform2D(0,(drag_end + drag_start) / 2)
#			selected = space.intersect_shape(query)
#			for unit in selected:
#				if(unit.collider.name!="TileMap"):
#					unit.collider.select()
#
#					if(get_parent().selected):
#						can_move = true
#					else:
#						can_move = false
#
#	if dragging:
#		if event is InputEventMouseMotion:
#			select_draw.update_status(drag_start,event.position,dragging)
#
#	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
#		if event.is_pressed():
#			target = get_parent().get_global_mouse_position()
#		if get_parent().selected:		
#			can_move = true
#		else:
#			can_move = false

	
		

#func _physics_process(delta):
#	if(can_move):
#
		#target = get_parent().get_global_mouse_position()
		#$Target_Position1.position = target
		
		###############################################
		##MÉTODO VIEJO
		###############################################
#		velocity = get_parent().position.direction_to(target) * speed
#
#		if get_parent().position.distance_to(target) > 5:
#			get_parent().move_and_collide(velocity*delta)
#			get_parent().velocity = velocity*delta
		
		
			
#
#
#
 



