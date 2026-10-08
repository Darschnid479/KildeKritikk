extends Node3D

const CyberWorldScript = preload("res://scripts/cyber_world.gd")
const DURATION: float = 900.0
const INK: Color = Color("06101e")
const PANEL: Color = Color(0.025, 0.065, 0.11, 0.95)
const PALE: Color = Color("e8f6ff")
const MUTED: Color = Color("92a9c2")
const CYAN: Color = Color("45e9f5")
const RED: Color = Color("ff647c")
const GREEN: Color = Color("64f6ba")
const PURPLE: Color = Color("a794ff")

const ROOM_HEADINGS: Array[String] = ["FINN DEN OPPRINNELIGE KILDEN", "VURDER BEVISENE", "SE HELE BILDET"]
const ROOM_NAMES: Array[String] = ["SPOR / KILDE", "BEVIS / DOKUMENTER", "KONTEKST / TIDSLINJE"]
const TERMINAL_TITLES: Array = [
    ["DALNYTT", "FJELLPOSTEN", "NYHETSBLIKK"],
    ["Reklame.exe", "Testrapport.pdf", "Kundemelding.txt"],
    ["Videoopptaket", "Videoarkivet", "Hackerens nyhet"]
]
const TERMINAL_META: Array = [
    ["09:00   //   KODE 417", "10:30   //   KODE 825", "12:15   //   KODE 639"],
    ["PÅSTAND   //   SUPERBOOST", "MÅLING   //   10s → 8s", "MENING   //   ANONYM"],
    ["LAGET I 2023", "PUBLISERT I 2023", "DELT 8. OKTOBER 2026"]
]
const TERMINAL_COPY: Array = [
    [
        "HEMSEDAL STENGER ALLE SKOLER FRA MANDAG!\n\nOppdiktet treningsnyhet fra Dalnytt, publisert kl. 09:00. Artikkelen påstår at alle skoler skal stenges, men viser ingen bekreftelse fra kommunen eller en navngitt kilde.\n\nKilden er ikke oppgitt. Dette er den tidligste av de tre artiklene. At den er først, betyr likevel ikke at innholdet er sant.\n\nARTIKKELKODE: 417",
        "HEMSEDAL-SKOLENE SKAL ANGIVELIG STENGES\n\nOppdiktet treningsnyhet fra Fjellposten, publisert kl. 10:30. Teksten bygger på det Dalnytt skrev kl. 09:00. Fjellposten har ikke vist til en egen bekreftelse fra kommunen.\n\nOPPGITT KILDE: Dalnytt\nARTIKKELKODE: 825",
        "FLERE NETTSTEDER OM SKOLESTENGING\n\nOppdiktet treningsnyhet fra Nyhetsblikk, publisert kl. 12:15. Denne artikkelen viser til Fjellposten. Fjellposten viser på sin side til Dalnytt.\n\nDette er altså ikke tre uavhengige bekreftelser på nyheten.\n\nOPPGITT KILDE: Fjellposten\nARTIKKELKODE: 639"
    ],
    [
        "SUPERBOOST GJØR ALLE DATAMASKINER 500 % RASKERE!\n\nDette er en oppdiktet reklamefil. Den lover at ALLE datamaskiner blir 500 % raskere. Reklamen viser ingen metode eller tester som dokumenterer løftet.\n\nHACKERENS MERKNAD: Del denne påstanden med alle brukere.",
        "TESTRAPPORT – EN DATAMASKIN / ETT PROGRAM\n\nOppdiktet testrapport:\n\nFØR: Ett program startet på 10 sekunder.\nETTER: Det samme programmet startet på 8 sekunder.\n\nDette er 2 sekunder kortere oppstartstid, altså en reduksjon på 20 % i akkurat denne målingen. Testen viser ikke at hele datamaskinen er 500 % raskere.",
        "KUNDEMELDING – UKJENT AVSENDER\n\n«Jeg synes maskinen føles mye raskere nå!»\n\nMeldingen er anonym. Det står ikke hvilken maskin som ble brukt, hvordan endringen ble målt eller om resultatet kan gjentas.\n\nEn personlig opplevelse er ikke nok til å bevise et generelt løfte om alle datamaskiner."
    ],
    [
        "KONTROLLERT FILMEFFEKT – 2023\n\nDette opptaket viser en dramatisk eksplosjon som ble laget som en kontrollert filmeffekt i 2023. Det var ikke en virkelig ulykke.\n\nSelve klippet kan være ekte, men det forteller ikke automatisk når eller hvorfor noe skjedde. Se også videoarkivet.",
        "ARKIVOPPFØRING – 2023\n\nEt oppdiktet videoarkiv oppgir at opptaket ble publisert i 2023, ETTER at filmeffekten ble laget. Arkivet forklarer at dette er en kontrollert effekt til film.\n\nDermed vet vi at opptaket allerede var tilgjengelig i 2023. Dette er et viktig spor når noen deler videoen som en ny hendelse.",
        "HACKERENS MELDING – 8. OKTOBER 2026\n\n«EKSPLOSJON VED LABORATORIET I DAG! SE VIDEOEN! DEL FØR DEN SLETTES!»\n\nMeldingen bruker et klipp fra 2023, men hevder at noe skjedde i dag. Ingen bekreftelse fra laboratoriet er oppgitt.\n\nOppgaven din er å avsløre feil tid og sammenheng."
    ]
]
const HINTS: Array = [
    ["Sammenlikn klokkeslettene. Hvilken artikkel var først?", "Følg kildehenvisningen bakover: Nyhetsblikk → Fjellposten → Dalnytt. Bruk koden til den første."],
    ["Sammenlikn det reklamen lover med det rapporten faktisk måler.", "Én oppstart på én PC ble 2 sekunder kortere. Hvilken fil lover mye mer enn bevisene viser?"],
    ["Sjekk året i arkivet og datoen i hackerens melding.", "Videoen ble først laget, deretter publisert i 2023. Hackerens melding kom i 2026."]
]

