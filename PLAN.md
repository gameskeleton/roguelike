# Player Code Issues - Analysis & Fix Plan

## Critical Issues

### 1. Damage Race Condition on Death
**File:** `src/player/scripts/player.gd:311-316`

**Problem:** When lethal damage occurs, both `hit.call_deferred()` and `die.call_deferred()` get queued. This can cause the hit state to activate briefly before death.

**Fix:** Modify `_on_life_points_damage_taken()`:
```gdscript
func _on_life_points_damage_taken(_damage_taken: float, _from_source: Node, _from_instigator: Node) -> void:
    if dead:
        return
    if life_points_system.has_lethal_damage():
        die.call_deferred()
    else:
        hit.call_deferred()
```

---

## Medium Priority

### 2. `play_animation_then` Function Misleading
**File:** `src/player/scripts/player_animation.gd:21-23`

**Problem:** Function name suggests playing animation A then B, but actually only plays B if A isn't already playing. The first animation must already be playing from elsewhere.

**Fix:** Either:
- Rename to `play_animation_if_not_playing()` and fix logic, or
- Implement actual sequential playback using animation queues

---

## Low Priority

### 3. Unnecessary Unary `+` Operator
**File:** `src/player/scripts/player_movement.gd:39`

**Problem:** `|= +player_node.one_way_collision_layer` has redundant `+` operator.

**Fix:** Change to:
```gdscript
player_node.collision_mask |= player_node.one_way_collision_layer
```

---

## Priority Order for Fixes

1. **P0 - Critical:** Fix damage race condition (#1)
2. **P2 - Medium:** Fix `play_animation_then` logic (#2)
3. **P3 - Low:** Clean up unary operator (#3)
