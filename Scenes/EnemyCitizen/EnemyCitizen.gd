extends "res://Scenes/Unit/Unit.gd"



onready var fruit_trees_node
onready var pine_trees_node
onready var plants_node
onready var quarries_node
onready var copper_node
onready var lake_node
onready var puddle_node


#Temporizador de comida, agrega un punto de comida por segundo cuando la unidad toca un árbol frutal.
onready var food_timer

#Marca de jefe guerrero.
onready var warchief_mark= $WarchiefMark


#Posición inicial, se actualiza cada vez que hacemos click con el botón derecho.
var initialPosition = Vector2()

#Puntos de comida de la unidad.
var food_points = 0


#Variable que indica si se está arrastrando el mouse sobre la unidad.
var dragging = true


#var click_relative = 16
#Indica si la unidad ha muerto.
var dead = false


var touch_enabled = false
#Indica si la unidad se encuentra bajo refugio.
var is_sheltered = false
#Indica si la unidad es o no mujer.
var is_girl = false
#Indica si la unidad está vestida (tiene túnica de hojas o no).
var is_dressed = false
#Indica si tiene cesta de hojas o no.
var has_bag = false
#Indica si la unidad ha sido eliminada o no.


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

#Indica si la unidad está tocando un árbol frutal.
var fruit_tree_touching = false

#Indica si la unidad está tocando una planta (para obtener hojas).
var plant_touching = false

#Indica si la unidad está tocando una cantera (para obtener piedra).
var quarry_touching = false

#Indica si la unidad está tocando un charco (para obtener lodo).
var puddle_touching = false

#Indica si la unidad está tocando un pino (para obtener madera).
var pine_tree_touching = false

#Indica si la unidad está tocando el lago (para obtener agua).
var lake_touching = false

#Indica si la unidad está tocando un pickable (objecto para recoger).
var pickable_touching = false


#Variable que indica el pickable que la unidad está tocando
var pickable = null




#Para saber si la unidad ha sido convertida en jefe guerrero.
var is_warchief = false

var can_shoot = true



var direction = Vector2.ZERO



#Variables para levantamiento de construcciones, que indican si una unidad ciudadano
#ha entrado en el Area2D de la construcción para erigirla.
var house_entered=false
var townhall_entered=false
var fort_entered=false
var tower_entered=false
var barn_entered=false

#Variables origen y destino de navegación.
var firstPoint = Vector2.ZERO
var secondPoint = Vector2.ZERO
var index = 0

var AI_state = 0

#Variable enumerador que discrimina el tipo de objetivo.
enum target_type {FRUIT_TREE,PINE_TREE,PLANT,STONE,COPPER,CLAY,WATER}

var target=null
export (target_type) var target_t
export (float) var MIN_DISTANCE
export (float) var MAX_DISTANCE

#Podígono de navegación
onready var nav2d

#Variables para curarse o curar a otro
#var health=MAX_HEALTH
var heal_counter=60
var can_heal_itself=false
var can_heal_another

var is_timer_timeout=false


func _ready():
	AI_state=1
	tree=Globals.current_scene
	food_timer=tree.food_timer
	fruit_trees_node=tree.get_node("FruitTrees")
	pine_trees_node=tree.get_node("PineTrees")
	plants_node=tree.get_node("Plants")
	quarries_node=tree.get_node("Quarries")
	copper_node=tree.get_node("Coppers")
	lake_node=tree.get_node("Lake")
	puddle_node=tree.get_node("Puddle")
	nav2d=tree.get_node("nav")

	
	
	has_bag=true
	bar=$Bar
	all_timer=$all_timer
	foot=$Selected
	
	sprite = $scalable/sprite
	bag_sprite = $scalable/bag_sprite
	shoot_node = $shootNode
	shoot_point = $shootNode/shootPoint
	
	#Salud.
	health = MAX_HEALTH
	
	is_dressed=true
	has_bag=true
	
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
			
	if(!has_bag):
		bag_sprite.visible=false
	else:
		bag_sprite.visible=true		

	#_set_selected(true)
	


