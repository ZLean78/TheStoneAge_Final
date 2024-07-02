extends Node2D


#Contador de unidades.
var unit_count = 1



onready var tree = Globals.current_scene
onready var food_timer = tree.get_node("food_timer")
onready var timer_label = tree.get_node("UI/Base/TimerLabel")
onready var food_label = tree.get_node("UI/Base/Rectangle/FoodLabel")
onready var prompts_label = tree.get_node("UI/Base/Rectangle/PromptsLabel")
onready var leaves_label = tree.get_node("UI/Base/Rectangle/LeavesLabel")
onready var stone_label = tree.get_node("UI/Base/Rectangle/StoneLabel")
onready var clay_label = tree.get_node("UI/Base/Rectangle/ClayLabel")
onready var wood_label = tree.get_node("UI/Base/Rectangle/WoodLabel")
onready var water_label = tree.get_node("UI/Base/Rectangle/WaterLabel")
#onready var developments_label = tree.get_node("UI/Base/Rectangle/DevelopmentsLabel")
onready var rectangle = tree.get_node("UI/Base/Rectangle")
onready var develop_stone_weapons = tree.get_node("UI/Base/Rectangle/DevelopStoneWeapons")
onready var invent_wheel = tree.get_node("UI/Base/Rectangle/InventWheel")
onready var discover_fire = tree.get_node("UI/Base/Rectangle/DiscoverFire")
onready var make_claypot = tree.get_node("UI/Base/Rectangle/MakeClaypot")
onready var develop_agriculture = tree.get_node("UI/Base/Rectangle/DevelopAgriculture")
onready var camera = tree.get_node("Camera")
onready var tiger_timer = tree.get_node("tiger_timer")
onready var tile_map = tree.get_node("TileMap")
onready var lake = tree.get_node("Lake")
onready var puddle = tree.get_node("Puddle")
onready var quarries = $Quarries
onready var citizens_node=tree.get_node("Citizens")
onready var nav2d=$nav
onready var spawn_position=tree.get_node("SpawnPosition")
onready var tiger_spawn=tree.get_node("TigerSpawn")
onready var tiger_target=tree.get_node("TigerTarget")
onready var tigers=$Tigers
onready var tiger = preload("res://Scenes/Tiger/Tiger.tscn")
onready var fruit_trees=$FruitTrees
onready var pine_trees=$PineTrees
onready var plants=$Plants
onready var next_scene_confirmation=$UI/Base/Rectangle/NextSceneConfirmation
onready var exit_confirmation=$UI/Base/ExitConfirmation
onready var replay_confirmation=$UI/Base/Rectangle/ReplayConfirmation

#Nodo que dibuja el rectángulo de selección de la cámara.
onready var select_draw=$SelectDraw

var path=[]

var cave

export (PackedScene) var Citizen

var selected_units=[]
var all_units=[]
var all_plants=[]
var all_trees=[]
var all_pine_trees=[]
var all_quarries=[]
var all_pickables=[]
var sheltered=[]
var all_tigers=[]


var dragging = false
var selected = []
var drag_start = Vector2.ZERO
#var select_rectangle = RectangleShape2D.new()


onready var draw_rect = get_tree().root.find_node("draw_rect")

var is_flipped = false

var screensize = Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height"))

var is_tiger=false
var is_tiger_coundown=false


signal is_arrow
signal is_basket
signal is_pick_mattock
signal is_sword
signal is_claypot
signal is_hand
signal is_axe
var arrow_mode=false
var basket_mode=false
var mattock_mode=false
var sword_mode=false
var claypot_mode=false
var hand_mode=false
var axe_mode=false

var start_string = """Recoge lodo, agua, alimentos, madera, piedra y hojas
para cumplir con cada uno de los hitos
marcados al seleccionar la
entrada de la cueva. Escapa de los tigres dientes de sable
o arrójales piedras haciendo
clic derecho sobre ellos estandoa gran distancia."""

#Si el cursor está en forma de espada tocando un tigre, lo guardamos en esta variable.
var touching_enemy

