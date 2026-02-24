local QBCore = exports['qb-core']:GetCoreObject()

-- Command to open Pet Menu
QBCore.Commands.Add(Config.Command, "Buka Menu Pet", {}, false, function(source, args)
    TriggerClientEvent('ap_pet:client:openMenu', source)
end)

-- Fetch player pets from database
lib.callback.register('ap_pet:server:getPlayerPets', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    
    local citizenid = Player.PlayerData.citizenid
    
    local result = MySQL.query.await('SELECT * FROM player_pets WHERE citizenid = ?', {citizenid})
    return result or {}
end)

-- Buy a new pet
RegisterNetEvent('ap_pet:server:buyPet', function(petType, petName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local citizenid = Player.PlayerData.citizenid
    local petData = Config.AvailablePets[petType]
    
    if not petData then return end
    
    -- Check if it's a K9
    if petData.type == 'k9' then
        local jobName = Player.PlayerData.job.name
        local isPolice = false
        for _, policeJob in ipairs(Config.PoliceJobName) do
            if jobName == policeJob then
                isPolice = true
                break
            end
        end
        if not isPolice then
            TriggerClientEvent('ap_pet:client:notify', src, 'error', Lang('k9_only'))
            return
        end
    else
        -- Pay for civilian pet
        if Player.PlayerData.money.cash >= petData.price then
            Player.Functions.RemoveMoney('cash', petData.price, 'buy-pet')
        elseif Player.PlayerData.money.bank >= petData.price then
            Player.Functions.RemoveMoney('bank', petData.price, 'buy-pet')
        else
            TriggerClientEvent('ap_pet:client:notify', src, 'error', Lang('not_enough_money'))
            return
        end
    end
    
    -- Insert into database
    local is_k9 = petData.type == 'k9'
    MySQL.insert('INSERT INTO player_pets (citizenid, pet_name, model, is_k9) VALUES (?, ?, ?, ?)', {
        citizenid, petName, petData.model, is_k9
    }, function(id)
        if id then
            TriggerClientEvent('ap_pet:client:notify', src, 'success', Lang('adopt_success', petName))
        else
            TriggerClientEvent('ap_pet:client:notify', src, 'error', Lang('adopt_fail'))
        end
    end)
end)

-- Save pet status to DB (called periodically)
RegisterNetEvent('ap_pet:server:savePetStatus', function(petId, h, f, t)
    MySQL.update('UPDATE player_pets SET health = ?, hunger = ?, thirst = ? WHERE id = ?', {
        h, f, t, petId
    })
end)

lib.callback.register('ap_pet:server:useItem', function(source, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local item = Player.Functions.GetItemByName(itemName)
    if item and item.amount > 0 then
        Player.Functions.RemoveItem(itemName, 1)
        return true
    else
        return false
    end
end)

lib.callback.register('ap_pet:server:feedPet', function(source, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false, nil end
    
    local itemsToCheck = type == 'food' and Config.PetNeeds.Items.Food or Config.PetNeeds.Items.Water
    if not itemsToCheck then return false, nil end

    for _, itemName in ipairs(itemsToCheck) do
        local item = Player.Functions.GetItemByName(itemName)
        if item and item.amount > 0 then
            Player.Functions.RemoveItem(itemName, 1)
            return true, itemName
        end
    end
    
    return false, nil
end)

lib.callback.register('ap_pet:server:sniffPlayer', function(source, targetId)
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then return false end
    
    local items = Target.PlayerData.items
    for _, item in pairs(items) do
        if item and item.amount > 0 then
            for _, contraband in ipairs(Config.ContrabandItems) do
                if item.name == contraband then
                    return true
                end
            end
        end
    end
    return false
end)

RegisterNetEvent('ap_pet:server:petDied', function(petId)
    MySQL.update('UPDATE player_pets SET is_dead = 1, health = 0 WHERE id = ?', {petId})
end)

RegisterNetEvent('ap_pet:server:revivePet', function(petId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local item = Player.Functions.GetItemByName('pet_revive')
    if item and item.amount > 0 then
        Player.Functions.RemoveItem('pet_revive', 1)
        MySQL.update('UPDATE player_pets SET is_dead = 0, health = 100, hunger = 100, thirst = 100 WHERE id = ?', {petId})
        TriggerClientEvent('ap_pet:client:notify', src, 'success', Lang('revive_success'))
    else
        TriggerClientEvent('ap_pet:client:notify', src, 'error', Lang('need_revive'))
    end
end)

RegisterNetEvent('ap_pet:server:deletePet', function(petId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    MySQL.query('DELETE FROM player_pets WHERE id = ? AND citizenid = ?', {petId, Player.PlayerData.citizenid})
end)

lib.callback.register('ap_pet:server:validateHeal', function(source, petId)
    -- This acts as a second check after the progress bar finishes
    -- The item was already consumed in 'useItem', but we could implement
    -- a more complex pending-heal queue if we wanted strictly zero exploits.
    -- For now, we simply return true to allow the client to set the HP.
    return true
end)
