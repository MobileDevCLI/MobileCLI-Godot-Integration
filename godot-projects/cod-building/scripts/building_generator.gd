extends Node3D
# Procedural two-story building generator - Call of Duty style
# Creates a combat-ready building with cover points, sight lines, and CQB layout

# Building dimensions (meters)
const BUILDING_WIDTH = 12.0
const BUILDING_DEPTH = 10.0
const FLOOR_HEIGHT = 3.5
const WALL_THICKNESS = 0.3
const FLOOR_THICKNESS = 0.25
const NUM_FLOORS = 2

# Materials
var mat_concrete_wall: StandardMaterial3D
var mat_concrete_floor: StandardMaterial3D
var mat_concrete_dark: StandardMaterial3D
var mat_metal: StandardMaterial3D
var mat_wood: StandardMaterial3D
var mat_window_frame: StandardMaterial3D
var mat_ground: StandardMaterial3D
var mat_stairs: StandardMaterial3D

func _ready():
	_create_materials()
	_build_ground()
	_build_floor_1()
	_build_floor_2()
	_build_roof()
	_build_stairs()
	_build_exterior_details()
	_add_cover_objects()
	_add_lighting()
	print("=== COD BUILDING GENERATED ===")
	print("Two-story CQB building ready")
	print("Building: %.0fm x %.0fm, %.0fm tall" % [BUILDING_WIDTH, BUILDING_DEPTH, FLOOR_HEIGHT * NUM_FLOORS])

func _create_materials():
	mat_concrete_wall = StandardMaterial3D.new()
	mat_concrete_wall.albedo_color = Color(0.65, 0.62, 0.58)
	mat_concrete_wall.roughness = 0.9
	mat_concrete_wall.metallic = 0.0

	mat_concrete_floor = StandardMaterial3D.new()
	mat_concrete_floor.albedo_color = Color(0.45, 0.43, 0.40)
	mat_concrete_floor.roughness = 0.85

	mat_concrete_dark = StandardMaterial3D.new()
	mat_concrete_dark.albedo_color = Color(0.35, 0.33, 0.30)
	mat_concrete_dark.roughness = 0.95

	mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.4, 0.42, 0.45)
	mat_metal.roughness = 0.4
	mat_metal.metallic = 0.8

	mat_wood = StandardMaterial3D.new()
	mat_wood.albedo_color = Color(0.55, 0.38, 0.22)
	mat_wood.roughness = 0.75

	mat_window_frame = StandardMaterial3D.new()
	mat_window_frame.albedo_color = Color(0.3, 0.32, 0.35)
	mat_window_frame.roughness = 0.5
	mat_window_frame.metallic = 0.6

	mat_ground = StandardMaterial3D.new()
	mat_ground.albedo_color = Color(0.35, 0.30, 0.22)
	mat_ground.roughness = 1.0

	mat_stairs = StandardMaterial3D.new()
	mat_stairs.albedo_color = Color(0.50, 0.48, 0.44)
	mat_stairs.roughness = 0.85

func _create_box(parent: Node, pos: Vector3, size: Vector3, material: StandardMaterial3D, name_prefix: String = "Box") -> StaticBody3D:
	var body = StaticBody3D.new()
	body.name = name_prefix
	parent.add_child(body)
	body.position = pos

	var mesh_inst = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_inst.mesh = box_mesh
	mesh_inst.material_override = material
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	body.add_child(mesh_inst)

	var col_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = size
	col_shape.shape = box_shape
	body.add_child(col_shape)

	return body

func _build_ground():
	var ground_node = Node3D.new()
	ground_node.name = "Ground"
	add_child(ground_node)
	_create_box(ground_node, Vector3(0, -0.125, 0), Vector3(60, 0.25, 60), mat_ground, "GroundPlane")
	_create_box(ground_node, Vector3(0, -0.05, 0), Vector3(BUILDING_WIDTH + 3, 0.1, BUILDING_DEPTH + 3), mat_concrete_dark, "ConcretePad")

