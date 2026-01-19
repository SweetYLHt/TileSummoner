extends Node

## 临时脚本：生成所有地块资源文件

func _ready() -> void:
	_generate_all_tile_resources()
	print("地块资源已生成，退出...")
	get_tree().quit()

func _generate_all_tile_resources() -> void:
	var tiles_data = {
		&"grassland": {
			"display_name": "草地",
			"category": &"basic",
			"element_type": &"nature",
			"movement_modifier": 0,
			"defense_bonus": 0,
			"attack_bonus": 0,
			"damage_per_second": 0,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, 0, -10, 0, 10, 20, 0, 0],
			"remains_after_consume": false,
			"description": "基准地形，无任何加成或减益。稳妥的中立地形，适合部署通用单位。"
		},
		&"water": {
			"display_name": "水域",
			"category": &"basic",
			"element_type": &"water",
			"movement_modifier": -1,
			"defense_bonus": 10,
			"attack_bonus": 0,
			"damage_per_second": 0,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, -20, 20, -10, 0, 10, 30, 0],
			"remains_after_consume": false,
			"description": "降低移动力，但提升防御。水系单位获得显著加成。"
		},
		&"sand": {
			"display_name": "沙漠",
			"category": &"basic",
			"element_type": &"earth",
			"movement_modifier": 0,
			"defense_bonus": 0,
			"attack_bonus": 0,
			"damage_per_second": 0,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, 20, -10, 10, -10, -20, 0, 0],
			"remains_after_consume": false,
			"description": "干燥环境，火系单位强力，但削弱自然系。"
		},
		&"rock": {
			"display_name": "岩石",
			"category": &"basic",
			"element_type": &"earth",
			"movement_modifier": 0,
			"defense_bonus": 20,
			"attack_bonus": -10,
			"damage_per_second": 0,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, 10, -10, 20, -10, -10, -10, 0],
			"remains_after_consume": true,
			"description": "高防御低攻击，被消耗后保留地块。土系单位加成明显。"
		},
		&"forest": {
			"display_name": "森林",
			"category": &"basic",
			"element_type": &"nature",
			"movement_modifier": -1,
			"defense_bonus": 15,
			"attack_bonus": 5,
			"damage_per_second": 0,
			"heal_per_5sec": 5,
			"dodge_chance": 0.1,
			"special_effects": 0,
			"affinity_matrix": [0, -20, 10, -10, 5, 20, 0, 0],
			"remains_after_consume": false,
			"description": "提供恢复能力和闪避加成。自然系单位的主场。"
		},
		&"farmland": {
			"display_name": "农田",
			"category": &"basic",
			"element_type": &"nature",
			"movement_modifier": 0,
			"defense_bonus": 0,
			"attack_bonus": 0,
			"damage_per_second": 0,
			"heal_per_5sec": 10,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, -10, 10, 0, 0, 15, 0, 0],
			"remains_after_consume": false,
			"description": "强力恢复地形，每5秒恢复10点生命值。"
		},
		&"lava": {
			"display_name": "熔岩",
			"category": &"special",
			"element_type": &"fire",
			"movement_modifier": -1,
			"defense_bonus": -10,
			"attack_bonus": 20,
			"damage_per_second": 3,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 0,
			"affinity_matrix": [0, 25, -20, -10, 10, -20, -15, 0],
			"remains_after_consume": false,
			"description": "危险地形！每秒造成3点伤害，但火系单位大幅强化。"
		},
		&"swamp": {
			"display_name": "沼泽",
			"category": &"special",
			"element_type": &"nature",
			"movement_modifier": -2,
			"defense_bonus": -5,
			"attack_bonus": -5,
			"damage_per_second": 1,
			"heal_per_5sec": 0,
			"dodge_chance": 0.2,
			"special_effects": 0,
			"affinity_matrix": [0, 0, 15, -10, 0, 10, 0, 0],
			"remains_after_consume": false,
			"description": "复杂地形，降低移动力和攻防，但提供高闪避。"
		},
		&"ice": {
			"display_name": "冰原",
			"category": &"special",
			"element_type": &"ice",
			"movement_modifier": 0,
			"defense_bonus": 5,
			"attack_bonus": 10,
			"damage_per_second": 0,
			"heal_per_5sec": 0,
			"dodge_chance": 0.0,
			"special_effects": 2,
			"affinity_matrix": [0, -20, 15, -5, 5, -10, 25, 0],
			"remains_after_consume": false,
			"description": "冰系单位强力加成，可冻结敌人。"
		}
	}

	var tile_data_script = load("res://Scripts/tile/tile_data.gd")

	for tile_type in tiles_data:
		var data = tiles_data[tile_type]
		var resource = Resource.new()
		resource.set_script(tile_data_script)
		resource.tile_type = tile_type
		resource.display_name = data["display_name"]
		resource.category = data["category"]
		resource.element_type = data["element_type"]
		resource.movement_modifier = data["movement_modifier"]
		resource.defense_bonus = data["defense_bonus"]
		resource.attack_bonus = data["attack_bonus"]
		resource.damage_per_second = data["damage_per_second"]
		resource.heal_per_5sec = data["heal_per_5sec"]
		resource.dodge_chance = data["dodge_chance"]
		resource.special_effects = data["special_effects"]
		resource.affinity_matrix = data["affinity_matrix"]
		resource.remains_after_consume = data["remains_after_consume"]
		resource.description = data["description"]

		var path = "res://Resources/Tiles/%s.tres" % tile_type
		var result = ResourceSaver.save(resource, path)
		if result == OK:
			print("✓ 已生成: %s" % path)
		else:
			print("✗ 生成失败: %s" % path)
