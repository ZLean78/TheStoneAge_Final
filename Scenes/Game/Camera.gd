######################################
####Código nuevo
#####################################

extends Camera2D

export var panSpeed=30.0

export var speed=10.0

export var zoomSpeed=10.0

export var zoomMargin=0.1

export var zoomMin=0.25

export var zoomMax=1.0

export var marginX=50.0

export var marginY=50.0

var mousePos=Vector2()

var mousePosGlobal=Vector2()

var start=Vector2()

var startV=Vector2()

var end=Vector2()

var endV=Vector2()

var zoomFactor=1.0

var zooming=false

var is_dragging=false

#var move_to_point=Vector2()

onready var tree=Globals.current_scene

#onready var rectd = tree.find_node("draw_rect")

onready var select_draw



var its_raining=false

signal area_selected
#signal start_move_selection

func _ready():
	
	connect("area_selected",get_parent(),"_area_selected",[self])
	#connect("start_move_selection",get_parent(),"start_move_selection",[self])
	#select_draw = Globals.current_scene.select_draw
	#pass

func _process(delta):
	
	
	
	#smooth movement
	var inpx = (int(Input.is_action_pressed("ui_right"))
				 - int(Input.is_action_pressed("ui_left")))
	var inpy = (int(Input.is_action_pressed("ui_down"))
				 - int(Input.is_action_pressed("ui_up")))
	position.x=lerp(position.x,position.x+inpx*panSpeed*zoom.x,panSpeed*delta)
	position.y=lerp(position.y,position.y+inpy*panSpeed*zoom.y,panSpeed*delta)
	

	#movimiento de cámara con mouse
	if Input.is_action_pressed("mouse_wheel_pressed"):
		#chequear posición del mouse
		if mousePos.x < marginX:
			position.x=lerp(position.x,position.x-abs(mousePos.x-marginX)/marginX*panSpeed*zoom.x,panSpeed*delta)
		elif mousePos.x > ProjectSettings.get("display/window/size/width") - marginX:
			position.x=lerp(position.x,position.x+abs(mousePos.x-ProjectSettings.get("display/window/size/width")+marginX)/marginX*panSpeed*zoom.x,panSpeed*delta)
		if mousePos.y < marginY:
			position.y=lerp(position.y,position.y-abs(mousePos.y-marginY)/marginY*panSpeed*zoom.y,panSpeed*delta)
		elif mousePos.y > ProjectSettings.get("display/window/size/height") - marginY:
			position.y=lerp(position.y,position.y+abs(mousePos.y-ProjectSettings.get("display/window/size/height")+marginY)/marginY*panSpeed*zoom.y,panSpeed*delta)

	

	if Input.is_action_just_pressed("ui_left_mouse_button"):
		if get_parent().arrow_mode:
			start = mousePosGlobal
			startV = mousePos
			is_dragging = true	
	if is_dragging:
		if startV.distance_to(mousePos)>20:
			end = mousePosGlobal
			endV = mousePos
			tree.select_draw.update_status(start,mousePosGlobal+Vector2(6,12),is_dragging)
			#var drag_end = mousePos
	if Input.is_action_just_released("ui_left_mouse_button"):
		if startV.distance_to(mousePos)>20:
			end = mousePosGlobal
			endV = mousePos
			is_dragging = false
			tree.select_draw.update_status(start,mousePosGlobal,is_dragging)				
			emit_signal("area_selected")
		else:
			end = start
			is_dragging = false

	#zoom in
	zoom.x = lerp(zoom.x,zoom.x*zoomFactor,zoomSpeed*delta)
	zoom.y = lerp(zoom.y,zoom.y*zoomFactor,zoomSpeed*delta)

	zoom.x=clamp(zoom.x,zoomMin,zoomMax)
	zoom.y=clamp(zoom.y,zoomMin,zoomMax)
	

	position.x=clamp(position.x,-1650,1650)
	position.y=clamp(position.y,-960,960)


	if not zooming:
		zoomFactor = 1.0



#func draw_area(s = true):
#	rectd.rect_size = endV-startV
#
#	var pos = Vector2()
#	pos.x = min(startV.x,endV.x)
#	pos.y = min(startV.y,endV.y)
#
#	pos.x = clamp(pos.x,0,OS.window_size.x - rectd.rect_size.x)
#	pos.y = clamp(pos.y,0,OS.window_size.y - rectd.rect_size.y)
#
#	#pos.y = min(startV.y,endV.y) - OS.window_size.y/1.25 - 18
#	pos.y = min(startV.y,endV.y) - OS.window_size.y/1.18	
#
#
#	rectd.rect_position = pos
#
#	rectd.rect_size *= int(s) # true = 1, false = 0	
	

