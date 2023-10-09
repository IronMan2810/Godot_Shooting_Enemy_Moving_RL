extends Node
var pid = 0
var epoch = 0
var state_num = 0
var peer: StreamPeerTCP
var first_time = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var doFileExists = FileAccess.file_exists("./info_models/info.txt")
	if doFileExists:
		var file = FileAccess.open("./info_models/info.txt", FileAccess.READ)
		var content = file.get_as_text()
		var lines = content.split('\n')
		epoch = int(lines[1].split(' ')[-1])
		state_num = int(lines[-1].split(' ')[-1])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
