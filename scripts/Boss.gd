extends "res://scripts/EnemyBase.gd"

func _ready():
	spawn()
	hit_audio = $BulletHit
	death_audio = $Death
	attack_audio = $Swing
	hit_timer = $HitTimer
	damage_type = "rake"

func set_level(level):
	pass
