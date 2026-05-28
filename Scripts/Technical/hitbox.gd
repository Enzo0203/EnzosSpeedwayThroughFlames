extends Area2D

## How much damage this does at base.
@export var Damage: int

## Attack's priority when clanking with other attacks. Higher number = Higher priority.
@export var Strength: int

## If true, attack can damage blocks and perfect blocks.
@export var Unblockable: bool
## If true, attack can damage counters.
@export var Uncounterable: bool
## If true, attack can damage intangible hurtboxes and ignore armor.
@export var Unstoppable: bool

## How much knockback this deals to the victim.
@export var Knockback: Vector2
## How much knockback this deals to the user.
@export var SelfKnockback: Vector2

## Multiplies the amount of damage given.
@export var DamageGiveMultiplier: float = 1.0
## Multiplies the amount of hitstop given.
@export var HitStopGiveMultiplier: float = 1.0
## Multiplies the amount of stun given.
@export var StunGiveMultiplier: float = 1.0
## Multiplies the amount of knockback given.
@export var KnockbackGiveMultiplier: float = 1.0

## Attack can clank if it hits another attack of similar strength.
@export var Clankable: bool = true
## If true and this attack is stronger than a projectile, it deflects it. If false, it destroys it instead.
@export var Deflector: bool = true
## Attack can be parried.
@export var Parriable: bool
## Attack deactivates when hitting a hurtbox.
@export var Stunnable: bool
## Attack can phase through walls.
@export var Ghost: bool

## Attack can parry.
@export var Parrybox: bool

## Sound effect played when this hits something.
@export var ImpactSfx: AudioStream
## Type of animation Enzo plays when killed by this attack.
@export var DeathType: String

signal clank(area: Area2D)
signal clashCounter(area: Area2D)
signal rebound(area: Area2D)
signal clashCountered(area: Area2D)
signal rebounded(area: Area2D)
signal parry(area: Area2D, range: String)
signal parried(area: Area2D, range: String)

signal hurtSomething(area: Area2D)
signal blocked(area: Area2D)

func _ready() -> void:
	if area_entered.is_connected(_on_area_entered) == false:
		connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		if not area.Intangible and not area.IntangibleGrace and not area.IntangibleSpecial:
			if area.State == area.Hurtbox_States.VULNERABLE:
				if not area.DamageTakeMultiplier == 0.0:
					if not Damage == 0:
						emit_signal("hurtSomething", area)
				if area.Parriable and Parrybox:
					emit_signal("parry", area, "Melee")
			if area.State == area.Hurtbox_States.BLOCKING or area.State == area.Hurtbox_States.PERFECT_BLOCKING:
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
						emit_signal("parry", area, "Melee")
			elif Strength + 1 < area.Strength:
				if not area.Parrybox:
					if is_in_group("Projectile"):
						emit_signal("rebounded", area)
					else:
						emit_signal("clashCountered", area)
				else:
					if Parriable:
						emit_signal("parried", area, "Ranged")
			else:
				#Clank
				emit_signal("clank", area)
