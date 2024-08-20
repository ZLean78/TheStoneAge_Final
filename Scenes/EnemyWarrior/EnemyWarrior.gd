extends KinematicBody2D

#Proyectil, piedra para lanzar al enemigo.
var spear
export var spear_scene=preload("res://Scenes/EnemySpear/EnemySpear.tscn")

#Velocidad
export (float) var SPEED = 50.0
#Máximo de Salud
export (float) var MAX_HEALTH = 100.0

#variable que indica el nodo principal de la escena.
onready var tree

#Temporizador de comida, agrega un punto de comida por segundo cuando la unidad toca un árbol frutal.

#Salud
#onready var health = MAX_HEALTH

#Variable que indica si está seleccionada la unidad.
var selected = true
#Marca de selección
onready var box = $Selected
#onready var label = $label
#Barra de Energía
onready var bar = $Bar
onready var all_timer = $all_timer
onready var sprite = get_node("scalable/sprite")

onready var shoot_node = $shootNode
onready var shoot_point = $shootNode/shootPoint

onready var line = $Line2D


#Variable que indica si el jugador debe moverse.
var move_p = false
#Vector2 que indica cuánto debe moverse el jugador.
var to_move = Vector2()
#PoolVector2Array que indica el camino variable teniendo en cuenta el Polígono de navegación.
var path = PoolVector2Array()
#Posición inicial, se actualiza cada vez que hacemos click con el botón derecho.
var initialPosition = Vector2()

#Puntos de comida de la unidad.
var food_points = 0
#Puntos de energía.
var energy_points = MAX_HEALTH
#Variable que indica si se está arrastrando el mouse sobre la unidad.
var dragging = true

#Indica si la animación de la unidad debe estar flipeada en x.
var is_flipped = false
var is_chased = false
#var click_relative = 16
#Indica si la unidad ha muerto.
var dead = false
var collision 



#Variables agregadas
#var device_number = 0
#!!!!
var motion = Vector2()
#Vector2 que indica la velocidad en x e y para las animaciones.
var velocity = Vector2()
#!!!!!
var touch_enabled = false
#Indica si la unidad se encuentra bajo refugio.
var is_sheltered = false
#Indica si la unidad es o no mujer.
var is_girl = false
#Indica si la unidad está vestida (tiene túnica de hojas o no).
var is_dressed = false
#Indica si tiene cesta de hojas o no.

#Indica si la unidad ha sido eliminada o no.
var is_erased = false


#Posición adonde la unidad debe moverse.
var target_position = Vector2.ZERO

#Indica si la unidad puede agregar puntos de comida o no.
var can_add = false
#Indica si la unidad puede agregar puntos de hojas.
var can_add_leaves = false

#var can_add_multiple = false

#Indica si está lloviendo para la unidad.
var its_raining = false

#Vector2 que indica el tamaño de la pantalla.
var screensize = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))

#Indica si la unidad está tocando un tgre
var is_enemy_touching=false

#Tigre que la unidad está tocando
var tiger = null


#!!!!

#Variable contador para diferenciar cuándo ha acabado el timer "all_timer".
var timer_count=1

#Para saber si la unidad ha sido eliminada.
var is_deleted=false

#Para detección de daño. Cuerpo que ingresa al área 2D
var body_entered

var can_shoot = true

var to_delta = 0.0

var direction = Vector2.ZERO

#Variables origen y destino de navegación.
var firstPoint = Vector2.ZERO
var secondPoint = Vector2.ZERO
var index = 0

var AI_state=0

#Variable enumerador que discrimina el tipo de objetivo.
enum target_type {TOWER,BARN,FORT,TOWNHALL}

var target=null
export (target_type) var target_t
export (float) var MIN_DISTANCE
export (float) var MAX_DISTANCE

#Polígono de navegación.
onready var nav2d

#var colliding_body: KinematicBody2D

#var body_velocity=Vector2.ZERO

#Variables para evitar encimarse.
const move_threshold=5.0
var last_distance_to_target = Vector2.ZERO
var current_distance_to_target = Vector2.ZERO

onready var stop_timer=$StopTimer

