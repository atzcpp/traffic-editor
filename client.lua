ESX, QBCore = nil, nil
local isFounder, nuiActive = false, false
local currentLang = "fr" -- default language, change if you want (EN/FR)
                         -- langue par défaut, changez si vous voulez (EN/FR)
local langs = {}        
local currentDensities = {vehicle=1.0, parked=1.0, ped=1.0, scene=1.0, police=1.0}

-- Densities apply every frame when their value is > 0, entities are deleted only when set to 0
local deleteVehicles, deletePeds = false, false

local function applyVehicleDensities(d)
    SetVehicleDensityMultiplierThisFrame(tonumber(d.vehicle) or 1.0)
    SetRandomVehicleDensityMultiplierThisFrame(tonumber(d.vehicle) or 1.0)
    SetParkedVehicleDensityMultiplierThisFrame(tonumber(d.parked) or 1.0)
    SetPoliceIgnorePlayer(PlayerPedId(), (tonumber(d.police) or 1.0) < 0.01)
    SetDispatchCopsForPlayer(PlayerId(), (tonumber(d.police) or 1.0) > 0.01)
end

local function applyPedDensities(d)
    SetPedDensityMultiplierThisFrame(tonumber(d.ped) or 1.0)
    SetScenarioPedDensityMultiplierThisFrame(tonumber(d.scene) or 1.0, tonumber(d.scene) or 1.0)
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        if not handle or handle == -1 then return end
        local finished = false
        repeat
            coroutine.yield(veh)
            finished, veh = FindNextVehicle(handle)
        until not finished
        EndFindVehicle(handle)
    end)
end

function EnumeratePeds()
    return coroutine.wrap(function()
        local handle, ped = FindFirstPed()
        if not handle or handle == -1 then return end
        local finished = false
        repeat
            coroutine.yield(ped)
            finished, ped = FindNextPed(handle)
        until not finished
        EndFindPed(handle)
    end)
end

local function deleteAmbientEntitiesIfNecessary()
    -- Vehicles
    deleteVehicles = (tonumber(currentDensities.vehicle) == 0 or tonumber(currentDensities.parked) == 0)
    if deleteVehicles then
        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)
        for vehicle in EnumerateVehicles() do
            if vehicle ~= playerVeh then
                local remove = false
                -- Delete if traffic and density vehicle == 0
                if tonumber(currentDensities.vehicle) == 0 and not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1)) then
                    remove = true
                end
                -- Delete if parked and density parked == 0
                if tonumber(currentDensities.parked) == 0 and IsVehicleSeatFree(vehicle, -1) and (GetEntitySpeed(vehicle) < 0.5) then
                    remove = true
                end
                if remove then
                    if not IsEntityAMissionEntity(vehicle) then
                        SetEntityAsMissionEntity(vehicle, true, true)
                    end
                    if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
    end
    -- Peds
    deletePeds = (tonumber(currentDensities.ped) == 0 or tonumber(currentDensities.scene) == 0)
    if deletePeds then
        local playerPed = PlayerPedId()
        for ped in EnumeratePeds() do
            if ped ~= playerPed and not IsPedAPlayer(ped) and not IsEntityAMissionEntity(ped) then
                SetEntityAsMissionEntity(ped, true, true)
                if DoesEntityExist(ped) and NetworkHasControlOfEntity(ped) then
                    DeleteEntity(ped)
                end
            end
        end
    end
    -- When density is restored (>0) let GTA spawn system do its job (stop deleting)
end

RegisterNetEvent("menu_traffic:applyDensity")
AddEventHandler("menu_traffic:applyDensity", function(densities)
    currentDensities = densities
end)

RegisterNetEvent("menu_traffic:founderResult")
AddEventHandler("menu_traffic:founderResult", function(value)
    isFounder = value
end)

RegisterNetEvent("menu_traffic:langs")
AddEventHandler("menu_traffic:langs", function(_langs)
    langs = _langs
    SendNUIMessage({action="setLangs", langs=langs, current=currentLang})
end)

RegisterNetEvent("menu_traffic:deleteAllVehicles")
AddEventHandler("menu_traffic:deleteAllVehicles", function()
    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteEntity(vehicle)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) if obj then ESX = obj end end)
    TriggerEvent('QBCore:GetObject', function(obj) if obj then QBCore = obj end end)
    Citizen.Wait(100)
    TriggerServerEvent('menu_traffic:loadDensity')
    TriggerServerEvent('menu_traffic:isFounder')
    TriggerServerEvent('menu_traffic:getLangs')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        -- Apply the current densities (does nothing if 0, but enable spawn if >0)
        applyVehicleDensities(currentDensities)
        Citizen.Wait(0)
        applyPedDensities(currentDensities)
        -- Only delete if at least one density is at 0
        deleteAmbientEntitiesIfNecessary()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 56) then -- F9
            if isFounder then
                SetNuiFocus(true, true)
                SendNUIMessage({action = "openMenu"})
                SendNUIMessage({action = "setLangs", langs=langs, current=currentLang})
                nuiActive = true
            else
                local txt = langs[currentLang] and langs[currentLang].only_founder or "Vous n'êtes pas fondateur."
                TriggerEvent("chat:addMessage",{ args={txt}})
            end
        end
        if nuiActive and IsControlJustPressed(0, 177) then -- ESC
            SetNuiFocus(false, false)
            SendNUIMessage({action = "closeMenu"})
            nuiActive = false
        end
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    nuiActive = false
    SendNUIMessage({action = "closeMenu"})
    cb('ok')
end)

RegisterNUICallback('setDensities', function(data, cb)
    currentDensities = data.densities
    cb('ok')
end)

RegisterNUICallback('saveDensities', function(data, cb)
    currentDensities = data.densities
    TriggerServerEvent('menu_traffic:saveDensity', currentDensities)
    cb('ok')
end)

RegisterNUICallback('switchLang', function(data, cb)
    currentLang = data and data.lang or "fr"
    SendNUIMessage({action = "setLang", lang=currentLang})
    cb('ok')
end)