extends Node

@export var STARTING_WEAPON: PackedScene

@onready var weapon_mount_point = get_parent().find_child("WeaponMountPoint")

var equipped_weapon: Node

func _ready():
	if STARTING_WEAPON:
		equip_weapon(STARTING_WEAPON)

func equip_weapon(weapon_to_equip):
	if equipped_weapon:
		#print("delete cur weap")
		equipped_weapon.queue_free()
	else:
		#print("no equipped weapon")
		equipped_weapon = weapon_to_equip.instantiate()
		weapon_mount_point.add_child(equipped_weapon)

func fire():
	if equipped_weapon:
		equipped_weapon.fire()

func secondary_fire():
	if equipped_weapon:
		equipped_weapon.secondary_fire()
