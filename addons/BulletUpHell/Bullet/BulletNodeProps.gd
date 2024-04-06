@tool
@icon("res://addons/BulletUpHell/Sprites/NodeIcons21.png")
extends BulletProps
class_name BulletNodeProps

@export var instance_id:String

@export var overwrite_groups:bool = false


func set_homing_type(value):
	homing_type = value
	_get_property_list()
	notify_property_list_changed()

