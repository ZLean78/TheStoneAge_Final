extends Node2D



func _ready():
	add_child(Globals.settings)
	AudioPlayer._select_music()
	AudioPlayer.music.play()
	$AnimationPlayer.play("Billboard")

func _unhandled_input(event):
	if event.is_action_pressed("EscapeKey"):
		Globals.settings.visible=!Globals.settings.visible


func _on_AnimationPlayer_animation_finished(anim_name):
	remove_child(Globals.settings)
	Globals.go_to_scene("res://Scenes/Menu/Menu.tscn")
