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

enum selectionScreens {TITLE, SETTINGS}
var selectionScreen: selectionScreens = selectionScreens.TITLE
enum titleScreenOptions {NONE, STARTGAME, SETTINGS}
var titleScreenSelectedOption: titleScreenOptions = titleScreenOptions.STARTGAME
enum settingsOptions {NONE, BACK, VOLUME, RESOLUTION, WINDOWMODE, FILTERING}
var settingsSelectedOption: settingsOptions = settingsOptions.NONE

func handle_titlescreen_buttons(_delta: float) -> void:
	if titleScreenSelectedOption == titleScreenOptions.NONE:
		ButtonStart.frame = 0
		ButtonSettings.frame = 0
	if titleScreenSelectedOption == titleScreenOptions.STARTGAME:
		if ButtonStart.frame != 2:
			ButtonStart.frame = 1
		ButtonSettings.frame = 0
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			titleScreenSelectedOption = titleScreenOptions.SETTINGS
		# Button press
		if Input.is_action_just_pressed("ui_accept"):
			$TitleScreenButtons/BlackFade.visible = true
			ButtonStart.frame = 2
			loadSceneTransition = true
			var title_volume_tween: Tween = create_tween()
			title_volume_tween.tween_property($"../Title Theme", "volume_db", -80, 2.0)
			await get_tree().create_timer(1.0, false).timeout
			$"../Title Theme".stop()
			await get_tree().process_frame
			get_tree().change_scene_to_file("res://Scenes/Levels/level1-1.tscn")
	if titleScreenSelectedOption == titleScreenOptions.SETTINGS:
		ButtonStart.frame = 0
		ButtonSettings.frame = 1
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			titleScreenSelectedOption = titleScreenOptions.STARTGAME
		# Button press
		if Input.is_action_just_pressed("ui_accept"):
			titleScreenSelectedOption = titleScreenOptions.NONE
			settingsSelectedOption = settingsOptions.BACK
			selectionScreen = selectionScreens.SETTINGS

func handle_setting_buttons(_delta: float) -> void:
	if settingsSelectedOption == settingsOptions.BACK:
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = settingsOptions.VOLUME
		# Button Press
		if Input.is_action_just_pressed("ui_accept"):
			settingsSelectedOption = settingsOptions.NONE
			selectionScreen = selectionScreens.TITLE
			titleScreenSelectedOption = titleScreenOptions.SETTINGS

	if settingsSelectedOption == settingsOptions.VOLUME:
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = settingsOptions.BACK
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = settingsOptions.RESOLUTION
		# Slider tweak
		if Input.is_action_pressed("ui_left"):
			Gamesettings.MasterVolume -= 1
			Gamesettings.MasterVolume = max(0, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			Gamesettings.MasterVolume += 1
			Gamesettings.MasterVolume = min(100, Gamesettings.MasterVolume)
			Gamesettings.emit_signal("update")

	if settingsSelectedOption == settingsOptions.RESOLUTION:
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = settingsOptions.VOLUME
		if Input.is_action_just_pressed("ui_down"):
			settingsSelectedOption = settingsOptions.WINDOWMODE
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

	if settingsSelectedOption == settingsOptions.WINDOWMODE:
		await get_tree().physics_frame
		# Selection change
		if Input.is_action_just_pressed("ui_up"):
			settingsSelectedOption = settingsOptions.RESOLUTION
		if Input.is_action_just_pressed("ui_down"):
			pass
		# Option tweak
		if Input.is_action_pressed("ui_left"):
			if Gamesettings.WindowMode == Window.MODE_FULLSCREEN:
				Gamesettings.WindowMode = Window.MODE_WINDOWED
				Gamesettings.emit_signal("update")
		if Input.is_action_pressed("ui_right"):
			if Gamesettings.WindowMode == Window.MODE_WINDOWED:
				Gamesettings.WindowMode = Window.MODE_FULLSCREEN
				Gamesettings.emit_signal("update")

	# Sorry, but linear filtering's causing a visual bug related to the palette swap shader.
	#if settingsSelectedOption == settingsOptions.FILTERING:
		#await get_tree().physics_frame
		## Selection change
		#if Input.is_action_just_pressed("ui_up"):
			#settingsSelectedOption = settingsOptions.WINDOWMODE
		## Option tweak
		#if Input.is_action_pressed("ui_left"):
			#if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR:
				#Gamesettings.Filtering = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
			#Gamesettings.emit_signal("update")
		#if Input.is_action_pressed("ui_right"):
			#if Gamesettings.Filtering == Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST:
				#Gamesettings.Filtering = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
			#Gamesettings.emit_signal("update")

func outline_selected_option() -> void:
	if settingsSelectedOption == settingsOptions.NONE:
		pass
	if settingsSelectedOption == settingsOptions.BACK:
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		$SettingButtons/Back.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == settingsOptions.VOLUME:
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		$SettingButtons/Volume/VolumeText.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == settingsOptions.RESOLUTION:
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		$SettingButtons/Resolution.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == settingsOptions.WINDOWMODE:
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		$SettingButtons/WindowMode.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	if settingsSelectedOption == settingsOptions.FILTERING:
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		$SettingButtons/Filtering.add_theme_color_override("font_outline_color", Color.TRANSPARENT)

func handle_selection_screens(_delta: float) -> void:
	if selectionScreen == selectionScreens.TITLE:
		$SettingButtons.visible = false
	if selectionScreen == selectionScreens.SETTINGS:
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
