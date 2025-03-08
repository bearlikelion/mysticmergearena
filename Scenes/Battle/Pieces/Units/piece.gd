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
	if is_inside_tree():
		await get_tree().process_frame

	_create_mouse_region_button()
	if is_inside_tree():
		await get_tree().process_frame

	_prepare_area_detectors()
	set_process(drag_enabled and not is_locked)


func _prepare_sprite() -> void:
	sprite = Match3BoardPluginUtilities.first_node_of_type(self, Sprite2D.new())

	if sprite == null:
		sprite = Match3BoardPluginUtilities.first_node_of_type(self, AnimatedSprite2D.new())

	assert(sprite != null, "Match3Piece: %s needs to have a Sprite2D or AnimatedSprite2D as child to create the mouse region" % name)

	if sprite is Sprite2D:
		sprite.scale = calculate_texture_scale(sprite.texture, cell.size if cell else Vector2i(48, 48))
	elif sprite is AnimatedSprite2D:
		sprite.scale = calculate_texture_scale(sprite.get_sprite_frames().get_frame(sprite.animation, sprite.get_frame()))
