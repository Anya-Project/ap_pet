UI = {}

local QBCore, ESX = nil, nil

CreateThread(function()
    if Config.Framework == 'qb' or Config.Framework == 'autodetect' and GetResourceState('qb-core') == 'started' then
        pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
    elseif Config.Framework == 'esx' or Config.Framework == 'autodetect' and GetResourceState('es_extended') == 'started' then
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
    end
end)

-- ===========================
-- MENU BRIDGE
-- ===========================
function UI.ShowMenu(id, title, options)
    if Config.UI.Menu == 'ox_lib' then
        lib.registerContext({
            id = id,
            title = title,
            options = options
        })
        lib.showContext(id)
    elseif Config.UI.Menu == 'qb-menu' then
        -- Convert ox_lib options to qb-menu syntax
        local qbOptions = {
            {
                header = title,
                isMenuHeader = true
            }
        }
        
        for k, v in pairs(options) do
            local btn = {
                header = v.title,
                txt = v.description,
                icon = v.icon,
                params = {
                    event = 'ap_pet:client:bridgeMenuSelect',
                    args = v.onSelect -- Since we can't pass function directly to qb-menu args safely
                }
            }
            if not v.onSelect then btn.params = nil end
            table.insert(qbOptions, btn)
        end
        exports['qb-menu']:openMenu(qbOptions)
    elseif Config.UI.Menu == 'lation_ui' then
        local lationOptions = {}
        for k, v in pairs(options) do
            table.insert(lationOptions, {
                title = v.title,
                description = v.description,
                icon = (v.icon and 'fas fa-'..v.icon) or nil,
                onSelect = v.onSelect
            })
        end
        exports.lation_ui:registerMenu({
            id = id,
            title = title,
            options = lationOptions
        })
        exports.lation_ui:showMenu(id)
    else
        -- Place custom UI menu logic here
        print("UI Menu Not Supported: " .. Config.UI.Menu)
    end
end

-- ===========================
-- DIALOG / ALERT BRIDGE
-- ===========================
function UI.ShowAlert(header, content, cancelLabel, confirmLabel, cb)
    if Config.UI.Menu == 'ox_lib' then
        local alert = lib.alertDialog({
            header = header,
            content = content,
            centered = true,
            cancel = true,
            labels = {
                cancel = cancelLabel,
                confirm = confirmLabel
            }
        })
        if alert == 'confirm' then cb(true) else cb(false) end
    else
        -- Fallback to standard input or standard QBCore Yes/No notify if applicable
        -- For simplicity in generic bridge, if it's not ox_lib, we use a command approach or skip visual alert.
        -- We strongly recommend ox_lib for Alerts
        print("Bridge Alert used non-oxlib. Auto-confirming.")
        cb(true)
    end
end

-- ===========================
-- INPUT BRIDGE
-- ===========================
function UI.ShowInput(title, inputObj, cb)
    if Config.UI.Input == 'ox_lib' then
        local input = lib.inputDialog(title, inputObj)
        cb(input)
    elseif Config.UI.Input == 'qb-input' then
        -- simple conversion for single input
        local dialog = exports['qb-input']:ShowInput({
            header = title,
            submitText = "Submit",
            inputs = {
                {
                    text = inputObj[1].label,
                    name = "input1",
                    type = "text",
                    isRequired = true
                }
            }
        })
        if dialog and dialog.input1 then
            cb({dialog.input1})
        else
            cb(nil)
        end
    elseif Config.UI.Input == 'lation_ui' then
        local dialogArgs = {
            title = title,
            options = {}
        }
        
        for k, v in ipairs(inputObj) do
            table.insert(dialogArgs.options, {
                type = v.type == 'input' and 'input' or 'input', -- lation uses 'input', 'number', etc. We fallback to 'input'
                label = v.label,
                required = v.required
            })
        end
        
        local result = exports.lation_ui:input(dialogArgs)
        if result then
            cb(result)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end

-- ===========================
-- NOTIFY BRIDGE
-- ===========================
function UI.Notify(type, text)
    if Config.UI.Notify == 'ox_lib' then
        lib.notify({ type = type, description = text })
    elseif Config.UI.Notify == 'qbcore' and QBCore then
        QBCore.Functions.Notify(text, type, 3000)
    elseif Config.UI.Notify == 'esx' and ESX then
        ESX.ShowNotification(text, type)
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
end

RegisterNetEvent('ap_pet:client:notify', function(type, text)
    UI.Notify(type, text)
end)

-- ===========================
-- PROGRESS BAR BRIDGE
-- ===========================
function UI.ProgressBar(duration, label, animDict, animClip, cb)
    if Config.UI.ProgressBar == 'ox_lib' then
        if lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true },
            anim = { dict = animDict, clip = animClip }
        }) then
            cb(true)
        else
            cb(false)
        end
    elseif Config.UI.ProgressBar == 'qbcore' and QBCore then
        QBCore.Functions.Progressbar("pet_action", label, duration, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = animDict,
            anim = animClip,
            flags = 49,
        }, {}, {}, function() -- Done
            cb(true)
        end, function() -- Cancel
            cb(false)
        end)
    elseif Config.UI.ProgressBar == 'lation_ui' then
        local success = exports.lation_ui:progressBar({
            label = label,
            duration = duration,
            useWhileDead = false,
            canCancel = true,
            disable = { move = true, car = true, mouse = false, combat = true },
            anim = { dict = animDict, clip = animClip }
        })
        if success then
            cb(true)
        else
            cb(false)
        end
    else
        -- Fallback
        Wait(duration)
        cb(true)
    end
end

-- ===========================
-- INTERNAL EVENTS
-- ===========================
-- Untuk callback fungsi anonim di qb-menu
RegisterNetEvent('ap_pet:client:bridgeMenuSelect', function(cbFunc)
    if type(cbFunc) == "function" then
        cbFunc()
    end
end)
