extends "res://scripts/EnemyBase.gd"

@onready var health_bar = $BossUI/BossHealthBar

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
	health = 30
	damage = 2
	default_speed = 5
	$BossUI.modulate = Color("ffffff", 0)
	adjust_ui()
	fade_ui(Color("ffffff", 1))
	$LaughTimer.start()

func set_level(level):
	health = 30 * level
	damage = 2 * level
	print(level)

func laugh():
	if $Laugh.playing: return
	var sound_to_play = laugh_sounds.pick_random()
	$Laugh.set_stream(sound_to_play)
	$Laugh.set_pitch_scale(randf_range(0.9,1.2))
	$Laugh.play()

func adjust_ui():
	health_bar.max_value = health
	health_bar.value = health

func apply_damage(damage):
	health -= damage
	health_bar.value = health
	if hit_audio.is_playing(): hit_audio.play()
	if health <= 0: 
		die()
		fade_ui(Color("ffffff", 0))

func fade_ui(final_value):
	var tween = get_tree().create_tween()
	tween.tween_property($BossUI, "modulate", final_value, 1.0)


func _on_death_finished():
	queue_free()


func _on_laugh_timer_timeout():
	laugh()
	$LaughTimer.start(randi_range(15,30))
