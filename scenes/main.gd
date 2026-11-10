extends Node2D
const GROUND := 590.0
var player := Vector2(260, GROUND)
var velocity := Vector2.ZERO
var enemy := Vector2(900, GROUND)
var enemy_hp := 5
var facing := 1
var attack_time := 0.0
var dodge_time := 0.0
var invuln := 0.0
var hp := 5
var buttons := {}
var held := {}
func _ready() -> void:
	for key in ["left", "right", "jump", "attack", "dodge"]:
		held[key] = false
	buttons = {"left": Rect2(40, 610, 105, 90), "right": Rect2(160, 610, 105, 90), "jump": Rect2(835, 610, 95, 90), "attack": Rect2(950, 610, 125, 90), "dodge": Rect2(1090, 610, 135, 90)}
func _physics_process(delta: float) -> void:
	attack_time = maxf(0, attack_time - delta)
	dodge_time = maxf(0, dodge_time - delta)
	invuln = maxf(0, invuln - delta)
	var move_axis := int(held["right"] or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - int(held["left"] or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
	if move_axis != 0:
		facing = move_axis
	velocity.x = move_axis * (650.0 if dodge_time > 0 else 280.0)
	velocity.y += 1450.0 * delta
	if player.y >= GROUND and (held["jump"] or Input.is_key_pressed(KEY_SPACE)):
		velocity.y = -610.0
	player += velocity * delta
	player.x = clampf(player.x, 25, 1255)
	if player.y >= GROUND:
		player.y = GROUND
		velocity.y = 0
	if enemy_hp > 0 and absf(enemy.x - player.x) < 48 and absf(enemy.y - player.y) < 65 and invuln <= 0:
		hp = max(0, hp - 1)
		invuln = 1.0
	if hp == 0:
		player = Vector2(260, GROUND)
		hp = 5
		enemy_hp = 5
	queue_redraw()
func _action(key: String) -> void:
	if key == "attack" and attack_time <= 0:
		attack_time = 0.24
		if enemy_hp > 0 and absf(enemy.x - player.x) < 145 and (enemy.x - player.x) * facing > 0 and absf(enemy.y - player.y) < 90:
			enemy_hp -= 1
	if key == "dodge" and dodge_time <= 0:
		dodge_time = 0.22
		invuln = 0.35
		velocity.x = facing * 650.0
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var p: Vector2 = event.position
		for key in buttons:
			var inside: bool = buttons[key].has_point(p)
			if event is InputEventScreenTouch:
				if event.pressed and inside and key in ["attack", "dodge"]:
					_action(key)
				if not event.pressed:
					held[key] = false
				elif inside:
					held[key] = true
			elif key in ["left", "right", "jump"]:
				held[key] = inside
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J:
			_action("attack")
		if event.keycode == KEY_K:
			_action("dodge")
func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("121b2b"))
	draw_rect(Rect2(0, 590, 1280, 130), Color("293b45"))
	for i in range(16):
		draw_rect(Rect2(i * 100, 560, 60, 30), Color("263441"))
	var player_color := Color("91e7ff") if invuln <= 0 else Color("ffffff")
	draw_rect(Rect2(player.x - 20, player.y - 72, 40, 72), player_color)
	draw_circle(Vector2(player.x, player.y - 85), 19, Color("e6d8b6"))
	if attack_time > 0:
		draw_line(Vector2(player.x + facing * 25, player.y - 48), Vector2(player.x + facing * 125, player.y - 78), Color("ffda74"), 11)
	if enemy_hp > 0:
		draw_rect(Rect2(enemy.x - 30, enemy.y - 100, 60, 100), Color("da6070"))
		draw_rect(Rect2(enemy.x - 35, enemy.y - 120, 70 * enemy_hp / 5.0, 8), Color("f36b79"))
	draw_string(ThemeDB.fallback_font, Vector2(30, 55), "GODOT 4 WEB ACTION TEST | HP %d/5 | ENEMY %d/5" % [hp, enemy_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(30, 92), "Keyboard: A/D move | SPACE jump | J attack | K dodge", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("b7c9d7"))
	for key in buttons:
		var rect: Rect2 = buttons[key]
		draw_rect(rect, Color("54758d") if held[key] else Color("34495e"), true)
		draw_rect(rect, Color("92b9c9"), false, 2)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(12, 54), key.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color.WHITE)
