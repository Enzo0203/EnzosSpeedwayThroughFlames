extends Area2D

var BaseDamage: int # The damage before going through any multipliers
var Damage: int # True in-game damage

var Strength: int # Clank priority

var Knockback: Vector2 # Knockback inflicted on victim
var SelfKnockback: Vector2 # Knockback inflicted on user

var Clankable: bool # Attack can clank
var Stunnable: bool # Attack will deactivate when hitting a hurtbox
var Ghost: bool # Attack can phase through walls

var ImpactSfx: AudioStreamPlayer2D # Audio that plays when hitbox hits something