var world: CyberWorld
var player: Node3D
var cam: Camera3D
var ui_layer: CanvasLayer
var ui_root: Control
var modal_layer: Control
var top_timer: Label
var top_room: Label
var shield_label: Label
var alert_label: Label
var side_content: VBoxContainer
var bottom_content: VBoxContainer
var mission_prompt: Label
var mission_action: Button
var trace_label: Label
var interaction_prompt: Label
var toast_container: Control
var code_field: LineEdit
var sound_button: Button
var sfx_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var sound_on: bool = true
var current_room: int = 1
var time_left: float = DURATION
var started: bool = false
var finished: bool = false
var transition_in_progress: bool = false
var viewed: Array = [[false, false, false], [false, false, false], [false, false, false]]
var hint_counts: Array[int] = [0, 0, 0]
var timeline_order: Array[int] = [2, 0, 1]
var timeline_solved: bool = false
var status_text: String = "SYSTEM ONLINE  //  VENTER PÅ AGENT"
var cursor_terminal: int = -1
var elapsed: float = 0.0
var tracker_clock: float = 0.0
var shield: float = 100.0
var hit_immunity: float = 0.0
const SPAWN: Vector3 = Vector3(0.0, 0.0, 17.5)


func _ready() -> void:
    _create_player()
    world = CyberWorldScript.new()
    add_child(world)
    world.build_room(1)
    _setup_audio()
    _create_ui()
    _show_intro()
    set_process(true)
    set_process_unhandled_input(true)

func _create_player() -> void:
    player = Node3D.new()
    player.name = "DigitalInvestigator"
    player.position = SPAWN
    add_child(player)
    cam = Camera3D.new()
    cam.name = "Eyes"
    cam.current = true
    cam.position = Vector3(0, 2.2, 0)
    cam.fov = 73.0
    cam.near = 0.08
    cam.far = 110
    player.add_child(cam)

func _setup_audio() -> void:
    sfx_player = AudioStreamPlayer.new()
    sfx_player.volume_db = -9
    add_child(sfx_player)
    ambience_player = AudioStreamPlayer.new()
    ambience_player.volume_db = -26
    add_child(ambience_player)
    ambience_player.finished.connect(_ambient_loop)

func _ambient_loop() -> void:
    if started and not finished and sound_on:
        ambience_player.play()

func _sound(path: String) -> void:
    if not sound_on:
        return
    var resource: Resource = load(path)
    if resource is AudioStream:
        sfx_player.stream = resource as AudioStream
        sfx_player.play()

func _process(delta: float) -> void:
    elapsed += delta
    if started and not finished:
        time_left = maxf(0.0, time_left - delta)
        if is_instance_valid(top_timer):
            top_timer.text = "%02d:%02d" % [int(time_left / 60.0), int(time_left) % 60]
            top_timer.add_theme_color_override("font_color", RED if time_left < 180 else CYAN)
        if time_left <= 0.0:
            _game_over()
    hit_immunity = maxf(0.0, hit_immunity - delta)
    var active_security: bool = started and not finished and not transition_in_progress and not is_instance_valid(modal_layer)
    if active_security:
        _move_player(delta)
        tracker_clock += delta
        if tracker_clock > 0.35:
            tracker_clock = 0.0
            _update_spor_indicator()
        var security: Dictionary = world.update_security(delta, player.global_position, true)
        if bool(security["spotted"]):
            alert_label.text = "● OPPDAGET AV DRONE"
            alert_label.add_theme_color_override("font_color", RED)
        else:
            alert_label.text = "● SIGNAL SKJULT"
            alert_label.add_theme_color_override("font_color", GREEN)
            shield = minf(100.0, shield + delta * 5.0)
        if int(security["strikes"]) > 0 and hit_immunity <= 0.0:
            _drone_strike()
        shield_label.text = "SKJOLD %d %%" % int(ceilf(shield))
        shield_label.add_theme_color_override("font_color", RED if shield < 35.0 else GREEN)
    else:
        world.update_security(delta, player.global_position, false)
    if active_security:
        if int(elapsed * 5.0) % 2 == 0:
            var hover: int = world.pick_terminal(cam, get_viewport().get_mouse_position())
            if hover != cursor_terminal:
                cursor_terminal = hover
                if hover >= 0:
                    Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
                    status_text = "TERMINAL %02d  //  KLIKK FOR Å ÅPNE" % (hover + 1)
                    interaction_prompt.text = "[ KLIKK FOR Å UNDERSØKE ]"
                else:
                    Input.set_default_cursor_shape(Input.CURSOR_ARROW)
                    interaction_prompt.text = ""

func _drone_strike() -> void:
    hit_immunity = 1.3
    shield = maxf(0.0, shield - 34.0)
    _sound("res://assets/error.wav")
    if shield <= 0.0:
        # A chase is a temporary obstacle, not a second failure condition.
        # Preserve collected evidence and the global 15-minute clock.
        shield = 100.0
        hit_immunity = 4.0
        player.position = SPAWN
        player.rotation = Vector3.ZERO
        cam.rotation = Vector3.ZERO
        time_left = maxf(0.0, time_left - 12.0)
        _toast("DRONE FANT DEG! RETUR TIL START · -12 SEK · SPOR BEHOLDT", true)
    else:
        _toast("SIKKERHETSDRONE ANGRIPER! SKJOLD %d %%" % int(shield), true)

