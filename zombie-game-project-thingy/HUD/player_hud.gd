extends CanvasLayer

func update_bullet_counter(bullet : int, mag_size : int):
	$Bullets.text = str(bullet) + " / " + str(mag_size)
