extends KinematicBody2D


var direction=Vector2()

#Variables origen y destino de navegación.
var firstPoint = Vector2.ZERO
var secondPoint = Vector2.ZERO
var index = 0

var target_position = Vector2.ZERO
var velocity = Vector2()
var selected=false
var to_delta=0.0
var is_flipped=false
var can_shoot=true
var just_shot=false

#Salud de la unidad.
export (float) var health = 100


onready var nav2d
onready var sprite
onready var bar
onready var foot=$Selected
onready var shootNode=$scalable/shootNode
onready var shootPoint=$scalable/shootNode/shootPoint

export (PackedScene) var stone_scene

export (float) var SPEED = 100.0
var tree
var path=PoolVector2Array()

#Señales que informan si la unidad ha sido seleccionada o desseleccionada.
signal was_selected
signal was_deselected

#Para saber si la unidad ha sido eliminada.
var is_deleted=false
var distance=Vector2.ZERO
func _ready():
	health=100
	bar=$Bar
	foot=$Selected
	SPEED=100.0
	bar.value=health
	tree=Globals.current_scene
	sprite=$scalable/Sprite
	selected=false
	to_delta=0.0
	nav2d=tree.get_node("nav")
	foot=$Selected
	tree=Globals.current_scene
	nav2d=tree.get_node("nav")
	connect("was_selected",tree,"_select_unit",[self])
	connect("was_deselected",tree,"_deselect_unit",[self])
	target_position=tree.get_node("townhall").position
	

func _physics_process(delta):
	to_delta=delta
		
	if selected:
		bar.visible = true
		foot.visible = true
	else:
		bar.visible = false
		foot.visible = false
	

	
		
	if target_position!=Vector2.ZERO:
		if position.distance_to(target_position) > 200:
			#_move_to_target(target_position)
			_move_along_path(SPEED*delta)
			
		else:
			velocity=Vector2.ZERO
			_shoot()
	
	# Orientar al player.
	if velocity.x<0:
		if(is_flipped==false):			
			$scalable.scale.x = -1
			is_flipped = true
	if velocity.x>0:
		if(is_flipped==true):			
			$scalable.scale.x = 1
			is_flipped = false
	
				
	#animar al personaje	
	$Animation._animate(sprite,velocity,target_position)	
		
	#Cambiar los cuadros de animación del player.
	if position.distance_to(target_position) <= 10:
		sprite.stop()
	else:
		sprite.play()
	
	$Bar.value=health
		
func _move_along_path(distance):	
	var last_point=position
	direction=secondPoint-last_point
	velocity=(direction).normalized()
	while path.size():
		var distance_between_points = last_point.distance_to(path[0])
		if distance_between_points>7:
			last_point=lerp(last_point,path[0],distance/distance_between_points)
			position=last_point
			return
		
		distance-=distance_between_points
		last_point=path[0]
		path.remove(0)
		position=last_point
		set_process(false)



func _move():
	firstPoint = global_position
	secondPoint = target_position		
	var arrPath: PoolVector2Array = nav2d.get_simple_path(firstPoint,secondPoint,true)
	firstPoint = arrPath[0]
	path = arrPath
	index = 0



func _shoot():
	if is_instance_valid(tree.touching_enemy):
		target_position = tree.touching_enemy.position
		var shotHeight = 100
		var distX = abs(target_position.x-shootPoint.global_position.x)
		var distY = abs(target_position.y-shootPoint.global_position.y) + shotHeight
		var vy = sqrt(2*9.8*distY)
		var travelTime = vy/4.9
		var vx = distX/travelTime
		vx*=7.05
		vy*=5
		print(target_position, " ", shootPoint.global_position)
		print(vx," ",vy)
		var new_stone = stone_scene.instance()
		new_stone.owner_name="Catapult"
		new_stone.position = Vector2(shootPoint.global_position.x,shootPoint.global_position.y)
		if target_position.x<position.x:
			new_stone.set_velocity(Vector2(-vx,-vy))
		else:
			new_stone.set_velocity(Vector2(vx,-vy))
		var the_tilemap=get_tree().get_nodes_in_group("tilemap")
		the_tilemap[0].add_child(new_stone)
		can_shoot=false
		just_shot=true

func _set_selected(value):
	if selected!=value:
		selected=value

		bar.visible = value
		foot.visible = value
		if selected:
			emit_signal("was_selected")
		else:
			emit_signal("was_deselected")


func _on_Unit_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():			
			if event.button_index == BUTTON_LEFT:
				_set_selected(not selected)
				tree._select_last()


func _on_Vehicle_was_deselected():
	tree._deselect_unit(self)
	


func _on_Vehicle_was_selected():
	tree._select_unit(self)
	


func _on_all_timer_timeout():
	can_shoot=true


func _on_Sprite_animation_finished():
	just_shot=false
	$Animation._animate(sprite,velocity,target_position)

func _get_damage(body):
	if "Bullet" in body.name:
		health-=3
		if health<=0:
			queue_free()
