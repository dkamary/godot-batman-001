class_name Layers
# Masque de bits des couches physiques (cuche n => bit n-1).

const WORLD := 1 << 0
const PLATFORM := 1 << 1
const PLAYER_BODY := 1 << 2
const ENEMY_BODY := 1 << 3
const PLAYER_HURTBOX := 1 << 4
const ENEMY_HURTBOX := 1 << 5
const PICKUPS := 1 << 6
const LEDGES := 1 << 7