func _build_floor_1():
	var f1 = Node3D.new()
	f1.name = "Floor1"
	add_child(f1)

	var hw = BUILDING_WIDTH / 2.0
	var hd = BUILDING_DEPTH / 2.0
	var wt = WALL_THICKNESS
	var fh = FLOOR_HEIGHT
	var wall_center_y = fh / 2.0

	# Floor slab
	_create_box(f1, Vector3(0, FLOOR_THICKNESS / 2.0, 0), Vector3(BUILDING_WIDTH, FLOOR_THICKNESS, BUILDING_DEPTH), mat_concrete_floor, "FloorSlab")

	# SOUTH WALL - main entrance
	_create_box(f1, Vector3(-hw/2.0 - 0.5, wall_center_y, -hd + wt/2.0), Vector3(hw - 1.0, fh, wt), mat_concrete_wall, "SouthWall_Left")
	_create_box(f1, Vector3(hw/2.0 + 0.5, wall_center_y, -hd + wt/2.0), Vector3(hw - 1.0, fh, wt), mat_concrete_wall, "SouthWall_Right")
	_create_box(f1, Vector3(0, fh - 0.5, -hd + wt/2.0), Vector3(2.0, 1.0, wt), mat_concrete_wall, "SouthWall_AboveDoor")
	# Door frame
	_create_box(f1, Vector3(-1.0, wall_center_y * 0.7, -hd + wt/2.0), Vector3(0.08, 2.4, wt + 0.05), mat_metal, "DoorFrame_L")
	_create_box(f1, Vector3(1.0, wall_center_y * 0.7, -hd + wt/2.0), Vector3(0.08, 2.4, wt + 0.05), mat_metal, "DoorFrame_R")
	_create_box(f1, Vector3(0, 2.5, -hd + wt/2.0), Vector3(2.16, 0.08, wt + 0.05), mat_metal, "DoorFrame_Top")

	# NORTH WALL - back door
	_create_box(f1, Vector3(-hw/2.0 - 0.75, wall_center_y, hd - wt/2.0), Vector3(hw - 1.5, fh, wt), mat_concrete_wall, "NorthWall_Left")
	_create_box(f1, Vector3(hw/2.0 + 0.25, wall_center_y, hd - wt/2.0), Vector3(hw - 0.5, fh, wt), mat_concrete_wall, "NorthWall_Right")
	_create_box(f1, Vector3(-1.5, fh - 0.5, hd - wt/2.0), Vector3(1.5, 1.0, wt), mat_concrete_wall, "NorthWall_AboveDoor")

	# WEST WALL - windows
	_create_box(f1, Vector3(-hw + wt/2.0, 0.5, 0), Vector3(wt, 1.0, BUILDING_DEPTH), mat_concrete_wall, "WestWall_Below")
	_create_box(f1, Vector3(-hw + wt/2.0, fh - 0.4, 0), Vector3(wt, 0.8, BUILDING_DEPTH), mat_concrete_wall, "WestWall_Above")
	_create_box(f1, Vector3(-hw + wt/2.0, wall_center_y, -hd + 1.5), Vector3(wt, fh, 3.0), mat_concrete_wall, "WestWall_WinLeft")
	_create_box(f1, Vector3(-hw + wt/2.0, wall_center_y, hd - 1.5), Vector3(wt, fh, 3.0), mat_concrete_wall, "WestWall_WinRight")
	_create_box(f1, Vector3(-hw + wt/2.0, wall_center_y, 0), Vector3(wt, fh, 0.4), mat_concrete_wall, "WestWall_Pillar")

	# EAST WALL - solid (stairwell)
	_create_box(f1, Vector3(hw - wt/2.0, wall_center_y, 0), Vector3(wt, fh, BUILDING_DEPTH), mat_concrete_wall, "EastWall")

	# INTERIOR WALL - divides two rooms
	_create_box(f1, Vector3(-hw/2.0, wall_center_y, 0), Vector3(hw - 1.2, fh, wt), mat_concrete_wall, "InteriorWall_L")
	_create_box(f1, Vector3(hw/2.0 - 0.5, wall_center_y, 0), Vector3(hw - 1.0, fh, wt), mat_concrete_wall, "InteriorWall_R")
	_create_box(f1, Vector3(0.4, fh - 0.5, 0), Vector3(1.6, 1.0, wt), mat_concrete_wall, "InteriorWall_AboveDoor")

