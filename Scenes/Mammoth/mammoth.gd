extends KinematicBody2D

var start_position
var state=0
var target_position=Vector2()
var body_entered
var velocity=Vector2()
var is_dead=false
var speed=50.0
var life=120
var tree
onready var progress_bar=$ProgressBar
export var is_flipped:bool
onready var warriors
onready var citizens

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	tree=Globals.current_scene
	warriors=tree.get_node("Warriors")
	citizens=tree.get_node("Units")
	start_position=position
	progress_bar.value = life
	if is_flipped==false:
		$Scalable.scale.x=1
	else:
		$Scalable.scale.x=-1

func _physics_process(delta):
	
	#Comprobar máquina de estados.
	check_state()
	
	#Mover y comprobar colisiones.
	if position.distance_to(target_position)>5:
		var direction=(target_position-position)
		velocity=direction.normalized()*speed
		
		var collision = move_and_slide(velocity)

#		if collision!=null && is_instance_valid(collision.collider):
#			if "Bullet" in collision.collider.name || "Stone" in collision.collider.name:
#				life-=20
#				if life <=0:
#					get_tree().root.get_child(0).food_points+=90
#					get_tree().root.get_child(0).wood_points+=60
#					get_tree().root.get_child(0).stone_points+=40
#					is_dead=true
#					queue_free()
	
	#Actualizar barra de vida.
	progress_bar.value=life
		
	# Orientar al mamut.
	if velocity.x<0:
		if(is_flipped==false):			
			$Scalable.scale.x = -1
			is_flipped = true
	if velocity.x>0:
		if(is_flipped==true):			
			$Scalable.scale.x = 1
			is_flipped = false
			
			
func _get_damage(var the_beast):
	if "Stone" in the_beast.name:
		the_beast.queue_free()
		if life>0:
			life-=10
	else:
		queue_free()
	
	if "Bullet" in the_beast.name:
		the_beast.queue_free()
		if life>0:
			life-=20
	else:
		queue_free()
	
func check_state():
	
	match state:
		0:
			target_position=position			
		1: 
			if body_entered!=null && is_instance_valid(body_entered):
				target_position=body_entered.position
		2:
			target_position=start_position
			if position.distance_to(target_position)<=5:
				state=0
				


func _on_Area2D_body_entered(body):
	if "Stone" in body.name:
		life-=3
		body.queue_free()
	
	if "Bullet" in body.name:
		life-=10
		body.queue_free()	
	
	if life <=0:
		Globals.food_points+=90
		Globals.wood_points+=60
		Globals.stone_points+=40
		is_dead=true
		queue_free()
			
	if "Unit" in body.name || "Warrior" in body.name:
		body.is_enemy_touching=true
	
				
func _on_Area2D_body_exited(body):
	if "Unit" in body.name || "Warrior" in body.name:
		body.is_enemy_touching=false

func _on_Mammoth_mouse_entered():
	tree._on_Game3_is_sword()
	tree.emit_signal("is_sword")
	tree.touching_enemy=self



func _on_Mammoth_mouse_exited():
	tree._on_Game3_is_arrow()



	


func _on_DetectionArea_body_entered(body):
	if "Warrior" in body.name || "Unit2" in body.name:
		body_entered=body
		for mammoth in get_parent().get_children():
			if is_instance_valid(mammoth):
				mammoth.state = 1



