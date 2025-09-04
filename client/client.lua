local QBCore = exports[Config.Core]:GetCoreObject()

local hasFakePlate = false

-- Net Events

RegisterNetEvent('brazzers-fakeplates:client:usePlate', function(plate)
    if not plate then return end
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local vehicleCoords = GetEntityCoords(vehicle)
    local dist = #(vehicleCoords - pedCoords)
    local hasKeys = false
    
    if dist <= 5.0 then
        local currentPlate = QBCore.Functions.GetPlate(vehicle)
        -- Has Keys Check
        if not exports.qbx_vehiclekeys:HasKeys(vehicle) then
            lib.notify({id = 'not_haskeys', type = 'error', description = 'Vous n\'avez pas les clés de ce véhicule'})
            return
        end
        hasKeys = true
        TaskTurnPedToFaceEntity(ped, vehicle, 3.0)
        QBCore.Functions.Progressbar("attaching_plate", "Installation de la plaque", 4000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            anim = 'machinic_loop_mechandplayer',
            flags = 1,
        }, {}, {}, function()
            TriggerServerEvent('brazzers-fakeplates:server:usePlate', VehToNet(vehicle), currentPlate, plate, hasKeys)
            ClearPedTasks(ped)
        end, function()
            ClearPedTasks(ped)
        end)
    end
end)

RegisterNetEvent('brazzers-fakeplates:client:removePlate', function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    local vehicleCoords = GetEntityCoords(vehicle)
    local dist = #(vehicleCoords - pedCoords)
    local hasKeys = false
    
    if dist <= 5.0 then
        local currentPlate = QBCore.Functions.GetPlate(vehicle)
        -- Has Keys Check
        if exports.qbx_vehiclekeys:HasKeys(vehicle) then
            hasKeys = true
        end
        TaskTurnPedToFaceEntity(ped, vehicle, 3.0)
        QBCore.Functions.Progressbar("removing_plate", "Removing Plate", 4000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            anim = 'machinic_loop_mechandplayer',
            flags = 1,
        }, {}, {}, function()
            TriggerServerEvent('brazzers-fakeplates:server:removePlate', VehToNet(vehicle), currentPlate, hasKeys)
            ClearPedTasks(ped)
        end, function()
            ClearPedTasks(ped)
        end)
    end
end)

-- Threads

CreateThread(function()
    while true do
        Wait(1000)
        local inRange = false
        local pos = GetEntityCoords(PlayerPedId())
        local vehicle = QBCore.Functions.GetClosestVehicle()
        local vehCoords = GetEntityCoords(vehicle)
        local closestPlate = QBCore.Functions.GetPlate(vehicle)

        if exports.qbx_vehiclekeys:HasKeys(vehicle) then -- Has Keys
            if not IsPedInAnyVehicle(PlayerPedId()) then -- Not in vehicle
                if #(pos - vector3(vehCoords.xyz)) < 7.0 then -- dist check
                    inRange = true
                    QBCore.Functions.TriggerCallback('brazzers-fakeplates:server:checkPlateStatus', function(result)
                        if result then
                            hasFakePlate = true
                        else
                            hasFakePlate = false
                        end
                    end, closestPlate)
                end
                if not inRange then
                    Wait(3000)
                end
            end
        end
    end
end)

CreateThread(function()
    local bones = {
        'boot',
    }
    
    exports[Config.Target]:addModel(bones, {
        label = 'Retirer la plaque',
        icon = 'fas fa-closed-captioning',
        distance = 2.5,
        canInteract = function(entity)
            local vehPlate = QBCore.Functions.GetPlate(entity)
            if hasFakePlate and vehPlate then
                return true
            end
            return false
        end,
        event = 'brazzers-fakeplates:client:removePlate',
    })
end)
