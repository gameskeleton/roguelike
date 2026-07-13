@tool
@abstract
class_name RkTeleportTarget extends Resource

# teleport moves the player from the given teleporter to this config's destination.
# note: implementations may load and swap scenes as a side effect.
# @impure
@abstract func teleport(from: RkTeleporter, player_node: RkPlayer) -> void

# get_configuration_warnings returns editor warnings for this target.
# @pure
@abstract func get_configuration_warnings(from: RkTeleporter) -> PackedStringArray
