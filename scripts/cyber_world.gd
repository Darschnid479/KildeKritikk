extends Node3D
class_name CyberWorld

# The world is real 3D geometry: terminals, server cabinets, security doors,
# light strips, hologram, floating dust, floor grid, and a simulated explosion.
# No 3D assets, external services or imported models are required.

var room_index: int = 1
var time_passed: float = 0.0
var terminal_areas: Array[Area3D] = []
var terminal_glows: Array[MeshInstance3D] = []
var terminal_status: Array[Label3D] = []
var moving_lights: Array[Node3D] = []
var floating_bits: Array[Node3D] = []
var portal: Node3D
var explosion: Node3D
var explosion_core: MeshInstance3D
var alert_light: OmniLight3D
var cleaned: bool = false
var terminal_names: Array[String] = []
var palette: Color = Color("3ce9f3")
var drone_guards: Array[Node3D] = []
var barriers: Array[Rect2] = []
const DroneScript = preload("res://scripts/security_drone.gd")


func _ready() -> void:
    set_process(true)

func build_room(which: int) -> void:
    room_index = which
    time_passed = 0.0
    cleaned = false
    for child in get_children():
        remove_child(child)
        child.queue_free()
    terminal_areas.clear()
    terminal_glows.clear()
    terminal_status.clear()
    moving_lights.clear()
    floating_bits.clear()
    drone_guards.clear()
    barriers.clear()
    match which:
        1:
            palette = Color("39e9f3")
            terminal_names = ["DALNYTT", "FJELLPOSTEN", "NYHETSBLIKK"]
        2:
            palette = Color("f9758b")
            terminal_names = ["REKLAME.EXE", "TESTRAPPORT.PDF", "KUNDEMELDING.TXT"]
        3:
            palette = Color("9b8cff")
            terminal_names = ["VIDEOOPPTAK", "VIDEOARKIV", "HACKERMELDING"]
    _make_architecture()
    _make_servers()
    _make_cover()
    _make_terminals()
    _make_portal()
    _make_holograms()
    _make_lighting()
    _make_security_drones()
    if which == 3:
        _make_explosion()