func _move_player(delta: float) -> void:
    var motion := Vector3.ZERO
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
        motion -= player.transform.basis.z
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
        motion += player.transform.basis.z
    if Input.is_key_pressed(KEY_A):
        motion -= player.transform.basis.x
    if Input.is_key_pressed(KEY_D):
        motion += player.transform.basis.x
    motion.y = 0
    if motion.length() > 0.0:
        var speed: float = 8.0 if Input.is_key_pressed(KEY_SHIFT) else 4.2
        var step: Vector3 = motion.normalized() * speed * minf(delta, 0.08)
        var next_x := player.position + Vector3(step.x, 0, 0)
        if world.can_walk(next_x):
            player.position.x = next_x.x
        var next_z := player.position + Vector3(0, 0, step.z)
        if world.can_walk(next_z):
            player.position.z = next_z.z
        cam.position.y = 2.2 + sin(elapsed * 10.0) * 0.025
    else:
        cam.position.y = lerpf(cam.position.y, 2.2, minf(delta * 7, 1.0))

func _unhandled_input(event: InputEvent) -> void:
    # F12 saves a genuine screenshot, including the visible HUD or dialog.
    # F10 opens the screenshot directory in the Windows file explorer.
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F12:
            _take_screenshot()
            get_viewport().set_input_as_handled()
            return
        if event.keycode == KEY_F10:
            _open_screenshot_folder()
            get_viewport().set_input_as_handled()
            return
    if not started or finished or transition_in_progress:
        return
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and not is_instance_valid(modal_layer):
        player.rotation.y -= event.relative.x * 0.003
        cam.rotation.x = clampf(cam.rotation.x - event.relative.y * 0.003, -0.86, 0.86)
        get_viewport().set_input_as_handled()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_instance_valid(modal_layer):
        var clicked_index := world.pick_terminal(cam, event.position)
        if clicked_index >= 0:
            var terminal_pos: Vector3 = world.terminal_areas[clicked_index].global_position
            if player.global_position.distance_to(terminal_pos) <= 6.0:
                _open_terminal(clicked_index)
            else:
                _toast("GÅ NÆRMERE TERMINALEN FOR Å LESE SPORET")
            get_viewport().set_input_as_handled()
    elif event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_E and not is_instance_valid(modal_layer):
            var near_index := world.nearest_terminal(cam.global_position, 5.0)
            if near_index >= 0:
                _open_terminal(near_index)
        elif event.keycode == KEY_TAB and not is_instance_valid(modal_layer):
            _open_puzzle()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_H and not is_instance_valid(modal_layer):
            _show_hint()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE and is_instance_valid(modal_layer):
            _close_modal()

func _panel_style(fill: Color = PANEL, outline: Color = Color("1e5668"), roundness: int = 14) -> StyleBoxFlat:
    var b := StyleBoxFlat.new()
    b.bg_color = fill
    b.border_color = outline
    b.set_border_width_all(1)
    b.set_corner_radius_all(roundness)
    b.shadow_color = Color(0, 0, 0, 0.42)
    b.shadow_size = 13
    return b

func _button(caption: String, primary: bool = false, danger: bool = false) -> Button:
    var b := Button.new()
    b.text = caption
    b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
    b.custom_minimum_size = Vector2(0, 46)
    b.add_theme_font_size_override("font_size", 17)
    var accent: Color = RED if danger else (CYAN if primary else Color("3c7793"))
    var bg: Color = Color("126c7f") if primary else Color("122638")
    if danger:
        bg = Color("79304a")
    b.add_theme_color_override("font_color", PALE)
    b.add_theme_color_override("font_hover_color", Color.WHITE)
    b.add_theme_stylebox_override("normal", _panel_style(bg, accent, 8))
    b.add_theme_stylebox_override("hover", _panel_style(bg.lightened(0.18), accent.lightened(0.22), 8))
    b.add_theme_stylebox_override("pressed", _panel_style(accent.darkened(0.35), Color.WHITE, 8))
    b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    return b

func _label(content: String, sz: int = 17, color: Color = PALE) -> Label:
    var l := Label.new()
    l.text = content
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_color_override("font_color", color)
    l.add_theme_font_size_override("font_size", sz)
    return l

func _vbox(sep: int = 12) -> VBoxContainer:
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", sep)
    return v

func _hbox(sep: int = 12) -> HBoxContainer:
    var h := HBoxContainer.new()
    h.add_theme_constant_override("separation", sep)
    return h

func _pad(parent: Control, margin: int = 22) -> MarginContainer:
    var m := MarginContainer.new()
    for field in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
        m.add_theme_constant_override(field, margin)
    parent.add_child(m)
    return m

func _sep(parent: Control, color: Color = Color("24485b")) -> void:
    var c := ColorRect.new()
    c.color = color
    c.custom_minimum_size = Vector2(1, 1)
    c.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(c)

func _empty(control: Node) -> void:
    for c in control.get_children():
        control.remove_child(c)
        c.queue_free()

func _single_line_label(content: String, sz: int = 16, tone: Color = PALE) -> Label:
    var label := _label(content, sz, tone)
    label.autowrap_mode = TextServer.AUTOWRAP_OFF
    label.clip_text = true
    return label

func _hud_panel(rect: Rect2, anchoring: Vector4, bg: Color, border: Color, rounded: int = 10) -> PanelContainer:
    var panel := PanelContainer.new()
    panel.anchor_left = anchoring.x
    panel.anchor_top = anchoring.y
    panel.anchor_right = anchoring.z
    panel.anchor_bottom = anchoring.w
    panel.offset_left = rect.position.x
    panel.offset_top = rect.position.y
    panel.offset_right = rect.end.x
    panel.offset_bottom = rect.end.y
    panel.add_theme_stylebox_override("panel", _panel_style(bg, border, rounded))
    ui_root.add_child(panel)
    return panel