func _build_floor_2():
	var f2 = Node3D.new()
	f2.name = "Floor2"
	add_child(f2)
	f2.position.y = FLOOR_HEIGHT

	var hw = BUILDING_WIDTH / 2.0
	var hd = BUILDING_DEPTH / 2.0
	var wt = WALL_THICKNESS
	var fh = FLOOR_HEIGHT
	var wall_center_y = fh / 2.0

	# Floor slab sections (with stairwell opening)
	_create_box(f2, Vector3(-hw/2.0 + 0.5, FLOOR_THICKNESS / 2.0, 0), Vector3(hw + 1.0, FLOOR_THICKNESS, BUILDING_DEPTH), mat_concrete_floor, "FloorSlab_West")
	_create_box(f2, Vector3(hw/2.0, FLOOR_THICKNESS / 2.0, -hd + 1.5), Vector3(hw, FLOOR_THICKNESS, 3.0), mat_concrete_floor, "FloorSlab_EastFront")
	_create_box(f2, Vector3(hw/2.0, FLOOR_THICKNESS / 2.0, hd - 1.0), Vector3(hw, FLOOR_THICKNESS, 2.0), mat_concrete_floor, "FloorSlab_EastBack")

	# SOUTH WALL - two windows
	_create_box(f2, Vector3(-hw + 1.5, wall_center_y, -hd + wt/2.0), Vector3(3.0, fh, wt), mat_concrete_wall, "F2_SouthWall_L")
	_create_box(f2, Vector3(0, wall_center_y, -hd + wt/2.0), Vector3(2.0, fh, wt), mat_concrete_wall, "F2_SouthWall_C")
	_create_box(f2, Vector3(hw - 1.5, wall_center_y, -hd + wt/2.0), Vector3(3.0, fh, wt), mat_concrete_wall, "F2_SouthWall_R")
	_create_box(f2, Vector3(-hw/2.0 + 1.0, 0.5, -hd + wt/2.0), Vector3(2.0, 1.0, wt), mat_concrete_wall, "F2_SWin1_Below")
	_create_box(f2, Vector3(hw/2.0 - 1.0, 0.5, -hd + wt/2.0), Vector3(2.0, 1.0, wt), mat_concrete_wall, "F2_SWin2_Below")
	_create_box(f2, Vector3(-hw/2.0 + 1.0, fh - 0.4, -hd + wt/2.0), Vector3(2.0, 0.8, wt), mat_concrete_wall, "F2_SWin1_Above")
	_create_box(f2, Vector3(hw/2.0 - 1.0, fh - 0.4, -hd + wt/2.0), Vector3(2.0, 0.8, wt), mat_concrete_wall, "F2_SWin2_Above")

	# Window frames
	_add_window_frame(f2, Vector3(-hw/2.0 + 1.0, 1.8, -hd + wt/2.0), Vector2(1.8, 1.4))
	_add_window_frame(f2, Vector3(hw/2.0 - 1.0, 1.8, -hd + wt/2.0), Vector2(1.8, 1.4))

	# NORTH WALL - one large window
	_create_box(f2, Vector3(-hw + 2.0, wall_center_y, hd - wt/2.0), Vector3(4.0, fh, wt), mat_concrete_wall, "F2_NorthWall_L")
	_create_box(f2, Vector3(hw - 2.0, wall_center_y, hd - wt/2.0), Vector3(4.0, fh, wt), mat_concrete_wall, "F2_NorthWall_R")
	_create_box(f2, Vector3(0, 0.5, hd - wt/2.0), Vector3(4.0, 1.0, wt), mat_concrete_wall, "F2_NWin_Below")
	_create_box(f2, Vector3(0, fh - 0.4, hd - wt/2.0), Vector3(4.0, 0.8, wt), mat_concrete_wall, "F2_NWin_Above")
	_add_window_frame(f2, Vector3(0, 1.8, hd - wt/2.0), Vector2(3.5, 1.4))

	# WEST WALL - windows
	_create_box(f2, Vector3(-hw + wt/2.0, 0.5, 0), Vector3(wt, 1.0, BUILDING_DEPTH), mat_concrete_wall, "F2_WestWall_Below")
	_create_box(f2, Vector3(-hw + wt/2.0, fh - 0.4, 0), Vector3(wt, 0.8, BUILDING_DEPTH), mat_concrete_wall, "F2_WestWall_Above")
	_create_box(f2, Vector3(-hw + wt/2.0, wall_center_y, -hd + 1.0), Vector3(wt, fh, 2.0), mat_concrete_wall, "F2_WestWall_C1")
	_create_box(f2, Vector3(-hw + wt/2.0, wall_center_y, hd - 1.0), Vector3(wt, fh, 2.0), mat_concrete_wall, "F2_WestWall_C2")
	_create_box(f2, Vector3(-hw + wt/2.0, wall_center_y, 0), Vector3(wt, fh, 0.4), mat_concrete_wall, "F2_WestWall_Pillar")

	# EAST WALL - solid
	_create_box(f2, Vector3(hw - wt/2.0, wall_center_y, 0), Vector3(wt, fh, BUILDING_DEPTH), mat_concrete_wall, "F2_EastWall")

	# Stairwell railing
	_create_box(f2, Vector3(hw/2.0 - 1.5, 0.5, 0), Vector3(0.08, 1.0, 4.0), mat_metal, "StairwellRailing")
	_create_box(f2, Vector3(hw/2.0 - 1.5, 1.0, 0), Vector3(0.06, 0.06, 4.0), mat_metal, "RailingTopBar")

