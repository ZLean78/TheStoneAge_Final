extends Node2D

onready var start_btn = $BtnControl/Start
onready var options_btn = $BtnControl/Options
onready var credits_btn = $BtnControl/Credits
onready var quit_btn = $BtnControl/Quit

var font1
var font2
var font3
var font4

func _ready():
	font1 = start_btn.get_font("font")
	font2 = options_btn.get_font("font")
	font3 = credits_btn.get_font("font")
	font4 = quit_btn.get_font("font")
	add_child(Globals.settings)
	AudioPlayer._select_music()
	AudioPlayer.music.play()
	

func _unhandled_input(_event):
	if Input.is_action_pressed("EscapeKey"):
		get_tree().quit()
	
		
	
	

func _on_Start_pressed():
	remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Game/Game.tscn")


func _on_Quit_pressed():
	get_tree().quit()



func _on_Start_mouse_entered():
	font1.size = 40
	font2.size = 30
	font3.size = 30
	font4.size = 30
	


func _on_Quit_mouse_entered():
	font1.size = 30
	font2.size = 30
	font3.size = 30
	font4.size = 40
	



func _on_Options_mouse_entered():
	font1.size = 30
	font2.size = 40
	font3.size = 30
	font4.size = 30


func _on_Credits_mouse_entered():
	font1.size = 30
	font2.size = 30
	font3.size = 40
	font4.size = 30


func _on_Options_pressed():
	Globals.settings.visible=!Globals.settings.visible


func _on_Credits_pressed():
	remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Credits/Credits.tscn")
