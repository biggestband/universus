extends Node2D

#region SFX
func _on_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.Confetti)

func _on_button_2_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.DeathPoof)

func _on_button_3_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.PlinkoGameScoring)

func _on_button_4_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.PlinkoPeg)

func _on_button_5_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.Punch)

func _on_button_6_pressed() -> void:
	AudioManager.playSFX.emit(AudioManager.SFX.SpawningTroop)
#endregion

#region BGM
func _on_BGM_button_pressed() -> void:
	AudioManager.changeBGM.emit(AudioManager.BGM.Plinko)

func _on_BGM_button_2_pressed() -> void:
	AudioManager.changeBGM.emit(AudioManager.BGM.NormalBattle)

func _on_BGM_button_3_pressed() -> void:
	AudioManager.changeBGM.emit(AudioManager.BGM.AmpedBattle)

func _on_BGM_button_4_pressed() -> void:
	AudioManager.toggleBGM.emit()
#endregion