func _create_ui() -> void:
    ui_layer = CanvasLayer.new()
    add_child(ui_layer)
    ui_root = Control.new()
    ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_layer.add_child(ui_root)

    # Small independent HUD elements. Never place the entire HUD into one HBox:
    # this previously caused line wrapping that stretched the header across the scene.
    var brand := _hud_panel(Rect2(20, 18, 325, 63), Vector4(0, 0, 0, 0), Color(0.012, 0.032, 0.064, 0.91), Color("28526c"))
    var brand_margin := _pad(brand, 12)
    var brand_row := _hbox(11)
    brand_margin.add_child(brand_row)
    var emblem := _single_line_label("◈", 32, CYAN)
    emblem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    emblem.custom_minimum_size.x = 30
    brand_row.add_child(emblem)
    var wordmark := _vbox(2)
    wordmark.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wordmark.add_child(_single_line_label("HACKERANGREPET", 19, PALE))
    wordmark.add_child(_single_line_label("SOURCE CHECK  /  SIKKER LINJE", 11, MUTED))
    brand_row.add_child(wordmark)

    var center_status := _hud_panel(Rect2(-147, 22, 294, 52), Vector4(0.5, 0, 0.5, 0), Color(0.014, 0.04, 0.074, 0.91), Color("275974"))
    var cpad := _pad(center_status, 10)
    top_room = _single_line_label("NIVÅ 01 / 03   ·   SPOR / KILDE", 15, CYAN)
    top_room.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    top_room.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    cpad.add_child(top_room)

    var timer_panel := _hud_panel(Rect2(-184, 18, 163, 64), Vector4(1, 0, 1, 0), Color(0.014, 0.04, 0.074, 0.95), Color("28677b"))
    var tpad := _pad(timer_panel, 9)
    var timer_row := _hbox(12)
    tpad.add_child(timer_row)
    var timer_caption := _single_line_label("TID", 12, MUTED)
    timer_caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    timer_row.add_child(timer_caption)
    top_timer = _single_line_label("15:00", 28, CYAN)
    top_timer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    top_timer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    timer_row.add_child(top_timer)
    shield_label = _single_line_label("SKJOLD 100 %", 15, GREEN)
    shield_label.anchor_left = 1.0
    shield_label.anchor_right = 1.0
    shield_label.offset_left = -186
    shield_label.offset_right = -22
    shield_label.offset_top = 91
    shield_label.offset_bottom = 114
    shield_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    shield_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(shield_label)
    alert_label = _single_line_label("● SIGNAL SKJULT", 13, GREEN)
    alert_label.anchor_left = 0.5
    alert_label.anchor_right = 0.5
    alert_label.offset_left = -160
    alert_label.offset_right = 160
    alert_label.offset_top = 81
    alert_label.offset_bottom = 104
    alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    alert_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(alert_label)

    sound_button = _button("LYD: PÅ", false)
    sound_button.add_theme_font_size_override("font_size", 12)
    sound_button.anchor_left = 1.0
    sound_button.anchor_right = 1.0
    sound_button.offset_left = -277
    sound_button.offset_right = -194
    sound_button.offset_top = 27
    sound_button.offset_bottom = 69
    sound_button.pressed.connect(_toggle_audio)
    ui_root.add_child(sound_button)

    # Compact mission card in the bottom-left corner; the 3D world stays visible.
    var mission := _hud_panel(Rect2(20, -188, 337, 168), Vector4(0, 1, 0, 1), Color(0.015, 0.035, 0.071, 0.94), Color("2b586c"), 12)
    var mission_pad := _pad(mission, 13)
    side_content = _vbox(6)
    mission_pad.add_child(side_content)

    # Bottom-right navigation: short enough to read, no vertical wrapping.
    var nav := _hud_panel(Rect2(-279, -75, 259, 54), Vector4(1, 1, 1, 1), Color(0.012, 0.033, 0.064, 0.78), Color("1b4555"))
    var navpad := _pad(nav, 8)
    var navlines := _vbox(3)
    navpad.add_child(navlines)
    navlines.add_child(_single_line_label("WASD GÅ   ·   HØYRE MUS SE", 11, MUTED))
    navlines.add_child(_single_line_label("E UNDERSØK · TAB OPPGAVE · SHIFT LØP", 11, CYAN))

    interaction_prompt = _single_line_label("", 13, CYAN)
    interaction_prompt.anchor_left = 0.5
    interaction_prompt.anchor_right = 0.5
    interaction_prompt.anchor_top = 0.55
    interaction_prompt.anchor_bottom = 0.55
    interaction_prompt.offset_left = -160
    interaction_prompt.offset_right = 160
    interaction_prompt.offset_top = 0
    interaction_prompt.offset_bottom = 30
    interaction_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    interaction_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(interaction_prompt)

    # Toast notifications appear for a moment, then fade away.
    toast_container = Control.new()
    toast_container.anchor_left = 0.5
    toast_container.anchor_right = 0.5
    toast_container.anchor_top = 0
    toast_container.anchor_bottom = 0
    toast_container.offset_left = -245
    toast_container.offset_right = 245
    toast_container.offset_top = 92
    toast_container.offset_bottom = 146
    toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(toast_container)
    _draw_side()

