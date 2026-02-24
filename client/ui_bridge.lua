UI = {}

local QBCore, ESX = nil, nil

CreateThread(function()
    if Config.Framework == 'qb' or Config.Framework == 'autodetect' and GetResourceState('qb-core') == 'started' then
        pcall(function() QBCore = exports['qb-core']:GetCoreObject() end)
    elseif Config.Framework == 'esx' or Config.Framework == 'autodetect' and GetResourceState('es_extended') == 'started' then
        pcall(function() ESX = exports['es_extended']:getSharedObject() end)
    end
end)

function UI.ShowMenu(id, title, options)
    if Config.UI.Menu == 'ox_lib' then
        lib.registerContext({
            id = id,
            title = title,
            options = options
        })
        lib.showContext(id)
    elseif Config.UI.Menu == 'qb-menu' then
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
                    args = v.onSelect
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
        print("UI Menu Not Supported: " .. Config.UI.Menu)
    end
end

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
        print("Bridge Alert used non-oxlib. Auto-confirming.")
        cb(true)
    end
end

function UI.ShowInput(title, inputObj, cb)
    if Config.UI.Input == 'ox_lib' then
        local input = lib.inputDialog(title, inputObj)
        cb(input)
    elseif Config.UI.Input == 'qb-input' then
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
                type = v.type == 'input' and 'input' or 'input',
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
        }, {}, {}, function()
            cb(true)
        end, function()
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
        Wait(duration)
        cb(true)
    end
end

RegisterNetEvent('ap_pet:client:bridgeMenuSelect', function(cbFunc)
    if type(cbFunc) == "function" then
        cbFunc()
    end
end)
