extends Node3D

# Weapon stats
const DAMAGE = 30
const FIRE_RATE = 0.1
const RELOAD_TIME = 2.2
const MAG_SIZE = 30
const MAX_RESERVE = 120
const RANGE = 100.0
const SPREAD_HIP = 2.5
const SPREAD_ADS = 0.4

# Recoil
const RECOIL_UP = 0.8
const RECOIL_SIDE = 0.3
const RECOIL_RECOVERY = 5.0

# State
var current_ammo = MAG_SIZE
var reserve_ammo = MAX_RESERVE
var can_fire = true
var is_reloading = false
var is_aiming = false

# ADS positions
const HIP_POS = Vector3(0.25, -0.15, -0.4)
const ADS_POS = Vector3(0.0, -0.1, -0.3)
const ADS_SPEED = 10.0

var recoil_offset = Vector2.ZERO
var fire_timer: Timer
var reload_timer: Timer
var raycast: RayCast3D

func _ready():
	fire_timer = Timer.new()
	fire_timer.one_shot = true
	fire_timer.wait_time = FIRE_RATE
	add_child(fire_timer)
	fire_timer.timeout.connect(_on_fire_cooldown)

	reload_timer = Timer.new()
	reload_timer.one_shot = true
	reload_timer.wait_time = RELOAD_TIME
	add_child(reload_timer)
	reload_timer.timeout.connect(_on_reload_complete)

	position = HIP_POS

	# Find raycast
	var camera = get_parent()
	if camera:
		raycast = camera.get_node_or_null("RayCast3D")

	# Build weapon model
	_build_weapon_mesh()

func _build_weapon_mesh():
	# Main body
	var body = MeshInstance3D.new()
	var body_mesh = BoxMesh.new()
	body_mesh.size = Vector3(0.06, 0.06, 0.35)
	body.mesh = body_mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	mat.roughness = 0.4
	mat.metallic = 0.7
	body.material_override = mat
	add_child(body)

	# Barrel
	var barrel = MeshInstance3D.new()
	var bm = CylinderMesh.new()
	bm.top_radius = 0.012
	bm.bottom_radius = 0.012
	bm.height = 0.3
	barrel.mesh = bm
	barrel.rotation_degrees.x = 90
	barrel.position = Vector3(0, 0.01, -0.32)
	var bmat = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.12, 0.12, 0.14)
	bmat.metallic = 0.9
	bmat.roughness = 0.2
	barrel.material_override = bmat
	add_child(barrel)

	# Magazine
	var mag = MeshInstance3D.new()
	var mm = BoxMesh.new()
	mm.size = Vector3(0.03, 0.12, 0.06)
	mag.mesh = mm
	mag.position = Vector3(0, -0.08, -0.05)
	mag.rotation_degrees.z = 3
	var mmat = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.1, 0.1, 0.12)
	mmat.metallic = 0.5
	mag.material_override = mmat
	add_child(mag)

	# Stock
	var stock = MeshInstance3D.new()
	var sm = BoxMesh.new()
	sm.size = Vector3(0.05, 0.055, 0.18)
	stock.mesh = sm
	stock.position = Vector3(0, -0.005, 0.26)
	stock.material_override = mat
	add_child(stock)

	# Grip
	var grip = MeshInstance3D.new()
	var gm = BoxMesh.new()
	gm.size = Vector3(0.035, 0.07, 0.03)
	grip.mesh = gm
	grip.position = Vector3(0, -0.06, 0.08)
	grip.rotation_degrees.x = -15
	grip.material_override = mat
	add_child(grip)

	# Handguard
	var hg = MeshInstance3D.new()
	var hm = BoxMesh.new()
	hm.size = Vector3(0.055, 0.05, 0.12)
	hg.mesh = hm
	hg.position = Vector3(0, 0, -0.15)
	var hmat = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.2, 0.18, 0.15)
	hmat.roughness = 0.7
	hg.material_override = hmat
	add_child(hg)

	# Front sight
	var fs = MeshInstance3D.new()
	var fsm = BoxMesh.new()
	fsm.size = Vector3(0.01, 0.025, 0.01)
	fs.mesh = fsm
	fs.position = Vector3(0, 0.04, -0.15)
	fs.material_override = bmat
	add_child(fs)

func _process(delta):
	is_aiming = Input.is_action_pressed("aim")
	var target_pos = ADS_POS if is_aiming else HIP_POS
	position = position.lerp(target_pos, ADS_SPEED * delta)

	if Input.is_action_pressed("shoot") and can_fire and not is_reloading and current_ammo > 0:
		_fire()

	if Input.is_action_just_pressed("reload") and not is_reloading:
		if current_ammo < MAG_SIZE and reserve_ammo > 0:
			_start_reload()

	if current_ammo == 0 and reserve_ammo > 0 and not is_reloading:
		_start_reload()

	recoil_offset = recoil_offset.lerp(Vector2.ZERO, RECOIL_RECOVERY * delta)

func _fire():
	current_ammo -= 1
	can_fire = false
	fire_timer.start()

	recoil_offset.x += randf_range(-RECOIL_SIDE, RECOIL_SIDE)
	recoil_offset.y += RECOIL_UP

	if raycast and raycast.is_colliding():
		var collider = raycast.get_collider()
		var hit_point = raycast.get_collision_point()
		var hit_normal = raycast.get_collision_normal()
		_spawn_impact(hit_point, hit_normal)
		if collider.has_method("take_damage"):
			collider.take_damage(DAMAGE)

	print("FIRE! Ammo: %d/%d" % [current_ammo, reserve_ammo])

func _start_reload():
	is_reloading = true
	reload_timer.start()
	print("Reloading...")

func _on_fire_cooldown():
	can_fire = true

func _on_reload_complete():
	var needed = MAG_SIZE - current_ammo
	var available = min(needed, reserve_ammo)
	current_ammo += available
	reserve_ammo -= available
	is_reloading = false
	print("Reload complete! Ammo: %d/%d" % [current_ammo, reserve_ammo])

func _spawn_impact(pos: Vector3, _normal: Vector3):
	var impact = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	impact.mesh = mesh
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.2)
	mat.emission_energy_multiplier = 3.0
	impact.material_override = mat
	get_tree().root.add_child(impact)
	impact.global_position = pos
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(impact):
		impact.queue_free()
