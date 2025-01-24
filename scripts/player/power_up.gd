class_name PowerUp extends Resource

enum PowerUpType {
    BURST_SHOT,
    FAST_RELOAD,
    DOUBLE_JUMP,
    DOUBLE_DASH
}

var type: PowerUpType
var active: bool = false