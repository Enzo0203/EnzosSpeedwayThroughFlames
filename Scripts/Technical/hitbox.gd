extends Area2D

@export var Damage: int # Attack damage

@export var Strength: int # Clank priority

@export var Unblockable: bool # Attack ignores blocks and perfect blocks.
@export var Uncounterable: bool # Attack can't be countered
@export var Unstoppable: bool # Attack can hit intangible foes and stun through armor

@export var Knockback: Vector2 # Knockback inflicted on victim
@export var SelfKnockback: Vector2 # Knockback inflicted on user

@export var DamageGiveMultiplier: float = 1.0 # Multiplies the amount of damage given when this hitbox hits a hurtbox
@export var HitStopGiveMultiplier: float = 1.0 # Multiplies the amount of hitstop given when this hitbox hits a hurtbox
@export var StunGiveMultiplier: float = 1.0 # Multiplies the amount of hitstun given when this hitbox hits a hurtbox

@export var Clankable: bool = true # Attack can clank
@export var Parriable: bool # Attack can be parried if clanking with a parrybox
@export var Stunnable: bool # Attack will deactivate when hitting a hurtbox
@export var Ghost: bool # Attack can phase through walls

@export var Parrybox: bool # Attack can parry

@export var ImpactSfx: String # Audio that plays when hitbox hits something
@export var DeathType: String # Way that Enzo dies if he gets killed by this attack

signal clank(area: Area2D)
signal clashCounter(area: Area2D)
signal rebound(area: Area2D)
signal clashCountered(area: Area2D)
signal rebounded(area: Area2D)
signal parry(area: Area2D)
signal parried(area: Area2D)

signal hurtSomething(area: Area2D)
signal blocked(area: Area2D)

func _ready() -> void:
	if area_entered.is_connected(_on_area_entered) == false:
		connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		if not area.Intangible and not area.IntangibleGrace and not area.IntangibleSpecial:
			if area.State == "Vuln":
				if not area.DamageTakeMultiplier == 0.0:
					if not Damage == 0:
						emit_signal("hurtSomething", area)
				if area.Parriable and Parrybox:
					emit_signal("parry", area)
			if area.State == "Blocking":
				emit_signal("blocked", area)
	if area.is_in_group("Hitbox"):
		if Clankable and area.Clankable:
			if Strength - 1 > area.Strength:
				if not Parrybox:
					if area.is_in_group("Projectile"):
						emit_signal("rebound", area)
					else:
						emit_signal("clashCounter", area)
				else:
					if area.Parriable:
						emit_signal("parry", area)
			elif Strength + 1 < area.Strength:
				if not area.Parrybox:
					if is_in_group("Projectile"):
						emit_signal("rebounded", area)
					else:
						emit_signal("clashCountered", area)
				else:
					if Parriable:
						emit_signal("parried", area)
			else:
				#Clank
				emit_signal("clank", area)