#Señal de cambio de salud (incremento o decremento).
signal health_change
#Señal de que la unidad ha muerto.
signal im_dead
#signal food_points_change




func _ready():
	tree=Globals.current_scene
	nav2d=tree.get_node("nav")
	#connect("was_selected",get_tree().root.get_child(0),"select_unit")
	#connect("was_deselected",get_tree().root.get_child(0),"deselect_unit")
	emit_signal("health_change",energy_points)
	
	AI_state=3
	
	is_dressed=true
	if(!is_dressed):
		if !is_girl:
			sprite.animation = "male_idle1"
		if is_girl:
			sprite.animation = "female_idle1"
	else:
		if !is_girl:
			sprite.animation = "male_idle1_d"
		if is_girl:
			sprite.animation = "female_idle1_d"
	
	
	

	

#func _set_selected(value):
#	if selected != value:
#		selected = value
#		box.visible = value
#		#label.visible = value
#		bar.visible = value
#		if selected:
#			emit_signal("was_selected",self)
#		else:
#			emit_signal("was_deselected",self)

	

func _physics_process(delta):
	
	to_delta=delta
	
	position.x = clamp(position.x,-1028,screensize.x)
	position.y = clamp(position.y,-608,screensize.y)	
	
	if AI_state==1 || AI_state==2:
		_move_along_path(SPEED*delta)
		
		if position.distance_to(target_position) > MAX_DISTANCE:
			_walk()	
	
	#Máquina de estados para las acciones.
	_state_machine()
	
	
	#animar al personaje	
	_animate()
	# Orientar al warrior.
	if velocity.x<0:
		if(is_flipped==false):			
			$scalable.scale.x = -1
			is_flipped = true
	if velocity.x>0:
		if(is_flipped==true):			
			$scalable.scale.x = 1
			is_flipped = false
	
				
		
	
		
	#Cambiar los cuadros de animación del player.
	if velocity.length() > 0:
		#velocity = velocity.normalized() * SPEED
		if(!sprite.is_playing()):
			sprite.play()
	else:
		sprite.stop()
		
	if(all_timer.is_stopped()):
		all_timer.start()

	if get_slide_count() && stop_timer.is_stopped():
		stop_timer.start()
		last_distance_to_target = position.distance_to(target)
		
func _get_damage(var collider):
	if "Tiger" in collider.name && is_enemy_touching && collider.visible:
		if(energy_points>0):
			energy_points-=5
			bar._set_health(energy_points)		
	if "Mammoth" in collider.name && is_enemy_touching:
		if energy_points>0:
			energy_points-=30
			bar._set_health(energy_points)
	if "Bullet" in collider.name:
		if collider.owner_name=="Tower":
			if energy_points>0:
				energy_points-=50
				bar._set_health(energy_points)			
		else:
			if energy_points>0:
				energy_points-=20
				bar._set_health(energy_points)
			
	if energy_points<=0:
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
	direction=target_position-firstPoint
	velocity=direction.normalized()
	while path.size():	
		var distance_between_points = last_point.distance_to(path[0])	
		if distance<=distance_between_points:
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
		if "Tiger" in collision.collider.name || "Mammoth" in collision.collider.name:
			is_enemy_touching=true
		if "Bullet" in collision.collider.name:
			is_enemy_touching=true
			body_entered=collision.collider
			
	