func _physics_process(delta):
	
	to_delta=delta
	
	position.x = clamp(position.x,-1028,1028)
	position.y = clamp(position.y,-608,608)	
	
	if AI_state==1 || AI_state==2:
		
		if(AI_state==2):
			_move_along_path((SPEED/2)*delta)
		else:
			_move_along_path(SPEED*delta)
		
		if target_position!=null:
			if position.distance_to(target_position) > MAX_DISTANCE:
				_walk()		
	
	
	if selected:
		if foot.visible == false:
			foot.visible = true
	else:
		if foot.visible == true:
			foot.visible = false
	


	
	# Orientar al player.
	if velocity.x<0:
		if(is_flipped==false):			
			$scalable.scale.x = -1
			is_flipped = true
	if velocity.x>0:
		if(is_flipped==true):			
			$scalable.scale.x = 1
			is_flipped = false
	
	
	
	#Máquina de estados para las acciones.
	_state_machine()		
	#animar al personaje	
	$Animation._animate(sprite,is_dressed,is_girl,bag_sprite,velocity,target_position)	
		
	#Cambiar los cuadros de animación del player.
	if position.distance_to(target_position) <= 10:
		sprite.stop()
	else:
		sprite.play()

		
	if(all_timer.is_stopped()):
		timer_count-=1
		all_timer.start()
	
		
func _collect_pickable(var _pickable):
	if _pickable.type == "fruit_tree" or _pickable.type == "pine_tree" or _pickable.type == "plant" or _pickable.type == "quarry" or _pickable.type == "copper":
		if _pickable.touching && !_pickable.empty && pickable_touching:
			if((abs(position.x-_pickable.position.x)<50)&&
			(abs(position.y-_pickable.position.y)<50)):
				if _pickable.type=="fruit_tree":
					if(has_bag):
						if(_pickable.points>=4):
							Globals.e_food_points+=4
							_pickable.points-=4
						else:
							Globals.e_food_points+=_pickable.points
							_pickable.points = 0
					else:					
						Globals.e_food_points+=1
						_pickable.points-=1
						#if _pickable.points <= 0:
						#_pickable.empty = true
				elif _pickable.type == "pine_tree":
					if(Globals.is_stone_weapons_developed):
						if(_pickable.points>=4):
							Globals.e_wood_points+=4
							_pickable.points-=4
						else:
							Globals.e_wood_points+=_pickable.points
							_pickable.points = 0
					else:					
						Globals.e_wood_points+=1
						_pickable.points-=1
				elif _pickable.type=="plant":
					if(has_bag):
						if(_pickable.points>=4):
							Globals.e_leaves_points+=4
							_pickable.points-=4
						else:
							Globals.e_leaves_points+=_pickable.points
							_pickable.points=0
					else:
						Globals.e_leaves_points+=1
						_pickable.points-=1
				elif _pickable.type == "copper":
					if(Globals.is_stone_weapons_developed):
						if(_pickable.points>=5):
							Globals.e_copper_points+=5
							_pickable.points-=5
						else:
							Globals.e_copper_points+=_pickable.points
							_pickable.points=0
					else:
						Globals.e_copper_points+=1
						_pickable.points-=1
				elif _pickable.type == "quarry":
					if(Globals.is_stone_weapons_developed):
						if(_pickable.points>=5):
							Globals.e_stone_points+=5
							_pickable.points-=5
						else:
							Globals.e_stone_points+=_pickable.points
							_pickable.points=5
					else:
						Globals.e_stone_points+=1
						_pickable.points-=1
				if _pickable.points <= 0:
					_pickable.empty = true	
	else:
		if _pickable.touching && pickable_touching:
			if _pickable.type == "puddle" && puddle_touching:
				Globals.e_clay_points+=4
			elif _pickable.type == "lake" && lake_touching:
				if tree.name == "Game2":
					if Globals.is_claypot_made:
						Globals.e_water_points+=4
					else:
						tree.prompts_label.text="Debes desarrollar el cuenco de barro \n para poder transportar agua."
				else:
					Globals.water_points+=4
				
					


		