func _add_window_frame(parent: Node, pos: Vector3, size: Vector2):
	var ft = 0.06
	_create_box(parent, pos + Vector3(-size.x/2.0, 0, 0), Vector3(ft, size.y, WALL_THICKNESS + 0.04), mat_window_frame, "WF_L")
	_create_box(parent, pos + Vector3(size.x/2.0, 0, 0), Vector3(ft, size.y, WALL_THICKNESS + 0.04), mat_window_frame, "WF_R")
	_create_box(parent, pos + Vector3(0, size.y/2.0, 0), Vector3(size.x, ft, WALL_THICKNESS + 0.04), mat_window_frame, "WF_T")
	_create_box(parent, pos + Vector3(0, -size.y/2.0, 0), Vector3(size.x, ft, WALL_THICKNESS + 0.04), mat_window_frame, "WF_B")

func _build_roof():
	var roof = Node3D.new()
	roof.name = "Roof"
	add_child(roof)
	var total_height = FLOOR_HEIGHT * NUM_FLOORS
	_create_box(roof, Vector3(0, total_height + FLOOR_THICKNESS / 2.0, 0), Vector3(BUILDING_WIDTH + 0.4, FLOOR_THICKNESS, BUILDING_DEPTH + 0.4), mat_concrete_dark, "RoofSlab")

	var hw = BUILDING_WIDTH / 2.0
	var hd = BUILDING_DEPTH / 2.0
	var ph = 0.8
	var py = total_height + FLOOR_THICKNESS + ph / 2.0
	_create_box(roof, Vector3(0, py, -hd - 0.1), Vector3(BUILDING_WIDTH + 0.6, ph, 0.2), mat_concrete_dark, "Parapet_S")
	_create_box(roof, Vector3(0, py, hd + 0.1), Vector3(BUILDING_WIDTH + 0.6, ph, 0.2), mat_concrete_dark, "Parapet_N")
	_create_box(roof, Vector3(-hw - 0.1, py, 0), Vector3(0.2, ph, BUILDING_DEPTH + 0.6), mat_concrete_dark, "Parapet_W")
	_create_box(roof, Vector3(hw + 0.1, py, 0), Vector3(0.2, ph, BUILDING_DEPTH + 0.6), mat_concrete_dark, "Parapet_E")

