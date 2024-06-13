-- Define a table to hold all the functions and variables related to your mod
local falling_blocks = {}

-- Register a function to handle updating blocks
function falling_blocks.update_falling(pos)
    local node = minetest.get_node(pos)
    local under_pos = {x = pos.x, y = pos.y - 1, z = pos.z}
    local under_node = minetest.get_node(under_pos)
    
    -- Check if the block is not on the ground and is not already falling
    if under_node.name == "air" and node.name ~= "falling_blocks:block_falling" then
        -- Change the node to a falling version
        minetest.set_node(pos, {name = "falling_blocks:block_falling"})
    elseif under_node.name ~= "air" and node.name == "falling_blocks:block_falling" then
        -- Block has landed, change it back to original state
        minetest.set_node(pos, {name = "falling_blocks:block"})
    end
end

-- Register an ABM (Active Block Modifier) to check for unsupported blocks
minetest.register_abm({
    label = "Check for falling blocks",
    nodenames = {"falling_blocks:block"},
    interval = 1,
    chance = 1,
    action = function(pos, node)
        -- Call the update function to check and handle block state
        falling_blocks.update_falling(pos)
    end,
})

-- Register your falling block node
minetest.register_node("falling_blocks:block", {
    description = "Falling Block",
    tiles = {"default_stone.png"},
    groups = {cracky = 3, falling_block = 1},
})

-- Register your falling version of the block
minetest.register_node("falling_blocks:block_falling", {
    description = "Falling Block (Falling)",
    tiles = {"default_stone.png"},
    groups = {not_in_creative_inventory = 1},
    drop = "",
})

-- Register an override for on_construct to initiate the check
minetest.override_item("falling_blocks:block", {
    on_construct = function(pos)
        falling_blocks.update_falling(pos)
    end,
})

-- Return the mod table so Minetest can load it
return falling_blocks
