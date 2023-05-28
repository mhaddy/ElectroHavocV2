extends Node

func tween_pulsate(node: Node) -> void:
	#TRANS_QUINT, _QUAD, _ELASTIC are cool too
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE * 1.3, 0.1)
	tween.tween_property(node, "scale", Vector2.ONE, 0.5)

func tween_fade_out(node: Node, fade_out_time: float = 1.0, destroy: bool = true) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ZERO, 0.5)
	# scale to 0 based on the center of node's position
	tween.parallel().tween_property(node, "position", node.get_size() / 2, 0.5).as_relative()
	tween.tween_property(node, "modulate", Color(0, 0, 0, 0), fade_out_time)
	
	if destroy:
		tween.tween_callback(node.queue_free)
	else:
		tween.tween_callback(node.hide)
