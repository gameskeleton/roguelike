class_name RkUtils

# pick_random returns a random item in the given array using the given rng.
# @impure
static func pick_random(arr: Array, rng: RandomNumberGenerator):
	return arr[rng.randi_range(0, arr.size() - 1)]
