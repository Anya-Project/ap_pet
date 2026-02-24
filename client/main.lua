local QBCore = exports['qb-core']:GetCoreObject()

activePet = nil
activePetData = nil
isHUDVisible = false

-- Function to load models
local function loadModel(model)
    local waitTime = 0
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
        waitTime = waitTime + 100
        if waitTime > 5000 then return false end
    end
    return true
end

-- Open Pet Main Menu
RegisterNetEvent('ap_pet:client:openMenu', function()
    local pets = lib.callback.await('ap_pet:server:getPlayerPets', false)
    
    local options = {}
    
    if activePet then
        table.insert(options, {
            title = Lang('return_pet', activePetData.pet_name),
            description = Lang('return_pet_desc'),
            icon = 'box-open',
            onSelect = function()
                DespawnPet()
            end
        })
        table.insert(options, {
            title = Lang('command_pet_menu'),
            description = Lang('command_pet_desc'),
            icon = 'paw',
            onSelect = function()
                OpenPetInteractMenu()
            end
        })
    else
        table.insert(options, {
            title = Lang('summon_pet_menu'),
            description = Lang('summon_pet_desc'),
            icon = 'dog',
            onSelect = function()
                OpenPetSelectionMenu(pets)
            end
        })
    end
    
    if Config.PetShop.CommandAccess then
        table.insert(options, {
            title = Lang('shop_menu'),
            description = Lang('shop_menu_desc'),
            icon = 'shop',
            onSelect = function()
                OpenPetShopMenu()
            end
        })
    end

    UI.ShowMenu('ap_pet_main_menu', Lang('main_menu_title'), options)
end)

function OpenPetSelectionMenu(pets)
    if #pets == 0 then
        UI.Notify('error', Lang('no_pet'))
        return
    end
    
    local options = {}
    for i, pet in ipairs(pets) do
        if pet.is_dead == 1 or pet.is_dead == true then
            table.insert(options, {
                title = Lang('pet_dead_status', pet.pet_name),
                description = Lang('pet_dead_desc'),
                icon = 'skull',
                onSelect = function()
                    OpenDeadPetActionMenu(pet)
                end
            })
        else
            table.insert(options, {
                title = pet.pet_name,
                description = Lang('pet_info', pet.model, pet.health),
                icon = 'bone',
                onSelect = function()
                    OpenPetActionMenu(pet)
                end
            })
        end
    end
    
    UI.ShowMenu('ap_pet_selection_menu', Lang('pet_menu_title'), options)
end

function OpenPetActionMenu(pet)
    local options = {
        {
            title = Lang('spawn_pet', pet.pet_name),
            description = Lang('spawn_pet_desc'),
            icon = 'arrow-right-from-bracket',
            onSelect = function()
                SpawnPet(pet)
            end
        },
        {
            title = Lang('delete_pet'),
            description = Lang('delete_pet_desc'),
            icon = 'trash',
            iconColor = '#ff4757',
            onSelect = function()
                DeletePetFromMenu(pet)
            end
        }
    }

    UI.ShowMenu('ap_pet_action_menu', Lang('pet_action_title', pet.pet_name), options)
end

function OpenDeadPetActionMenu(pet)
    local options = {
        {
            title = Lang('revive_pet'),
            description = Lang('revive_pet_desc'),
            icon = 'syringe',
            onSelect = function()
                TriggerServerEvent('ap_pet:server:revivePet', pet.id)
            end
        },
        {
            title = Lang('delete_pet'),
            description = Lang('delete_pet_desc'),
            icon = 'trash',
            iconColor = '#ff4757',
            onSelect = function()
                DeletePetFromMenu(pet)
            end
        }
    }

    UI.ShowMenu('ap_dead_pet_action_menu', Lang('pet_dead_action_title', pet.pet_name), options)
end

