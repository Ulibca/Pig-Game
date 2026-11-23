extends CharacterBody2D

signal dice_rolled(result: int)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var roll_timer: Timer = $Timer

# Настройки прыжка (можно менять прямо в Инспекторе справа)
@export var jump_force: float = -450.0 # Сила прыжка вверх
@export var gravity: float = 1200.0    # Сила притяжения вниз

enum State { IDLE, JUMPING, SHOWING_RESULT }
var current_state: State = State.IDLE
var current_value: int = 1
var start_y: float # Запоминаем высоту "пола"

func _ready() -> void:
	start_y = position.y
	input_event.connect(_on_input_event)
	roll_timer.timeout.connect(_on_timer_timeout)
	
	# Сразу запускаем анимацию ожидания
	sprite.play("idle_spin")

func _physics_process(delta: float) -> void:
	# Обрабатываем полёт только во время прыжка
	if current_state == State.JUMPING:
		velocity.y += gravity * delta
		position += velocity * delta
		
		# Проверяем, приземлился ли кубик обратно на стартовую высоту
		if position.y >= start_y:
			position.y = start_y
			velocity.y = 0
			_finish_roll()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Бросаем кубик, только если он сейчас в режиме ожидания
		if current_state == State.IDLE:
			_start_roll()

func _start_roll() -> void:
	current_state = State.JUMPING
	velocity.y = jump_force # Задаём импульс вверх
	sprite.play("roll")     # Включаем быструю анимацию броска

func _finish_roll() -> void:
	current_state = State.SHOWING_RESULT
	current_value = randi_range(1, 6)
	
	# Останавливаем вращение и показываем выпавшую грань
	sprite.stop()
	sprite.animation = "sides"
	sprite.frame = current_value - 1
	
	dice_rolled.emit(current_value)
	print("Выпало: ", current_value)
	
	# Запускаем таймер, сколько секунд игрок будет смотреть на результат
	roll_timer.start()

func _on_timer_timeout() -> void:
	# Возвращаем кубик обратно в режим ожидания и вращения
	current_state = State.IDLE
	sprite.play("idle_spin")

func reset_to_idle() -> void:
	roll_timer.stop()
	current_state = State.IDLE
	sprite.play("idle_spin")
