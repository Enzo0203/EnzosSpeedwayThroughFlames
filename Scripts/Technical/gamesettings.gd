extends Node

signal update

var MasterVolume: float = 100
#var SfxVolume: int
#var MusicVolume: int

var ResolutionOptions: Dictionary[String, Vector2i] = {"540p": Vector2i(960, 540), "720p":Vector2i(1280, 720)}
var Resolution: Vector2i = ResolutionOptions["540p"]

var WindowMode: Window.Mode = Window.MODE_WINDOWED

var Filtering: Viewport.DefaultCanvasItemTextureFilter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

func _ready() -> void:
	update.connect(_update)
	emit_signal("update")

func _update() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(MasterVolume / 100))
	get_window().size = Resolution
	get_window().mode = WindowMode
	get_viewport().canvas_item_default_texture_filter = Filtering
