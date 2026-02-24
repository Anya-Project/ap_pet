function OpenPetInteractMenu()
    local options = {
        {
            title = Lang('feed_food'),
            description = Lang('feed_food_desc'),
            icon = 'bone',
            onSelect = function()
                FeedPet('food')
            end
        },
        {
            title = Lang('feed_water'),
            description = Lang('feed_water_desc'),
            icon = 'droplet',
            onSelect = function()
                FeedPet('water')
            end
        },
        {
            title = Lang('pet_dog'),
            description = Lang('pet_dog_desc'),
            icon = 'hand',
            onSelect = function()
                PetTheDog()
            end
        },
        {
            title = Lang('heal_pet_action'),
            description = Lang('heal_pet_desc'),
            icon = 'briefcase-medical',
            onSelect = function()
                HealPet()
            end
        }
    }

    local cmdSitAllowed = true
    if activePetData then
        for k, v in pairs(Config.AvailablePets) do
            if v.model == activePetData.model then
                if v.canSit == false then
                    cmdSitAllowed = false
                end
                break
            end
        end
    end

    if cmdSitAllowed then
        table.insert(options, {
            title = Lang('command_sit_follow'),
            icon = 'chair',
            onSelect = function()
                ToggleSit()
            end
        })
    end

    table.insert(options, {
        title = Lang('toggle_vehicle'),
        description = Lang('toggle_vehicle_desc'),
        icon = 'car',
        onSelect = function()
            ToggleVehicle()
        end
    })

    table.insert(options, {
        title = Lang('delete_pet'),
        description = Lang('delete_pet_desc'),
        icon = 'trash-can',
        iconColor = '#ff4757',
        onSelect = function()
            DeletePetPermanently()
        end
    })

    UI.ShowMenu('ap_pet_interact_menu', Lang('interact_title'), options)
end

function FeedPet(type)
    if not activePet or not activePetData then return end
    
    lib.callback('ap_pet:server:feedPet', false, function(success, itemName)
        if success then
            TaskTurnPedToFaceEntity(PlayerPedId(), activePet, 1000)
            Wait(1000)
            
            UI.ProgressBar(3000, type == 'food' and Lang('prog_food') or Lang('prog_water'), 'creatures@rottweiler@tricks@', 'petting_franklin', function(successAnim)
                if successAnim then
                    if type == 'food' then
                        activePetData.hunger = math.min(100, activePetData.hunger + 40)
                    else
                        activePetData.thirst = math.min(100, activePetData.thirst + 40)
                    end
                    SendNUIMessage({
                        action = "updateHUD",
                        hunger = activePetData.hunger,
                        thirst = activePetData.thirst
                    })
                    TriggerServerEvent('ap_pet:server:savePetStatus', activePetData.id, activePetData.health, activePetData.hunger, activePetData.thirst)
                    UI.Notify('success', Lang('feed_success', itemName))
                end
            end)
        else
            UI.Notify('error', Lang('no_item', type))
        end
    end, type)
end

function PetTheDog()
    if not activePet then return end
    TaskTurnPedToFaceEntity(PlayerPedId(), activePet, 1000)
    Wait(1000)
    UI.ProgressBar(5000, Lang('prog_play'), 'creatures@rottweiler@tricks@', 'petting_franklin', function(success)
    end)
end

function HealPet()
    if not activePet or not activePetData then return end
    
    lib.callback('ap_pet:server:useItem', false, function(hasItem)
        if hasItem then
            TaskTurnPedToFaceEntity(PlayerPedId(), activePet, 1000)
            Wait(1000)
            
            UI.ProgressBar(4000, Lang('prog_heal'), 'amb@medic@standing@kneel@base', 'base', function(success)
                if success then
                    lib.callback('ap_pet:server:validateHeal', false, function(isValid)
                        if isValid then
                            local maxHp = GetEntityMaxHealth(activePet)
                            SetEntityHealth(activePet, maxHp)
                            
                            activePetData.health = 100
                            
                            SendNUIMessage({
                                action = "updateHUD",
                                health = activePetData.health
                            })
                            
                            TriggerServerEvent('ap_pet:server:savePetStatus', activePetData.id, activePetData.health, activePetData.hunger, activePetData.thirst)
                            UI.Notify('success', Lang('heal_success'))
                        else
                            UI.Notify('error', Lang('need_revive'))
                        end
                    end, activePetData.id)
                end
            end)
        else
            UI.Notify('error', Lang('no_item', 'pet_medkit'))
        end
    end, 'pet_medkit')
end

