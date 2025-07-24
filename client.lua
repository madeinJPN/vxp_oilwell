local coreName = GetResourceState("qbx-core") ~= "missing" and "qbx-core" or "qb-core"
local QBCore = exports[coreName]:GetCoreObject()

RegisterNetEvent('oil:showStatusMenu', function(well)
    local playerCid = QBCore.Functions.GetPlayerData().citizenid
    local ownerLabel = not well.owner and 'Disponible' or (well.owner == playerCid and 'Tú' or 'Otro Jugador')

    lib.registerContext({
        id = 'oil_status_' .. well.id,
        title = 'Pozo #' .. well.id,
        options = {
            { title = 'Dueño: ' .. ownerLabel },
            { title = 'Petróleo: ' .. well.oil_amount .. 'L' },
            { title = 'Mantenimiento: ' .. (well.maintained == 1 and 'Sí' or 'No') },
        }
    })
    lib.showContext('oil_status_' .. well.id)
end)

CreateThread(function()
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(500)
    end
    local cid = QBCore.Functions.GetPlayerData().citizenid

    for _, loc in pairs(Config.OilLocations) do
        if Config.ShowBlips then
            local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipColour(blip, Config.BlipColor)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(Config.BlipLabel)
            EndTextCommandSetBlipName(blip)
        end
        lib.callback('oil:getWellOwner', false, function(owner)
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
                    name = 'maintain_' .. loc.id,
                    label = 'Dar Mantenimiento',
                    icon = 'fa-solid fa-wrench',
                    onSelect = function()
                        TriggerServerEvent('oil:maintain', loc.id)
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
