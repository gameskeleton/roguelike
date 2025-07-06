@tool
extends Node2D
class_name RkLevel

const TILE_SIZE := Vector2i(16, 16)
const CORNER_CUSTOM_DATA_LAYER_NAME := &"Corner"

@export_group("Nodes")
@export var wall_tile_map_layer: TileMapLayer
@export var one_way_tile_map_layer: TileMapLayer

# has_corner_tile returns true if there is a corner tile at the given position.
# @pure
func has_corner_tile(pos: Vector2) -> bool:
	var data := wall_tile_map_layer.get_cell_tile_data(wall_tile_map_layer.local_to_map(pos))
	return data and data.get_custom_data(CORNER_CUSTOM_DATA_LAYER_NAME) == true

# get_corner_tile_pos returns the top-center position of the corner tile.
# note: calling this when has_corner_tile of the given position is false will yield incorrect results.
# @pure
func get_corner_tile_pos(pos: Vector2) -> Vector2:
	assert(has_corner_tile(pos), "get_corner_tile_pos called without checking if has_corner_tile")
	return wall_tile_map_layer.map_to_local(wall_tile_map_layer.local_to_map(pos))

# get_wall_bbox returns the bounding box of this level.
# note: this takes only into account tiles in the wall tile map layer.
# @pure
func get_wall_bbox() -> Rect2:
	var used_rect := wall_tile_map_layer.get_used_rect()
	return Rect2(position + Vector2(used_rect.position), used_rect.size * TILE_SIZE)

# get_wall_tiles returns the position of all wall tiles in this level's tilemap.
# @pure
func get_wall_tiles() -> Array[Vector2i]:
	return wall_tile_map_layer.get_used_cells()

# get_one_way_tiles returns the position of all one way tiles in this level's tilemap.
# @pure
func get_one_way_tiles() -> Array[Vector2i]:
	return one_way_tile_map_layer.get_used_cells()
