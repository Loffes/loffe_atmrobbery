ESX = nil
local busy = false

CreateThread(function()
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) 
            ESX = obj 
        end)
        Wait(0) 
    end

    while ESX['GetPlayerData']()['job'] == nil do 
        Wait(0) 
    end

    CreateThread(function()
        while true do
            local sleep, PP = 250, PlayerPedId()
            if not busy then
                local obj 
                for k, v in pairs(Config['ATM']) do
                    local closest = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 2.0, GetHashKey(v))
                    if DoesEntityExist(closest) then
                        if DoesEntityExist(obj) then
                            if #(GetEntityCoords(closest) - GetEntityCoords(PP)) < #(GetEntityCoords(obj) - GetEntityCoords(PP)) then
                                obj = closest
                            end
                        else
                            obj = closest
                        end
                    end
                end

                if DoesEntityExist(obj) then
                    while #(GetEntityCoords(PP) - GetEntityCoords(obj)) <= 2.0 and not busy do
                        Wait(0)

                        Config['3DText'](GetOffsetFromEntityInWorldCoords(obj, 0.0, -0.5, 1.25), Strings['Rob'])

                        if IsControlJustReleased(0, 47) then

                            ESX['TriggerServerCallback']('loffe_atm:canRob', function(res)
                                if res[1] then
                                    busy = true

                                    TriggerServerEvent('loffe_atm:police', GetEntityCoords(PP))

                                    TaskStartScenarioInPlace(PP, 'WORLD_HUMAN_STAND_MOBILE', 0, true)

                                    Wait(2500)

                                    TriggerEvent('mhacking:show')
                                    
                                    TriggerEvent('mhacking:start', 4, 60, function(success)
                                        TriggerEvent('mhacking:hide')
                                        if success then
                                            TriggerServerEvent('loffe_atm:getMoney')
                                        end
                                        ClearPedTasks(PP)
                                        busy = false
                                    end)
                                else
                                    ESX['ShowNotification'](res[2])
                                end
                            end)
                        end
                    end
                end
            end

            Wait(sleep)
        end
    end)
end)

RegisterNetEvent('loffe_atm:alert')
AddEventHandler('loffe_atm:alert', function(coords)
    local timer = GetGameTimer() + 12500
    while GetGameTimer() <= timer do 
        Wait(0)
        AddTextEntry(GetCurrentResourceName(), Strings['Police'])
        DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
        if IsControlJustReleased(0, 47) then
            SetNewWaypoint(coords['x'], coords['y'])
            break
        end
    end
end)