func _get_damage(var collider):
	if "Tiger" in collider.name && collider.visible && is_enemy_touching:
		if is_warchief:
			if(health>0):
				if(!is_dressed):
					health-=10
				else:
					health-=5
				bar._set_health(health)
				
			else:
				_set_selected(false)			
				is_deleted=true				
		else:
			if(health>0):
				if(!is_dressed):
					health-=15
				else:
					health-=10
				bar._set_health(health)
				
			else:
				if collider:
					_set_selected(false)			
					is_deleted=true
	if "Mammoth" in collider.name && is_enemy_touching:
		if health>0:
			health-=30
			bar._set_health(health)
			
		else:
			_set_selected(false)			
			is_deleted=true
	if "Bullet" in collider.name:
		
		if health>0:			
			health-=20
			bar._set_health(health)			
		else:
			is_deleted=true

	if "Warrior" in collider.name && is_enemy_touching:
		if health>0:
			health-=20
			bar._set_health(health)
			
		else:
			_set_selected(false)			
			is_deleted=true
	if "Unit2" in collider.name && is_enemy_touching:
		if health>0:
			health-=10
			bar._set_health(health)
			
		else:
			_set_selected(false)			
			is_deleted=true
	if "Stone" in collider.name && collider.owner_name=="Citizen":
		if health>0:
			health-=15
			bar._set_health(health)			
		else:
			_set_selected(false)			
			is_deleted=true
					
								


	
	
func _move_towards(pos,point,delta):
	var v = (point-pos).normalized()
	v *=delta*SPEED
	position += v
	if position.distance_squared_to(point) < 5:
		path.remove(0)
		initialPosition = position
		
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
		

func _move_to_target(target):
	direction = (target-position)
	velocity=(direction).normalized()
	var collision = move_and_collide(velocity*to_delta*SPEED)
	




func _on_Target_Position_body_entered(_body):
	velocity = Vector2(0,0)
	touch_enabled = false
	#device_number = 0
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
		



func _set_pickable_touching(var _pickable):
	pickable_touching=_pickable
	
func _set_pickable(_pickable):
	pickable=_pickable	


	
func _set_erased(var _is_erased):
	is_erased=_is_erased
	

#	
func _on_all_timer_timeout():
#	if body_entered!=null:
#		heal(body_entered)
	timer_count+=1	
	

	
	
	
	if pickable!=null:
		_collect_pickable(pickable)
	if timer_count>3:
		can_shoot=true
		
	if timer_count>4:
		timer_count=0
		
	all_timer.start()
	
	

func _die():
	queue_free()

func _on_Area2D_body_entered(body):
	if (("Tower" in body.name || "Warrior" in body.name || "Unit" in body.name || "Vehicle" in body.name)
		&& !("Enemy" in body.name)):	
		body_entered=body	
		if is_instance_valid(body_entered):
			if "Warrior" in body.name || "Unit" in body.name || "Vehicle" in body.name:
				body.is_enemy_touching=true
			
	
	
func heal(_body):
	if is_warchief:
		#print(to_delta)	
		if _body.health<_body.MAX_HEALTH:
			#if timer_count==0:
			_body.health+=5
			print("unit energy" + str(_body.health))
			_body.bar._set_health(_body.health)
			
	
			if _body.health>_body.MAX_HEALTH:
				_body.health=_body.MAX_HEALTH
		
		_body.bar.visible=true
		
			
func self_heal():	
	if health<MAX_HEALTH:
		health+=5
		bar._set_health(health)
		
		
		if health>MAX_HEALTH:
			health=MAX_HEALTH
			can_heal_itself=false
			heal_counter=60





func _shoot():
	if(target!=null) && is_instance_valid(target):
		target_position = target.position
		shoot_node.look_at(target_position)				
		var angle = shoot_node.rotation
		#var forward = Vector2(cos(angle),sin(angle))
		var new_stone = stone_scene.instance()
		shoot_point.rotation = angle				
		new_stone.position = Vector2(shoot_point.global_position.x,shoot_point.global_position.y)
		if target_position.x<position.x:
			new_stone.set_velocity(Vector2(-200,0))
		else:
			new_stone.set_velocity(Vector2(200,0))
		new_stone.rotation = angle
		new_stone.owner_name="EnemyCitizen"		
		var the_tilemap=get_tree().get_nodes_in_group("tilemap")
		the_tilemap[0].add_child(new_stone)
		can_shoot=false

func _walk():
	firstPoint = global_position
	secondPoint = target_position		
	var arrPath: PoolVector2Array = nav2d.get_simple_path(firstPoint,secondPoint,true)
	firstPoint = arrPath[0]
	path = arrPath
	index = 0				
			


func _on_Area2D_body_exited(body):
	if "Warrior" in body.name || "Unit" in body.name:
		body.is_enemy_touching=false
		body_entered=null	
	
	
