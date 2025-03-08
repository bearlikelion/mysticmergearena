extends Match3Piece


func _enter_tree() -> void:
	add_to_group(GroupName)

	if is_special():
		add_to_group(SpecialGroupName)
	elif is_obstacle():
		add_to_group(ObstacleGroupName)

	name = "%s_%s_%s" % [id, get_parent().name, shape]
	add_to_group(name)
	z_index = 10
	original_z_index = z_index


func _ready() -> void:
	_prepare_sprite()
	await get_tree().process_frame

	_create_mouse_region_button()
	await get_tree().process_frame

	_prepare_area_detectors()
	set_process(drag_enabled and not is_locked)