func _mat(albedo: Color, emit: Color = Color.BLACK, strength: float = 1.0, alpha: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = albedo
    m.metallic = 0.46
    m.roughness = 0.30
    if emit != Color.BLACK:
        m.emission_enabled = true
        m.emission = emit
        m.emission_energy_multiplier = strength
    if alpha:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    return m

func _block(parent: Node3D, size: Vector3, pos: Vector3, material: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    mesh_instance.material_override = material
    mesh_instance.position = pos
    mesh_instance.rotation = rot
    parent.add_child(mesh_instance)
    return mesh_instance

func _sphere(parent: Node3D, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 20
    mesh.rings = 10
    node.mesh = mesh
    node.material_override = material
    node.position = pos
    parent.add_child(node)
    return node

func _text(parent: Node3D, value: String, pos: Vector3, size: int, color: Color, scale_factor: float = 1.0) -> Label3D:
    var t := Label3D.new()
    t.text = value
    t.font_size = size
    t.pixel_size = 0.0038 * scale_factor
    t.outline_size = 5
    t.modulate = color
    t.outline_modulate = Color("030a17")
    t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    t.no_depth_test = false
    t.double_sided = true
    t.position = pos
    parent.add_child(t)
    return t

func _make_architecture() -> void:
    # Expanded exploration map: 28 m wide and 48 m long. Terminals are far apart.
    var base := _mat(Color("101d30"))
    var metal := _mat(Color("1e3045"))
    var seam := _mat(Color("07121e"))
    var glow := _mat(palette.darkened(0.5), palette, 2.8)
    _block(self, Vector3(28.0, 0.38, 49.0), Vector3(0, -0.25, -1.0), base)
    _block(self, Vector3(28.0, 0.22, 49.0), Vector3(0, 9.0, -1.0), seam)
    for side in [-1, 1]:
        _block(self, Vector3(0.45, 9.2, 49.0), Vector3(float(side) * 14.0, 4.3, -1.0), metal)
    _block(self, Vector3(28.0, 9.2, 0.35), Vector3(0, 4.3, -25.0), seam)
    _block(self, Vector3(28.0, 9.2, 0.35), Vector3(0, 4.3, 23.0), base)
    for x in [-13.6, -11.1, 11.1, 13.6]:
        for z in [-21.0, -13.0, -5.0, 3.0, 11.0, 19.0]:
            _block(self, Vector3(0.24, 8.8, 0.24), Vector3(x, 4.2, z), metal)
            _block(self, Vector3(0.045, 8.2, 0.045), Vector3(x + 0.13, 4.2, z + 0.13), glow)
    var line := _mat(Color("10202d"), palette.darkened(0.48), 0.75)
    for ix in range(-25, 26):
        _block(self, Vector3(0.012, 0.008, 46.0), Vector3(float(ix) * 0.54, -0.052, -1.0), line)
    for iz in range(-45, 46):
        _block(self, Vector3(27.2, 0.008, 0.012), Vector3(0, -0.05, float(iz) * 0.52 - 1.0), line)
    for side in [-1, 1]:
        _block(self, Vector3(0.08, 0.035, 41.0), Vector3(float(side) * 10.9, 0.015, -1.0), glow)
    for z in [-21.0, -15.0, -9.0, -3.0, 3.0, 9.0, 15.0, 21.0]:
        _block(self, Vector3(26.4, 0.10, 0.10), Vector3(0, 8.82, z), glow)
    _text(self, "H A C K E R A N G R E P E T", Vector3(0, 7.24, -24.7), 78, palette, 1.35)
    var sub: String = ["01 // SPOR OPPHAVET", "02 // VURDER BEVISENE", "03 // AVSLØR KONTEKSTEN"][room_index - 1]
    _text(self, sub, Vector3(0, 6.55, -24.69), 49, Color("9baec6"), 0.9)
    # Area signs nudge the player to explore instead of seeing every clue from spawn.
    _text(self, "ARKIV / NORD", Vector3(0, 4.3, -18), 42, palette)
    _text(self, "SERVERSAL / MIDTEN", Vector3(0, 4.3, -3), 42, palette)
    _text(self, "ADGANG / SØR", Vector3(0, 4.3, 18), 42, palette)

func _make_servers() -> void:
    var cabinet := _mat(Color("182737"))
    var trim := _mat(Color("334558"))
    var cyan := _mat(Color("0b242a"), Color("3aebff"), 2.0)
    var red := _mat(Color("2c111b"), Color("ff5067"), 1.8)
    for side in [-1, 1]:
        for zi in range(5):
            var z: float = -19.0 + zi * 9.0
            var x: float = float(side) * 12.2
            _block(self, Vector3(1.45, 4.6, 2.05), Vector3(x, 2.35, z), cabinet)
            _block(self, Vector3(1.5, 0.09, 2.11), Vector3(x, 4.69, z), trim)
            _block(self, Vector3(1.42, 0.07, 2.12), Vector3(x, 0.13, z), trim)
            # Alternating animated-looking status banks.
            for row in range(9):
                var y := 0.55 + float(row) * 0.39
                var led_material: Material = red if row % 5 == 0 else cyan
                _block(self, Vector3(0.035, 0.075, 0.18), Vector3(x - side * 0.74, y, z - 0.5), led_material)
                _block(self, Vector3(0.035, 0.045, 0.55), Vector3(x - side * 0.74, y, z + 0.17), trim)

func _make_cover() -> void:
    var steel := _mat(Color("243a4d"))
    var trim := _mat(Color("142635"), palette, 1.4)
    # Obstacles force a zigzag route, but never fully block the arena.
    var cover_data: Array[Vector3] = [
        Vector3(-2.0, 0, 12.0), Vector3(4.0, 0, 5.0),
        Vector3(-2.0, 0, -5.5), Vector3(3.0, 0, -12.5)
    ]
    for pos in cover_data:
        _block(self, Vector3(3.2, 2.1, 1.8), Vector3(pos.x, 1.0, pos.z), steel)
        _block(self, Vector3(3.25, 0.075, 1.82), Vector3(pos.x, 2.06, pos.z), trim)
        # Top-down Rect2 on the x/z plane, slightly expanded for the player.
        barriers.append(Rect2(pos.x - 1.85, pos.z - 1.16, 3.7, 2.32))

func can_walk(pos: Vector3) -> bool:
    if absf(pos.x) > 10.65 or pos.z < -21.7 or pos.z > 20.2:
        return false
    for wall in barriers:
        if wall.has_point(Vector2(pos.x, pos.z)):
            return false
    return true

func _make_security_drones() -> void:
    # Security drones are fictional, non-graphic threats with pulse attacks.
    var patrols: Array = [
        [Vector3(-4.5, 2.2, 4.0), Vector3(4.5, 2.2, -1.5), Vector3(2.0, 2.2, -9.0), Vector3(-4.5, 2.2, -5.0)],
        [Vector3(5.0, 2.2, -17.0), Vector3(-3.0, 2.2, -13.0), Vector3(-6.0, 2.2, -7.0)]
    ]
    var count: int = 1 if room_index == 1 else 2
    for i in range(count):
        var guard: Node3D = DroneScript.new()
        add_child(guard)
        guard.call("configure", patrols[i], Color("ff506f") if i == 0 else Color("e6a0ff"))
        drone_guards.append(guard)

func _clear_sight(observer: Vector3, target: Vector3) -> bool:
    # A crate hides the player from a drone's sensor. This encourages exploration
    # and taking cover without introducing a combat requirement to the lesson.
    var begin := Vector2(observer.x, observer.z)
    var end := Vector2(target.x, target.z)
    for barrier in barriers:
        for i in range(1, 15):
            var sample := begin.lerp(end, float(i) / 15.0)
            if barrier.has_point(sample):
                return false
    return true

func closest_unread_distance(from_position: Vector3, seen: Array) -> float:
    var closest: float = -1.0
    for i in range(min(terminal_areas.size(), seen.size())):
        if not bool(seen[i]):
            var candidate: float = from_position.distance_to(terminal_areas[i].global_position)
            if closest < 0.0 or candidate < closest:
                closest = candidate
    return closest

func update_security(delta: float, player_pos: Vector3, active: bool) -> Dictionary:
    var strikes: int = 0
    var spotted: bool = false
    for guard in drone_guards:
        if is_instance_valid(guard):
            var visible: bool = _clear_sight(guard.position, player_pos)
            var result: Dictionary = guard.call("tick_guard", delta, player_pos, active, visible)
            if result.get("struck", false):
                strikes += 1
            if result.get("spotted", false):
                spotted = true
    return {"strikes": strikes, "spotted": spotted}

func _make_terminals() -> void:
    var outer := _mat(Color("0d1b2b"))
    var edge := _mat(Color("1e3448"))
    var screen_mat := _mat(Color("0b2636"), palette.darkened(0.45), 2.5)
    var neon := _mat(palette.darkened(0.45), palette, 2.8)
    for i in range(3):
        var station := Node3D.new()
        station.position = [Vector3(-7.0, 0, -16.0), Vector3(7.0, 0, -2.0), Vector3(-5.0, 0, 9.0)][i]
        station.rotation.y = (i - 1) * -0.08
        add_child(station)
        _block(station, Vector3(3.7, 0.21, 1.6), Vector3(0, 1.08, 0.75), outer)
        for x in [-1.65, 1.65]:
            _block(station, Vector3(0.15, 1.05, 0.15), Vector3(x, 0.55, 0.8), edge)
        _block(station, Vector3(3.8, 2.65, 0.28), Vector3(0, 2.65, 0), outer)
        _block(station, Vector3(3.56, 2.37, 0.035), Vector3(0, 2.65, 0.17), screen_mat)
        _block(station, Vector3(3.75, 0.05, 0.09), Vector3(0, 3.96, 0.20), neon)
        _block(station, Vector3(3.75, 0.05, 0.09), Vector3(0, 1.35, 0.20), neon)
        _block(station, Vector3(0.06, 2.52, 0.09), Vector3(-1.86, 2.65, 0.20), neon)
        _block(station, Vector3(0.06, 2.52, 0.09), Vector3(1.86, 2.65, 0.20), neon)
        _text(station, "0%d // INTEL NODE" % (i + 1), Vector3(0, 3.52, 0.228), 37, palette, 0.95)
        _text(station, terminal_names[i], Vector3(0, 2.85, 0.24), 50, Color("f4faff"), 0.9)
        var status := _text(station, "[ KLIKK FOR Å UNDERSØKE ]", Vector3(0, 2.13, 0.24), 31, Color("8da9bb"), 0.86)
        terminal_status.append(status)
        var scan := _block(station, Vector3(3.45, 0.025, 0.025), Vector3(0, 1.58, 0.205), neon)
        terminal_glows.append(scan)
        moving_lights.append(scan)
        # Large invisible interaction hitbox on the monitor.
        var area := Area3D.new()
        area.position = Vector3(0, 2.65, 0.35)
        area.collision_layer = 1
        area.collision_mask = 0
        area.set_meta("terminal_index", i)
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(3.8, 2.65, 0.40)
        shape.shape = box
        area.add_child(shape)
        station.add_child(area)
        terminal_areas.append(area)
        # A small translucent keypad and hardware pedestal.
        _block(station, Vector3(2.85, 0.055, 0.78), Vector3(0, 1.20, 1.15), edge, Vector3(-0.18, 0, 0))
        for key in range(9):
            var key_x: float = (key % 3 - 1) * 0.26
            var key_z: float = (float(key / 3) - 1.0) * 0.18 + 1.11
            _block(station, Vector3(0.14, 0.016, 0.085), Vector3(key_x, 1.265, key_z), neon)

func _make_portal() -> void:
    portal = Node3D.new()
    portal.position = Vector3(0, 3.5, -23.65)
    add_child(portal)
    var ring := _mat(palette.darkened(0.35), palette, 2.5)
    var spokes := _mat(Color("153849"), palette.darkened(0.18), 1.2)
    for i in range(32):
        var a: float = float(i) * TAU / 32.0
        var seg := Node3D.new()
        seg.position = Vector3(cos(a) * 2.3, sin(a) * 2.3, 0)
        seg.rotation.z = a + PI / 2.0
        portal.add_child(seg)
        _block(seg, Vector3(0.48, 0.09, 0.18), Vector3.ZERO, ring)
        if i % 4 == 0:
            _block(seg, Vector3(0.72, 0.03, 0.1), Vector3(0, 0, 0.04), spokes)
    var interior := _mat(Color(0.015, 0.10, 0.15, 0.32), palette.darkened(0.55), 0.8, true)
    _block(portal, Vector3(4.05, 4.05, 0.07), Vector3(0, 0, -0.09), interior)
    _text(portal, "SIGNAL / LIVE", Vector3(0, -0.2, 0.10), 38, Color("e5f5ff"))

func _make_holograms() -> void:
    var bit_mat := _mat(Color(0.1, 0.4, 0.5, 0.45), palette, 1.8, true)
    for i in range(58):
        var angle: float = float(i * 47 % 360) * PI / 180.0
        var x: float = cos(angle) * (1.4 + float(i % 7) * 1.12)
        var z: float = sin(angle) * (1.1 + float(i % 5) * 1.9) - 1.3
        var y: float = 0.6 + float(i * 19 % 29) * 0.19
        var dot := _block(self, Vector3(0.025, 0.05 + (i % 3) * 0.03, 0.03), Vector3(x, y, z), bit_mat)
        floating_bits.append(dot)
    var hologram := _mat(Color("0a2432"), palette.darkened(0.4), 1.6, true)
    for j in range(8):
        var unit := Node3D.new()
        unit.position = Vector3(-6.6 if j % 2 == 0 else 6.6, 3.0 + j * 0.28, -9.0 + (j / 2) * 4.5)
        add_child(unit)
        _block(unit, Vector3(0.25, 0.25, 0.035), Vector3.ZERO, hologram)
        unit.rotation.y = j * 0.3
        floating_bits.append(unit)

func _make_lighting() -> void:
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("030914")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("263953")
    env.ambient_light_energy = 0.9
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    add_child(environment)
    var main_light := OmniLight3D.new()
    main_light.position = Vector3(0, 7.6, 2.0)
    main_light.light_color = Color("b1d7ff")
    main_light.light_energy = 1.45
    main_light.omni_range = 26
    add_child(main_light)
    for side in [-1, 1]:
        var accent := OmniLight3D.new()
        accent.position = Vector3(9.4 * side, 3.7, -8.0)
        accent.light_color = palette
        accent.light_energy = 2.6
        accent.omni_range = 12
        add_child(accent)
    alert_light = OmniLight3D.new()
    alert_light.position = Vector3(0, 5.0, -18)
    alert_light.light_color = Color("ff315a")
    alert_light.light_energy = 1.5
    alert_light.omni_range = 9
    add_child(alert_light)

func _make_explosion() -> void:
    explosion = Node3D.new()
    explosion.position = Vector3(0, 4.9, -23.1)
    add_child(explosion)
    var fire := _mat(Color(1.0, 0.42, 0.13, 0.64), Color("ff642f"), 3.5, true)
    explosion_core = _sphere(explosion, 0.9, Vector3.ZERO, fire)
    var spark := _mat(Color("ffb365"), Color("ff7c26"), 2.5, true)
    for i in range(14):
        var a: float = float(i) * TAU / 14.0
        var p := Vector3(cos(a) * 1.1, sin(a) * 1.1, 0)
        var shard := _block(explosion, Vector3(0.09, 0.27, 0.05), p, spark)
        shard.rotation.z = a
    _text(explosion, "SIMULERT FILMEFFEKT // 2023", Vector3(0, -1.9, 0.3), 30, Color("ffd5a8"), 1.0)

func set_opened(viewed: Array) -> void:
    for i in range(min(3, viewed.size())):
        if viewed[i]:
            terminal_status[i].text = "[ SPOR UNDERSØKT  /  ✓ ]"
            terminal_status[i].modulate = Color("76ffbd")
        else:
            terminal_status[i].text = "[ KLIKK FOR Å UNDERSØKE ]"
            terminal_status[i].modulate = Color("8da9bb")

func set_cleaned() -> void:
    cleaned = true
    if is_instance_valid(alert_light):
        alert_light.light_color = Color("47ffad")
    for glow in terminal_glows:
        if is_instance_valid(glow) and glow.material_override is StandardMaterial3D:
            var material: StandardMaterial3D = glow.material_override as StandardMaterial3D
            material.emission = Color("54f7bc")
    if is_instance_valid(portal):
        for ring_piece in portal.get_children():
            if ring_piece is Node3D:
                for mesh_child in ring_piece.get_children():
                    if mesh_child is MeshInstance3D and mesh_child.material_override is StandardMaterial3D:
                        var material: StandardMaterial3D = mesh_child.material_override as StandardMaterial3D
                        material.emission = Color("54f7bc")

func _process(delta: float) -> void:
    time_passed += delta
    for i in range(moving_lights.size()):
        if is_instance_valid(moving_lights[i]):
            moving_lights[i].position.y = 1.54 + (sin(time_passed * 1.7 + float(i) * 2.0) + 1.0) * 1.05
    for i in range(floating_bits.size()):
        if is_instance_valid(floating_bits[i]):
            floating_bits[i].position.y += sin(time_passed * (0.7 + float(i % 5) * 0.15) + float(i)) * delta * 0.05
    if is_instance_valid(portal):
        portal.rotation.z = sin(time_passed * 0.12) * 0.08
        portal.scale = Vector3.ONE * (1.0 + sin(time_passed * 1.2) * 0.025)
    if is_instance_valid(alert_light):
        alert_light.light_energy = 0.7 if cleaned else 0.7 + 1.6 * (0.5 + 0.5 * sin(time_passed * 3.7))
    if is_instance_valid(explosion_core):
        var beat: float = 0.8 + (sin(time_passed * 1.9) + 1.0) * 0.29
        explosion_core.scale = Vector3.ONE * beat
        explosion.rotation.z += delta * 0.09

func pick_terminal(cam: Camera3D, point: Vector2) -> int:
    var from: Vector3 = cam.project_ray_origin(point)
    var toward: Vector3 = from + cam.project_ray_normal(point) * 90.0
    var query := PhysicsRayQueryParameters3D.create(from, toward)
    query.collide_with_areas = true
    query.collide_with_bodies = false
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit.has("collider") and hit["collider"] is Area3D:
        var a: Area3D = hit["collider"]
        if a.has_meta("terminal_index"):
            return int(a.get_meta("terminal_index"))
    return -1

func nearest_terminal(from_position: Vector3, max_distance: float = 7.5) -> int:
    var result: int = -1
    var best := max_distance
    for i in range(terminal_areas.size()):
        var d: float = from_position.distance_to(terminal_areas[i].global_position)
        if d < best:
            best = d
            result = i
    return result