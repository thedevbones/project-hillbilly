extends "res://scripts/EnemyBase.gd"

var laugh_sounds = [
	preload("res://audio/SFX/Enemy/Boss_evil_laugh.mp3"),
	preload("res://audio/SFX/Enemy/Deeper_Boss_Laugh.mp3"),
	preload("res://audio/SFX/Enemy/Deep_ Boss_laugh.mp3"),
]

func _ready():
	spawn()
	hit_audio = $BulletHit
	death_audio = $Death
	attack_audio = $Swing
	hit_timer = $HitTimer
	laugh()
	damage_type = "rake"

func set_level(level):
	pass

func laugh():
	if $Laugh.playing: return
	var sound_to_play = laugh_sounds.pick_random()
	$Laugh.set_stream(sound_to_play)
	$Laugh.play()
