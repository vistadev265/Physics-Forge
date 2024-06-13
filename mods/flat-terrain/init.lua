-- Define the mod name and path
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- Create a table to store player permissions
local player_permissions = {}

-- Function to show the formspec
local function show_formspec(player_name)
    local formspec = "formspec_version[3]"
    .. "size[8,6]"
    .. "label[0.5,0.5;Grant or Revoke Permissions]"
    .. "field[1,1.5;6,1;target_player;Target Player;]"
    .. "field[1,2.5;6,1;permission;Permission;]"
    .. "button[1,4;2,1;grant;Grant]"
    .. "button[5,4;2,1;revoke;Revoke]"

    minetest.show_formspec(player_name, modname .. ":permission_form", formspec)
end

-- Register a chat command to open the formspec
minetest.register_chatcommand("permissions", {
    params = "",
    description = "Open the permissions UI",
    func = function(name)
        show_formspec(name)
    end,
})

-- Handle formspec input
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= modname .. ":permission_form" then
        return
    end

    local player_name = player:get_player_name()
    local target_player = fields.target_player
    local permission = fields.permission

    if fields.grant and target_player and permission then
        if minetest.get_player_by_name(target_player) then
            minetest.chat_send_player(player_name, "Granted " .. permission .. " to " .. target_player)
            player_permissions[target_player] = player_permissions[target_player] or {}
            player_permissions[target_player][permission] = true
        else
            minetest.chat_send_player(player_name, "Target player not found")
        end
    end

    if fields.revoke and target_player and permission then
        if player_permissions[target_player] and player_permissions[target_player][permission] then
            player_permissions[target_player][permission] = nil
            minetest.chat_send_player(player_name, "Revoked " .. permission .. " from " .. target_player)
        else
            minetest.chat_send_player(player_name, "Permission not found for target player")
        end
    end
end)

-- Function to check permissions
minetest.register_on_prejoinplayer(function(name, ip)
    local perms = player_permissions[name]
    if perms then
        for perm, _ in pairs(perms) do
            if not minetest.check_player_privs(name, {[perm]=true}) then
                minetest.set_player_privs(name, {[perm]=true})
            end
        end
    end
end)