func _draw_side() -> void:
    _empty(side_content)
    var title_row := _hbox(8)
    side_content.add_child(title_row)
    var badge := _single_line_label("ROM 0%d / 03" % current_room, 13, CYAN)
    badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_row.add_child(badge)
    var done_count: int = 0
    for flag in viewed[current_room - 1]:
        if flag:
            done_count += 1
    trace_label = _single_line_label("SPOR  %d / 3" % done_count, 13, GREEN if done_count == 3 else MUTED)
    title_row.add_child(trace_label)
    side_content.add_child(_single_line_label(ROOM_HEADINGS[current_room - 1], 16, PALE))
    mission_prompt = _single_line_label("", 12, MUTED)
    side_content.add_child(mission_prompt)
    var action_line := _hbox(8)
    side_content.add_child(action_line)
    mission_action = _button("ÅPNE OPPGAVE   ↗", true)
    mission_action.add_theme_font_size_override("font_size", 14)
    mission_action.custom_minimum_size.y = 43
    mission_action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    mission_action.pressed.connect(_open_puzzle)
    action_line.add_child(mission_action)
    var hint_button := _button("HINT", false)
    hint_button.add_theme_font_size_override("font_size", 13)
    hint_button.custom_minimum_size = Vector2(66, 43)
    hint_button.pressed.connect(_show_hint)
    action_line.add_child(hint_button)
    _draw_bottom()

func _update_spor_indicator() -> void:
    if not is_instance_valid(mission_prompt):
        return
    var distance: float = world.closest_unread_distance(player.global_position, viewed[current_room - 1])
    if distance < 0.0:
        mission_prompt.text = "ALLE 3 SPOR FUNNET · ÅPNE OPPGAVE"
    else:
        mission_prompt.text = "NÆRMESTE ULESTE SPOR: %d M" % int(ceilf(distance))

func _draw_bottom() -> void:
    if not is_instance_valid(mission_prompt):
        return
    if not started:
        mission_prompt.text = "Søk gjennom den større banen."
        mission_action.text = "START OPPDRAGET"
        mission_action.disabled = true
        return
    mission_action.disabled = false
    match current_room:
        1:
            mission_prompt.text = "Finn den første nyheten og koden."
            mission_action.text = "LÅS OPP MED KODE  ↗"
        2:
            mission_prompt.text = "Sjekk hvilket bevis som ikke holder."
            mission_action.text = "ÅPNE FILKONTROLL  ↗"
        3:
            mission_prompt.text = "Avslør tidslinjen bak videoen."
            mission_action.text = "ÅPNE TIDSLINJE  ↗"

func _open_puzzle() -> void:
    if not started or finished or transition_in_progress:
        return
    match current_room:
        1:
            _open_code_puzzle()
        2:
            _open_quarantine_puzzle()
        3:
            _open_timeline()

func _open_code_puzzle() -> void:
    var host := _create_modal("SIKKERHETSLÅS // 01", "SPOR DEN OPPRINNELIGE KILDEN", CYAN)
    host.add_child(_label("HVILKEN ARTIKKEL KOM FØRST?", 23, PALE))
    _modal_paragraph(host, "Åpne alle tre nyhetsterminalene ute i 3D-rommet. Bruk koden fra den eldste artikkelen for å låse opp neste sikkerhetsnivå.", 19)
    var read_count: int = 0
    for seen in viewed[0]:
        if seen:
            read_count += 1
    host.add_child(_label("SPOR UNDERSØKT: %d / 3" % read_count, 14, GREEN if read_count == 3 else MUTED))
    code_field = LineEdit.new()
    code_field.placeholder_text = "SKRIV INN TRESIFRET KODE"
    code_field.max_length = 3
    code_field.custom_minimum_size.y = 56
    code_field.add_theme_color_override("font_color", PALE)
    code_field.add_theme_font_size_override("font_size", 24)
    code_field.add_theme_stylebox_override("normal", _panel_style(Color("0b2135"), Color("38677a"), 7))
    code_field.text_submitted.connect(func(_value: String) -> void: _check_code())
    host.add_child(code_field)
    var check := _button("VERIFISER KODEN   →", true)
    check.pressed.connect(_check_code)
    host.add_child(check)
    var help := _button("TRENGER DU ET HINT?", false)
    help.pressed.connect(_show_hint)
    host.add_child(help)
    code_field.grab_focus.call_deferred()

func _open_quarantine_puzzle() -> void:
    var host := _create_modal("FILKONTROLL // 02", "ANALYSER PÅSTANDEN OG BEVISENE", RED)
    host.add_child(_label("HVA MÅ SETTES I KARANTENE?", 22, PALE))
    _modal_paragraph(host, "Alle tre filer ligger på terminalene ute i rommet. Velg filen med den udokumenterte påstanden. Bevisene skal bevares, ikke slettes.", 17)
    var titles := ["REKLAME.EXE", "TESTRAPPORT.PDF", "KUNDEMELDING.TXT"]
    for i in range(3):
        var choice := _button("SETT I KARANTENE: " + str(titles[i]), false)
        choice.pressed.connect(_quarantine.bind(i))
        host.add_child(choice)
    host.add_child(_label("Et feil valg er ikke farlig. Du får prøve på nytt.", 14, MUTED))
    var help := _button("TRENGER DU ET HINT?", false)
    help.pressed.connect(_show_hint)
    host.add_child(help)

func _toggle_audio() -> void:
    sound_on = not sound_on
    sound_button.text = "LYD: PÅ" if sound_on else "LYD: AV"
    if not sound_on:
        ambience_player.stop()
        sfx_player.stop()
    elif started and not finished:
        ambience_player.stream = load("res://assets/ambient.wav")
        ambience_player.play()
        _sound("res://assets/select.wav")

func _toast(message: String, warning: bool = false) -> void:
    _empty(toast_container)
    var item := PanelContainer.new()
    item.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    item.add_theme_stylebox_override("panel", _panel_style(Color("331725") if warning else Color("0c3441"), RED if warning else CYAN, 8))
    toast_container.add_child(item)
    ui_root.move_child(toast_container, ui_root.get_child_count() - 1)
    var m := _pad(item, 12)
    var label := _label(message, 16, Color.WHITE)
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    m.add_child(label)
    var t := create_tween()
    t.tween_interval(4.0)
    t.tween_property(item, "modulate:a", 0.0, 0.65)
    t.tween_callback(func() -> void:
        if is_instance_valid(item):
            item.queue_free()
    )

