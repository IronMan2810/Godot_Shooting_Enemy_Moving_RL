@tool
extends StaticBody3D
class_name Enemy


signal transform_changed
signal bullet_collision

const _base_texture_folder = "res://addons/devblocks/textures/"

enum DEVBLOCK_COLOR_GROUP {DARK, GREEN, LIGHT, ORANGE, PURPLE, RED}
const _devblock_color_to_foldername := [
	"dark",
	"green",
	"light",
	"orange",
	"purple",
	"red"
]
# Looks very bad, eh

@export var block_color_group : DEVBLOCK_COLOR_GROUP = DEVBLOCK_COLOR_GROUP.DARK :
	set(value):
		block_color_group = value
		_update_mesh()

enum DEVBLOCK_STYLE {
	DEFAULT,
	CROSS,
	CONTRAST,
	DIAGONAL,
	DIAGONAL_FADED,
	GROUPED_CROSS,
	GROUPED_CHECKERS,
	CHECKERS,
	CROSS_CHECKERS,
	STAIRS,
	DOOR,
	WINDOW,
	INFO
}

@export var block_style : DEVBLOCK_STYLE = DEVBLOCK_STYLE.DEFAULT :
	set(value):
		block_style = value
		_update_mesh()


@onready var _mesh : MeshInstance3D = $Mesh

var min_x = -10
var max_x = 10
var min_y = -10
var max_y = 10
var go_left = true
var moving_range = 5

func _ready():
	var data = {
	player_level = 42,
	last_item = "sword"
	}
	
	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	# Set the player's position to the random coordinates
	#set_position(Vector3(random_x, 0, random_y))
	
	_mesh.set_surface_override_material(0, load("res://addons/devblocks/blocks/block_material.tres").duplicate(true))
	_update_mesh()
	_update_uvs()
	_mesh.set_notify_local_transform(true)
	transform_changed.connect(Callable(self, "_update_uvs"))
	bullet_collision.connect(Callable(self, "_on_bullet_collision"))

func _notification(what : int):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		transform_changed.emit()


func _physics_process(delta):
	if not Engine.is_editor_hint():
		if go_left:
			self.position.z += 5* delta
		else:
			self.position.z -= 5 * delta
		if self.position.z > moving_range:
			go_left = false
		if self.position.z < -moving_range:
			go_left = true

func _update_mesh() -> void:
	if not _mesh:
		return
	var mat := _mesh.get_surface_override_material(0)
	if not mat:
		return
	
	
	var texture_i : int = block_style + 1
	var texture_i_str : String = ("0" if texture_i < 10 else "") + str(texture_i)
	var texture_name := "texture_" + texture_i_str
	var texture_folder :String = _devblock_color_to_foldername[block_color_group]
	var full_texture_path :String = _base_texture_folder + texture_folder + "/" + texture_name + ".png"
	var texture : Resource = load(full_texture_path)
	if not (texture is Texture):
		return
	
	_mesh.get_surface_override_material(0).set("albedo_texture", texture as Texture)

func _update_uvs() -> void:
	var mat = _mesh.get_surface_override_material(0)
	var offset := Vector3()
	for i in range(3):
		var different_offset := fmod(scale[i], 2.0) >= 0.99
		var different_offset2 := fmod(scale[i], 1.0) >= 0.49
		offset[i] = (0.5 if different_offset else 1) - (0.25 if different_offset2 else 0.0)
	mat.set("uv1_scale", scale)
	mat.set("uv1_offset", offset)
	
func _on_bullet_collision():
	queue_free()