func _ready():
	AudioPlayer._select_music()
	AudioPlayer.music.play()
	
	all_units=citizens_node.get_children()
	all_plants=plants.get_children()
	all_trees=fruit_trees.get_children()
	all_pine_trees=pine_trees.get_children()
	all_quarries=quarries.get_children()
	
	#tile_map=tree.find_node("TileMap")
	cave=get_node("Cave/Cave")
	all_trees.append(tree.find_node("fruit_tree"))
	all_trees.append(tree.find_node("fruit_tree2"))
	all_trees.append(tree.find_node("fruit_tree3"))
	all_trees.append(tree.find_node("fruit_tree4"))
	all_trees.append(tree.find_node("fruit_tree5"))
	all_trees.append(tree.find_node("fruit_tree6"))
	all_plants.append(tree.find_node("Plant"));
	all_plants.append(tree.find_node("Plant2"));
	#all_units.append(tree.find_node("Unit2"))
	
	
	all_pine_trees.append(tree.find_node("PineTree1"))
	all_pine_trees.append(tree.find_node("PineTree2"))
	all_pine_trees.append(tree.find_node("PineTree3"))
	all_pine_trees.append(tree.find_node("PineTree4"))
	all_pine_trees.append(tree.find_node("PineTree5"))
	all_pine_trees.append(tree.find_node("PineTree6"))
	all_pine_trees.append(tree.find_node("PineTree7"))
	all_pine_trees.append(tree.find_node("PineTree8"))
	
	
	#all_tigers.append(tree.find_node("Tiger1"))
	#all_tigers.append(tree.find_node("Tiger2"))
	#all_tigers.append(tree.find_node("Tiger3"))

#	all_quarries.append(quarry1)
#	all_quarries.append(quarry2)

	$UI.add_child(Globals.settings)
	
	for i in range(0,11):
		_create_citizen();
	
	for i in range(0,12):
		if i==0:
			all_units[i].position = Vector2(camera.position.x+50,camera.position.y+50)
			#all_units[i].position = Vector2(camera.get_viewport().size.x/6,camera.get_viewport().size.y/4)
		else:
			if i<4:
				all_units[i].position =	Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
			elif i>=4 && i<8:
				if i==4:
					all_units[i].position =	Vector2(all_units[0].position.x,all_units[0].position.y+20)
				else:
					all_units[i].position = Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
			elif i>=8:
				if i==8:
					all_units[i].position = Vector2(all_units[0].position.x,all_units[0].position.y+40)
				else:
					all_units[i].position = Vector2(all_units[i-1].position.x+20,all_units[i-1].position.y)
	
	_rebake_navigation()
	
	#Agregar ropa y bolso a todas las unidades
	for a_unit in all_units:
		a_unit.is_dressed=true
		a_unit.has_bag=true
		a_unit.bag_sprite.visible=true
		if a_unit.is_girl:
			a_unit.sprite.animation="female_idle1_d"
		else:
			a_unit.sprite.animation="male_idle1_d"
		Globals.group_dressed=true
		Globals.group_has_bag=true

	emit_signal("is_arrow")
	arrow_mode=true
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	

func _process(_delta):
	var valid_counter=0
	for a_tiger in all_tigers:
		if is_instance_valid(a_tiger):
			valid_counter+=1
			
	if valid_counter==0:
		timer_label.text = "POSIBLE PELIGRO EN: " + str(int(tiger_timer.time_left))
	else:
		timer_label.text = "¡CUIDADO, HAY TIGRES!"
	
	
	food_label.text = str(int(Globals.food_points))
	leaves_label.text = str(int(Globals.leaves_points))	
	stone_label.text = str(int(Globals.stone_points))	
	clay_label.text = str(int(Globals.clay_points))
	wood_label.text = str(int(Globals.wood_points))
	water_label.text = str(int(Globals.water_points))
	
	_check_units()	
	_check_victory()
			
		
	if !is_tiger:
		if !is_tiger_coundown:
			tiger_timer.start()
			is_tiger_coundown=true	
	
	
			
		
func _select_unit(unit):
	if not selected_units.has(unit):
		selected_units.append(unit)
	#print("selected %s" % unit.name)
	#create_buttons()

func _deselect_unit(unit):
	if selected_units.has(unit):
		selected_units.erase(unit)			

		
func _deselect_all():
	while selected_units.size()>0:
		selected_units[0]._set_selected(false)
		
func _select_last():
	for unit in selected_units:
		if selected_units[selected_units.size()-1] == unit:
			unit._set_selected(true)
		else:
			unit._set_selected(false)
		
func _unhandled_input(event):
	if event.is_action_pressed("RightClick"):
		if arrow_mode:
			for i in range(0,selected_units.size()):			
				if i==0:
					selected_units[i].target_position=get_global_mouse_position()
				else:
					if i%4==0:
						selected_units[i].target_position=Vector2(selected_units[0].target_position.x,selected_units[i-1].target_position.y+20)
					else:
						selected_units[i].target_position=Vector2(selected_units[i-1].target_position.x+20,selected_units[i-1].target_position.y)
		if basket_mode || axe_mode || mattock_mode || hand_mode || claypot_mode:
			for i in range(0,selected_units.size()):
				selected_units[i].target_position=get_global_mouse_position()
		
			
	if event.is_action_pressed("EscapeKey"):
		#Si el cursor está en modo flecha.
		if arrow_mode:
			if(all_units.size()==0 && Globals.food_points<15):
				replay_confirmation.visible=true
			else:
				$UI/Base/Rectangle/OptionsMenu.visible=!$UI/Base/Rectangle/OptionsMenu.visible
		else:
			_on_Game2_is_arrow()

			
	
