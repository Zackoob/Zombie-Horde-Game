extends CanvasLayer

var bullets_loaded : int
var bullets_total : int

func update_bullet_counter(loaded_bullets : int, total_bullets : int):
	$Bullets.text = str(loaded_bullets) + " / " + str(total_bullets)
	bullets_loaded = loaded_bullets
	bullets_total = total_bullets
	

func show_prompt(prompt_text):
	$prompt.text = prompt_text

func hide_prompt():
	$prompt.text = ""
