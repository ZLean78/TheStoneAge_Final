extends "res://Scenes/Unit/Unit.gd"


#Variable que indica si el jugador debe moverse.
var move_p = false
#Vector2 que indica cuánto debe moverse el jugador.
var to_move = Vector2()
#PoolVector2Array que indica el camino variable teniendo en cuenta el Polígono de navegación.

#Posición inicial, se actualiza cada vez que hacemos click con el botón derecho.
var initialPosition = Vector2()

#Puntos de comida de la unidad.
var food_points = 0

#Variable que indica si se está arrastrando el mouse sobre la unidad.
var dragging = true

#var click_relative = 16
#Indica si la unidad ha muerto.
var dead = false
var collision 


#Variables agregadas
#var device_number = 0
#!!!!
var motion = Vector2()
#Vector2 que indica la velocidad en x e y para las animaciones.

#!!!!!
var touch_enabled = false
#Indica si la unidad se encuentra bajo refugio.
var is_sheltered = false
#Indica si la unidad es o no mujer.
var is_girl = false

#Vector2 que indica el tamaño de la pantalla.
var screensize = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))

#Indica si la unidad está tocando un enemigo
var is_enemy_touching=false

var can_shoot = true

var direction = Vector2.ZERO

#Variables origen y destino de navegación.
var firstPoint = Vector2.ZERO
var secondPoint = Vector2.ZERO
var index = 0

#Polígono de navegación.
onready var nav2d

#Nodo de animación
onready var animation

#Nodo de control
onready var control

func _ready():
	tree=Globals.current_scene
	nav2d=tree.get_node("nav")
	connect("was_selected",tree,"_select_unit")
	connect("was_deselected",tree,"_deselect_unit")
	emit_signal("health_change",health)
	
	tree=Globals.current_scene
	nav2d=tree.get_node("nav")
	animation=$Animation
	control=$Control
	
	bar=$Bar
	all_timer=$all_timer
	foot=$Selected
	
	sprite = $scalable/sprite
	shoot_node = $shootNode
	shoot_point = $shootNode/shootPoint
	
	
	#Salud.
	health = MAX_HEALTH

	sprite.animation = "male_idle1_d"
	
	foot.visible = false
	
	bar.visible = false


func _set_selected(value):
	if selected != value:
		selected = value
		foot.visible = value
		#label.visible = value
		bar.visible = value
		if selected:
			emit_signal("was_selected",self)
		else:
			emit_signal("was_deselected",self)

	

func _physics_process(delta):
	
	to_delta=delta
	
	position.x = clamp(position.x,-1028,screensize.x)
	position.y = clamp(position.y,-608,screensize.y)	
	
	if selected:
		if foot.visible == false:
			foot.visible = true
	else:
		if foot.visible == true:
			foot.visible = false
	
	if target_position!=Vector2.ZERO:
		if position.distance_to(target_position) > 10:
			#_move_to_target(target_position)
			_move_along_path(SPEED*delta)
		else:
			velocity=Vector2.ZERO
	
	
	# Orientar al guerrero.
	if velocity.x<0:
		if(is_flipped==false):			
			$scalable.scale.x = -1
			is_flipped = true
	if velocity.x>0:
		if(is_flipped==true):			
			$scalable.scale.x = 1
			is_flipped = false
	
				
	#animar al personaje	
	animation._animate(velocity,sprite,target_position)	
		
	#Cambiar los cuadros de animación del player.
	if velocity.length() > 0:
		#velocity = velocity.normalized() * SPEED
		if(!sprite.is_playing()):
			sprite.play()
	else:
		sprite.stop()		
		
	if(all_timer.is_stopped()):
		all_timer.start()
		
