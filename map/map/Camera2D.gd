extends Camera2D
var scaleNum = 2 
var isDrag = false
var startPos = Vector2.ZERO
var startCamPos = Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 4:
			startPos = Vector2.ZERO
			if scaleNum >= 10:
				return
			elif scaleNum <= 0.3:
				scaleNum += 0.03
			elif scaleNum <= 1:
				scaleNum += 0.06
			elif scaleNum >= 8:
				scaleNum += 0.6
			elif scaleNum >= 2:
				scaleNum += 0.3
			else:
				scaleNum += 0.1
		elif event.button_index == 5:
			startPos = Vector2.ZERO
			if scaleNum <= 0.2:
				return
			elif scaleNum <= 0.3:
				scaleNum -= 0.03
			elif scaleNum <= 1:
				scaleNum -= 0.06
			elif scaleNum >= 8:
				scaleNum -= 0.6
			elif scaleNum >= 2:
				scaleNum -= 0.3
			else:
				scaleNum -= 0.1
		
		if event.button_index == 2 or event.button_index == 3:
			if event.is_pressed():
				isDrag = true
				startPos = event.position
				startCamPos = self.position
			else:
				isDrag = false
				startPos = Vector2.ZERO
	
	if isDrag and (startPos != Vector2.ZERO):
			var offset = startPos - event.position
			self.position = startCamPos + offset/scaleNum
		
		
		
func _process(delta):
	self.zoom = lerp(self.zoom, Vector2(scaleNum, scaleNum), 8*delta)	

func _ready():
	pass