function DeletePetFromMenu(pet)
    UI.ShowAlert(Lang('confirm_delete_title', pet.pet_name), Lang('confirm_delete_content', pet.pet_name), Lang('cancel'), Lang('confirm_delete'), function(confirmed)
        if confirmed then
            TriggerServerEvent('ap_pet:server:deletePet', pet.id)
            
            -- Jika pet yang dihapus kebetulan sedang aktif dikeluarkan
            if activePetData and activePetData.id == pet.id then
                local pedToDelete = activePet
                local petNameToDelete = activePetData.pet_name
                activePet = nil
                activePetData = nil
                
                SendNUIMessage({ action = "hideHUD" })
                isHUDVisible = false
                
                if Config.TargetSystem == 'ox' or (Config.TargetSystem == 'autodetect' and GetResourceState('ox_target') == 'started') then
                    exports.ox_target:removeLocalEntity(pedToDelete, 'pet_interact_' .. pedToDelete)
                elseif Config.TargetSystem == 'qb' or (Config.TargetSystem == 'autodetect' and GetResourceState('qb-target') == 'started') then
                    exports['qb-target']:RemoveTargetEntity(pedToDelete, 'Berinteraksi dengan ' .. petNameToDelete)
                    exports['qb-target']:RemoveGlobalPed({'K9: Endus Target', 'K9: Serang Target'})
                end
                
                DeleteEntity(pedToDelete)
            end
            
            UI.Notify('success', Lang('pet_deleted'))
        else
            UI.Notify('inform', Lang('pet_delete_cancel'))
        end
    end)
end

function OpenPetShopMenu()
    local options = {}
    for key, data in pairs(Config.AvailablePets) do
        local isK9 = data.type == 'k9'
        table.insert(options, {
            title = data.name .. (isK9 and Lang('pet_shop_k9') or ''),
            description = isK9 and Lang('pet_shop_free') or Lang('pet_shop_price', data.price),
            icon = 'tag',
            onSelect = function()
                UI.ShowInput(Lang('pet_name_input'), {
                    {type = 'input', label = Lang('pet_name_label'), required = true, min = 3, max = 15}
                }, function(input)
                    if input and input[1] then
                        TriggerServerEvent('ap_pet:server:buyPet', key, input[1])
                    end
                end)
            end
        })
    end
    
    UI.ShowMenu('ap_pet_shop_menu', Lang('pet_shop_title'), options)
end


