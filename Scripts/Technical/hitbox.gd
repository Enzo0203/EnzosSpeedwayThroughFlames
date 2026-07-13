class_name Hitbox extends Area2D

@export_category("Children")

# The Hitbox's shape.
@export var Shape: CollisionShape2D

@export_category("Base Stats")

## How much damage this does at base.
@export var Damage: int
## Attack's priority when clanking with other attacks. Higher number = Higher priority.
@export var Strength: int
## How much knockback this deals to the victim. If (0, 0), does not deal knockback. The X value of this scales with the Area2d's scale.x.
@export var Knockback: Vector2
## How much knockback this deals to the user. If (0, 0), does not deal knockback. The X value of this scales with the Area2d's scale.x.
@export var SelfKnockback: Vector2

@export_category("Attributes")

## If true, attack can damage blocks and perfect blocks.
@export var Unblockable: bool
## If true, attack can damage counters.
@export var Uncounterable: bool
## If true, attack can damage intangible hurtboxes and ignore armor.
@export var Unstoppable: bool
## Attack can clank if it hits another attack of similar strength.
@export var Clankable: bool = true
## If true and this attack is stronger than a projectile, it deflects it. If false, it just clanks instead.
@export var Deflector: bool = false
## Attack can be parried.
@export var Parriable: bool
## Attack can phase through walls.
@export var Ghost: bool
## What this attack's shape should do when it hits something.
@export var OnHitShapeBehavior: OnHitShapeBehaviors = OnHitShapeBehaviors.NONE
enum OnHitShapeBehaviors {
	## Keep shape active.
	NONE,
	## Disables its shape until it enables itself again.
	DISABLE,
}
## Attack can parry.
@export var Parrybox: bool

@export_category("Multipliers")

## Multiplies the amount of damage given.
@export var DamageGiveMultiplier: float = 1.0
## Multiplies the amount of hitstop given.
@export var HitStopGiveMultiplier: float = 1.0
## Multiplies the amount of stun given.
@export var StunGiveMultiplier: float = 1.0
## Multiplies the amount of knockback given.
@export var KnockbackGiveMultiplier: float = 1.0

@export_category("Miscellaneous")

## Sound effect played when this hits something.
@export var ImpactSfx: AudioStream
## Type of animation Enzo plays when killed by this attack.
@export var DeathType: EnzoDeathTypes
enum EnzoDeathTypes { 
	GENERIC,
	BLUNT,
	FIRE,
	SPIKE}

## Emitted whenever this Hitbox hits a Hurtbox but its final Damage post calculation
## is equal or lower than 0.
signal tinked(area: Area2D)
## Emitted whenever this Hitbox hits another Hitbox whose strength has a difference
## of 1 or less than this Hitbox's.
signal clank(area: Area2D)
## Emitted whenever this Hitbox hits another Hitbox whose strength is lower
## than this Hitbox's. Only possible if both Hitboxes are Clankable.
signal clashCounter(area: Area2D)
## Emitted whenever this Hitbox hits a projectile's Hitbox whose strength is lower
## than this Hitbox's. Only possible if both [Hitbox]es are Clankable and this
## Hitbox is a Deflector.
signal rebound(area: Area2D)
## Emitted whenever this Hitbox hits another [Hitbox] whose strength is higher
## than this Hitbox's. Only possible if both [Hitbox]es are Clankable.
signal clashCountered(area: Area2D)
## Emitted whenever this Hitbox hits a Hitbox whose strength is higher
## than this Hitbox's and this Hitbox belongs to a projectile.
## Only possible if both [Hitbox]es are Clankable and the other [Hitbox] is a Deflector.
signal rebounded(area: Area2D)
## Emitted whenever this Hitbox hits a projectile's [Hitbox] whose strength is lower
## than this [Hitbox]'s. Only possible if this [Hitbox] is a Parrybox and the other
## [Hitbox] is parriable.
signal parry(area: Area2D, range: String)
## Emitted whenever this Hitbox hits a projectile's Hitbox whose strength is lower
## than this Hitbox's. Only possible if this [Hitbox] is [member Parriable] and the other
## Hitbox is a Parrybox.
signal parried(area: Area2D, range: String)

## Emitted when this Hitbox succesfully hurts a [Hurtbox].
signal hurtSomething(area: Area2D)

## Emitted when this [Hitbox] hits a [Hurtbox] while its [member Hurtbox.Intangible] is [code]true[/code].
signal missed(area: Area2D)
## Emitted when this Hitbox hits a [Hurtbox] whose [member Hurtbox.State] is Blocking.
signal blocked(area: Area2D)

func _ready() -> void:
	if area_entered.is_connected(_on_area_entered) == false:
		connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		if not (area.IntangibleGrace or area.IntangibleSpecial):
			if not area.Intangible:
				if area.State == area.Hurtbox_States.VULNERABLE:
					if Damage * DamageGiveMultiplier * area.DamageTakeMultiplier > 0:
						emit_signal("hurtSomething", area)
						if OnHitShapeBehavior == OnHitShapeBehaviors.DISABLE:
							Shape.set_deferred("disabled", true)
					else:
						emit_signal("tinked", area)
					if area.Parriable and Parrybox:
						emit_signal("parry", area, "Melee")
				if area.State == area.Hurtbox_States.BLOCKING or area.State == area.Hurtbox_States.PERFECT_BLOCKING:
					emit_signal("blocked", area)
			else:
				emit_signal("missed", area)

	if area is Hitbox:
		if Clankable and area.Clankable:
			if Strength - 1 > area.Strength:
				if not Parrybox:
					if area.is_in_group("Projectile"):
						if Deflector:
							emit_signal("rebound", area)
						else:
							emit_signal("clashCounter", area)
					else:
						emit_signal("clashCounter", area)
				else:
					if area.Parriable:
						emit_signal("parry", area, "Melee")
			elif Strength + 1 < area.Strength:
				if not area.Parrybox:
					if is_in_group("Projectile"):
						if area.Deflector:
							emit_signal("rebounded", area)
						else:
							emit_signal("clank", area)
					else:
						emit_signal("clashCountered", area)
				else:
					if Parriable:
						emit_signal("parried", area, "Ranged")
			else:
				#Clank
				emit_signal("clank", area)
