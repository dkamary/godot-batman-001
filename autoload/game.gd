extends Node
## Etat global de la partie. le HUD l'écoute via ses signaux (patron Observateur)

signal score_changed(score: int)
signal lives_changed(lives: int)
signal credits_changed(credits: int)
signal weapon_changed(weapon_id: StringName, level: int)

enum Hero { BATMAN, ROBIN }

const START_LIVES : int = 2
const START_CREDITS: int = 6
const MAX_WEAPON_LEVEL : int = 7

var extra_life_every : int = 20000

var hero: Hero = Hero.BATMAN
var score: int = 0
var lives: int = START_LIVES
var credits: int = START_CREDITS
var credits_settings: int = START_CREDITS
var weapon_id: StringName = &"batarang"
var weapon_level: int = 1
var current_section: String = "" ## chemin de la section en cours : point de reprise du "CONTINUE"
var _next_extra_life : int = 0

func new_game(selected: Hero) -> void:
	hero = selected
	credits = credits_settings
	_reset_run()
	
func continue_game() -> bool:
	## Renvoie false s'il n'y a plus de crédit
	if credits <= 0:
		return false
	credits -= 1
	credits_changed.emit(credits)
	_reset_run()
	return true
	
func _reset_run() -> void:
	score = 0
	lives = START_LIVES
	weapon_id = &"batarang"
	weapon_level = 1
	_next_extra_life = extra_life_every
	score_changed.emit(score)
	lives_changed.emit(lives)
	weapon_changed.emit(weapon_id, weapon_level)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	while extra_life_every > 0 and score >= _next_extra_life:
		_next_extra_life += extra_life_every
		add_life()
		
func add_life() -> void:
	lives += 1
	lives_changed.emit(lives)
	
func lose_life() -> bool:
	if lives <= 0:
		return false
	lives -= 1
	lives_changed.emit(lives)
	return true
	
func set_weapon(id: StringName, level: int) -> void:
	weapon_id = id
	weapon_level = level
	weapon_changed.emit(weapon_id, weapon_level)
