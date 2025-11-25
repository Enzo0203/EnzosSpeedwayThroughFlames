extends Control

var loadSceneTransition: bool

@onready var ButtonStart: Sprite2D = $TitleScreenButtons/StartButton
@onready var ButtonOptions: Sprite2D = $TitleScreenButtons/OptionsButton

@onready var ButtonVolume: TextureProgressBar = $OptionButtons/Volume
@onready var ButtonResolution: Label = $OptionButtons/Resolution

var selectionScreen: String = "Title"
var titleScreenSelectedOption: String = "StartGame"
var optionsSelectedOption: String = "None"

func _ready() -> void:
	visible = true
	loadSceneTransition = false
	$TitleScreenButtons/BlackFade.position.x = 1510
	selectionScreen = "Title"
	$OptionButtons/Volume.value = 100
	$OptionButtons/Resolution.text = str("Resolution: ", get_window().size.x, " x ", get_window().size.y)

func _physics_process(_delta: float) -> void:
	handle_titlescreen_buttons(_delta)
	handle_option_buttons(_delta)
	handleSelectionScreens(_delta)
	if loadSceneTransition:
		if $TitleScreenButtons/BlackFade.position.x > 410:
			$TitleScreenButtons/BlackFade.position.x -= 20
		else:
			$TitleScreenButtons/BlackFade.position.x = 410

func handle_titlescreen_buttons(_delta: float) -> void:
	if titleScreenSelectedOption == "None":
		ButtonStart.frame = 0
		ButtonOptions.frame = 0
	if titleScreenSelectedOption == "StartGame":
		if ButtonStart.frame != 2:
			ButtonStart.frame = 1
		ButtonOptions.frame = 0
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			titleScreenSelectedOption = "Options"
		# Button press
		if Input.is_action_just_pressed("character_z"):
			$TitleScreenButtons/BlackFade.visible = true
			ButtonStart.frame = 2
			loadSceneTransition = true
			await get_tree().create_timer(1.0, false).timeout
			$"../Title Theme".stop()
			await get_tree().process_frame
			get_tree().change_scene_to_file("res://Scenes/Levels/level1-1.tscn")
	if titleScreenSelectedOption == "Options":
		ButtonStart.frame = 0
		ButtonOptions.frame = 1
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			titleScreenSelectedOption = "StartGame"
		# Button press
		if Input.is_action_just_pressed("character_z"):
			titleScreenSelectedOption = "None"
			optionsSelectedOption = "Back"
			selectionScreen = "Options"

func handle_option_buttons(_delta: float) -> void:
	if optionsSelectedOption == "None":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if optionsSelectedOption == "Back":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "Volume"
		# Button Press
		if Input.is_action_just_pressed("character_z"):
			optionsSelectedOption = "None"
			selectionScreen = "Title"
			titleScreenSelectedOption = "Options"
	if optionsSelectedOption == "Volume":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Back"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "Resolution"
		# Slider tweak
		if Input.is_action_pressed("ui_left"):
			$OptionButtons/Volume.value -= 1
		if Input.is_action_pressed("ui_right"):
			$OptionButtons/Volume.value += 1
	if optionsSelectedOption == "Resolution":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Volume"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "WindowMode"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if get_window().size == Vector2i(1280, 720):
				get_window().size = Vector2i(960, 540)
				get_window().move_to_center()
				$OptionButtons/Resolution.text = str("Resolution: ", get_window().size.x, " x ", get_window().size.y)
		if Input.is_action_pressed("ui_right"):
			if get_window().size == Vector2i(960, 540):
				get_window().size = Vector2i(1280, 720)
				get_window().move_to_center()
				$OptionButtons/Resolution.text = str("Resolution: ", get_window().size.x, " x ", get_window().size.y)
	if optionsSelectedOption == "WindowMode":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Resolution"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "Filtering"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if get_window().mode == Window.MODE_FULLSCREEN:
				get_window().mode = Window.MODE_WINDOWED
				$OptionButtons/WindowMode.text = "Window Mode: Windowed"
		if Input.is_action_pressed("ui_right"):
			if get_window().mode == Window.MODE_WINDOWED:
				get_window().mode = Window.MODE_FULLSCREEN
				$OptionButtons/WindowMode.text = "Window Mode: Fullscreen"
	if optionsSelectedOption == "Filtering":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.BLACK)
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "WindowMode"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if get_viewport().canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR:
				get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
				$OptionButtons/Filtering.text = "Filtering: Nearest"
		if Input.is_action_pressed("ui_right"):
			if get_viewport().canvas_item_default_texture_filter == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST:
				get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
				$OptionButtons/Filtering.text = "Filtering: Linear"

func handleSelectionScreens(_delta: float) -> void:
	if selectionScreen == "Title":
		$OptionButtons.visible = false
	if selectionScreen == "Options":
		$OptionButtons.visible = true

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db($OptionButtons/Volume.value / 100))
	$OptionButtons/Volume/VolumeNumber.text = str(roundi($OptionButtons/Volume.value), "%")

func _on_filtering_item_selected(index: int) -> void:
	if index == 0:
		get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	if index == 1:
		get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