func _build_stairs():
	var stairs = Node3D.new()
	stairs.name = "Stairs"
	add_child(stairs)

	var hw = BUILDING_WIDTH / 2.0
	var stair_count = 14
	var stair_width = 1.2
	var stair_depth = 0.35
	var stair_height = FLOOR_HEIGHT / float(stair_count)
	var stair_x = hw - 1.5

	# First flight (south to north)
	var half_count = stair_count / 2
	for i in range(half_count):
		var y = (i + 1) * stair_height
		var z = -2.0 + i * stair_depth * 1.2
		_create_box(stairs, Vector3(stair_x, y / 2.0, z), Vector3(stair_width, y, stair_depth), mat_stairs, "Stair_Up_%d" % i)

	# Landing
	var mid_y = FLOOR_HEIGHT / 2.0
	_create_box(stairs, Vector3(stair_x, mid_y, 1.5), Vector3(stair_width + 0.4, FLOOR_THICKNESS, 1.2), mat_concrete_floor, "StairLanding")

	# Second flight (north to south)
	for i in range(half_count):
		var y = mid_y + (i + 1) * stair_height
		var z = 1.5 - i * stair_depth * 1.2
		_create_box(stairs, Vector3(stair_x, y - (mid_y / 2.0) + mid_y / 2.0, z), Vector3(stair_width, stair_height, stair_depth), mat_stairs, "Stair_Down_%d" % i)

	# Stairwell wall
	_create_box(stairs, Vector3(stair_x + stair_width/2.0 + 0.15, FLOOR_HEIGHT / 2.0, 0), Vector3(WALL_THICKNESS, FLOOR_HEIGHT, 5.0), mat_concrete_wall, "StairWall_E")

func _build_exterior_details():
	var details = Node3D.new()
	details.name = "ExteriorDetails"
	add_child(details)
	var hw = BUILDING_WIDTH / 2.0
	var hd = BUILDING_DEPTH / 2.0

	# Sandbags (front entrance cover)
	_create_box(details, Vector3(-2.0, 0.35, -hd - 1.5), Vector3(1.5, 0.7, 0.5), mat_ground, "Sandbags_L")
	_create_box(details, Vector3(2.0, 0.35, -hd - 1.5), Vector3(1.5, 0.7, 0.5), mat_ground, "Sandbags_R")

	# Jersey barriers (back)
	_create_box(details, Vector3(-1.5, 0.5, hd + 2.0), Vector3(2.5, 1.0, 0.4), mat_concrete_dark, "JerseyBarrier1")
	_create_box(details, Vector3(2.0, 0.5, hd + 2.5), Vector3(2.5, 1.0, 0.4), mat_concrete_dark, "JerseyBarrier2")

	# Rubble (west)
	_create_box(details, Vector3(-hw - 2.0, 0.3, -1.0), Vector3(1.5, 0.6, 1.5), mat_concrete_dark, "Rubble1")
	_create_box(details, Vector3(-hw - 1.5, 0.15, 0.5), Vector3(0.8, 0.3, 0.8), mat_concrete_dark, "Rubble2")

	# Destroyed vehicle (east)
	_create_box(details, Vector3(hw + 3.0, 0.6, -1.0), Vector3(4.0, 1.2, 2.0), mat_metal, "VehicleHull")
	_create_box(details, Vector3(hw + 2.5, 1.5, -1.0), Vector3(2.0, 0.8, 1.8), mat_metal, "VehicleCabin")

