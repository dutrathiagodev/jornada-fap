class_name Coracoes
extends Control

const TEX := preload("res://assets/objetos/coracao.png")
var cheios := 3
var total := 3

func _draw() -> void:
	for i in total:
		var cor := Color(1, 1, 1, 1) if i < cheios else Color(0.1, 0.1, 0.15, 0.45)
		draw_texture_rect(TEX, Rect2(10 + i * 84, 6, 72, 64), false, cor)
