extends Node2D

onready var tree_instance
onready var unit_instance

func _ready():
	tree_instance=Globals.current_scene
	unit_instance=get_parent()

func _animate(sprite,velocity,target_position):
	if unit_instance.just_shot:
		sprite.animation = "horizontal_shot"
	else:
		sprite.animation = "horizontal"
