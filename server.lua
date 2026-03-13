local ESX, QBCore = nil, nil
local usingESX, usingQBCore = false, false

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) if obj then ESX = obj usingESX = true end end)
    TriggerEvent('QBCore:GetObject', function(obj) if obj then QBCore = obj usingQBCore = true end end)
end)

function getPlayerIdentifier(src)
    if usingESX and ESX then 
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.identifier then return xPlayer.identifier end
    end
    if usingQBCore and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.citizenid then return Player.PlayerData.citizenid end
        for _,id in ipairs(GetPlayerIdentifiers(src)) do if string.find(id, "license:") or string.find(id, "steam:") then return id end end
    end
    return "global"
end

RegisterNetEvent('menu_traffic:isFounder')
AddEventHandler('menu_traffic:isFounder', function()
    local src = source
    local isFounder = false
    if usingESX and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local group = (xPlayer.getGroup and type(xPlayer.getGroup) == "function" and xPlayer:getGroup()) or xPlayer.group
            isFounder = group == "fondateur" -- change "fondateur" to your founder group name if different 
                                             -- change "fondateur" en le nom de votre groupe fondateur si différent
        end
    elseif usingQBCore and QBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData and Player.PlayerData.role then
            isFounder = Player.PlayerData.role == "fondateur" -- change "fondateur" to your founder role name if different 
                                                              -- change "fondateur" en le nom de votre rôle fondateur si différent
        end
    end
    TriggerClientEvent("menu_traffic:founderResult", src, isFounder)
end)

RegisterNetEvent('menu_traffic:getLangs')
AddEventHandler('menu_traffic:getLangs', function()
    local src = source
    TriggerClientEvent("menu_traffic:langs", src, Config.Languages or {})
end)

RegisterNetEvent('menu_traffic:loadDensity')
AddEventHandler('menu_traffic:loadDensity', function()
    local src = source
    local identifier = getPlayerIdentifier(src)
    exports.oxmysql:execute("SELECT * FROM density_settings WHERE identifier = @id", {["@id"]=identifier}, function(result)
        if result and result[1] then
            TriggerClientEvent('menu_traffic:applyDensity', src, {
                vehicle = result[1].vehicle,
                parked = result[1].parked,
                ped = result[1].ped,
                scene = result[1].scene,
                police = result[1].police,
            })
        else
            TriggerClientEvent('menu_traffic:applyDensity', src, Config.DefaultDensity)
        end
    end)
end)

RegisterNetEvent('menu_traffic:saveDensity')
AddEventHandler('menu_traffic:saveDensity', function(density)
    local src = source
    local identifier = getPlayerIdentifier(src)
    if not density then return end
    exports.oxmysql:execute("REPLACE INTO density_settings (identifier,vehicle,parked,ped,scene,police) VALUES (@id,@veh,@par,@ped,@scen,@pol)",
        {
            ["@id"]=identifier,
            ["@veh"]=density.vehicle or 1,
            ["@par"]=density.parked or 1,
            ["@ped"]=density.ped or 1,
            ["@scen"]=density.scene or 1,
            ["@pol"]=density.police or 1
        })
end)

-- Suppression auto véhicules si activée (auto vehicle wipe if activated)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(8000)
        if Config.EnableDeleteAllVehiclesOverPlayers then
            local players = GetPlayers()
            if #players >= (Config.DeleteAllVehiclesOverPlayers or 80) then
                for _,id in ipairs(players) do
                    TriggerClientEvent("menu_traffic:deleteAllVehicles", id)
                end
            end
        end
    end
end)