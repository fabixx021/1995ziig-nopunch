-- Block Punching Without Aiming and Player/NPC Nearby Script
-- FiveM Script by 1995ziig

-- Function to check if another player or NPC is nearby
function IsEntityNearby(playerPed)
    local playerCoords = GetEntityCoords(playerPed)
    local nearbyEntities = GetNearbyPeds(playerPed, 3.0)
    
    for _, entity in ipairs(nearbyEntities) do
        if DoesEntityExist(entity) and not IsPedAPlayer(entity) then
            return true
        end
    end
    
    local players = GetActivePlayers()
    for i = 1, #players do
        local targetPed = GetPlayerPed(players[i])
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            if #(playerCoords - targetCoords) <= 3.0 then
                return true
            end
        end
    end
    
    return false
end

-- Feature to get nearby peds
function GetNearbyPeds(playerPed, radius)
    local peds = {}
    local handle, ped = FindFirstPed()
    local success

    repeat
        local pos = GetEntityCoords(ped)
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) and #(pos - GetEntityCoords(playerPed)) <= radius then
            table.insert(peds, ped)
        end
        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)
    return peds
end

-- Main thread
Citizen.CreateThread(function()
    while true do
        -- Waiting time in milliseconds to reduce the load on the server
        Citizen.Wait(0)

        -- Get the player and check the current weapon
        local playerPed = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(playerPed)

        -- If the player has no weapon in hand (Unarmed)
        if weaponHash == GetHashKey("WEAPON_UNARMED") then
            -- Check if the right mouse button is pressed and another player or NPC is nearby
            if IsControlPressed(0, 25) and IsEntityNearby(playerPed) then
                -- Allow punch controls
                EnableControlAction(0, 24, true)  -- Attack
                EnableControlAction(0, 257, true) -- Attack 2
                EnableControlAction(0, 140, true) -- Melee Attack Light
                EnableControlAction(0, 141, true) -- Melee Attack Heavy
                EnableControlAction(0, 142, true) -- Melee Attack Alternate
            else
                -- Block the punch controls
                DisableControlAction(0, 24, true)  -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 140, true) -- Melee Attack Light
                DisableControlAction(0, 141, true) -- Melee Attack Heavy
                DisableControlAction(0, 142, true) -- Melee Attack Alternate
            end
        end
    end
end)
