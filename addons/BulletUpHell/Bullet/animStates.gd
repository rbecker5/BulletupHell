@icon("res://addons/BulletUpHell/Sprites/NodeIcons24.png")
extends Resource
class_name animState

@export_placeholder("ID") var ID:String
@export_placeholder("Texture name") var texture:String
@export_placeholder("Node name") var collision:String
@export_placeholder("Node name") var SFX:String
@export_group("Advanced")
@export_range(-9999,9999, 0.001, "hide_slider") var tex_scale:float = 1
@export_range(-90,90) var tex_skew:float = 0

func _init():
	resource_name = "animState"