func _input(event):

	if (event is InputEventMouseButton):
		if(event.is_pressed()):
			zooming = true
			if(event.button_index==BUTTON_WHEEL_UP):
				zoomFactor -= 0.01 *zoomSpeed				
			if(event.button_index==BUTTON_WHEEL_DOWN):
				zoomFactor += 0.01 *zoomSpeed				
		else:
			zooming = false


	if event is InputEventMouse:
		mousePos = event.position
		mousePosGlobal = get_global_mouse_position()

	
					
	


######################################


######################################
####Código original
#####################################


#extends Camera2D
#
#var its_raining = false
#
#const MAX_CAMERA_DISTANCE = 50.0
#const MAX_CAMERA_PERCENT = 0.1
#const CAMERA_SPEED = 0.01
#
#var mousepos=Vector2()
#var mouseposGlobal=Vector2()
#var move_to_point = Vector2()
#
#var dragging = false
#var selected = []
#var drag_start = Vector2.ZERO
#var select_rectangle = RectangleShape2D.new()
#
#onready var tree = get_tree().root.get_child(0)
#onready var select_draw = tree.find_node("SelectDraw")
#
#
#signal area_selected
#signal start_move_selection
#signal start_move_tigers
#
#func _ready():
#	connect("area_selected",get_parent(),"area_selected",[self])
#	connect("start_move_selection",get_parent(),"start_move_selection",[self])
#
#func _process(delta):
#
#	#connect("area_selected",get_parent(),"area_selected",[self])
#
#
#	var the_children = get_tree().root.get_child(0).get_children()
#	var unit
#
#	var viewport = get_viewport()
#	var viewport_center = Vector2(0,0)
#	var direction = viewport.get_mouse_position() - viewport_center
#	var percent = (direction / viewport.size * 2.0).length()
#
#	var camera_position = Vector2()
#
#	for a_node in the_children:
#		if "Unit" in a_node.name && a_node.selected:
#			unit = a_node			
#
#			if(unit.selected):				
#				if percent < MAX_CAMERA_PERCENT:
#					camera_position = unit.position + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
#				else:
#					camera_position = unit.position  + direction.normalized() * MAX_CAMERA_DISTANCE
#		else:			
#			if percent < MAX_CAMERA_PERCENT:
#				camera_position = get_global_mouse_position()  + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
#			else:
#				camera_position = get_global_mouse_position()  + direction.normalized() * MAX_CAMERA_DISTANCE
#
#	global_position = lerp(global_position, camera_position, CAMERA_SPEED)
#
#	if(Input.is_action_just_pressed("ui_right_mouse_button")):
#		position=get_global_mouse_position()
#		position.x=lerp(position.x,position.x+CAMERA_SPEED*zoom.x,CAMERA_SPEED*delta)
#		position.y=lerp(position.y,position.y+CAMERA_SPEED*zoom.y,CAMERA_SPEED*delta)	
#
#		move_to_point = position
#		emit_signal("start_move_selection")		
#
#
#func _set_its_raining(var _its_raining):
#	its_raining = _its_raining
#
#	if(its_raining):
#		$AnimatedSprite.visible = true
#		if(!$AnimatedSprite.playing):
#			$AnimatedSprite.play("default")
#	else:
#		$AnimatedSprite.visible = false
#		$AnimatedSprite.stop()
#
#
#func _input(event):
#
#	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
#		if event.pressed:	
#			for unit in selected:
#				if "Unit" in unit.collider.name:
#					if(!unit.collider.is_erased):					
#						unit.collider._set_selected(false)
#					else:
#						unit.collider.visible=false
#						unit.collider.queue_free()
#			selected = []
#			dragging = true
#			drag_start = get_global_mouse_position()
#		elif dragging:
#			dragging = false
#			select_draw.update_status(drag_start,get_global_mouse_position(),dragging)
#			var drag_end = get_global_mouse_position()
#			select_rectangle.extents = (drag_end-drag_start)/2
#			var space = get_world_2d().get_direct_space_state()
#			var query = Physics2DShapeQueryParameters.new()
#			query.set_shape(select_rectangle)
#			query.transform = Transform2D(0,(drag_end+drag_start)/2)
#			selected = space.intersect_shape(query)
#			for unit in selected:
#				if "Unit" in unit.collider.name:
#					unit.collider._set_selected(true)
#					emit_signal("area_selected")
#
#	if dragging:
#		if event is InputEventMouseMotion:
#			#var drag_end=get_global_mouse_position()
#			select_draw.update_status(drag_start,get_global_mouse_position(),dragging)
#
#	if event is InputEventKey && event.scancode == KEY_C:
#		var the_unit = get_tree().root.get_child(0).get_child(1)	
#		the_unit.queue_free()

######################################

#	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
#		if event.is_pressed():
#			for unit in selected:
#				if(unit.collider.selected):
#					#unit.collider.get_node("Mouse_Control").can_move = true
#					unit.collider.target_position = get_global_mouse_position()
#					#print(str(unit.target_position.x))
#					#unit.collider.device_number = 2
#				#else:
#					#unit.collider.get_node("Mouse_Control").can_move = false
