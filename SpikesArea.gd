extends Area2D



func _on_SpikesArea_body_entered(body):
	if(body.get_name() == "player"):
		body._death()
