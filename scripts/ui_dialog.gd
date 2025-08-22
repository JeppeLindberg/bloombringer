extends Control

@export var dialog_bubble_prefab: PackedScene

@export var player: Node3D

var dialog_array = []


func enter_dialog(new_dialog_array):
	dialog_array = new_dialog_array

	var talker = dialog_array[0].get('talker')
	if talker == null:
		talker = player

	var new_dialog_bubble = dialog_bubble_prefab.instantiate()
	add_child(new_dialog_bubble)
	new_dialog_bubble.follow_node = talker
	new_dialog_bubble.update_pos()




