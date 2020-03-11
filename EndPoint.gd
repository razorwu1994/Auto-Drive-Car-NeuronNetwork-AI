extends Area2D

signal finished
var currentPosition = self.position

func _on_EndPoint_body_entered(body):
	var angleBtw = currentPosition.angle_to_point(body.position)
	if angleBtw*180/PI>=0:
		print("Success pass")
		emit_signal('finished',body)
	else:
		print("Cheat!!!")