func _create_citizen(cost = 0):
	var new_citizen = Citizen.instance()
	unit_count+=1	
	if(unit_count%2==0):
		new_citizen.is_girl=true
	else:
		new_citizen.is_girl=false
	if(Globals.group_dressed):
		new_citizen.is_dressed=true	
	if(Globals.group_has_bag):
		new_citizen.has_bag=true	
		new_citizen.get_child(3).visible = true
	Globals.food_points -= cost
	new_citizen.position = spawn_position.position
	for unit in citizens_node.get_children():
		if new_citizen.position==unit.position:
			new_citizen.position+=Vector2(20,20)
	citizens_node.add_child(new_citizen)
	all_units.append(new_citizen)
		

			
func _check_victory():
	if Globals.is_fire_discovered && Globals.is_wheel_invented && Globals.is_stone_weapons_developed && Globals.is_claypot_made && Globals.is_agriculture_developed:
		prompts_label.text = "¡Has ganado!"
		next_scene_confirmation.visible=true
			
		
	elif(all_units.size()==0 && Globals.food_points<15):
		prompts_label.text = "Has sido derrotado."	
		replay_confirmation.visible=true

		
	
func _on_CreateCitizen_pressed():
	if Globals.food_points>=15:
		_create_citizen(15)
		


func _on_tiger_timer_timeout():
	var valid_counter=0
	for a_tiger in all_tigers:
		if is_instance_valid(a_tiger):
			valid_counter+=1
	
	
	if valid_counter==0:	
		for tiger_counter in range(0,2):
			var new_tiger = tiger.instance()
			if tiger_counter==0:
				new_tiger.tiger_number=1
			if tiger_counter==1:
				new_tiger.tiger_number=2
			if tiger_counter==2:
				new_tiger.tiger_number=3
			new_tiger.position = tiger_spawn.position
			tigers.add_child(new_tiger)
			all_tigers.append(new_tiger)
			
	else:
		tiger_timer.start()
		
		
		
	for a_tiger in all_tigers:
		if is_instance_valid(a_tiger):
			a_tiger.visible=true
			is_tiger=true
			var random_num=randi()
			if random_num%2==0:
				a_tiger.target_position=spawn_position.position
			else:
				a_tiger.target_position=tiger_spawn.position

		

		
func get_units_in_area(area):
	var u=[]
	for unit in all_units:
		if unit.position.x>area[0].x and unit.position.x<area[1].x:
			if unit.position.y>area[0].y and unit.position.y<area[1].y:
				u.append(unit)
	return u

func _area_selected(obj):
	var start=obj.start
	var end=obj.end
	var area=[]
	area.append(Vector2(min(start.x,end.x),min(start.y,end.y)))
	area.append(Vector2(max(start.x,end.x),max(start.y,end.y)))
	var ut = get_units_in_area(area)
	if not Input.is_key_pressed(KEY_SHIFT):
		_deselect_all()
	for u in ut:
		u.selected = not u.selected
		

		
func start_move_selection(obj):
	for un in all_units:
		if un.selected:
			un.move_unit(obj.move_to_point)
		


func move_group():
	var pos_minus_one=0
	for i in range (0,selected_units.size()):
		if i==0:
			selected_units[i].target_position = get_global_mouse_position()	
		else:
			if i%4==0:
				selected_units[i].target_position =	Vector2(get_global_mouse_position().x,pos_minus_one.y+20)
			else:
				selected_units[i].target_position =	Vector2(pos_minus_one.x+20,pos_minus_one.y)
		pos_minus_one=selected_units[i].target_position





	

func _on_DevelopStoneWeapons_pressed():
	if Globals.stone_points>=70 && Globals.wood_points>=70 && Globals.leaves_points >=50:
		Globals.stone_points-=70
		Globals.wood_points-=70
		Globals.leaves_points-=50
		Globals.is_stone_weapons_developed=true	
		develop_stone_weapons.visible = false	
		
		


func _on_InventWheel_pressed():
	if Globals.stone_points >=70 && Globals.wood_points>=40:
		Globals.stone_points-=70
		Globals.wood_points-=40
		Globals.is_wheel_invented=true
		invent_wheel.visible = false

func _on_DiscoverFire_pressed():
	if Globals.wood_points >=60 && Globals.stone_points>=40:
		Globals.wood_points-=60
		Globals.stone_points-=40
		Globals.is_fire_discovered=true
		discover_fire.visible = false
		