func _create_modal(title: String, subtitle: String, tone: Color = CYAN) -> VBoxContainer:
    _close_modal()
    modal_layer = Control.new()
    modal_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_layer.mouse_filter = Control.MOUSE_FILTER_STOP
    ui_root.add_child(modal_layer)
    var shadow := ColorRect.new()
    shadow.color = Color(0, 0.006, 0.019, 0.78)
    shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_layer.add_child(shadow)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    modal_layer.add_child(center)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(740, 510)
    panel.add_theme_stylebox_override("panel", _panel_style(Color(0.020, 0.054, 0.095, 0.99), tone, 14))
    center.add_child(panel)
    panel.modulate.a = 0.0
    create_tween().tween_property(panel, "modulate:a", 1.0, 0.22)
    var pad := _pad(panel, 26)
    var column := _vbox(18)
    pad.add_child(column)
    var h := _hbox(10)
    column.add_child(h)
    var title_label := _label(title, 31, PALE)
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    h.add_child(title_label)
    var close := _button("✕", false)
    close.custom_minimum_size = Vector2(48, 46)
    close.pressed.connect(_close_modal)
    h.add_child(close)
    column.add_child(_label(subtitle, 13, tone))
    _sep(column, tone.darkened(0.5))
    return column

func _close_modal() -> void:
    if is_instance_valid(modal_layer):
        var old := modal_layer
        modal_layer = null
        old.get_parent().remove_child(old)
        old.queue_free()

func _modal_paragraph(host: VBoxContainer, content: String, size: int = 17) -> void:
    var label := _label(content, size, PALE)
    label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    host.add_child(label)

func _show_intro() -> void:
    var host := _create_modal("23:47  //  INNBRUDD OPPDAGET", "KLASSIFISERT // NIVÅ 0  ·  SYSTEMET TRENGER DEG", RED)
    host.add_child(_label("H A C K E R A N G R E P E T", 38, CYAN))
    _modal_paragraph(host, "En hacker har brutt seg inn i et oppdiktet nyhetssystem. Falske og misvisende opplysninger sprer seg. Du er den siste digitale etterforskeren som kan stoppe angrepet.\n\nDu har 15 minutter og tre sikkerhetsrom. Finn den opprinnelige kilden, undersøk bevisene, og avslør en video som deles med feil forklaring.", 19)
    host.add_child(_label("3 STØRRE ROM   •   SIKKERHETSDRONER   •   15 MINUTTER", 15, MUTED))
    host.add_child(_label("WASD: gå  |  Shift: løp  |  Høyre mus: se  |  E: undersøk  |  Unngå sikkerhetsdronene", 15, PURPLE))
    var go := _button("▶  START OPPDRAGET", true)
    go.pressed.connect(_start_game)
    host.add_child(go)
    host.add_child(_label("Alle artikler, filer, hendelser og personer i spillet er oppdiktet.", 13, MUTED))

func _start_game() -> void:
    started = true
    finished = false
    time_left = DURATION
    shield = 100.0
    hit_immunity = 3.0
    _close_modal()
    _draw_side()
    ambience_player.stream = load("res://assets/ambient.wav")
    if sound_on:
        ambience_player.play()
    _sound("res://assets/start.wav")
    _toast("SIKKER LINJE ÅPNET // UNDERSØK DE TRE SKJERMENE")

func _open_terminal(index: int) -> void:
    if not started or finished:
        return
    _sound("res://assets/select.wav")
    viewed[current_room - 1][index] = true
    world.set_opened(viewed[current_room - 1])
    _draw_side()
    var tone: Color = CYAN if current_room == 1 else (RED if current_room == 2 else PURPLE)
    var title: String = str(TERMINAL_TITLES[current_room - 1][index])
    var host := _create_modal("INTEL // " + title, str(TERMINAL_META[current_room - 1][index]), tone)
    host.add_child(_label("DEKRYPTERT INFORMASJON  //  ØVELSESMATERIALE", 14, tone))
    _modal_paragraph(host, str(TERMINAL_COPY[current_room - 1][index]), 19)
    if current_room == 3 and index == 0:
        host.add_child(_label("BAK TERMINALEN: En oransje 3D-hologrameksplosjon visualiserer filmeffekten. Den er laget som en simulering, ikke som ekte nyhetsvideo.", 14, MUTED))
    var buttons := _hbox(10)
    host.add_child(buttons)
    var close := _button("LUKK DOKUMENT", false)
    close.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    close.pressed.connect(_close_modal)
    buttons.add_child(close)
    var next := _button("FORTSETT ETTERFORSKNING  →", true)
    next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    next.pressed.connect(_close_modal)
    buttons.add_child(next)

func _all_seen() -> bool:
    var room_viewed: Array = viewed[current_room - 1]
    return room_viewed[0] and room_viewed[1] and room_viewed[2]

func _check_code() -> void:
    if not _all_seen():
        _sound("res://assets/error.wav")
        _toast("ÅPNE ALLE TRE ARTIKLENE FØR DU SVARER.", true)
        return
    var value := code_field.text.strip_edges()
    if value == "417":
        _room_solved("KILDEN ER SPORET", "Du fulgte nyheten tilbake til Dalnytt kl. 09:00. De to andre artiklene bygde videre på samme opplysning. Husk: Den første kilden er ikke nødvendigvis en sann kilde.", "▶  FORTSETT TIL ROM 2", 2)
    else:
        _sound("res://assets/error.wav")
        _toast("FEIL KODE. FINN DEN FØRSTE ARTIKKELEN OG LES KODEN.", true)

