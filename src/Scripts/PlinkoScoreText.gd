#extends Label
#
#signal incrementText
#signal resetText
#
#var counter = 0
#
#func _incrementText(addition):
	#counter += addition
	#_updateText()
	#
#func _resetText():
	#counter = 0
	#_updateText()
	#
#func _updateText():
	#text = str(counter)
