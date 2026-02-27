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

func _physics_process(_delta: float) -> void:
	handle_titlescreen_buttons(_delta)
	handle_option_buttons(_delta)
	outline_selected_option()
	handle_selection_screens(_delta)
	update_text()
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
	if optionsSelectedOption == "Back":
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
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Back"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "Resolution"
		# Slider tweak
		if Input.is_action_pressed("ui_left"):
			Gamesettings.MasterVolume -= 1
			Gamesettings.MasterVolume = max(0, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			Gamesettings.MasterVolume += 1
			Gamesettings.MasterVolume = min(100, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")

	if optionsSelectedOption == "Resolution":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Volume"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "WindowMode"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if Gamesettings.Resolution == Gamesettings.ResolutionOptions["720p"]:
				Gamesettings.Resolution = Gamesettings.ResolutionOptions["540p"]
				Gamesettings.emit_signal("update")
				get_window().move_to_center()
		if Input.is_action_pressed("ui_right"):
			if Gamesettings.Resolution == Gamesettings.ResolutionOptions["540p"]:
				Gamesettings.Resolution = Gamesettings.ResolutionOptions["720p"]
				Gamesettings.emit_signal("update")
				get_window().move_to_center()

	if optionsSelectedOption == "WindowMode":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "Resolution"
		if Input.is_action_just_pressed("ui_down"):
			optionsSelectedOption = "Filtering"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if Gamesettings.WindowMode == Window.MODE_FULLSCREEN:
				Gamesettings.WindowMode = Window.MODE_WINDOWED
				Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			if Gamesettings.WindowMode == Window.MODE_WINDOWED:
				Gamesettings.WindowMode = Window.MODE_FULLSCREEN
				Gamesettings.emit_signal("update")

	if optionsSelectedOption == "Filtering":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			optionsSelectedOption = "WindowMode"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR:
				Gamesettings.Filtering = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
			Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST:
				Gamesettings.Filtering = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
			Gamesettings.emit_signal("update")

func outline_selected_option() -> void:
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
	if optionsSelectedOption == "Volume":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if optionsSelectedOption == "Resolution":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if optionsSelectedOption == "WindowMode":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.BLACK)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if optionsSelectedOption == "Filtering":
		$OptionButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$OptionButtons/Filtering.add_theme_color_override("font_outline_color", Color.BLACK)

func handle_selection_screens(_delta: float) -> void:
	if selectionScreen == "Title":
		$OptionButtons.visible = false
	if selectionScreen == "Options":
		$OptionButtons.visible = true

func update_text() -> void:
	$OptionButtons/Volume/VolumeNumber.text = str(roundi($OptionButtons/Volume.value), "%")
	$OptionButtons/Volume.value = Gamesettings.MasterVolume
	$OptionButtons/Resolution.text = str("Resolution: ", get_window().size.x, " x ", get_window().size.y)
	if Gamesettings.WindowMode == Window.MODE_WINDOWED:
		$OptionButtons/WindowMode.text = "Window Mode: Windowed"
	elif Gamesettings.WindowMode == Window.MODE_FULLSCREEN:
		$OptionButtons/WindowMode.text = "Window Mode: Fullscreen"
	if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR:
		$OptionButtons/Filtering.text = "Filtering: Linear"
	elif Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST:
		$OptionButtons/Filtering.text = "Filtering: Nearest"
