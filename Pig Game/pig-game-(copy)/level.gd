extends Node2D

@onready var cube = $Cube
@onready var turn_score_label: Label = $CanvasLayer/TurnScoreLabel
@onready var p1_score_label: Label = $CanvasLayer/Player1ScoreLabel
@onready var p2_score_label: Label = $CanvasLayer/Player2ScoreLabel
@onready var info_label: Label = $CanvasLayer/TurnInfoLabel
@onready var hold_button: Button = $CanvasLayer/HoldButton
@onready var restart_button: Button = $CanvasLayer/RestartButton
@onready var menu_button: Button = $CanvasLayer/MenuButton

const WIN_SCORE: int = 100

var scores: Array[int] = [0, 0]
var current_turn_score: int = 0
var active_player: int = 0
var game_over: bool = false

func _ready() -> void:
	cube.dice_rolled.connect(_on_dice_rolled)
	hold_button.pressed.connect(_on_hold_button_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	
	restart_button.hide()
	_update_ui()

func _on_dice_rolled(result: int) -> void:
	if game_over:
		return

	if result == 1:
		current_turn_score = 0
		info_label.text = "Выпала 1! Очки сгорели, ход переходит."
		_switch_player()
	else:
		current_turn_score += result
		info_label.text = "Игрок %d: выпало %d. Кидай ещё или забери!" % [active_player + 1, result]
	
	_update_ui()

func _on_hold_button_pressed() -> void:
	# Запрещаем нажимать кнопку ТОЛЬКО пока кубик летит в воздухе (JUMPING)
	if game_over or current_turn_score == 0 or cube.current_state == cube.State.JUMPING:
		return
	
	scores[active_player] += current_turn_score
	current_turn_score = 0
	
	# Сразу возвращаем кубик в режим ожидания, если он ещё показывал старую цифру
	cube.reset_to_idle()
	
	if scores[active_player] >= WIN_SCORE:
		game_over = true
		info_label.text = "ПОБЕДИЛ ИГРОК %d!" % [active_player + 1]
		restart_button.show()
	else:
		info_label.text = "Игрок %d забрал очки!" % [active_player + 1]
		_switch_player()
		
	_update_ui()
	if game_over or current_turn_score == 0 or cube.current_state != cube.State.IDLE:
		return
	
	scores[active_player] += current_turn_score
	current_turn_score = 0
	
	if scores[active_player] >= WIN_SCORE:
		game_over = true
		info_label.text = "ПОБЕДИЛ ИГРОК %d!" % [active_player + 1]
		restart_button.show()
	else:
		info_label.text = "Игрок %d забрал очки!" % [active_player + 1]
		_switch_player()
		
	_update_ui()

func _switch_player() -> void:
	active_player = 1 - active_player

func _update_ui() -> void:
	turn_score_label.text = "В банке хода: " + str(current_turn_score)
	p1_score_label.text = "Игрок 1: %d / %d" % [scores[0], WIN_SCORE]
	p2_score_label.text = "Игрок 2: %d / %d" % [scores[1], WIN_SCORE]
	
	hold_button.disabled = (current_turn_score == 0 or game_over)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