func _choose_target():
	if is_instance_valid(body_entered) && body_entered!=null && ("Warrior" in body_entered.name || "Citizen" in body_entered.name || "Vehicle" in body_entered.name) && !("Enemy" in body_entered.name):
		target=body_entered
		target_position=body_entered.position
	else:
		match target_t:
			target_type.PLANT:
				if !(AI_state==2):
					if plants_node.get_child_count()>0:
						for i in range(0,plants_node.get_child_count()):
							if !plants_node.get_child(i).empty:
								target_position=plants_node.get_child(i).position
								break
							else:
								target_position=plants_node.get_child(i+1).position
	
	
			target_type.FRUIT_TREE:
				if !(AI_state==2):
					if fruit_trees_node.get_child_count()>0:
						for i in range(0,fruit_trees_node.get_child_count()):
							if !fruit_trees_node.get_child(i).empty:
								target_position=fruit_trees_node.get_child(i).position
								break
							else:
								target_position=fruit_trees_node.get_child(i+1).position
			target_type.PINE_TREE:
				if !(AI_state==2):
					if pine_trees_node.get_child_count()>0:				
						for i in range(0,pine_trees_node.get_child_count()):
							if !pine_trees_node.get_child(i).empty:
								target_position=pine_trees_node.get_child(i).position
								break
							else:
								target_position=pine_trees_node.get_child(i+1).position		
			target_type.COPPER:
				if !(AI_state==2):
					if copper_node.get_child_count()>0:				
						for i in range(0,copper_node.get_child_count()):
							if !copper_node.get_child(i).empty:
								target_position=copper_node.get_child(i).position
								break
							else:
								target_position=copper_node.get_child(i+1).position
			target_type.STONE:
				if !(AI_state==2):
					if quarries_node.get_child_count()>0:				
						for i in range(0,quarries_node.get_child_count()):
							if !quarries_node.get_child(i).empty:
								target_position=quarries_node.get_child(i).position
								break
							else:
								target_position=quarries_node.get_child(i+1).position
	

	
	

func _state_machine():
	match AI_state:
		0:
			_choose_target()
			AI_state=1
		1:
			if target!=null && is_instance_valid(target):
				if( !("Lake" in target.name) && !("Puddle" in target.name) 
				&& !("Unit" in target.name) && !("Warrior" in target.name) && !("Vehicle"in target.name)):
					if target.empty:
						AI_state=0
						if target_t==target_type.COPPER:
							print("Cambio buscador de cobre a estado 0")							
			else:
				AI_state=0
		2:
			if !(is_instance_valid(body_entered)):
				#print("vuelta a estado 0")
				AI_state=0
			else:	
				if position.distance_to(target_position)<=150 && target_position!=self.position:	
					if can_shoot:
						_shoot()
				else:
					target_position=body_entered.position
				
		3:
			target_position=self.position
			
	if body_entered!=null && is_instance_valid(body_entered):
		if !("Enemy" in body_entered.name) && ("Warrior" in body_entered.name || "Citizen" in body_entered.name || "Vehicle" in body_entered.name):
			target_position=body_entered.position-Vector2(50,50)
			AI_state=2	
			if position.distance_to(target_position)<=50:
				if can_shoot:
					_shoot()
	
						
	if tree.enemy_fort_node.get_child_count()>0:
		if is_instance_valid(tree.enemy_fort_node.get_child(0)):	
			if target_t==target_type.PINE_TREE:
				if tree.enemy_fort_node.get_child(0).condition<70:
					target_position=tree.enemy_fort_node.get_child(0).position
	
	if is_instance_valid(tree.enemy_townhall):			
		if tree.enemy_townhall.condition<80 && target_t!=target_type.PINE_TREE:
			target_position=tree.enemy_townhall.position


	
	
	

func _on_EnemyCitizen_mouse_entered():
	if tree.name=="Game4":
		tree._on_Game4_is_sword()
	if tree.name=="Game5":
		tree._on_Game5_is_sword()
	tree.emit_signal("is_sword")
	tree.touching_enemy=self


func _on_EnemyCitizen_mouse_exited():
	if tree.name=="Game4":
		tree._on_Game4_is_arrow()
	if tree.name=="Game5":
		tree._on_Game5_is_arrow()
	tree.emit_signal("is_arrow")
	tree.touching_enemy=null
