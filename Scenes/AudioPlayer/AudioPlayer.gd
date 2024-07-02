extends Node2D

onready var music=$Music
onready var soundFx=$Rain

func _select_music():
	if Globals.current_scene.name=="Menu":
		music.stream=load("res://Sound/Opening.ogg")
	if Globals.current_scene.name=="Game":
		music.stream=load("res://Sound/Stage1.ogg")
	if Globals.current_scene.name=="Game2":
		music.stream=load("res://Sound/Stage2.ogg")
	if Globals.current_scene.name=="Game3":
		music.stream=load("res://Sound/Stage3.ogg")
	if Globals.current_scene.name=="Game4":
		music.stream=load("res://Sound/Stage4.ogg")
	if Globals.current_scene.name=="Game5":
		music.stream=load("res://Sound/Stage5.ogg")
	if Globals.current_scene.name=="Intermission1":
		music.stream=load("res://Sound/Intermission.ogg")
	if Globals.current_scene.name=="Intermission2":
		music.stream=load("res://Sound/Intermission.ogg")
	if Globals.current_scene.name=="Intermission3":
		music.stream=load("res://Sound/OpeningSlow.ogg")
	if Globals.current_scene.name=="Intermission4":
		music.stream=load("res://Sound/OpeningSlow.ogg")
	if Globals.current_scene.name=="FinalScene":
		music.stream=load("res://Sound/NonLoopingOpening.ogg")
	if Globals.current_scene.name=="Credits":
		music.stream=load("res://Sound/FinalCredits.ogg")
	
func _play_rain():
	if Globals.current_scene.its_raining:
		if !$Rain.playing:
			$Rain.play()
	else:
		if $Rain.playing:
			$Rain.stop() 
			
func _stop_rain():
	$Rain.stop()
