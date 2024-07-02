extends StaticBody2D


export var condition=0
export var condition_max=0
onready var tree
onready var enemy_citizens
onready var timer=$Timer
onready var polygon=$CollisionPolygon2D
onready var bar=$Bar
var mouse_entered=false


func _ready():
	tree=Globals.current_scene	
	enemy_citizens=tree.get_node("EnemyCitizens")
	
func _process(_delta):
	bar.value=condition
	


func _house_build():
	if condition<condition_max:
		condition+=1	
		
			


func _on_Area2D_body_entered(body):
	if "EnemyCitizen" in body.name:
		body.house_entered=true


func _on_Area2D_body_exited(body):
	if "EnemyCitizen" in body.name:
		body.house_entered=false


func _on_Timer_timeout():
	for enemy_citizen in enemy_citizens.get_children():
		if enemy_citizen.house_entered && enemy_citizen.position.distance_to(self.position)<150:
			_house_build()
	timer.start()


func _on_Area2D_mouse_entered():
	mouse_entered=true
	if tree.name=="Game5":
		tree._on_Game5_is_sword()
		tree.emit_signal("is_sword")
		tree.touching_enemy=self


func _on_Area2D_mouse_exited():
	mouse_entered=false
	if tree.name=="Game5":
		tree._on_Game5_is_arrow()
		tree.emit_signal("is_arrow")
		tree.touching_enemy=null

func _get_damage(body):
	if is_instance_valid(body):
		if "Bullet" in body.name:
			condition-=3
		if "Stone" in body.name && body.owner_name=="Citizen":
			condition-=3
	if condition<=0:
		polygon.visible=false
		queue_free()
		tree.emit_signal("remove_building")




