@tool
extends Node2D


var auto_pattern_id:String = ""
var auto_start_on_cam:bool = true : set = _set_start_on_cam
var auto_start_after_time:float = 0.0
var auto_start_at_distance:float = 5 : set = _set_start_at_dist
var auto_distance_from:NodePath
var trigger_container:NodePath

var trig_container:TriggerContainer
var trigger_counter = 0
var trig_iter:Dictionary
var trigger_timeout:bool = false
var trigger_time:float = 0
var trig_collider
var trig_signal

var rotating_speed = 0.0
var active:bool = true
var shared_area_name = "0"
var shared_area
var pool_amount:int = 50

var was_on_cam = false
var was_at_dist = false
var was_at_time = false
var can_respawn:bool = true

func _ready():
	if Engine.is_editor_hint(): return
	set_physics_process(false)
	
	if shared_area_name != "":
		shared_area = Spawning.get_shared_area(shared_area_name)
	else: push_error("Spawnpoint doesn't have any shared_area")
	
	assert(auto_pattern_id != "")
	# setup spawning conditions
	if active:
		if auto_start_on_cam: _set_start_on_cam(true)
		if auto_distance_from != NodePath(): set_physics_process(true)
		if not (auto_start_on_cam or auto_distance_from != NodePath()) and auto_start_after_time > float(0.0):
			await get_tree().create_timer(auto_start_after_time, false).timeout
			was_at_time = true
		
	if rotating_speed > 0: set_physics_process(active)
		
	if active and pool_amount > 0:
		call_deferred("set_pool")
		
	if trigger_container:
		trig_container = get_node(trigger_container)
#		set_physics_process(false)

func set_pool():
	var props = Spawning.pattern(auto_pattern_id)["bullet"]
	Spawning.create_pool(props, shared_area_name, pool_amount, Spawning.bullet(props).has("instance_id"))

#func _process(delta):
	#rotation += rotating_speed

var _delta:float
func _physics_process(delta):
	if Engine.is_editor_hint(): return
	_delta = delta
	#rotate(rotating_speed)
	rotation += rotating_speed * 100 * delta
	if trig_container:
		checkTrigger()
		return
	
	# can spawn
	if can_respawn and check_can_spawn() and active:
		call_deferred("callAction")
		can_respawn = false
		if not rotating_speed > 0: set_physics_process(false)
		#apply_randomness(false)
	elif was_at_dist == false and auto_distance_from != NodePath() and \
			global_position.distance_to(get_node(auto_distance_from).global_position) <= auto_start_at_distance:
		if auto_start_after_time > float(0.0):
			await get_tree().create_timer(auto_start_after_time, false).timeout
			was_at_time = true
		was_at_dist = true

func check_can_spawn():
	return (!auto_start_on_cam or was_on_cam) and (auto_distance_from == NodePath() or was_at_dist) and (auto_start_after_time == float(0.0) or was_at_time)

func on_screen(is_on):
	if was_on_cam: return
	if is_on and auto_start_after_time > float(0.0):
		await get_tree().create_timer(auto_start_after_time, false).timeout
		was_at_time = true
	was_on_cam = true
	set_physics_process(active)

func triggerSignal(sig):
	trig_signal = sig
	checkTrigger()

func trig_timeout(time:float=0):
	trigger_time += _delta
	if trigger_time >= time:
		trigger_timeout = true
		trigger_time = 0
		return true
	return false
#	checkTrigger()

func checkTrigger():
	if not (active and auto_pattern_id != "" and trig_container): return
	trig_container.checkTriggers(self, self)
#		Spawning.spawn(self, auto_pattern_id, shared_area_name)

var vis:VisibleOnScreenNotifier2D
func _set_start_on_cam(value):
	auto_start_on_cam = value
	if Engine.is_editor_hint(): return
	if not auto_start_on_cam or vis != null: return
	vis = VisibleOnScreenNotifier2D.new()
	vis.connect("screen_entered",Callable(self,"on_screen").bind(true))
	vis.connect("screen_exited",Callable(self,"on_screen").bind(false))
	call_deferred("add_child", vis)
	
func _set_start_at_dist(value):
	auto_start_at_distance = value
	if Engine.is_editor_hint(): return
	set_physics_process(value)

func callAction():
	Spawning.spawn(self, auto_pattern_id, shared_area_name)

func _get_property_list() -> Array:
	return [
		{
			name = "active",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_pattern_id",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "shared_area_name",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "rotating_speed",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "pool_amount",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Autostart & Triggering",
			type = TYPE_NIL,
			hint_string = "auto_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "auto_start_on_cam",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_start_after_time",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_start_at_distance",
			type = TYPE_FLOAT,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "auto_distance_from",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		},{
			name = "Advanced Triggering",
			type = TYPE_NIL,
			hint_string = "trigger_",
			usage = PROPERTY_USAGE_GROUP
		},{
			name = "trigger_container",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]