func _on_MakeClaypot_pressed():
	if Globals.clay_points>=85:
		Globals.clay_points-=85
		Globals.is_claypot_made=true
		make_claypot.visible=false


func _on_DevelopAgriculture_pressed():
	if Globals.food_points>=70 && Globals.leaves_points>=70 && Globals.water_points>=70:
		Globals.food_points-=70
		Globals.leaves_points-=70
		Globals.water_points-=70
		Globals.is_agriculture_developed=true
		develop_agriculture.visible=false


func _on_Game2_is_arrow():
	Input.set_custom_mouse_cursor(Globals.arrow)
	arrow_mode=true
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false


func _on_Game2_is_basket():
	Input.set_custom_mouse_cursor(Globals.basket)
	basket_mode=true
	arrow_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	
func _on_Game2_is_pick_mattock():
	Input.set_custom_mouse_cursor(Globals.pick_mattock)
	mattock_mode=true
	basket_mode=false
	arrow_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false


func _on_Game2_is_sword():
	Input.set_custom_mouse_cursor(Globals.sword)
	sword_mode=true
	mattock_mode=false
	basket_mode=false
	arrow_mode=false
	claypot_mode=false
	hand_mode=false
	axe_mode=false
	


func _on_Game2_is_hand():
	Input.set_custom_mouse_cursor(Globals.hand)
	hand_mode=true
	mattock_mode=false
	basket_mode=false
	arrow_mode=false
	sword_mode=false
	claypot_mode=false
	axe_mode=false
	


func _on_Game2_is_claypot():
	Input.set_custom_mouse_cursor(Globals.claypot)
	claypot_mode=true
	arrow_mode=false
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	hand_mode=false
	axe_mode=false


func _on_Game2_is_axe():
	Input.set_custom_mouse_cursor(Globals.axe)
	axe_mode=true
	arrow_mode=false
	basket_mode=false
	mattock_mode=false
	sword_mode=false
	claypot_mode=false
	hand_mode=false



func _check_units():
	for a_unit in all_units:
		if a_unit.is_deleted:
			var the_unit=all_units[all_units.find(a_unit,0)]
			all_units.remove(all_units.find(a_unit,0))
			the_unit._die()
	
	
func _update_path(new_obstacle):	
	var citizens=citizens_node.get_children()
	var the_citizen=null
	var new_polygon=PoolVector2Array()
	var col_polygon=new_obstacle.get_node("CollisionPolygon2D").get_polygon()
	
	for vector in col_polygon:
		new_polygon.append(vector + new_obstacle.position)		
		
	var navi_polygon=nav2d.get_node("polygon").get_navigation_polygon()
	navi_polygon.add_outline(new_polygon)
	navi_polygon.make_polygons_from_outlines()	
	
	for citizen in citizens:
		if citizen.selected:
			the_citizen=citizen
			break
	
	if the_citizen!=null:	
		var p = nav2d.get_simple_path(the_citizen.firstPoint,the_citizen.secondPoint,true)
		path = Array(p)
		path.invert()

func _rebake_navigation():
	nav2d.get_node("polygon").enabled=false
	var navi_polygon=nav2d.get_node("polygon").get_navigation_polygon()
	navi_polygon.clear_outlines()
	navi_polygon.clear_polygons()
	
	#Agregar límite general y cueva.
	navi_polygon.add_outline(PoolVector2Array([
	Vector2(-1024,-608),
	Vector2(1024,-608),
	Vector2(1024,608),
	Vector2(-1024,608)]))
	
	#Agregar lago.
	_update_path(lake)
	
	#Agregar cueva.
	_update_path(cave)
		

		
	
		
	navi_polygon.make_polygons_from_outlines()	
	nav2d.get_node("polygon").enabled=true
	


func _on_ExitConfirmation_confirmed():
	$UI.remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Menu/Menu.tscn")



func _on_ReplayOk_pressed():
	$UI.remove_child(Globals.settings)
	get_tree().reload_current_scene()


func _on_ReplayCancel_pressed():
	exit_confirmation.popup()
	exit_confirmation.get_ok().text="Aceptar"
	exit_confirmation.get_cancel().text="Cancelar"


func _on_NextSceneOk_pressed():
	$UI.remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Intermissions/Intermission2.tscn")


func _on_Settings_pressed():
	Globals.settings.visible=true


func _on_Quit_pressed():
	exit_confirmation.popup()
	exit_confirmation.get_ok().text="Aceptar"
	exit_confirmation.get_cancel().text="cancelar"


func _on_Back_pressed():
	$UI/Base/Rectangle/OptionsMenu.visible=false
