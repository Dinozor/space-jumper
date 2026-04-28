extends Node

## Music and SFX playback singleton.

const _SFX_BOUNCE_JUMP: AudioStream = preload("res://assets/kenney/audio/sfx/bounce_jump.ogg")
const _SFX_DAMAGE: AudioStream = preload("res://assets/kenney/audio/sfx/damage.ogg")
const _SFX_BUTTON: AudioStream = preload("res://assets/kenney/audio/sfx/button_click.ogg")
const _SFX_WIN: AudioStream = preload("res://assets/kenney/audio/sfx/win.ogg")
const _SFX_LOSE: AudioStream = preload("res://assets/kenney/audio/sfx/lose.ogg")
const _SFX_DRIFT_WARNING: AudioStream = preload("res://assets/kenney/audio/sfx/drift_warning.ogg")

var _music_player: AudioStreamPlayer


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)


func play_music(stream: AudioStream) -> void:
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func play_jump() -> void:
	_play_sfx(_SFX_BOUNCE_JUMP)


func play_damage() -> void:
	_play_sfx(_SFX_DAMAGE)


func play_button() -> void:
	_play_sfx(_SFX_BUTTON)


func play_win() -> void:
	_play_sfx(_SFX_WIN)


func play_lose() -> void:
	_play_sfx(_SFX_LOSE)


func play_drift_warning() -> void:
	_play_sfx(_SFX_DRIFT_WARNING)


func _play_sfx(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	player.finished.connect(player.queue_free)