func _quarantine(index: int) -> void:
    if not _all_seen():
        _sound("res://assets/error.wav")
        _toast("DU MÅ UNDERSØKE ALLE TRE FILENE FØRST.", true)
        return
    if index == 0:
        world.set_cleaned()
        _room_solved("SYSTEMRENSING FULLFØRT", "Reklame.exe er satt i karantene, ikke slettet. Den lovet 500 % raskere datamaskin, mens testen bare undersøkte oppstarten av ett program på én maskin (fra 10 til 8 sekunder). Påstanden støttes ikke av bevisene.", "▶  FORTSETT TIL ROM 3", 3)
    else:
        _sound("res://assets/error.wav")
        _toast("DEN FILEN ER ET SPOR, IKKE DEN VILLEDENDE REKLAMEN. PRØV IGJEN.", true)

func _room_solved(title: String, reason: String, next_button: String, next_room: int) -> void:
    _sound("res://assets/success.wav")
    var host := _create_modal("✓  " + title, "SIKKERHETSNIVÅ FULLFØRT  //  GODKJENT", GREEN)
    host.add_child(_label("BEVISET ER FUNNET", 35, GREEN))
    _modal_paragraph(host, reason, 20)
    host.add_child(_label("LÆRINGSMÅL OPPNÅDD    //    KLOKKEN FORTSETTER Å GÅ", 14, MUTED))
    var b := _button(next_button, true)
    b.pressed.connect(_advance_room.bind(next_room))
    host.add_child(b)

func _advance_room(next_room: int) -> void:
    if transition_in_progress:
        return
    transition_in_progress = true
    _close_modal()
    _sound("res://assets/start.wav")
    var veil := ColorRect.new()
    veil.color = Color(0, 0.01, 0.04, 0)
    veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    veil.mouse_filter = Control.MOUSE_FILTER_STOP
    ui_root.add_child(veil)
    var fade := create_tween()
    fade.tween_property(veil, "color:a", 1.0, 0.46)
    fade.tween_callback(func() -> void:
        current_room = next_room
        world.build_room(current_room)
        world.set_opened(viewed[current_room - 1])
        player.position = SPAWN
        shield = 100.0
        hit_immunity = 3.0
        player.rotation = Vector3.ZERO
        cam.rotation = Vector3.ZERO
        top_room.text = "NIVÅ 0%d / 03   ·   %s" % [current_room, ROOM_NAMES[current_room - 1]]
        cursor_terminal = -1
        interaction_prompt.text = ""
        _draw_side()
    )
    fade.tween_property(veil, "color:a", 0.0, 0.65)
    fade.tween_callback(func() -> void:
        if is_instance_valid(veil):
            veil.queue_free()
        transition_in_progress = false
        _toast("NIVÅ 0%d AKTIVERT  //  FINN ALLE TRE SPOR" % current_room)
    )

func _show_hint() -> void:
    var n: int = current_room - 1
    hint_counts[n] = mini(2, hint_counts[n] + 1)
    _sound("res://assets/select.wav")
    var hint_text: String = HINTS[n][hint_counts[n] - 1]
    var host := _create_modal("ETTERFORSKERENS HINT", "SIKKER TILGANG   //   TRINN %d AV 2" % hint_counts[n], PURPLE)
    host.add_child(_label("TIPS FRA SYSTEMET", 28, PURPLE))
    _modal_paragraph(host, hint_text, 23)
    host.add_child(_label("Et hint trekker ikke fra tiden. Nedtellingen går fortsatt.", 15, MUTED))
    var close := _button("TILBAKE TIL OPPDRAGET", true)
    close.pressed.connect(_close_modal)
    host.add_child(close)

func _open_timeline() -> void:
    if not _all_seen():
        _sound("res://assets/error.wav")
        _toast("SE ALLE TRE SPOR FØR DU ÅPNER TIDSLINJEN.", true)
        return
    _sound("res://assets/select.wav")
    _render_timeline()

func _render_timeline() -> void:
    var host := _create_modal("DIGITAL TIDSLINJE", "SISTE SIKKERHETSLÅS // FRA ELDST TIL NYEST", PURPLE)
    host.add_child(_label("FLYTT HENDELSENE I RIKTIG REKKEFØLGE", 19, PALE))
    for i in range(3):
        var item: int = timeline_order[i]
        var row := _hbox(12)
        host.add_child(row)
        var num := _label("0%d" % (i + 1), 25, PURPLE)
        num.custom_minimum_size = Vector2(48, 55)
        num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        row.add_child(num)
        var card := PanelContainer.new()
        card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        card.add_theme_stylebox_override("panel", _panel_style(Color("0c213b"), Color("344967"), 7))
        row.add_child(card)
        var pad := _pad(card, 9)
        var cell := _vbox(2)
        pad.add_child(cell)
        var label: String = ["VIDEOEN BLIR LAGET", "ARKIVET PUBLISERER VIDEOEN", "HACKEREN DELER NYHETEN"][item]
        var date: String = ["2023 // FILMEFFEKT", "2023 // ARKIV", "2026 // FEIL FORKLARING"][item]
        cell.add_child(_label(label, 17, PALE))
        cell.add_child(_label(date, 13, MUTED))
        var controls := _vbox(3)
        row.add_child(controls)
        var up := _button("▲", false)
        up.custom_minimum_size = Vector2(45, 26)
        up.disabled = i == 0
        up.pressed.connect(_timeline_move.bind(i, -1))
        controls.add_child(up)
        var down := _button("▼", false)
        down.custom_minimum_size = Vector2(45, 26)
        down.disabled = i == 2
        down.pressed.connect(_timeline_move.bind(i, 1))
        controls.add_child(down)
    var check := _button("✓  KONTROLLER TIDSLINJEN", true)
    check.pressed.connect(_check_timeline)
    host.add_child(check)
    host.add_child(_label("TIPS: To hendelser skjedde i 2023, men den ene skjedde før den andre.", 14, MUTED))

