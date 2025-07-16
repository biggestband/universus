extends Node2D

#region SFX
func _on_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.Confetti)

func _on_button_2_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.DeathPoof)

func _on_button_3_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.PlinkoGameScoring)

func _on_button_4_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.PlinkoPeg)

func _on_button_5_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.Punch)

func _on_button_6_pressed() -> void:
	AudioManager.play_sfx(AudioManager.SFX.SpawningTroop)
#endregion

#region BGM
func _on_BGM_button_pressed() -> void:
	AudioManager.change_bgm(AudioManager.BGM.Plinko)

func _on_BGM_button_2_pressed() -> void:
	AudioManager.change_bgm(AudioManager.BGM.NormalBattle)

func _on_BGM_button_3_pressed() -> void:
	AudioManager.change_bgm(AudioManager.BGM.AmpedBattle)

func _on_BGM_button_4_pressed() -> void:
	AudioManager.toggle_bgm()
#endregion
