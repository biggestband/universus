extends Node

# signals
signal initAudioSystem
signal changeBGM(song: BGM)
signal playSFX(sound: SFX)
signal toggleBGM

# variables
var backgroundMusicOn = true
var currentSong

# enums
enum BGM { Plinko, NormalBattle, AmpedBattle }
enum SFX { PlinkoPeg, PlinkoGameScoring, SpawningTroop, Punch, DeathPoof, Confetti, Dizzy }

# audio dictionaries
@export var backgroundMusic: Dictionary[BGM, AudioStreamPlayer]
@export var soundEffects: Dictionary[SFX, AudioStreamPlayer]
	
func _process(delta):
	handle_bgm_change()

# enable/disable background music
func toggle_bgm():
	backgroundMusicOn = !backgroundMusicOn

# handles music toggle logic
func handle_bgm_change():
	if currentSong == null:
		return
	if backgroundMusicOn:
		if !currentSong.playing:
			currentSong.play()
	else:
		currentSong.stop()

# switch between background music tracks
func change_bgm(song: BGM):
	if currentSong != null:
		currentSong.stop()
		
	currentSong	= backgroundMusic[song]

# plays sound effect
func play_sfx(sound: SFX):
	var soundPlayer := soundEffects[sound]
	soundPlayer.play()