func _get_damage(var _collider):
	if "Tiger" in _collider.name && _collider.visible:
		if(health>0):
			health-=5
			bar._set_health(health)
			
		else:
			#the_beast.unit = null
			#the_beast.is_chasing = false
			_set_selected(false)			
			is_deleted=true
	if "Mammoth" in _collider.name && is_enemy_touching:
		if health>0:
			health-=30
			bar._set_health(health)
			
		else:
			_set_selected(false)			
			is_deleted=true	
	if "EnemySpear" in _collider.name:
		_collider.queue_free()
		if health>0:
			health-=20
			bar._set_health(health)
			
		else:
			_set_selected(false)			
			is_deleted=true	
		
	
func move_towards(pos,point,delta):
	var v = (point-pos).normalized()
	v *=delta*SPEED
	position += v
	if position.distance_squared_to(point) < 5:
		path.remove(0)
		initialPosition = position
		
func _move_along_path(distance):	
	var last_point=position
	direction=last_point-firstPoint
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
		

func _move_to_target(target):
	direction = (target-position)*SPEED
	velocity=(direction*to_delta).normalized()
	collision = move_and_collide(velocity)
	
	if collision != null:
		if "Tiger" in collision.collider.name || "Mammoth" in collision.collider.name || "EnemySpear" in collision.collider.name:
			is_enemy_touching=true
			
	

func _unhandled_input(event):
	if event.is_action_pressed("RightClick"):
		if tree.sword_mode:
			if tree.touching_enemy!=null:
				if is_instance_valid(tree.touching_enemy):
					#if selected && can_shoot:
					if selected:
						_shoot()
				else:
					if tree.name=="Game3":
						tree._on_Game3_is_arrow()
					elif tree.name=="Game4":
						tree._on_Game4_is_arrow()
					elif tree.name=="Game5":
						tree._on_Game5_is_arrow()
		else:
			_walk()
			
					
func _on_Unit_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():			
			if event.button_index == BUTTON_LEFT:
				_set_selected(not selected)
				tree._select_last()
				


func _on_Target_Position_body_entered(_body):
	velocity = Vector2(0,0)
	touch_enabled = false
	if !is_girl:
		sprite.animation = "male_idle1"
	if is_girl:
		sprite.animation = "female_idle1"


func _on_Target_Position1_body_entered(_body):
	velocity = Vector2(0,0)
	if !is_girl:
		sprite.animation = "male_idle1"
	if is_girl:
		sprite.animation = "female_idle1"
		


	


func _on_player_mouse_entered():
	selected = true


	
func _set_erased(var _is_erased):
	is_erased=_is_erased
	

#	
func _on_all_timer_timeout():
	#timer_count+=1	
	#if tiger!=null && is_instance_valid(tiger):
		#_get_damage(tiger)
	if body_entered!=null && is_instance_valid(body_entered):
		#if "Tiger" in body_entered.name || "Mammoth" in body_entered.name:
		_get_damage(body_entered)
#	if timer_count>=3:
#		can_shoot=true
#	else:
#		can_shoot=false
#	if timer_count>4:
#		timer_count=0
	all_timer.start()
	
	

func _die():
	queue_free()

func _on_Area2D_body_entered(body):
	body_entered=body
	

func _shoot():
	var bullet_target = tree.touching_enemy.position
	shoot_node.look_at(bullet_target)				
	var angle = shoot_node.rotation
	var forward = Vector2(cos(angle),sin(angle))
	var the_tilemap=get_tree().get_nodes_in_group("tilemap")
	var spear_count=0
	for tilemap_child in the_tilemap[0].get_children():
		if "Bullet" in tilemap_child.name:
			spear_count+=1
	if spear_count<2:
		bullet = bullet_scene.instance()
		shoot_point.rotation = angle				
		bullet.position = Vector2(shoot_point.global_position.x,shoot_point.global_position.y)
		bullet.set_dir(forward)
		bullet.rotation = angle
		bullet.owner_name="Warrior"
		#target_position=bullet_target		
		the_tilemap[0].add_child(bullet)
	
	
func _walk():
	firstPoint = global_position	
	secondPoint = target_position		
	var arrPath: PoolVector2Array = nav2d.get_simple_path(firstPoint,secondPoint,true)
	firstPoint = arrPath[0]
	path = arrPath
	index = 0		


