extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var food_points=0
var leaves_points=0
var enemy_attack=0
var phrase=""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _set_food_points(var _food_points):
	food_points = _food_points
	_set_control_food_points(food_points)
	
func _set_leaves_points(var _leaves_points):
	leaves_points = _leaves_points
	_set_control_leaves_points(leaves_points)
	
func _set_enemy_attack(var _enemy_attack):
	enemy_attack = _enemy_attack
	_set_control_enemy_attack(enemy_attack)

func _set_control_food_points(var _food_points):
	$The_Control._set_food_points(food_points)
	
func _set_control_leaves_points(var _leaves_points):
	$The_Control._set_leaves_points(leaves_points)
	
func _set_control_enemy_attack(var _enemy_attack):
	$The_Control.enemy_attack = _enemy_attack

func _set_phrase(var _phrase):
	phrase = _phrase
	$The_Control._set_phrase(phrase)
