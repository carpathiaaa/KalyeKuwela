class_name TrackingComponent
extends RefCounted

@export var target_player = null # Default target value
var tracking_body : Node = null # Default parent node value

func _init(new_tracking_body : Node) -> void:
	tracking_body = new_tracking_body

func track_target(new_target : Player) -> void:
	if new_target is Player:
		target_player = new_target
	else:
		push_error("Invalid target type in Tracking Component")

func find_target_position() -> Vector2:
	if not target_player or not is_instance_valid(target_player):
		push_error("No valid target detected")
		return tracking_body.global_position # Returns current position if no valid target exists
	# Returns target position relative to current position
	return (target_player.global_position - tracking_body.global_position).normalized() 
