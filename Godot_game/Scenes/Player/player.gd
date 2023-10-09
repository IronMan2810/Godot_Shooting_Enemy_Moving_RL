extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
var _bullet_scene = preload("res://Scenes/Bullet/Bullet.tscn")
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
var damage = 10
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var bullets_left = 100
var total_reward = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var agent_name
var agent_n
var frame_left = 500
var server := TCPServer.new()
var t = "Agent%d: Total Reward: %d, State: %d \n    Frame Left: %d, Enemy_pos_z %.2f, Player_rot_y %.2f Action: %s"
@onready var enemy = get_parent().get_parent().get_node("Enemy")


func _ready():
	#Captures mouse and stops rgun from hitting yourself
	agent_name = get_parent().name
	agent_n = int(agent_name.split("agent")[-1])
	$Agent_n.text = str(agent_n)
	$Info.text = t % [agent_n, total_reward, GlobalVars.state_num, frame_left, enemy.position.z, self.rotation.y, ""]
	$Info.position.y += (agent_n - 1) * 50
	gunRay.add_exception(self)
	$Is_touch_enemy.add_exception(self)
	$Is_touch_enemy.add_exception(get_parent().get_parent().get_node("Floor"))
#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_process_input(true)
	add_to_group("Players")
	server.listen(4240 + agent_n)

func _process(delta):
	var action = ''
	if server.is_connection_available():
		GlobalVars.peer = server.take_connection()
		save_state(0, 0)
	if GlobalVars.peer:
		action = GlobalVars.peer.get_utf8_string(GlobalVars.peer.get_available_bytes())
	if action == '' or action == 'starting':
		return
	frame_left -= 1
	play_action(action)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
		
func play_action(action):
	var done = 0
	if frame_left == 0:
		done = 1
	if action == "shoot":
		shoot()
		$Info.text = t % [agent_n, total_reward, GlobalVars.state_num, frame_left, enemy.position.z, self.rotation.y, action]
		return
	elif action == "left":
		rotation.y -= -100.0 / mouseSensibility
		$Head.rotation.x -= 0.0 / mouseSensibility
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	elif action == "right":
		rotation.y -= 100.0 / mouseSensibility
		$Head.rotation.x -= 0.0 / mouseSensibility
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	$Info.text = t % [agent_n, total_reward, GlobalVars.state_num, frame_left, enemy.position.z, self.rotation.y, action]	
	save_state(0, done)

func _input(event):
#	if event.is_action_pressed("Shoot"):
#		shoot()
#	if event is InputEventMouseMotion:
	if false:
		rotation.y -= event.relative.x / mouseSensibility
		$Head.rotation.x -= event.relative.y / mouseSensibility
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)


func shoot():
	var reward = 0
	var done = 0
	if frame_left == 0:
		done = 1
	if not gunRay.is_colliding():
		total_reward += reward
		save_state(reward, done)
		return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)
	var collided_object = gunRay.get_collider()
	if collided_object and collided_object.name == "Enemy":
#			collided_object.emit_signal("bullet_collision")
		reward = 5
		total_reward += reward
		save_state(reward, done)
	

func save_state(reward, done):
	var data_to_send = {
		"reward" : reward,
		"player_rotation_y" : self.rotation.y,
		"enemy_pos_z" : enemy.position.z,
		"done" : done,
	}
	var json_string = JSON.stringify(data_to_send)
	GlobalVars.peer.put_data(json_string.to_utf8_buffer())
	GlobalVars.state_num += 1
