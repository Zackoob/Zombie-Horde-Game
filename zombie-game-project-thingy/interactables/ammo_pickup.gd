extends StaticBody3D

@export var prompt : String = "E - Pickup Ammo"

func interacted(hud : Node):
	hud.update_bullet_counter(hud.bullets_loaded, hud.bullets_total + 30)
	get_node(self.get_path()).queue_free()
