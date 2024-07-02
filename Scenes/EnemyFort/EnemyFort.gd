extends Node2D


export var condition=0
export var condition_max=0
onready var tree=Globals.current_scene
onready var enemy_citizens=tree.get_node("EnemyCitizens")
onready var timer=$Timer
onready var bar=$Bar
onready var polygon=$CollisionPolygon2D
onready var enemy_fort_spawn=tree.get_node("EnemyFortSpawn")
var mouse_entered=false
var body_entered


func _ready():
	
	timer.start()
	
func _process(_delta):
	bar.value=condition


func _fort_build():
	if condition<condition_max:
		condition+=1

func _on_Timer_timeout():
	for enemy_citizen in enemy_citizens.get_children():
		if enemy_citizen.fort_entered:
			_fort_build()
	if body_entered!=null && is_instance_valid(body_entered):
		_get_damage(body_entered)
		timer.start()
	
		
	
func _get_damage(body):
	if is_instance_valid(body):
		if "Bullet" in body.name:
			condition-=3
			if condition<0:
				polygon.visible=false
				Globals.is_fort_built=false
				queue_free()
				tree.emit_signal("remove_building")
				Globals.is_enemy_fort_built=false
	else:
		body_entered=null


func _on_Area2D_body_entered(body):
	if "EnemyCitizen" in body.name:
		body.fort_entered=true
	if "Bullet" in body.name:
		body_entered=body

func _on_Area2D_body_exited(body):
	if "EnemyCitizen" in body.name:
		body.fort_entered=false


func _on_Fort_mouse_entered():
	mouse_entered=true
	tree._on_Game5_is_sword()
	tree.touching_enemy=self


func _on_Fort_mouse_exited():
	mouse_entered=false
	tree._on_Game5_is_arrow()
	tree.touching_enemy=null
