extends Area2D

var Intangible: bool # Whether the hurtbox can be hit or not

var Armored: bool # Whether the hurtbox has armor or not
var ArmorHealthLimit: int # How many damage it takes for the armor to break

var DamageTakeMultiplier: float # Multiplies the amount of damage taken when this hurtbox is hit
var StunTakeMultiplier: float # Multiplies the amount of stun taken when this hurtbox is hit
