extends Node

# variables
var backgroundMusicOn = false
var currentSong

# enums
enum BGM { Plinko, NormalBattle, AmpedBattle }
enum SFX { PlinkoPeg, PlinkoGameScoring, SpawningTroop, Punch, DeathPoof }

# audio Busses
var master_bus
var music_bus
var sfx_bus

# audio dictionaries
@export var backgroundMusic: Dictionary[BGM, AudioStreamPlayer]
@export var soundEffects: Dictionary[SFX, AudioStreamPlayer]

func _ready():	
	init_audio_system()
	
	# temp testing
	toggle_bgm()
	change_bgm(BGM.Plinko)

func init_audio_system():
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	
func _process(delta):
	
	# for temp debug
	if Input.is_action_just_pressed("LeftMouse"):
		play_sfx(SFX.Punch)
		
		#AudioServer.set_bus_mute(music_bus, true)
		
		change_bgm(BGM.NormalBattle)

# enable/disable background music
func toggle_bgm():
	backgroundMusicOn = !backgroundMusicOn

# switch between background music tracks
func change_bgm(song: BGM):
	# stops current playing song
	if currentSong != null:
		currentSong.stop()

	var musicPlayer := backgroundMusic[song]
	currentSong	= backgroundMusic[song]
	
	# handles music toggle logic
	if backgroundMusicOn:
		if !musicPlayer.playing:
			musicPlayer.play()
	else:
		musicPlayer.stop()

# plays sound effect
func play_sfx(sound: SFX):
	var soundPlayer := soundEffects[sound]
	soundPlayer.play()
