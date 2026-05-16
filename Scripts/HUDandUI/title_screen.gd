extends Control

var loadSceneTransition: bool

@onready var ButtonStart: Sprite2D = $TitleScreenButtons/StartButton
@onready var ButtonSettings: Sprite2D = $TitleScreenButtons/SettingsButton

@onready var ButtonVolume: TextureProgressBar = $SettingButtons/Volume
@onready var ButtonResolution: Label = $SettingButtons/Resolution

func _ready() -> void:
	visible = true
	loadSceneTransition = false
	$TitleScreenButtons/BlackFade.position.x = 1510
	selectionScreen = "Title"

func _physics_process(_delta: float) -> void:
	handle_titlescreen_buttons(_delta)
	handle_setting_buttons(_delta)
	outline_selected_option()
	handle_selection_screens(_delta)
	update_text()
	if loadSceneTransition:
		if $TitleScreenButtons/BlackFade.position.x > 410:
			$TitleScreenButtons/BlackFade.position.x -= 20
		else:
			$TitleScreenButtons/BlackFade.position.x = 410

var selectionScreen: String = "Title"
var titleScreenSelectedOption: String = "StartGame"
var settingsSelectedOption: String = "None"

func handle_titlescreen_buttons(_delta: float) -> void:
	if titleScreenSelectedOption == "None":
		ButtonStart.frame = 0
		ButtonSettings.frame = 0
	if titleScreenSelectedOption == "StartGame":
		if ButtonStart.frame != 2:
			ButtonStart.frame = 1
		ButtonSettings.frame = 0
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			titleScreenSelectedOption = "Settings"
		# Button press
		if Input.is_action_just_pressed("character_z"):
			$TitleScreenButtons/BlackFade.visible = true
			ButtonStart.frame = 2
			loadSceneTransition = true
			await get_tree().create_timer(1.0, false).timeout
			$"../Title Theme".stop()
			await get_tree().process_frame
			get_tree().change_scene_to_file("res://Scenes/Levels/level1-1.tscn")
	if titleScreenSelectedOption == "Settings":
		ButtonStart.frame = 0
		ButtonSettings.frame = 1
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			titleScreenSelectedOption = "StartGame"
		# Button press
		if Input.is_action_just_pressed("character_z"):
			titleScreenSelectedOption = "None"
			settingsSelectedOption = "Back"
			selectionScreen = "Settings"

func handle_setting_buttons(_delta: float) -> void:
	if settingsSelectedOption == "Back":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = "Volume"
		# Button Press
		if Input.is_action_just_pressed("character_z"):
			settingsSelectedOption = "None"
			selectionScreen = "Title"
			titleScreenSelectedOption = "Settings"

	if settingsSelectedOption == "Volume":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = "Back"
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = "Resolution"
		# Slider tweak
		if Input.is_action_pressed("ui_left"):
			Gamesettings.MasterVolume -= 1
			Gamesettings.MasterVolume = max(0, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			Gamesettings.MasterVolume += 1
			Gamesettings.MasterVolume = min(100, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")

	if settingsSelectedOption == "Resolution":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = "Volume"
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = "WindowMode"
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

	if settingsSelectedOption == "WindowMode":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = "Resolution"
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = "Filtering"
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if Gamesettings.WindowMode == Window.MODE_FULLSCREEN:
				Gamesettings.WindowMode = Window.MODE_WINDOWED
				Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			if Gamesettings.WindowMode == Window.MODE_WINDOWED:
				Gamesettings.WindowMode = Window.MODE_FULLSCREEN
				Gamesettings.emit_signal("update")

	if settingsSelectedOption == "Filtering":
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = "WindowMode"
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
	if settingsSelectedOption == "None":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == "Back":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.BLACK)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == "Volume":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.BLACK)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == "Resolution":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.BLACK)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == "WindowMode":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.BLACK)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == "Filtering":
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.BLACK)

func handle_selection_screens(_delta: float) -> void:
	if selectionScreen == "Title":
		$SettingButtons.visible = false
	if selectionScreen == "Settings":
		$SettingButtons.visible = true

func update_text() -> void:
	$SettingButtons/Volume/VolumeNumber.text = str(roundi($SettingButtons/Volume.value), "%")
	$SettingButtons/Volume.value = Gamesettings.MasterVolume
	$SettingButtons/Resolution.text = str("Resolution: ", get_window().size.x, " x ", get_window().size.y)
	if Gamesettings.WindowMode == Window.MODE_WINDOWED:
		$SettingButtons/WindowMode.text = "Window Mode: Windowed"
	elif Gamesettings.WindowMode == Window.MODE_FULLSCREEN:
		$SettingButtons/WindowMode.text = "Window Mode: Fullscreen"
	if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR:
		$SettingButtons/Filtering.text = "Filtering: Linear"
	elif Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST:
		$SettingButtons/Filtering.text = "Filtering: Nearest"
