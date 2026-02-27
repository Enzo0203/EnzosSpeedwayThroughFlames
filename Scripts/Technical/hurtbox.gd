extends Area2D

@export var State: String = "Vuln" # Vuln, Blocking, PerfectBlocking
@export var Intangible: bool = false # Whether this hurtbox can be hit by a hitbox or not
var IntangibleGrace: bool = false # Same as above, but used temporarily after getting hurt
var IntangibleSpecial: bool = false # Ignores hitboxes, regardless if they're "Unstoppable" or not
@export var Immovable: bool = false # Whether this hurtbox can be grabbed by a grabbox or not
@export var Parriable: bool = false # Whether this hurtbox can be parried by a parrybox or not

@export var Armored: bool = false # Whether the hurtbox has armor or not
@export var ArmorHealthLimit: int = 0 # How many damage it takes for the armor to break ("inf" if you want Hyper Armor)

var DamageTakeMultiplier: float = 1.0 # Multiplies the amount of damage taken when this hurtbox is hit (0.0 if you want invincibility)
var HitStopTakeMultiplier: float = 1.0 # Multiplies the amount of hitstop taken when this hurtbox is hit
var StunTakeMultiplier: float = 1.0 # Multiplies the amount of hitstun taken when this hurtbox is hit

signal hurt(
	area: Area2D,
	Damage: int, 
	Knockback: Vector2,
	DeathType: String)
signal parried(area: Area2D)
signal block(area: Area2D)
signal perfectBlock(area: Area2D)

func _ready() -> void:
	if area_entered.is_connected(_on_area_entered) == false:
		connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hitbox"):
		if not (Intangible or IntangibleGrace or IntangibleSpecial):
			if State == "Vuln":
				if not DamageTakeMultiplier == 0.0:
					if not area.Damage == 0:
						emit_signal("hurt", area,
						area.Damage * area.DamageGiveMultiplier * DamageTakeMultiplier, 
						area.Knockback * area.scale, 
						area.DeathType)
				if Parriable and area.Parrybox:
					emit_signal("parried", area)
			if State == "Blocking":
				emit_signal("block", area)
			if State == "PerfectBlocking":
				emit_signal("perfectBlock", area)
