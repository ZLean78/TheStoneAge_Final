extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = 0
var speed = 400
var start_position = Vector2.ZERO
var owner_name=""

# Called when the node enters the scene tree for the first time.
func _ready():
	start_position=position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move_spears(delta)

func _move_spears(var _to_delta):
	#var new_position=position.x+2
	var collision = move_and_collide(speed*dir*_to_delta)
	
	if collision != null:		
		if ("Tiger" in collision.collider.name || "Mammoth" in collision.collider.name
		|| "EnemyWarrior" in collision.collider.name
		|| "EnemyCitizen" in collision.collider.name
		|| "EnemyHouse" in collision.collider.name
		|| "EnemyVehicle" in collision.collider.name):
			collision.collider._get_damage(self)
		queue_free()
			
		
	
#	if collision != null:
#		if "Tiger" in collision.collider.name || "Mammoth" in collision.collider.name:
#			if "Tiger" in collision.collider.name:
#				collision.collider.unit.is_tiger_touching=false
#				collision.collider.unit=null
#			#collision.collider.queue_free()
#		queue_free()
	
	if position.distance_to(start_position) > 400:
		queue_free()
	
	
			

func set_dir(new_dir):
	dir = new_dir
	scale.x = 1
	
func set_speed(new_speed):
	speed = new_speed
	

