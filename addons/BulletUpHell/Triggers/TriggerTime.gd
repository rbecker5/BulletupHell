@icon("res://addons/BulletUpHell/Sprites/NodeIcons10.png")
extends RichTextEffect
class_name TriggerTime

@export_range(0.017, 999999, 0.001, "hide_slider", "suffix:s") var time:float = 1

func _init():
	resource_name = "TrigTime"

