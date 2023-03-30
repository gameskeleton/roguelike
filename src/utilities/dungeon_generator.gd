class_name RkDungeonGenerator

var rng := RandomNumberGenerator.new()
var start := 45 # x: 5, y: 4
var min_rooms := 20
var max_rooms := 25
var end_rooms: Array[int] = []

var _floorplan: Array[int] = []
var _cell_queue: Array[int] = []
var _floor_plan_count := 0

func next() -> Array[int]:
	while true:
		if _cell_queue.size() > 0:
			var i: int = _cell_queue.pop_back()
			var x: int = i % 10
			var created := false
			if x > 1: created = created || _visit_cell(i - 1)
			if x < 9: created = created || _visit_cell(i + 1)
			if i > 20: created = created || _visit_cell(i - 10)
			if i < 70: created = created || _visit_cell(i + 10)
			if not created:
				end_rooms.push_back(i)
		else:
			if _floor_plan_count < min_rooms:
				_reset()
			else:
				return _floorplan.duplicate()
	return []

func _reset():
	end_rooms.clear()
	_cell_queue.clear()
	_floorplan.clear()
	_floorplan.resize(100)
	_floor_plan_count = 0
	for i in 100:
		_floorplan[i] = 0
	_visit_cell(start)

func _visit_cell(i: int):
	if _floorplan[i] == 1:
		return false
	if _floor_plan_count >= max_rooms:
		return false
	if _neighbour_count(i) > 1:
		return false
	if rng.randf() < 0.5 && i != start:
		return false
	_floorplan[i] = 1
	_cell_queue.push_back(i)
	_floor_plan_count += 1
	return true

func _neighbour_count(i: int):
	return _floorplan[i - 10] + _floorplan[i - 1] + _floorplan[i + 1] + _floorplan[i + 10]
