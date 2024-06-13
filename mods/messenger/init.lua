-- Function to get the phone's formspec
local function get_phone_formspec(player_name)
    return "formspec_version[3]" ..
           "size[8,9]" ..
           "label[2,1;Phone Interface]" ..
           "field[1,3;6,1;message;Enter message:;]" ..
           "button_exit[2.5,4.5;3,1;send;Send]"
end

-- Register the phone item with the correct mod namespace prefix
minetest.register_craftitem(":phone_mod:smartphone", {
    description = "Smartphone",
    inventory_image = "default_steel_block.png", -- Use a default texture
    on_use = function(itemstack, user, pointed_thing)
        local player_name = user:get_player_name()
        minetest.show_formspec(player_name, "phone_mod:interface", get_phone_formspec(player_name))
    end,
})

-- Table to store messages
local messages = {}

-- Handle form submissions
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "phone_mod:interface" and fields.send then
        local player_name = player:get_player_name()
        if fields.message and fields.message ~= "" then
            table.insert(messages, {from = player_name, message = fields.message})
            minetest.chat_send_player(player_name, "Message sent: " .. fields.message)
        end
    end
end)

-- Command to check received messages
minetest.register_chatcommand("check_messages", {
    description = "Check your messages",
    func = function(name)
        local player_messages = {}
        for _, msg in ipairs(messages) do
            if msg.from ~= name then
                table.insert(player_messages, msg.from .. ": " .. msg.message)
            end
        end
        if #player_messages == 0 then
            return true, "No messages."
        else
            return true, table.concat(player_messages, "\n")
        end
    end
})
