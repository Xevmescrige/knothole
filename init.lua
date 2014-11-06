default.chest_formspec = 
	"size[8,9]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	"list[current_name;main;3.5,0;1,2;]"..
	"list[current_player;main;0,2.85;8,1;]"..
	"list[current_player;main;0,4.08;8,3;8]"..
	default.get_hotbar_bg(0,2.85)

minetest.register_node("knothole:default_tree_knothole", {
	description = "Log With Knothole",
	tiles = {"default_tree_top.png", "default_tree_top.png", "default_tree.png",
	"default_tree.png", "default_tree.png", "default_tree.png"},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, -0.2, 0.5, 0.5},
			{0.2, -0.5, -0.5, 0.5, 0.5, 0.5},
			{-0.5, 0.2, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.5, -0.2, 0.5},
			{-0.5, -0.5, -0.2, 0.5, 0.5, 0.5},
		}
	},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
	sounds = default.node_sound_wood_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec",default.chest_formspec)
		meta:set_string("infotext", "Knothole")
		local inv = meta:get_inventory()
		inv:set_size("main", 1*2)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		return inv:is_empty("main")
	end,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
				" shuffles the order of the items in knothole at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" hides stuff in knothole at "..minetest.pos_to_string(pos))
	end,
    on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
				" takes stuff from knothole at "..minetest.pos_to_string(pos))
	end,
})

minetest.register_abm({
	nodenames = {"default:tree"},
	interval = 50,
	chance = 20,
	action = function(pos, node)
		pos.y = pos.y-2
		local name = minetest.get_node(pos).name
		if name == "default:tree" then
			if minetest.find_node_near(pos, 3, {"default:tree", "group:water"}) ~= nil then
				minetest.set_node(pos, {name="knothole:default_tree_knothole"})
			end
			end
		end
})

minetest.register_abm({
	nodenames = {"default:leaves"},
	interval = 60,
	chance = 20,
	action = function(pos, node)
			if minetest.find_node_near(pos, 3, {"knothole:default_tree_knothole"}) ~= nil then
				minetest.set_node(pos, {name="knothole:nest"})
			end
		end
})

minetest.register_abm({
	nodenames = {"knothole:default_tree_knothole"},
	interval = 500,
	chance = 20,
	action = function(pos, node)
		minetest.set_node(pos, {name="default:tree"})
	end
})

minetest.register_craft({
	output = 'default:wood 3',
	recipe = {
		{'knothole:default_tree_knothole'},
	}
})

minetest.register_node("knothole:nest", {
	tiles = {
		"nest_empty_top.png",
		"nest_empty_top.png",
		"nest_empty_side.png",
		"nest_empty_side.png",
		"nest_empty_side.png",
		"nest_empty_side.png"
	},
	groups = {choppy=2,oddly_breakable_by_hand=2},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.1875, -0.375, 0.375, 0.0625, 0.375}, 
			{-0.25, -0.3125, -0.25, 0.25, -0.1875, 0.25}, 
			{-0.375, -0.1875, -0.25, -0.25, 0.1875, 0.375}, 
			{-0.375, -0.1875, -0.375, 0.25, 0.1875, -0.25}, 
			{0.25, -0.1875, -0.375, 0.375, 0.1875, 0.25},
			{-0.25, -0.1875, 0.25, 0.375, 0.1875, 0.375}, 
		}
	}
})

dofile(minetest.get_modpath("knothole").."/api.lua")

mobs:register_mob("knothole:bird", {
	type = "animal",
	hp_max = 2,
	collisionbox = {-0.25*(0.5/0.7), -0.33*(0.5/0.7), -0.25*(0.5/0.7), 0.25*(0.5/0.7), 0.33*(0.5/0.7), 0.25*(0.5/0.7)},
	visual = "cube",
	visual_size = { x = 0.5, y = 0.5},
	textures = {"bird_top.png", "bird_bot.png", "bird_side.png", "bird_side.png", "bird_front.png", "bird_back.png"},
	makes_footstep_sound = false,
	walk_velocity = 2,
	armor = 100,
	drops = {
		{name = "knothole:meat_raw",
		chance = 1,
		min = 1,
		max = 1,},
		},
	drawtype = "front",
	water_damage = 0.5,
	lava_damage = 1,
	light_damage = 0,
})
	
minetest.register_craftitem("knothole:bird", {
	description = "bird",
	inventory_image = "bird_front.png",
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.above then
			minetest.env:add_entity(pointed_thing.above, "knothole:bird")
		end
		return itemstack
	end,
})

minetest.register_craftitem("knothole:egg", {
	description = "egg",
	inventory_image = "egg.png",
	on_use = minetest.item_eat(1),
})

