extends CanvasLayer
# Call of Duty style HUD

var crosshair: Control
var ammo_label: Label
var health_bar: Control
var hit_marker: Control
var health = 100
var max_health = 100

func _ready():
	_setup_hud()

func _setup_hud():
	# Crosshair
	var ch = Control.new()
	ch.name = "Crosshair"
	ch.set_anchors_preset(Control.PRESET_CENTER)
	add_child(ch)
	crosshair = ch

	var dot = ColorRect.new()
	dot.color = Color(1, 1, 1, 0.8)
	dot.size = Vector2(3, 3)
	dot.position = Vector2(-1.5, -1.5)
	ch.add_child(dot)

	for dir in [Vector2(0, -8), Vector2(0, 5), Vector2(-8, 0), Vector2(5, 0)]:
		var line = ColorRect.new()
		line.color = Color(1, 1, 1, 0.6)
		line.size = Vector2(2, 6) if dir.x == 0 else Vector2(6, 2)
		line.position = dir
		ch.add_child(line)

	# Ammo display (bottom right)
	var ammo = Label.new()
	ammo.name = "AmmoDisplay"
	ammo.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	ammo.offset_left = -200
	ammo.offset_top = -60
	ammo.offset_right = -20
	ammo.offset_bottom = -20
	ammo.text = "30 / 120"
	ammo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ammo.add_theme_font_size_override("font_size", 28)
	ammo.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	ammo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	ammo.add_theme_constant_override("shadow_offset_x", 2)
	ammo.add_theme_constant_override("shadow_offset_y", 2)
	add_child(ammo)
	ammo_label = ammo

	# Health (bottom left)
	var hp_container = Control.new()
	hp_container.name = "HealthBar"
	hp_container.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	hp_container.offset_left = 20
	hp_container.offset_top = -50
	hp_container.offset_right = 220
	hp_container.offset_bottom = -20
	add_child(hp_container)
	health_bar = hp_container

	var hp_bg = ColorRect.new()
	hp_bg.color = Color(0.2, 0.2, 0.2, 0.6)
	hp_bg.size = Vector2(200, 8)
	hp_bg.position = Vector2(0, 18)
	hp_container.add_child(hp_bg)

	var hp_fill = ColorRect.new()
	hp_fill.name = "Fill"
	hp_fill.color = Color(0.2, 0.8, 0.2, 0.8)
	hp_fill.size = Vector2(200, 8)
	hp_fill.position = Vector2(0, 18)
	hp_container.add_child(hp_fill)

	var hp_label = Label.new()
	hp_label.text = "100"
	hp_label.position = Vector2(0, 0)
	hp_label.add_theme_font_size_override("font_size", 18)
	hp_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	hp_container.add_child(hp_label)

	# Hit marker
	var hm = Control.new()
	hm.name = "HitMarker"
	hm.set_anchors_preset(Control.PRESET_CENTER)
	hm.visible = false
	add_child(hm)
	hit_marker = hm

	for angle in [45, 135, 225, 315]:
		var tick = ColorRect.new()
		tick.color = Color(1, 1, 1, 0.9)
		tick.size = Vector2(10, 2)
		tick.rotation = deg_to_rad(angle)
		tick.position = Vector2(-5, -1)
		hm.add_child(tick)

	# Minimap placeholder (top right)
	var minimap_bg = ColorRect.new()
	minimap_bg.color = Color(0.1, 0.1, 0.1, 0.5)
	minimap_bg.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap_bg.offset_left = -130
	minimap_bg.offset_top = 10
	minimap_bg.offset_right = -10
	minimap_bg.offset_bottom = 130
	add_child(minimap_bg)

func update_ammo(current: int, reserve: int):
	if ammo_label:
		ammo_label.text = "%d / %d" % [current, reserve]
		if current <= 5:
			ammo_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 0.9))
		else:
			ammo_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))

func update_health(hp: int):
	health = hp
	if health_bar:
		var fill = health_bar.get_node_or_null("Fill")
		if fill:
			fill.size.x = (float(health) / max_health) * 200
			if health > 60:
				fill.color = Color(0.2, 0.8, 0.2, 0.8)
			elif health > 30:
				fill.color = Color(0.9, 0.7, 0.1, 0.8)
			else:
				fill.color = Color(0.9, 0.2, 0.2, 0.8)

func show_hit_marker():
	if hit_marker:
		hit_marker.visible = true
		await get_tree().create_timer(0.15).timeout
		hit_marker.visible = false

func flash_damage():
	var flash = ColorRect.new()
	flash.color = Color(0.8, 0, 0, 0.3)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(flash)
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(flash):
		flash.queue_free()
