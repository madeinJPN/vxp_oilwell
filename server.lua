local QBCore = exports['qb-core']:GetCoreObject()
local oilWells = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll('SELECT * FROM oil_wells', {}, function(results)
            for _, well in pairs(results) do
                oilWells[well.id] = well
            end
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(600000)
        for id, well in pairs(oilWells) do
            if well.maintained == 1 and well.oil_amount < 10000 then
                local newAmt = math.min(10000, well.oil_amount + 250)
                MySQL.Async.execute('UPDATE oil_wells SET oil_amount = ? WHERE id = ?', { newAmt, id })
                well.oil_amount = newAmt
            end

            well._ticks = (well._ticks or 0) + 1
            if well._ticks >= 6 then
                MySQL.Async.execute('UPDATE oil_wells SET maintained = 0 WHERE id = ?', { id })
                well.maintained = 0
                well._ticks = 0
                for _, playerId in pairs(QBCore.Functions.GetPlayers()) do
                    local p = QBCore.Functions.GetPlayer(playerId)
                    if p and p.PlayerData.citizenid == well.owner then
                        TriggerClientEvent('ox_lib:notify', playerId, {
                            description = 'Uno de tus pozos ha expirado por falta de mantenimiento.',
                            type = 'error'
                        })
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('oil:getStatus', function(wellId)
    local src = source
    local well = oilWells[wellId]
    if well then
        TriggerClientEvent('oil:showStatusMenu', src, well)
    end
end)

RegisterNetEvent('oil:buy', function(wellId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local well = oilWells[wellId]
    if well and not well.owner then
        MySQL.Async.execute('UPDATE oil_wells SET owner = ? WHERE id = ?', { Player.PlayerData.citizenid, wellId })
        well.owner = Player.PlayerData.citizenid
        TriggerClientEvent('ox_lib:notify', src, { description = 'Pozo comprado con éxito.', type = 'success' })
    else
        TriggerClientEvent('ox_lib:notify', src, { description = 'Este pozo ya tiene dueño.', type = 'error' })
    end
end)

RegisterNetEvent('oil:collect', function(wellId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local well = oilWells[wellId]
    if not well or well.owner ~= Player.PlayerData.citizenid then return end
    if well.oil_amount < 500 then
        TriggerClientEvent('ox_lib:notify', src, { description = 'No hay suficiente petróleo.', type = 'error' })
        return
    end
    if exports.ox_inventory:Search(src, 'count', 'barrel') < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Necesitas un barril.', type = 'error' })
        return
    end
    exports.ox_inventory:RemoveItem(src, 'barrel', 1)
    exports.ox_inventory:AddItem(src, 'crude_oil', 500)
    well.oil_amount = well.oil_amount - 500
    MySQL.Async.execute('UPDATE oil_wells SET oil_amount = ? WHERE id = ?', { well.oil_amount, wellId })
    TriggerClientEvent('ox_lib:notify', src, { description = 'Recolectaste 500L de petróleo.', type = 'success' })
end)

RegisterNetEvent('oil:maintain', function(wellId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local well = oilWells[wellId]
    if not well or well.owner ~= Player.PlayerData.citizenid then return end
    if exports.ox_inventory:Search(src, 'count', 'wrench') < 1 or exports.ox_inventory:Search(src, 'count', 'oil_filter') < 1 then
        TriggerClientEvent('ox_lib:notify', src, { description = 'Faltan materiales de mantenimiento.', type = 'error' })
        return
    end
    exports.ox_inventory:RemoveItem(src, 'wrench', 1)
    exports.ox_inventory:RemoveItem(src, 'oil_filter', 1)
    well.maintained = 1
    well._ticks = 0
    MySQL.Async.execute('UPDATE oil_wells SET maintained = 1 WHERE id = ?', { wellId })
    TriggerClientEvent('ox_lib:notify', src, { description = 'Pozo mantenido correctamente.', type = 'success' })
end)

lib.callback.register('oil:getWellOwner', function(wellId)
    local well = oilWells[wellId]
    return well and well.owner or nil
end)