#func _unhandled_input(event):
#	if event.is_action_pressed("RightClick"):
#		if get_tree().root.get_child(0).sword_mode:
#			if get_tree().root.get_child(0).touching_enemy!=null:
#				if is_instance_valid(get_tree().root.get_child(0).touching_enemy):
#					if selected && can_shoot:
#						var bullet_target = get_tree().root.get_child(0).touching_enemy.position
#						shoot_node.look_at(bullet_target)				
#						var angle = shoot_node.rotation
#						var forward = Vector2(cos(angle),sin(angle))
#						bullet = bullet_scene.instance()
#						shoot_point.rotation = angle				
#						bullet.position = Vector2(shoot_point.global_position.x,shoot_point.global_position.y)
#						bullet.set_dir(forward)
#						bullet.rotation = angle
#						target_position=bullet_target	
#						var the_tilemap=get_tree().get_nodes_in_group("tilemap")
#						the_tilemap[0].add_child(bullet)
#						can_shoot=false
#				else:
#					get_tree().root.get_child(0)._on_Game3_is_arrow()
#		else:
#			firstPoint=global_position
#
#	if event.is_action_released("RightClick"):	
#		if !get_tree().root.get_child(0).sword_mode:
#			secondPoint = target_position		
#			var arrPath: PoolVector2Array = nav2d.get_simple_path(firstPoint,secondPoint,true)
#			firstPoint = arrPath[0]
#			path = arrPath
#			index = 0			
#
#
#func _on_Unit_input_event(_viewport, event, _shape_idx):
#	if event is InputEventMouseButton:
#		if event.is_pressed():			
#			if event.button_index == BUTTON_LEFT:
#				_set_selected(not selected)
#				root.select_last()
				





#func hurt(amount):
#	health-=amount
#	#esto podría ir en un setter
#	if health <= 0:
#		if !dead:
#			emit_signal("im_dead")
#			dead = true
#			set_physics_process(false) 
#		health = 0
#		return
#	elif health > 100:
#		health = 100
#	emit_signal("health_change",health)


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
		

		
func _animate():
	if(!is_dressed):
		if(!is_girl):
			if velocity == Vector2(0,0):
				if sprite.animation == "male_backwalk":
					sprite.animation = "male_idle2"
				elif sprite.animation == "male_frontwalk":
					sprite.animation = "male_idle1"
				elif sprite.animation == "male_sidewalk":
					sprite.animation = "male_idle3"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_backwalk"
					else:
						sprite.animation = "male_sidewalk"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_frontwalk"
					else:
						sprite.animation = "male_sidewalk"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk"
					else:
						sprite.animation = "male_backwalk"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk"
					else:
						sprite.animation = "male_frontwalk"
					
		else:
			if velocity == Vector2(0,0):
				if sprite.animation == "female_backwalk":
					sprite.animation = "female_idle2"
				elif sprite.animation == "female_frontwalk":
					sprite.animation = "female_idle1"
				elif sprite.animation == "female_sidewalk":
					sprite.animation = "female_idle3"	
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_backwalk"
					else:
						sprite.animation = "female_sidewalk"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_frontwalk"
					else:
						sprite.animation = "female_sidewalk"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk"
					else:
						sprite.animation = "female_backwalk"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk"
					else:
						sprite.animation = "female_frontwalk"
#				
	else:
		if(!is_girl):
			if velocity == Vector2(0,0):
				if sprite.animation == "male_backwalk_d":
					sprite.animation = "male_idle2_d"
				elif sprite.animation == "male_frontwalk_d":
					sprite.animation = "male_idle1_d"
				elif sprite.animation == "male_sidewalk_d":
					sprite.animation = "male_idle3_d"
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_backwalk_d"
					else:
						sprite.animation = "male_sidewalk_d"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "male_frontwalk_d"
					else:
						sprite.animation = "male_sidewalk_d"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk_d"
					else:
						sprite.animation = "male_backwalk_d"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "male_sidewalk_d"
					else:
						sprite.animation = "male_frontwalk_d"
		else:
			if velocity == Vector2(0,0):
				if sprite.animation == "female_backwalk_d":
					sprite.animation = "female_idle2_d"
				elif sprite.animation == "female_frontwalk_d":
					sprite.animation = "female_idle1_d"
				elif sprite.animation == "female_sidewalk_d":
					sprite.animation = "female_idle3_d"	
			else:
				if velocity.y < 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_backwalk_d"
					else:
						sprite.animation = "female_sidewalk_d"
				elif velocity.y > 0:
					if abs(velocity.y) > abs(velocity.x):
						sprite.animation = "female_frontwalk_d"
					else:
						sprite.animation = "female_sidewalk_d"
				elif velocity.x < 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk_d"
					else:
						sprite.animation = "female_backwalk_d"
				elif velocity.x > 0:
					if abs(velocity.x) > abs(velocity.y):
						sprite.animation = "female_sidewalk_d"
					else:
						sprite.animation = "female_frontwalk_d"

	

	if position.distance_to(target_position) < 5:
		if(!is_dressed):
			if(!is_girl):
				sprite.animation = "male_idle1"
			else:
				sprite.animation = "female_idle1"
		else:
			if(!is_girl):
				sprite.animation = "male_idle1_d"
			else:
				sprite.animation = "female_idle1_d"




