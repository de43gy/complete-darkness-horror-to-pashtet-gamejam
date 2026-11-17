class_name Girl
extends Node2D
## The girl's sprite. Only shows things; the rules live in Explorer.

const WALK_ANIMATIONS: Dictionary[Vector2i, StringName] = {
	Vector2i.UP: &"walk_up",
	Vector2i.DOWN: &"walk_down",
	Vector2i.LEFT: &"walk_left",
	Vector2i.RIGHT: &"walk_right",
}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


## Turn towards a direction and play the matching animation.
func face(direction: Vector2i) -> void:
	if WALK_ANIMATIONS.has(direction):
		animated_sprite.play(WALK_ANIMATIONS[direction])
