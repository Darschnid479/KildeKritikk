extends Node3D
class_name SecurityDrone

# Autonomous hovering drone. No bullets, gore or external 3D assets.
# On impact it emits a visual pulse; the game controller applies shield damage.
var waypoints: Array[Vector3] = []
var accent: Color = Color("ff5477")
var waypoint_index: int = 0
var flight_clock: float = 0.0
var damage_cooldown: float = 0.0
var detection_range: float = 6.4
var pulse: MeshInstance3D
var eye: MeshInstance3D
var scan_light: OmniLight3D
var is_alert: bool = false

func configure(points: Array, tone: Color) -> void:
    accent = tone
    for p in points:
        waypoints.append(p)
    if waypoints.is_empty():
        return
    position = waypoints[0]
    _build_drone()

func _metal(color: Color, neon: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.55
    mat.roughness = 0.25
    if neon:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 3.0
    return mat

func _mesh(parent: Node3D, mesh: PrimitiveMesh, mat: Material, loc: Vector3) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.material_override = mat
    node.position = loc
    parent.add_child(node)
    return node

func _build_drone() -> void:
    var shell := SphereMesh.new()
    shell.radius = 0.53
    shell.height = 1.06
    _mesh(self, shell, _metal(Color("243544")), Vector3.ZERO)
    var orb := SphereMesh.new()
    orb.radius = 0.20
    orb.height = 0.4
    eye = _mesh(self, orb, _metal(accent, true), Vector3(0, 0.02, -0.49))
    var arm := BoxMesh.new()
    arm.size = Vector3(1.9, 0.11, 0.17)
    _mesh(self, arm, _metal(Color("5d7a8b")), Vector3.ZERO)
    for side in [-1, 1]:
        var fan := CylinderMesh.new()
        fan.top_radius = 0.42
        fan.bottom_radius = 0.42
        fan.height = 0.10
        _mesh(self, fan, _metal(accent, true), Vector3(float(side) * 0.93, 0.04, 0))
    var sphere := SphereMesh.new()
    sphere.radius = 1.0
    sphere.height = 2.0
    pulse = _mesh(self, sphere, _metal(Color(1, 0.2, 0.35, 0.0)), Vector3.ZERO)
    pulse.visible = false
    scan_light = OmniLight3D.new()
    scan_light.light_color = accent
    scan_light.light_energy = 1.5
    scan_light.omni_range = 5.0
    add_child(scan_light)

func tick_guard(delta: float, player_pos: Vector3, enabled: bool, visible: bool = true) -> Dictionary:
    flight_clock += delta
    if not enabled:
        return {"struck": false, "spotted": false}
    damage_cooldown = maxf(0.0, damage_cooldown - delta)
    var flat_delta := Vector2(player_pos.x - position.x, player_pos.z - position.z)
    is_alert = visible and flat_delta.length() < detection_range
    var target: Vector3 = player_pos if is_alert else waypoints[waypoint_index]
    var move_speed: float = 3.2 if is_alert else 1.55
    # Hover at constant height, allowing the drone to pass above cover boxes.
    target.y = 2.2
    var direction: Vector3 = target - position
    if direction.length() > 0.12:
        position += direction.normalized() * minf(direction.length(), move_speed * delta)
    if not is_alert and position.distance_to(target) < 0.6:
        waypoint_index = (waypoint_index + 1) % waypoints.size()
    position.y = 2.2 + sin(flight_clock * 3.4) * 0.18
    if is_instance_valid(eye):
        eye.scale = Vector3.ONE * (1.0 + 0.16 * sin(flight_clock * 8.0))
    if is_instance_valid(scan_light):
        scan_light.light_energy = 3.2 if is_alert else 1.2 + sin(flight_clock * 2.0) * 0.6
    var struck := false
    if is_alert and flat_delta.length() < 2.0 and damage_cooldown <= 0.0:
        damage_cooldown = 1.8
        struck = true
        _pulse_animation()
    return {"struck": struck, "spotted": is_alert}

func _pulse_animation() -> void:
    if not is_instance_valid(pulse):
        return
    pulse.visible = true
    pulse.scale = Vector3.ONE * 0.12
    pulse.transparency = 0.12
    var anim := create_tween()
    anim.set_parallel(true)
    anim.tween_property(pulse, "scale", Vector3.ONE * 2.25, 0.33)
    anim.tween_property(pulse, "transparency", 1.0, 0.33)
    anim.chain().tween_callback(func() -> void:
        if is_instance_valid(pulse):
            pulse.visible = false
    )