#func _on_tiger_tiger_entered():
#	is_tiger_touching=true

#func _on_tiger_tiger_exited():
#	is_tiger_touching=false

func _on_player_mouse_entered():
	selected = true



	
func _set_erased(var _is_erased):
	is_erased=_is_erased
	


#	
#func _on_all_timer_timeout():
#	timer_count+=1	
#
#	if timer_count>2:
#		can_shoot=true
#
#
#	if timer_count>4:
#		timer_count=0
#
#
#	all_timer.start()
	
	

func _die():
	queue_free()


func _on_Area2D_body_entered(body):	
	if (("Tower" in body.name || "Warrior" in body.name || "Unit" in body.name || "Vehicle" in body.name)
		&& !("Enemy" in body.name)):		
		if is_instance_valid(body_entered):
			if "Warrior" in body.name || "Unit" in body.name || "Vehicle" in body.name:
				body.is_enemy_touching=true
			

		
func _on_Area2D_body_exited(body):
	if "Warrior" in body.name || "Unit" in body.name:
		body.is_enemy_touching=false	
		
#

		
		
func _choose_target():
	if target_t == target_type.TOWER && tree.tower_node.get_child_count()>0:
		for i in range(0,tree.tower_node.get_child_count()):
			if i!=0:
				if tree.tower_node.get_child(i).position.distance_to(position)<tree.tower_node.get_child(i-1).position.distance_to(position):
					target=tree.tower_node.get_child(i)
					target_position=tree.tower_node.get_child(i).position
#					if position.distance_to(root.tower_node.get_child(i).position)==position.distance_to(root.tower_node.get_child(i-1).position):
#						target=root.tower_node.get_child(i)
#						target_position=root.tower_node.get_child(i).position
			else:
				target=tree.tower_node.get_child(0)
				target_position=tree.tower_node.get_child(0).position
	elif target_t==target_type.BARN && tree.barn_node.get_child_count()>0:				
		for i in range(0,tree.barn_node.get_child_count()):
			if i!=0:
				if tree.barn_node.get_child(i).position.distance_to(position)<tree.barn_node.get_child(i-1).position.distance_to(position):
					target=tree.barn_node.get_child(i)
					target_position=tree.barn_node.get_child(i).position
#					if position.distance_to(root.tower_node.get_child(i).position)==position.distance_to(root.tower_node.get_child(i-1).position):
#						target=root.tower_node.get_child(i)
#						target_position=root.tower_node.get_child(i).position
			else:
				target=tree.barn_node.get_child(0)
				target_position=tree.barn_node.get_child(0).position
	elif target_t==target_type.FORT && tree.fort_node.get_child_count()>0:
		for i in range(0,tree.fort_node.get_child_count()):
			if i!=0:
				if tree.fort_node.get_child(i).position.distance_to(position)<tree.fort_node.get_child(i-1).position.distance_to(position):
					target=tree.fort_node.get_child(i)
					target_position=tree.fort_node.get_child(i).position
