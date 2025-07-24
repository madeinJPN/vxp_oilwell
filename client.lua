local coreName = GetResourceState("qbx-core") ~= "missing" and "qbx-core" or "qb-core"
local QBCore = exports[coreName]:GetCoreObject()

local wellBlips = {}
local locMap = {}
for _, loc in pairs(Config.OilLocations) do
    locMap[loc.id] = loc.coords
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

RegisterNetEvent('oil:showStatusMenu', function(well)
    local playerCid = QBCore.Functions.GetPlayerData().citizenid
    local ownerLabel = not well.owner and 'Disponible' or (well.owner == playerCid and 'Tú' or 'Otro Jugador')

    lib.registerContext({
        id = 'oil_status_' .. well.id,
        title = 'Pozo #' .. well.id,
        options = {
            { title = 'Dueño: ' .. ownerLabel },
            { title = 'Petróleo: ' .. well.oil_amount .. 'L' },
            { title = 'Mantenimiento: ' .. (well.maintained > 0 and ('Nivel ' .. well.maintained) or 'No') },
            (not well.owner) and { title = 'Precio: $' .. well.price } or nil,
        }
    })
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
            local options = {
                {
                    name = 'status_' .. loc.id,
                    label = 'Ver Estado del Pozo',
                    icon = 'fa-solid fa-circle-info',
                    onSelect = function()
                        TriggerServerEvent('oil:getStatus', loc.id)
                    end
                }
            }

            if not owner then
                options[#options + 1] = {
                    name = 'buy_' .. loc.id,
                    label = 'Comprar Pozo',
                    icon = 'fa-solid fa-oil-can',
                    onSelect = function()
                        TriggerServerEvent('oil:buy', loc.id)
                    end
                }
            elseif owner == cid then
                options[#options + 1] = {
                    name = 'collect_' .. loc.id,
                    label = 'Recolectar Petróleo',
                    icon = 'fa-solid fa-barrel',
                    onSelect = function()
                        TriggerServerEvent('oil:collect', loc.id)
                    end
                }
                options[#options + 1] = {
                    name = 'maintain_basic_' .. loc.id,
                    label = 'Mantenimiento Básico',
                    icon = 'fa-solid fa-wrench',
                    onSelect = function()
                        TriggerServerEvent('oil:maintain', loc.id, 1)
                    end
                }
                options[#options + 1] = {
                    name = 'maintain_adv_' .. loc.id,
                    label = 'Mantenimiento Avanzado',
                    icon = 'fa-solid fa-gears',
                    onSelect = function()
                        TriggerServerEvent('oil:maintain', loc.id, 2)
                    end
                }
            end

            exports.ox_target:addBoxZone({
                coords = loc.coords,
                size = vec3(2, 2, 2),
                rotation = 0,
                debug = false,
                options = options
            })
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
                description = well.oil_amount .. 'L - Nivel ' .. (well.maintained or 0),
                onSelect = function()
                    TriggerEvent('oil:showStatusMenu', well)
                end
            }
        end
        lib.registerContext({ id = 'oil_manage', title = 'Mis Pozos', options = opts })
        lib.showContext('oil_manage')
    end)
end)
