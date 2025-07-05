extends Node2D

# how many body‑tiles tall each pipe is
@onready var coin: Area2D = $coin

var pipe_height = 15
var gap = 5
var spawn_x = -30
var min_center_y = -2
var max_center_y = 1
var speed=100


var FLIP_V = TileSetAtlasSource.TRANSFORM_FLIP_V
@onready var tile_map: TileMap = $TileMap

# these must be the *integer* tile IDs from your TileSet,
# not Vector2i’s.  Look in the TileSet inspector for each tile’s ID:
var bodyTile = Vector2i(2,15)
var headTile = Vector2i(2,17)

func PipeSpawner():
	print("spawned pepe ")
	# pick a random vertical center for the gap
	var center_y = randi_range(min_center_y, max_center_y)
	coin.position = tile_map.map_to_local(Vector2i(spawn_x, center_y-1))
	# bottom pipe: head at bottom gap edge, bodies below
	var bottom_head_y = center_y - gap / 2 - 1
	tile_map.set_cell(0, Vector2i(spawn_x, bottom_head_y), 0, headTile, 0)
	for i in range(pipe_height):
		tile_map.set_cell(
			0,
			Vector2i(spawn_x, bottom_head_y - 1 - i),
			0,
			bodyTile,
			0
		)

	# top pipe: flipped head at top gap edge, bodies above
	var top_head_y = center_y + gap / 2
	tile_map.set_cell(0, Vector2i(spawn_x, top_head_y), 0, headTile, FLIP_V)
	for i in range(pipe_height):
		tile_map.set_cell(
			0,
			Vector2i(spawn_x, top_head_y + 1 + i),
			0,
			bodyTile,
			FLIP_V
		)

func _ready() -> void:
	PipeSpawner()

func _process(delta):
	position.x -= speed * delta
	if position.x<0:
		queue_free()