#					if position.distance_to(root.tower_node.get_child(i).position)==position.distance_to(root.tower_node.get_child(i-1).position):
#						target=root.tower_node.get_child(i)
#						target_position=root.tower_node.get_child(i).position
			else:
				target=tree.fort_node.get_child(0)
				target_position=tree.fort_node.get_child(0).position
	elif target_t==target_type.TOWNHALL && tree.townhall_node.get_child_count()>0:
		target=tree.townhall_node.get_child(0)
		target_position=tree.townhall_node.get_child(0).position
	elif ((target_t == target_type.TOWER && tree.tower_node.get_child_count()==0)||
		(target_t==target_type.BARN && tree.barn_node.get_child_count()==0)||
		(target_t==target_type.FORT && tree.fort_node.get_child_count()==0)):
		if tree.name=="Game5":
			if tree.townhall_node.get_child_count()>0:
				target=tree.townhall_node.get_child(0)
				target_position=tree.townhall_node.get_child(0).position
		else:
			if tree.warriors.get_child_count()>0:					
				for i in range(0,tree.warriors.get_child_count()):
					if i!=0:
						if tree.warriors.get_child(i).position.distance_to(position)<tree.warriors.get_child(i-1).position.distance_to(position):
							target=tree.warriors.get_child(i)
							target_position=tree.warriors.get_child(i).position
					else:
						target=tree.warriors.get_child(0)
						target_position=tree.warriors.get_child(0).position	
			else:
				if tree.units.get_child_count()>0:
					for i in range(0,tree.units.get_child_count()):
						if i!=0:
							if tree.units.get_child(i).position.distance_to(position)<tree.units.get_child(i-1).position.distance_to(position):
								target=tree.units.get_child(i)
								target_position=tree.units.get_child(i).position
						else:
							target=tree.units.get_child(0)
							target_position=tree.units.get_child(0).position	

func _state_machine():
	match AI_state:
		0:
			_choose_target()
			#print("Cambio a estado 1.")
			AI_state=1
		1:
			if target!=null && is_instance_valid(target):
				target_position=target.position
			else:
				#print("vuelta a estado 0")
				AI_state=0
			
		
		2:
			if !(is_instance_valid(body_entered)):
				#print("vuelta a estado 0")
				AI_state=0
			else:			
				target=body_entered.position
		3:
			target_position=self.position
	
	if body_entered!=null && is_instance_valid(body_entered):
		#print("se ha detectado un cuerpo")
		if !("Enemy" in body_entered.name) && ("Warrior" in body_entered.name || "Unit" in body_entered.name):
			target=body_entered
			target_position=body_entered.position
			#print("cambio a estado 2")
			AI_state=2	
	
	
	if position.distance_to(target_position)<=150 && target_position!=self.position:
		if can_shoot:
			_shoot()
		
			
	

func _on_EnemyWarrior_mouse_entered():
	if tree.name=="Game4":
		tree._on_Game4_is_sword()
	if tree.name=="Game5":
		tree._on_Game5_is_sword()
	tree.emit_signal("is_sword")
	tree.touching_enemy=self


func _on_EnemyWarrior_mouse_exited():
	if tree.name=="Game4":
		tree._on_Game4_is_arrow()
	if tree.name=="Game5":
		tree._on_Game5_is_arrow()
	tree.emit_signal("is_arrow")
	tree.touching_enemy=null


func _on_DetectionArea_body_entered(body):
	if ("Unit" in body.name || "Warrior" in body.name && !("Enemy" in body.name)):
		body_entered=body
		

func _shoot():
	var the_tilemap=get_tree().get_nodes_in_group("tilemap")
	var spear_target = target_position
	shoot_node.look_at(spear_target)				
	var angle = shoot_node.rotation
	var forward = Vector2(cos(angle),sin(angle))
	var spear_count=0
	for tilemap_child in the_tilemap[0].get_children():
		if "EnemySpear" in tilemap_child.name:
			spear_count+=1
	if spear_count==0:		
		spear = spear_scene.instance()
		shoot_point.rotation = angle				
		spear.position = Vector2(shoot_point.global_position.x,shoot_point.global_position.y)
		spear.set_dir(forward)
		spear.rotation = angle
			
	
		the_tilemap[0].add_child(spear)
	can_shoot=false	

func _walk():	
	firstPoint=position
	secondPoint=target_position
	var arrPath: PoolVector2Array = nav2d.get_simple_path(firstPoint,secondPoint,true)
	firstPoint=arrPath[0]
	path = arrPath			
	#line.points=arrPath	
	index=0		
	


func _on_DetectionArea_body_exited(body):
	body_entered=false




func _on_all_timer_timeout():
	if !can_shoot:
		can_shoot=true


func _on_StopTimer_timeout():
	if get_slide_count():
		current_distance_to_target = position.distance_to(target)
		if last_distance_to_target < current_distance_to_target + move_threshold:
			target = position
