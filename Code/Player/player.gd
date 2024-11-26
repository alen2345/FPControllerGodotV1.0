extends CharacterBody3D

##Public Variables##
@export_category("Player Properties")
@export_subgroup("Locomotion")
@export var mspeed : float = 3.8
@export var macceleration : float = 40
@export var mdeacceleration : float = 80
@export_subgroup("Camera")
@export var mouse_sens : float = 0.065
@export var camera : Camera3D
@export var cam_rot : Node3D
@export_subgroup("Animation")
@export var anim : AnimationPlayer
@export_subgroup("Stats")
@export var health = 100
@export_subgroup("Raycast")
@export var feetCast : RayCast3D

##Private Variables##
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var dir = Vector3.ZERO

func _ready() -> void:
	_mouse_lock()

func _mouse_lock():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	_mouse_look(event)

func _mouse_look(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		cam_rot.rotate_x(deg_to_rad(event.relative.y * mouse_sens * -1))
		self.rotate_y(deg_to_rad(event.relative.x * mouse_sens * -1))
		
		var camera_rot = cam_rot.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		cam_rot.rotation = camera_rot
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	_player_movement_logic(delta)

func _player_movement_logic(delta):
	var moving = false
	var accel
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if dir.dot(velocity) > 0:
		accel = macceleration
		moving = true
	else:
		accel = mdeacceleration
		moving = false
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * mspeed, macceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * mspeed, macceleration * delta)
		anim.play("camera_moving")
	else:
		velocity.x = move_toward(velocity.x, 0, mdeacceleration * delta)
		velocity.z = move_toward(velocity.z, 0, mdeacceleration * delta)
		anim.get_blend_time("camera_moving", "RESET")
		anim.set_blend_time("camera_moving", "RESET", 0.5)
	
	move_and_slide()
