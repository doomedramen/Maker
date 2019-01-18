extends Node

var private_canvas_layer

onready var ScreenSize = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))

func _ready():
	#every scene should have a private canvas layer
	private_canvas_layer = CanvasLayer.new()
	add_child(private_canvas_layer)
	private_canvas_layer.name = "private_canvas_layer"
	

func alert(text):
	var popup = WindowDialog.new()
	var popupsize = Vector2(Global.ScreenSize.x/2,Global.ScreenSize.y/2)
	popup.rect_size = popupsize
	popup.rect_position = Vector2((Global.ScreenSize.x/2) - (popupsize.x/2),(Global.ScreenSize.y/2) - (popupsize.y/2))
	
	var label = Label.new()
	label.anchor_left = 0
	label.anchor_top = 0
	label.anchor_right = 1
	label.anchor_bottom = 1
	label.margin_left = 10
	label.margin_top = 10
	label.margin_right = -10
	label.margin_bottom = -10
	
	label.text = text
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.autowrap = true
	
	popup.add_child(label)
	
	private_canvas_layer.add_child(popup)
	popup.popup()
	