-- SPAWN PET LOGIC
function SpawnPet(petData)
    if activePet then DespawnPet() end
    
    local model = GetHashKey(petData.model)
    if not loadModel(model) then
        UI.Notify('error', Lang('adopt_fail_model'))
        return
    end
    
    local playerPed = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)
    
    activePet = CreatePed(28, model, pos.x, pos.y, pos.z, GetEntityHeading(playerPed), true, false)
    activePetData = petData
    
    SetEntityAsMissionEntity(activePet, true, true)
    SetPedCanBeTargetted(activePet, false)
    SetPedCanBeKnockedOffVehicle(activePet, true)
    SetPedCanRagdoll(activePet, true)
    SetBlockingOfNonTemporaryEvents(activePet, true)
    SetPedFleeAttributes(activePet, 0, 0)
    
    -- Sync health
    SetEntityHealth(activePet, 200) -- Default max FiveM health
    -- (In future we will scale the literal Health bar to petData.health)
    
    UI.Notify('success', Lang('pet_called', petData.pet_name))
    
    TaskFollowToOffsetOfEntity(activePet, playerPed, 2.0, -2.0, 0.0, 7.0, -1, 1.0, true)
    
    -- Show UI
    SendNUIMessage({ action = "showHUD" })
    SendNUIMessage({
        action = "updateHUD",
        name = petData.pet_name,
        health = petData.health,
        hunger = petData.hunger,
        thirst = petData.thirst,
        status = 'following'
    })
    isHUDVisible = true
    
    -- Setup Target
    if Config.TargetSystem == 'ox' or (Config.TargetSystem == 'autodetect' and GetResourceState('ox_target') == 'started') then
        exports.ox_target:addLocalEntity(activePet, {
            {
                name = 'pet_interact_' .. activePet,
                icon = 'fas fa-paw',
                label = Lang('interact_label', petData.pet_name),
                onSelect = function()
                    OpenPetInteractMenu()
                end
            }
        })
        
        -- Tambahkan Target ke semua Ped lain untuk opsi K9 Attack/Sniff jika is_k9
        if petData.is_k9 == 1 or petData.is_k9 == true then
            exports.ox_target:addGlobalPed({
                {
                    name = 'k9_sniff_target',
                    icon = 'fas fa-magnifying-glass',
                    label = Lang('k9_sniff'),
                    canInteract = function(entity)
                        -- Cek 1: Pet dipanggil, Cek 2: Target bukan diri sendiri, Cek 3: Target bukan pet itu sendiri
                        return activePet and entity ~= PlayerPedId() and entity ~= activePet and IsEntityAPed(entity)
                    end,
                    onSelect = function(data)
                        TriggerEvent('ap_pet:client:sniffTarget', data.entity)
                    end
                },
                {
                    name = 'k9_attack_target',
                    icon = 'fas fa-skull',
                    label = Lang('k9_attack'),
                    canInteract = function(entity)
                        return activePet and entity ~= PlayerPedId() and entity ~= activePet and IsEntityAPed(entity)
                    end,
                    onSelect = function(data)
                        TriggerEvent('ap_pet:client:attackTarget', data.entity)
                    end
                }
            })
        end
    elseif Config.TargetSystem == 'qb' or (Config.TargetSystem == 'autodetect' and GetResourceState('qb-target') == 'started') then
        exports['qb-target']:AddTargetEntity(activePet, {
            options = {
                {
                    icon = 'fas fa-paw',
                    label = Lang('interact_label', petData.pet_name),
                    action = function()
                        OpenPetInteractMenu()
                    end
                }
            },
            distance = 2.5
        })
        
        if petData.is_k9 == 1 or petData.is_k9 == true then
            exports['qb-target']:AddGlobalPed({
                options = {
                    {
                        icon = 'fas fa-magnifying-glass',
                        label = Lang('k9_sniff'),
                        canInteract = function(entity)
                            -- Cek 1: Pet dipanggil, Cek 2: Target bukan diri sendiri, Cek 3: Target bukan pet itu sendiri
                            return activePet and entity ~= PlayerPedId() and entity ~= activePet and IsEntityAPed(entity)
                        end,
                        action = function(entity)
                            TriggerEvent('ap_pet:client:sniffTarget', entity)
                        end
                    },
                    {
                        icon = 'fas fa-skull',
                        label = Lang('k9_attack'),
                        canInteract = function(entity)
                            return activePet and entity ~= PlayerPedId() and entity ~= activePet and IsEntityAPed(entity)
                        end,
                        action = function(entity)
                            TriggerEvent('ap_pet:client:attackTarget', entity)
                        end
                    }
                },
                distance = 3.0
            })
        end
    end
    
    -- Start Needs Loop
    StartNeedsLoop()
end

-- DESPAWN PET LOGIC
function DespawnPet()
    if DoesEntityExist(activePet) then
        if Config.TargetSystem == 'ox' or (Config.TargetSystem == 'autodetect' and GetResourceState('ox_target') == 'started') then
            exports.ox_target:removeLocalEntity(activePet, 'pet_interact_' .. activePet)
            -- Untuk ox_target global ped remove (belum disupport luas di docs lama, tapi bisa diakali via model)
        elseif Config.TargetSystem == 'qb' or (Config.TargetSystem == 'autodetect' and GetResourceState('qb-target') == 'started') then
            exports['qb-target']:RemoveTargetEntity(activePet, Lang('interact_label', activePetData.pet_name))
            if activePetData.is_k9 == 1 or activePetData.is_k9 == true then
                exports['qb-target']:RemoveGlobalPed({Lang('k9_sniff'), Lang('k9_attack')})
            end
        end
        
        -- Save current status to DB
        if activePetData then
            TriggerServerEvent('ap_pet:server:savePetStatus', activePetData.id, activePetData.health, activePetData.hunger, activePetData.thirst)
        end
        
        DeleteEntity(activePet)
    end
    activePet = nil
    activePetData = nil
    
    SendNUIMessage({ action = "hideHUD" })
    isHUDVisible = false
    
    UI.Notify('inform', Lang('pet_returned'))
end