func _add_cover_objects():
	var cover = Node3D.new()
	cover.name = "CoverObjects"
	add_child(cover)

	# Ground floor Room 1 (front)
	_create_box(cover, Vector3(-3.0, 0.4, -3.0), Vector3(1.0, 0.8, 0.6), mat_wood, "Crate_F1_1")
	_create_box(cover, Vector3(-3.0, 1.0, -3.0), Vector3(0.8, 0.5, 0.5), mat_wood, "Crate_F1_1b")
	_create_box(cover, Vector3(1.5, 0.45, -3.5), Vector3(2.0, 0.9, 0.8), mat_metal, "Desk_F1")
	_create_box(cover, Vector3(-4.5, 0.5, -2.0), Vector3(0.6, 1.0, 0.6), mat_metal, "Barrel_F1_1")
	_create_box(cover, Vector3(-4.0, 0.5, -2.0), Vector3(0.6, 1.0, 0.6), mat_metal, "Barrel_F1_2")

	# Ground floor Room 2 (back)
	_create_box(cover, Vector3(-2.0, 0.4, 2.5), Vector3(1.0, 0.8, 0.6), mat_wood, "Crate_F1_R2_1")
	_create_box(cover, Vector3(1.0, 0.5, 3.0), Vector3(1.5, 1.0, 0.5), mat_wood, "Table_F1_R2")
	_create_box(cover, Vector3(-4.0, 0.4, 3.5), Vector3(0.8, 0.8, 0.8), mat_wood, "Crate_F1_R2_2")

	# Second floor
	var f2y = FLOOR_HEIGHT
	_create_box(cover, Vector3(-3.0, f2y + 0.4, -2.5), Vector3(1.0, 0.8, 0.6), mat_wood, "Crate_F2_1")
	_create_box(cover, Vector3(-3.0, f2y + 1.0, -2.5), Vector3(0.6, 0.5, 0.5), mat_wood, "Crate_F2_1b")
	_create_box(cover, Vector3(0, f2y + 0.55, -3.0), Vector3(2.0, 1.1, 0.5), mat_metal, "Desk_F2")
	_create_box(cover, Vector3(-4.5, f2y + 0.5, 2.0), Vector3(0.6, 1.0, 0.6), mat_metal, "Barrel_F2")
	_create_box(cover, Vector3(1.5, f2y + 0.4, 2.0), Vector3(1.2, 0.8, 1.2), mat_wood, "LargeCrate_F2")
	_create_box(cover, Vector3(-1.5, f2y + 0.3, 0.5), Vector3(1.5, 0.6, 0.15), mat_wood, "FlippedTable_F2")

func _add_lighting():
	var lights = Node3D.new()
	lights.name = "Lighting"
	add_child(lights)

	# Sun
	var sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.light_color = Color(1.0, 0.95, 0.85)
	sun.light_energy = 0.7
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-35, 45, 0)
	lights.add_child(sun)

	# Ground floor room 1
	var l1 = OmniLight3D.new()
	l1.name = "Light_F1_R1"
	l1.position = Vector3(-1.0, 2.8, -2.5)
	l1.light_color = Color(1.0, 0.9, 0.7)
	l1.light_energy = 0.5
	l1.omni_range = 6.0
	l1.shadow_enabled = true
	lights.add_child(l1)

	# Ground floor room 2
	var l2 = OmniLight3D.new()
	l2.name = "Light_F1_R2"
	l2.position = Vector3(-1.0, 2.8, 2.5)
	l2.light_color = Color(1.0, 0.9, 0.7)
	l2.light_energy = 0.4
	l2.omni_range = 6.0
	lights.add_child(l2)

	# Second floor
	var l3 = OmniLight3D.new()
	l3.name = "Light_F2"
	l3.position = Vector3(-1.0, FLOOR_HEIGHT + 2.8, 0)
	l3.light_color = Color(0.8, 0.85, 1.0)
	l3.light_energy = 0.5
	l3.omni_range = 8.0
	l3.shadow_enabled = true
	lights.add_child(l3)

	# Stairwell
	var l4 = OmniLight3D.new()
	l4.name = "Light_Stairs"
	l4.position = Vector3(BUILDING_WIDTH / 2.0 - 1.5, FLOOR_HEIGHT * 0.8, 0)
	l4.light_color = Color(1.0, 0.8, 0.5)
	l4.light_energy = 0.3
	l4.omni_range = 4.0
	lights.add_child(l4)
