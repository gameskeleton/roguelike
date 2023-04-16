class_name RkDungeonGenerator

var rng := RandomNumberGenerator.new()
var start := Vector2i(0, 0)
var width := 5
var height := 5
var min_rooms := 12
var max_rooms := 19
var end_rooms: Array[Vector2i] = []

var _cells: Array[Array] = []
var _cell_queue: Array[Vector2i] = []
var _cells_count := 0

# next returns a new dungeon of the given width/height.
# note: the resulting dungeon is padded with an additional row/column for avoiding border checks.
# @impure
func next() -> Array[Array]:
	_reset()
	while true:
		if _cell_queue.size() > 0:
			var pos: Vector2i = _cell_queue.pop_back()
			var created := false
			if pos.x > 1:
				created = _visit_cell(pos + Vector2i.LEFT) || created
			if pos.x > 0 and pos.x < width:
				created = _visit_cell(pos + Vector2i.RIGHT) || created
			if pos.y > 1:
				created = _visit_cell(pos + Vector2i.UP) || created
			if pos.y > 0 and pos.y < height:
				created = _visit_cell(pos + Vector2i.DOWN) || created
			if not created:
				end_rooms.push_back(pos)
		else:
			if _cells_count >= min_rooms:
				return _cells.duplicate(true)
			_reset()
	return []

func _reset():
	end_rooms.clear()
	_cells.resize(height + 2)
	_cell_queue.clear()
	_cells_count = 0
	for y in height + 2:
		_cells[y].resize(width + 2)
		for x in width + 2:
			_cells[y][x] = 0
	_visit_cell(start + Vector2i(1, 1))

func _visit_cell(pos: Vector2i):
	if _cells[pos.y][pos.x] == 1:
		return false
	if _cells_count >= max_rooms:
		return false
	if _neighbour_count(pos) > 1:
		return false
	if rng.randf() < 0.5 and pos != start:
		return false
	_cells[pos.y][pos.x] = 1
	_cell_queue.push_back(pos)
	_cells_count += 1
	return true

func _neighbour_count(pos: Vector2i):
	return _cells[pos.y - 1][pos.x] + _cells[pos.y + 1][pos.x] + _cells[pos.y][pos.x - 1] + _cells[pos.y][pos.x + 1]
