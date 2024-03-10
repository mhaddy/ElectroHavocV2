extends Node

# enum types defined in player.gd
# weapon_types {}
@export var CANNON: PackedScene
@export var MEGA_CANNON: PackedScene

@onready var weapon_mount_point = get_parent().find_child("WeaponMountPoint")

var equipped_weapon: Node

func _ready() -> void:
	# starting weapon
	equip_weapon(Player.weapon_types.CANNON)

func equip_weapon(weapon_to_equip) -> void:
	if equipped_weapon:
		print("delete cur weap")
		equipped_weapon.queue_free()

	match weapon_to_equip:
		Player.weapon_types.CANNON:
			equipped_weapon = CANNON.instantiate()
			weapon_mount_point.add_child(equipped_weapon)
		Player.weapon_types.MEGA_CANNON:
			equipped_weapon = MEGA_CANNON.instantiate()
			weapon_mount_point.add_child(equipped_weapon)

func fire() -> void:
	if equipped_weapon:
		equipped_weapon.fire()

# TODO: Not hooked up
func secondary_fire() -> void:
	if equipped_weapon:
		equipped_weapon.secondary_fire()
