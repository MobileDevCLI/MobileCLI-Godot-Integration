extends MeshInstance
# Generates a simple assault rifle model from primitives

func _ready():
	_build_weapon()

func _build_weapon():
	# Main body/receiver
	var body = CubeMesh.new()
	body.size = Vector3(0.06, 0.06, 0.35)
	mesh = body

	var mat = SpatialMaterial.new()
	mat.albedo_color = Color(0.15, 0.15, 0.18)
	mat.roughness = 0.4
	mat.metallic = 0.7
	material_override = mat

	# Barrel
	var barrel_mesh = MeshInstance.new()
	var barrel = CylinderMesh.new()
	barrel.top_radius = 0.012
	barrel.bottom_radius = 0.012
	barrel.height = 0.3
	barrel_mesh.mesh = barrel
	barrel_mesh.rotation_degrees.x = 90
	barrel_mesh.translation = Vector3(0, 0.01, -0.32)
	var barrel_mat = SpatialMaterial.new()
	barrel_mat.albedo_color = Color(0.12, 0.12, 0.14)
	barrel_mat.metallic = 0.9
	barrel_mat.roughness = 0.2
	barrel_mesh.material_override = barrel_mat
	add_child(barrel_mesh)

	# Magazine
	var mag_mesh = MeshInstance.new()
	var mag = CubeMesh.new()
	mag.size = Vector3(0.03, 0.12, 0.06)
	mag_mesh.mesh = mag
	mag_mesh.translation = Vector3(0, -0.08, -0.05)
	mag_mesh.rotation_degrees.z = 3
	var mag_mat = SpatialMaterial.new()
	mag_mat.albedo_color = Color(0.1, 0.1, 0.12)
	mag_mat.metallic = 0.5
	mag_mesh.material_override = mag_mat
	add_child(mag_mesh)

	# Stock
	var stock_mesh = MeshInstance.new()
	var stock = CubeMesh.new()
	stock.size = Vector3(0.05, 0.055, 0.18)
	stock_mesh.mesh = stock
	stock_mesh.translation = Vector3(0, -0.005, 0.26)
	stock_mesh.material_override = mat
	add_child(stock_mesh)

	# Grip
	var grip_mesh = MeshInstance.new()
	var grip = CubeMesh.new()
	grip.size = Vector3(0.035, 0.07, 0.03)
	grip_mesh.mesh = grip
	grip_mesh.translation = Vector3(0, -0.06, 0.08)
	grip_mesh.rotation_degrees.x = -15
	grip_mesh.material_override = mat
	add_child(grip_mesh)

	# Front sight
	var sight_mesh = MeshInstance.new()
	var sight = CubeMesh.new()
	sight.size = Vector3(0.01, 0.025, 0.01)
	sight_mesh.mesh = sight
	sight_mesh.translation = Vector3(0, 0.04, -0.15)
	sight_mesh.material_override = barrel_mat
	add_child(sight_mesh)

	# Rear sight
	var rear_sight = MeshInstance.new()
	var rs = CubeMesh.new()
	rs.size = Vector3(0.04, 0.02, 0.01)
	rear_sight.mesh = rs
	rear_sight.translation = Vector3(0, 0.04, 0.1)
	rear_sight.material_override = barrel_mat
	add_child(rear_sight)

	# Handguard / foregrip area
	var handguard = MeshInstance.new()
	var hg = CubeMesh.new()
	hg.size = Vector3(0.055, 0.05, 0.12)
	handguard.mesh = hg
	handguard.translation = Vector3(0, 0, -0.15)
	var hg_mat = SpatialMaterial.new()
	hg_mat.albedo_color = Color(0.2, 0.18, 0.15)
	hg_mat.roughness = 0.7
	handguard.material_override = hg_mat
	add_child(handguard)
