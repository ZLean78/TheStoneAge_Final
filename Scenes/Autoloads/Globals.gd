extends Node

var current_scene=null
var root

#Variables de íconos del mouse.
var basket=load("res://Scenes/MouseIcons/basket.png")
var arrow=load("res://Scenes/MouseIcons/arrow.png")
var pick_mattock=load("res://Scenes/MouseIcons/pick_mattock.png")
var sword=load("res://Scenes/MouseIcons/sword.png")
var claypot=load("res://Scenes/MouseIcons/claypot.png")
var hand=load("res://Scenes/MouseIcons/hand.png")
var axe=load("res://Scenes/MouseIcons/axe.png")
var house=load("res://Scenes/MouseIcons/house.png")
var house_b=load("res://Scenes/MouseIcons/house_b.png")
var townhall=load("res://Scenes/MouseIcons/townHall.png")
var townhall_b=load("res://Scenes/MouseIcons/townHall_b.png")
var fort=load("res://Scenes/MouseIcons/fort_s.png")
var fort_b=load("res://Scenes/MouseIcons/fort_sb.png")
var barn=load("res://Scenes/MouseIcons/barn_s.png")
var barn_b=load("res://Scenes/MouseIcons/barn_sb.png")
var tower=load("res://Scenes/MouseIcons/tower_s.png")
var tower_b=load("res://Scenes/MouseIcons/tower_sb.png")

#var settings=load("res://Scenes/Settings/Settings.tscn")

#Puntos de recursos de la comunidad.
var food_points = 15
var leaves_points = 0
var stone_points = 0
var wood_points = 0
var clay_points = 0
var water_points = 0
var copper_points = 0

#Puntos de recursos del pueblo enemigo:
var e_food_points = 0
var e_leaves_points = 0
var e_stone_points = 0
var e_wood_points = 0
var e_clay_points = 0
var e_water_points = 0
var e_copper_points = 0

#Condiciones que afectan a toda la comunidad
var group_dressed = false
var group_has_bag = false

#Variables de hitos
var is_fire_discovered = false
var is_wheel_invented = false
var is_stone_weapons_developed = false
var is_claypot_made = false
var is_agriculture_developed = false
var is_townhall_created = false
var is_pottery_developed=false
var is_carpentry_developed=false
var is_mining_developed=false
var is_metals_developed=false
var is_first_tower_built=false
var is_barn_built=false
var is_fort_built=false
var is_enemy_fort_built=false
var is_townhall_down=false
var is_enemy_townhall_down=false

var screen_size:Vector2

var settings_scene=load("res://Scenes/Settings/Settings.tscn")
var settings=settings_scene.instance()

var houses_p=[]
var townhall_p=Vector2()
var barn_p=Vector2()
var fort_p=Vector2()
var towers_p=[]
var warchief_index=0

func _ready():
	root=get_tree().root
	current_scene = root.get_child(root.get_child_count()-1)
	screen_size=Vector2(1280,720)
	


	

func go_to_scene(path):
	call_deferred("_deferred_go_to_scene", path)

func _deferred_go_to_scene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	
	get_tree().root.add_child(current_scene)
	
	#Opcional, para hacerlo compatible con la API the SceneTree.change_scene_to_file(). 
	get_tree().current_scene=current_scene
	
func _clear_globals():
	
	food_points = 15
	leaves_points = 0
	stone_points = 0
	wood_points = 0
	clay_points = 0
	water_points = 0
	copper_points = 0

	e_food_points = 0
	e_leaves_points = 0
	e_stone_points = 0
	e_wood_points = 0
	e_clay_points = 0
	e_water_points = 0
	e_copper_points = 0

	group_dressed = false
	group_has_bag = false

	is_fire_discovered = false
	is_wheel_invented = false
	is_stone_weapons_developed = false
	is_claypot_made = false
	is_agriculture_developed = false
	is_townhall_created = false
	is_pottery_developed=false
	is_carpentry_developed=false
	is_mining_developed=false
	is_metals_developed=false
	is_first_tower_built=false
	is_barn_built=false
	is_fort_built=false
	is_enemy_fort_built=false
	is_townhall_down=false
	is_enemy_townhall_down=false

	houses_p=[]
	townhall_p=Vector2()
	barn_p=Vector2()
	fort_p=Vector2()
	towers_p=[]
	warchief_index=0