-- LOOP KEBUTUHAN & HEALTH CHECK
function StartNeedsLoop()
    CreateThread(function()
        local nextNeedsTick = GetGameTimer() + Config.PetNeeds.LossRate.TickRate
        local lastHp = -1 -- Cache HP to prevent spamming NUI
        
        while activePet do
            Wait(1000) -- Check health every 1 second
            
            if activePet and activePetData then
                -- HP SYNC LOGIC
                local currentHp = GetEntityHealth(activePet) -- Scale varies by model, usually 100-200. Max 200.
                if currentHp > 0 then
                    local calculatedHp = math.floor((currentHp / 200) * 100)
                    if calculatedHp > 100 then calculatedHp = 100 end
                    
                    if lastHp ~= calculatedHp then
                        activePetData.health = calculatedHp
                        lastHp = calculatedHp
                        
                        SendNUIMessage({
                            action = "updateHUD",
                            health = activePetData.health
                        })
                    end
                end
                
                -- Death check dari tembakan/damage physical
                if currentHp <= 0 or (currentHp <= 100 and IsEntityDead(activePet)) then
                    activePetData.health = 0
                    SendNUIMessage({ action = "updateHUD", health = 0 })
                    
                    UI.Notify('error', Lang('pet_shot', activePetData.pet_name))
                    TriggerServerEvent('ap_pet:server:petDied', activePetData.id)
                    
                    Wait(5000)
                    DespawnPet()
                end
                
                -- HUNGER/THIRST LOGIC (Tick Rate Based)
                if GetGameTimer() > nextNeedsTick then
                    -- Reduce Hunger & Thirst
                    activePetData.hunger = math.max(0, activePetData.hunger - Config.PetNeeds.LossRate.Hunger)
                    activePetData.thirst = math.max(0, activePetData.thirst - Config.PetNeeds.LossRate.Thirst)
                    
                    -- Reduce health if starving/dehydrated (simulated damage)
                    if activePetData.hunger <= 0 or activePetData.thirst <= 0 then
                        local newHp = math.max(0, currentHp - 10)
                        SetEntityHealth(activePet, newHp)
                    end
                    
                    -- Update UI
                    SendNUIMessage({
                        action = "updateHUD",
                        hunger = activePetData.hunger,
                        thirst = activePetData.thirst
                    })
                    
                    -- Save state
                    TriggerServerEvent('ap_pet:server:savePetStatus', activePetData.id, activePetData.health, activePetData.hunger, activePetData.thirst)
                    
                    nextNeedsTick = GetGameTimer() + Config.PetNeeds.LossRate.TickRate
                end
            end
        end
    end)
end

-- Clean up on player disconnect or resource stop
local shopPeds = {}

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    DespawnPet()
    
    for _, ped in ipairs(shopPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

-- PET SHOP LOCATIONS LOGIC
CreateThread(function()
    if not Config.PetShop or not Config.PetShop.Locations then return end
    
    for i, shop in ipairs(Config.PetShop.Locations) do
        -- 1. Create Blip
        if shop.blip.enable then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, shop.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, shop.blip.scale)
            SetBlipColour(blip, shop.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.blip.name)
            EndTextCommandSetBlipName(blip)
        end
        
        -- 2. Create Ped
        local model = GetHashKey(shop.pedModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end
        
        local ped = CreatePed(0, model, shop.coords.x, shop.coords.y, shop.coords.z - 1.0, shop.coords.w, false, false)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        table.insert(shopPeds, ped)
        
        -- 3. Add Target Interaction
        if Config.TargetSystem == 'ox' or (Config.TargetSystem == 'autodetect' and GetResourceState('ox_target') == 'started') then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'pet_shop_npc_'..i,
                    icon = 'fas fa-shop',
                    label = Lang('shop_menu'),
                    onSelect = function()
                        OpenPetShopMenu()
                    end
                }
            })
        elseif Config.TargetSystem == 'qb' or (Config.TargetSystem == 'autodetect' and GetResourceState('qb-target') == 'started') then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = 'fas fa-shop',
                        label = Lang('shop_menu'),
                        action = function()
                            OpenPetShopMenu()
                        end
                    }
                },
                distance = 2.5
            })
        end
    end
end)