function ToggleSit()
    if not activePet or not activePetData then return end
    
    if activePetData.status == 'sitting' then
        activePetData.status = 'following'
        ClearPedTasks(activePet)
        TaskFollowToOffsetOfEntity(activePet, PlayerPedId(), 1.5, -1.5, 0.0, 7.0, -1, 1.0, true)
        
        SendNUIMessage({
            action = "updateHUD",
            status = 'following'
        })
    else
        activePetData.status = 'sitting'
        lib.requestAnimDict('creatures@rottweiler@amb@world_dog_sitting@base')
        TaskPlayAnim(activePet, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
        
        SendNUIMessage({
            action = "updateHUD",
            status = 'sitting'
        })
    end
end

function ToggleVehicle()
    if not activePet then return end
    
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if IsPedInAnyVehicle(activePet, false) then
        -- Keluar
        TaskLeaveVehicle(activePet, GetVehiclePedIsIn(activePet, false), 256)
        Wait(2000)
        TaskFollowToOffsetOfEntity(activePet, playerPed, 1.5, -1.5, 0.0, 7.0, -1, 1.0, true)
    else
        if vehicle and vehicle ~= 0 then
            -- Masuk
            local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
            for i = 0, maxSeats - 1 do
                if IsVehicleSeatFree(vehicle, i) then
                    TaskEnterVehicle(activePet, vehicle, -1, i, 2.0, 1, 0)
                    break
                end
            end
        else
            UI.Notify('error', Lang('need_vehicle'))
        end
    end
end

function DeletePetPermanently()
    if not activePet or not activePetData then return end

    UI.ShowAlert(Lang('confirm_delete_title', activePetData.pet_name), Lang('confirm_delete_content', activePetData.pet_name), Lang('cancel'), Lang('confirm_delete'), function(confirmed)
        if confirmed then
            TriggerServerEvent('ap_pet:server:deletePet', activePetData.id)
            
            local pedToDelete = activePet
            local petNameToDelete = activePetData.pet_name
            activePet = nil
            activePetData = nil
            
            SendNUIMessage({ action = "hideHUD" })
            isHUDVisible = false
            
            if Config.TargetSystem == 'ox' or (Config.TargetSystem == 'autodetect' and GetResourceState('ox_target') == 'started') then
                exports.ox_target:removeLocalEntity(pedToDelete, 'pet_interact_' .. pedToDelete)
            elseif Config.TargetSystem == 'qb' or (Config.TargetSystem == 'autodetect' and GetResourceState('qb-target') == 'started') then
                exports['qb-target']:RemoveTargetEntity(pedToDelete, Lang('interact_label', petNameToDelete))
                exports['qb-target']:RemoveGlobalPed({Lang('k9_sniff'), Lang('k9_attack')})
            end
            
            DeleteEntity(pedToDelete)
            UI.Notify('success', Lang('pet_deleted'))
        else
            UI.Notify('inform', Lang('pet_delete_cancel'))
        end
    end)
end

RegisterNetEvent('ap_pet:client:sniffTarget', function(entity)
    if not activePet or not entity then return end
    
    local playerPed = PlayerPedId()
    local targetPed = entity
    local isTargetPlayer = IsPedAPlayer(targetPed)
    
    UI.Notify('inform', Lang('k9_sniffing'))
    
    TaskGoToEntity(activePet, targetPed, -1, 1.0, 7.0, 1073741824, 0)
    Wait(2000)
    
    lib.requestAnimDict('missfra0_1ig_6')
    TaskPlayAnim(activePet, 'missfra0_1ig_6', 'dog_sniff_ground', 8.0, -8.0, 2000, 1, 0, false, false, false)
    Wait(2000)
    
    if isTargetPlayer then
        local targetPlayerId = NetworkGetPlayerIndexFromPed(targetPed)
        local targetServerId = GetPlayerServerId(targetPlayerId)
        
        lib.callback('ap_pet:server:sniffPlayer', false, function(found)
            if found then
                UI.Notify('success', Lang('k9_bark'))
                PlayAmbientSpeech1(activePet, "BARK_TENSE", "SPEECH_PARAMS_FORCE")
                TaskPlayAnim(activePet, 'creatures@rottweiler@indication@', 'indicate_high', 8.0, -8.0, 3000, 1, 0, false, false, false)
            else
                UI.Notify('inform', Lang('k9_clean'))
                PlayAmbientSpeech1(activePet, "GENERIC_NORMAL", "SPEECH_PARAMS_FORCE")
            end
            Wait(3000)
            TaskFollowToOffsetOfEntity(activePet, playerPed, 1.5, -1.5, 0.0, 7.0, -1, 1.0, true)
        end, targetServerId)
    else
        UI.Notify('inform', Lang('k9_npc_clean'))
        PlayAmbientSpeech1(activePet, "GENERIC_NORMAL", "SPEECH_PARAMS_FORCE")
        Wait(3000)
        TaskFollowToOffsetOfEntity(activePet, playerPed, 1.5, -1.5, 0.0, 7.0, -1, 1.0, true)
    end
end)

RegisterNetEvent('ap_pet:client:attackTarget', function(entity)
    if not activePet or not entity then return end
    
    local playerPed = PlayerPedId()
    
    UI.Notify('error', Lang('k9_attacking'))
    PlayAmbientSpeech1(activePet, "BARK_TENSE", "SPEECH_PARAMS_FORCE")
    
    ClearPedTasks(activePet)
    SetPedRelationshipGroupHash(activePet, GetHashKey("K9"))
    SetPedRelationshipGroupHash(entity, GetHashKey("TARGET"))
    SetRelationshipBetweenGroups(5, GetHashKey("K9"), GetHashKey("TARGET"))
    
    TaskCombatPed(activePet, entity, 0, 16)
    
    CreateThread(function()
        local attackTimeout = GetGameTimer() + 10000
        
        while activePet do
            Wait(500)
            
            if GetGameTimer() > attackTimeout or IsEntityDead(entity) or GetEntityHealth(entity) <= 100 then
                ClearPedTasks(activePet)
                
                ClearPedRelationshipGroupHash(activePet)
                ClearPedRelationshipGroupHash(entity)
                
                UI.Notify('inform', Lang('k9_return'))
                TaskFollowToOffsetOfEntity(activePet, playerPed, 1.5, -1.5, 0.0, 7.0, -1, 1.0, true)
                break
            end
        end
    end)
end)