func _timeline_move(index: int, direction: int) -> void:
    var target: int = index + direction
    if target < 0 or target >= 3:
        return
    var temp: int = timeline_order[index]
    timeline_order[index] = timeline_order[target]
    timeline_order[target] = temp
    _sound("res://assets/select.wav")
    _render_timeline()

func _check_timeline() -> void:
    if timeline_order == [0, 1, 2]:
        timeline_solved = true
        _sound("res://assets/success.wav")
        var host := _create_modal("✓  VIDEOEN ER AVSLØRT", "SISTE SIKKERHETSNIVÅ GODKJENT", GREEN)
        host.add_child(_label("SANNHETEN ER GJENOPPRETTET", 32, GREEN))
        _modal_paragraph(host, "Opptaket ble laget som en filmeffekt og publisert i 2023. I 2026 delte hackeren det som om en virkelig eksplosjon nettopp hadde skjedd.\n\nVideoen behøvde ikke være forfalsket. Den var brukt med feil dato og forklaring. Et ekte bilde eller klipp kan derfor brukes til å villede.", 19)
        host.add_child(_label("KILDER  ✓      BEVIS  ✓      KONTEKST  ✓", 18, CYAN))
        var stop := _button("◈  STOPP HACKERANGREPET", true)
        stop.pressed.connect(_finish_game)
        host.add_child(stop)
    else:
        _sound("res://assets/error.wav")
        _toast("FEIL REKKEFØLGE. VIDEOEN BLE LAGET FØR DEN BLE PUBLISERT.", true)

func _finish_game() -> void:
    finished = true
    _close_modal()
    ambience_player.stop()
    _sound("res://assets/success.wav")
    world.set_cleaned()
    var host := _create_modal("HACKERANGREPET STOPPET", "OPPDRAG FULLFØRT  //  ALLE TRE NIVÅ GODKJENT", GREEN)
    host.add_child(_label("DU KLARTE DET!", 47, GREEN))
    host.add_child(_label("GJENSTÅENDE TID: %02d:%02d" % [int(time_left / 60.0), int(time_left) % 60], 25, CYAN))
    _modal_paragraph(host, "ROM 1  ✓  Finn den opprinnelige kilden.\nROM 2  ✓  Se om bevisene støtter påstanden.\nROM 3  ✓  Kontroller dato og sammenheng.\n\nNyhetssystemet er sikret. Angrepet er stoppet.", 20)
    var message := _label("INNKOMMENDE MELDING ...", 17, MUTED)
    host.add_child(message)
    var restart := _button("↻  SPILL PÅ NYTT", true)
    restart.pressed.connect(_restart)
    host.add_child(restart)
    var cinematic := create_tween()
    cinematic.tween_interval(2.8)
    cinematic.tween_callback(func() -> void:
        if finished and is_instance_valid(message):
            message.text = "«DETTE VAR BARE BEGYNNELSEN ...»"
            message.add_theme_color_override("font_color", RED)
            _sound("res://assets/alarm.wav")
    )

func _game_over() -> void:
    finished = true
    _sound("res://assets/error.wav")
    ambience_player.stop()
    var host := _create_modal("TIDEN ER UTE", "SIKKERHETSLÅSEN BLE IKKE ÅPNET I TIDE", RED)
    host.add_child(_label("00:00 // FORBINDELSE BRUTT", 37, RED))
    _modal_paragraph(host, "Du rakk ikke å sikre alle tre rommene innen 15 minutter. Men kildene og sporene finnes fortsatt. Prøv igjen og bruk det du har lært.", 22)
    var b := _button("↻  PRØV PÅ NYTT", true)
    b.pressed.connect(_restart)
    host.add_child(b)

func _restart() -> void:
    viewed = [[false, false, false], [false, false, false], [false, false, false]]
    hint_counts = [0, 0, 0]
    timeline_order = [2, 0, 1]
    timeline_solved = false
    current_room = 1
    time_left = DURATION
    shield = 100.0
    hit_immunity = 0.0
    tracker_clock = 0.0
    if is_instance_valid(shield_label):
        shield_label.text = "SKJOLD 100 %"
    started = false
    finished = false
    transition_in_progress = false
    cursor_terminal = -1
    interaction_prompt.text = ""
    player.position = SPAWN
    player.rotation = Vector3.ZERO
    cam.rotation = Vector3.ZERO
    top_room.text = "NIVÅ 01 / 03   ·   SPOR / KILDE"
    world.build_room(1)
    _draw_side()
    _close_modal()
    _show_intro()


# Screenshots are always taken from the real running game, not mock-ups.
func _screenshot_directory() -> String:
    return ProjectSettings.globalize_path("user://screenshots")

func _take_screenshot() -> void:
    var directory: String = _screenshot_directory()
    var make_result: Error = DirAccess.make_dir_recursive_absolute(directory)
    if make_result != OK:
        push_warning("Kunne ikke opprette mappe for skjermbilder: " + directory)
        return
    await RenderingServer.frame_post_draw
    var stamp: String = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
    var image_path: String = directory.path_join("Hackerangrepet_%s.png" % stamp)
    var save_result: Error = get_viewport().get_texture().get_image().save_png(image_path)
    if save_result == OK:
        _toast("SKJERMBILDE LAGRET  //  TRYKK F10 FOR MAPPE")
        print("[Hackerangrepet] Skjermbilde: " + image_path)
    else:
        push_warning("Kunne ikke lagre skjermbilde: " + image_path)

func _open_screenshot_folder() -> void:
    var directory: String = _screenshot_directory()
    DirAccess.make_dir_recursive_absolute(directory)
    OS.shell_open("file://" + directory.replace("\\", "/"))