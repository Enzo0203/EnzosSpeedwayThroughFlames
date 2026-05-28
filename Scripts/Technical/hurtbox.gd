extends Area2D

@export_category("States")

enum Hurtbox_States {
	## No additional effects.
	VULNERABLE, 
	## Blocks hits.
	BLOCKING, 
	## Also blocks hits, but has a special interaction.
	PERFECT_BLOCKING}
## What state the hurtbox is in, can be "Vuln", "Blocking" or "PerfectBlocking"
@export var State: Hurtbox_States = Hurtbox_States.VULNERABLE
## If true, this hurtbox can't be hit by hitboxes.
@export var Intangible: bool = false
## Intangibility given to segmented-health users after getting hurt.
var IntangibleGrace: bool = false
## If true. this hurtbox can't be hit by hitboxes, regardless if they're Unstoppable or not
var IntangibleSpecial: bool = false
## If true, this hurtbox can't be grabbed by a grabbox
@export var Immovable: bool = false
## If true, this hurtbox can be parried by a parrybox
@export var Parriable: bool = false

@export_category("Armor")

## If true, this hurtbox has armor.
@export var Armored: bool = false
## If Armored is true, how many damage it takes for the armor to break. ("inf" if you want Hyper Armor)
@export var ArmorHealthLimit: int = 0

@export_category("Multipliers")

## Multiplies the amount of damage taken. (0.0 if you want invincibility)
@export var DamageTakeMultiplier: float = 1.0
## Multiplies the amount of hitstop taken.
@export var HitStopTakeMultiplier: float = 1.0
## Multiplies the amount of hitstun taken.
@export var StunTakeMultiplier: float = 1.0
## Multiplies the amount of knockback taken.
@export var KnockbackTakeMultiplier: Vector2 = Vector2(1.0, 1.0)

signal hurt(
	area: Area2D,
	Damage: int, 
	Knockback: Vector2,
	DeathType: String)
signal parried(area: Area2D, range: String)
signal block(area: Area2D)
signal perfectBlock(area: Area2D)

func _ready() -> void:
	if area_entered.is_connected(_on_area_entered) == false:
		connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hitbox"):
		if not (Intangible or IntangibleGrace or IntangibleSpecial):
			if State == Hurtbox_States.VULNERABLE:
				if not DamageTakeMultiplier == 0.0:
					if not area.Damage == 0:
						emit_signal("hurt", area,
						area.Damage * area.DamageGiveMultiplier * DamageTakeMultiplier, 
						area.Knockback * area.KnockbackGiveMultiplier * KnockbackTakeMultiplier * area.scale, 
						area.DeathType)
				if Parriable and area.Parrybox:
					emit_signal("parried", area, "Melee")
			if State == Hurtbox_States.BLOCKING:
				emit_signal("block", area)
			if State == Hurtbox_States.PERFECT_BLOCKING:
				emit_signal("perfectBlock", area)
