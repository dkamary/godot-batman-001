extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.score_changed.connect(func(s: int) -> void: print("Score: ", s))
	Game.lives_changed.connect(func(l: int) -> void: print("Vies: ", l))
	
	Game.add_score(15000)
	Game.add_score(6000) ## On franchit le palier de 20 000 => une vie en plus


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
