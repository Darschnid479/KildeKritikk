extends SceneTree

# Lightweight test run through: godot --headless --path . --script res://tests/smoke.gd
# Does not require screenshots or user input.
const WorldScript = preload("res://scripts/cyber_world.gd")
var failed: bool = false

func _initialize() -> void:
    call_deferred("_run_checks")

func _expect(condition: bool, description: String) -> void:
    if condition:
        print("[PASS] " + description)
    else:
        failed = true
        push_error("[FAIL] " + description)

func _run_checks() -> void:
    var world = WorldScript.new()
    root.add_child(world)
    world.build_room(1)
    await process_frame
    _expect(world.terminal_areas.size() == 3, "Room 1 contains exactly three clues")
    _expect(world.drone_guards.size() == 1, "Room 1 includes one security drone")
    _expect(world.can_walk(Vector3(0.0, 0, 17.5)), "Spawn point is navigable")
    _expect(not world.can_walk(Vector3(-2.0, 0, 12.0)), "Cover blocks walking")
    _expect(not world._clear_sight(Vector3(-2.0, 2.2, 10.0), Vector3(-2.0, 0, 14.0)), "Cover blocks drone detection")
    _expect(world.closest_unread_distance(Vector3(0, 0, 17.5), [false, false, false]) > 0.0, "Distance to next clue is available")
    _expect(world.closest_unread_distance(Vector3(0, 0, 17.5), [true, true, true]) < 0.0, "All clues found indicator is available")
    var result: Dictionary = world.update_security(0.1, Vector3(-4.5, 0, 4.0), true)
    _expect(bool(result.get("spotted", false)), "Drone detects a nearby visible player")
    world.build_room(2)
    await process_frame
    _expect(world.terminal_areas.size() == 3, "Room 2 clues are preserved")
    _expect(world.drone_guards.size() == 2, "Room 2 includes two drones")
    world.build_room(3)
    await process_frame
    _expect(world.terminal_areas.size() == 3, "Room 3 clues are preserved")
    _expect(world.drone_guards.size() == 2, "Room 3 includes two drones")
    if failed:
        print("SECURITY V3 SMOKE TEST FAILED")
        quit(1)
    else:
        print("SECURITY V3 SMOKE TEST PASSED")
        quit(0)