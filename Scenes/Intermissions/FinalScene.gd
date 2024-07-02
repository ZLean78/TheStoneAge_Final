extends Node2D

var civilization_number=0
var civilization_name=""

func _ready():
	add_child(Globals.settings)
	Globals._clear_globals()
	randomize()
	AudioPlayer._select_music()
	AudioPlayer.music.play()
	$Narrative.text=$Narrative.text+_get_civilization()
	$AnimationPlayer.play("Billboard")


func _on_Button_pressed():
	remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Credits/Credits.tscn")

func _get_civilization()->String:
	
	civilization_number=randi()%4+1
	
	match civilization_number:
		1:
			civilization_name=" los Sumerios."
		2:
			civilization_name=" los Asirios."
		3:
			civilization_name=" los Caldeos."
		4: 
			civilization_name=" los Acadios."
	
	return civilization_name
			 

func _unhandled_input(event):
	if event.is_action_pressed("EscapeKey"):
		Globals.settings.visible=!Globals.settings.visible


	
