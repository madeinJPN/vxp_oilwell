local coreName = GetResourceState("qbx-core") ~= "missing" and "qbx-core" or "qb-core"
local QBCore = exports[coreName]:GetCoreObject()

local wellBlips = {}
local locMap = {}
local locations = {}
local targetZones = {}
for _, loc in pairs(Config.OilLocations) do
    locMap[loc.id] = loc.coords
    locations[loc.id] = loc
end

local function createBlip(id)
    local c = locMap[id]
    local blip = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(blip, Config.BlipSprite)
    SetBlipScale(blip, Config.BlipScale)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.BlipLabel)
    EndTextCommandSetBlipName(blip)
    return blip
end

local function refreshTargetZone(id, owner)
    local loc = locations[id]
    if not loc then return end
    if targetZones[id] then
        exports.ox_target:removeZone(targetZones[id])
        targetZones[id] = nil
    end

    local cid = QBCore.Functions.GetPlayerData().citizenid
    local options = {
        {
            name = 'status_' .. id,
            label = 'Ver estado del pozo',
            icon = 'fa-solid fa-circle-info',
            onSelect = function()
                TriggerServerEvent('oil:getStatus', id)
            end
        }
    }

    if not owner then
        options[#options + 1] = {
            name = 'buy_' .. id,
            label = ('Comprar pozo ($%d)'):format(loc.price or 0),
            icon = 'fa-solid fa-oil-can',
            onSelect = function()
                TriggerServerEvent('oil:buy', id)
            end
        }
    elseif owner == cid then
        options[#options + 1] = {
            name = 'collect_' .. id,
            label = 'Recolectar 500L de petróleo',
            icon = 'fa-solid fa-barrel',
            onSelect = function()
                TriggerServerEvent('oil:collect', id)
            end
        }
        options[#options + 1] = {
            name = 'maintain_basic_' .. id,
            label = 'Mantenimiento básico',
            icon = 'fa-solid fa-wrench',
            description = 'Requiere wrench x1 y oil_filter x1',
            onSelect = function()
                TriggerServerEvent('oil:maintain', id, 1)
            end
        }
        options[#options + 1] = {
            name = 'maintain_adv_' .. id,
            label = 'Mantenimiento avanzado',
            icon = 'fa-solid fa-gears',
            description = 'Requiere wrench x1, oil_filter x1 y advanced_oil_kit x1',
            onSelect = function()
                TriggerServerEvent('oil:maintain', id, 2)
            end
        }
    end

    targetZones[id] = exports.ox_target:addBoxZone({
        coords = loc.coords,
        size = vec3(2, 2, 2),
        rotation = 0,
        debug = false,
        options = options
    })
end

RegisterNetEvent('oil:showStatusMenu', function(well)
    local playerCid = QBCore.Functions.GetPlayerData().citizenid
    local ownerLabel = not well.owner and 'Disponible' or (well.owner == playerCid and 'Tú' or 'Otro Jugador')

        local opts = {
        { title = 'Dueño: ' .. ownerLabel },
        { title = ('Petroleo almacenado: %dL'):format(well.oil_amount) },
        { title = ('Nivel de mantenimiento: %d'):format(well.maintained or 0) },
        (not well.owner) and { title = 'Precio: $' .. well.price } or nil,
    }

    if well.owner == playerCid then
        opts[#opts + 1] = {
            title = 'Mantenimiento básico',
            description = 'Requiere wrench x1 y oil_filter x1',
            onSelect = function()
                TriggerServerEvent('oil:maintain', well.id, 1)
            end
        }
        opts[#opts + 1] = {
            title = 'Mantenimiento avanzado',
            description = 'Requiere wrench x1, oil_filter x1 y advanced_oil_kit x1',
            onSelect = function()
                TriggerServerEvent('oil:maintain', well.id, 2)
            end
        }
    end

    lib.registerContext({ id = 'oil_status_' .. well.id, title = 'Pozo #' .. well.id, options = opts })
    lib.showContext('oil_status_' .. well.id)
end)

RegisterNetEvent('oil:updateWellOwner', function(id, owner)
    local cid = QBCore.Functions.GetPlayerData().citizenid
    if wellBlips[id] then
        RemoveBlip(wellBlips[id])
        wellBlips[id] = nil
    end
    if Config.ShowBlips and (not owner or owner == cid) then
        wellBlips[id] = createBlip(id)
    end
    refreshTargetZone(id, owner)
end)

CreateThread(function()
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(500)
    end
    local cid = QBCore.Functions.GetPlayerData().citizenid

    for _, loc in pairs(Config.OilLocations) do
        lib.callback('oil:getWellOwner', false, function(owner)
            if Config.ShowBlips and (not owner or owner == cid) then
                wellBlips[loc.id] = createBlip(loc.id)
            end
            refreshTargetZone(loc.id, owner)
        end, loc.id)
    end
end)

RegisterCommand('oilmanage', function()
    lib.callback('oil:getPlayerWells', false, function(wells)
        if not wells or #wells == 0 then
            lib.notify({ description = 'No tienes pozos.', type = 'error' })
            return
        end
        local opts = {}
        for _, well in pairs(wells) do
            opts[#opts + 1] = {
                title = 'Pozo #' .. well.id,
                description = ('Petroleo: %dL - Mantenimiento: %d'):format(well.oil_amount, well.maintained or 0),
                onSelect = function()
                    TriggerEvent('oil:showStatusMenu', well)
                end
            }
        end
        lib.registerContext({ id = 'oil_manage', title = 'Mis Pozos', options = opts })
        lib.showContext('oil_manage')
    end)
end)
