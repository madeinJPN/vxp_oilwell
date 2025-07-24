local coreName = GetResourceState("qbx-core") ~= "missing" and "qbx-core" or "qb-core"
local QBCore = exports[coreName]:GetCoreObject()
local oilWells = {}
local wellPrices = {}

for _, loc in pairs(Config.OilLocations) do
    wellPrices[loc.id] = loc.price or Config.DefaultWellPrice
end

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        MySQL.Async.fetchAll('SELECT * FROM oil_wells', {}, function(results)
            local existing = {}
            for _, well in pairs(results) do
                well.price = wellPrices[well.id] or Config.DefaultWellPrice
                oilWells[well.id] = well
                existing[well.id] = true
            end
            for _, loc in pairs(Config.OilLocations) do
                if not existing[loc.id] then
                    MySQL.Async.execute('INSERT INTO oil_wells (id) VALUES (?)', { loc.id })
                    oilWells[loc.id] = {
                        id = loc.id,
                        owner = nil,
                        oil_amount = 0,
                        maintained = 0,
                        price = wellPrices[loc.id] or Config.DefaultWellPrice
                    }
                end
            end
        end)
    end
end)

CreateThread(function()
    while true do
        Wait(600000)
        for id, well in pairs(oilWells) do
            local levelCfg = Config.MaintenanceLevels[well.maintained]
            if levelCfg and well.oil_amount < 10000 then
                local newAmt = math.min(10000, well.oil_amount + levelCfg.rate)
                MySQL.Async.execute('UPDATE oil_wells SET oil_amount = ? WHERE id = ?', { newAmt, id })
                well.oil_amount = newAmt
            end

            if levelCfg then
                well._ticks = (well._ticks or 0) + 1
                if well._ticks >= levelCfg.duration then
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
        local price = wellPrices[wellId] or Config.DefaultWellPrice
        if Player.Functions.GetMoney('bank') < price then
            TriggerClientEvent('ox_lib:notify', src, { description = 'No tienes suficiente dinero.', type = 'error' })
            return
        end
        Player.Functions.RemoveMoney('bank', price, 'buy-oil-well')
        MySQL.Async.execute('UPDATE oil_wells SET owner = ? WHERE id = ?', { Player.PlayerData.citizenid, wellId })
        well.owner = Player.PlayerData.citizenid
        TriggerClientEvent('ox_lib:notify', src, { description = 'Pozo comprado con éxito.', type = 'success' })
        TriggerClientEvent('oil:updateWellOwner', -1, wellId, well.owner)
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

RegisterNetEvent('oil:maintain', function(wellId, level)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local well = oilWells[wellId]
    if not well or well.owner ~= Player.PlayerData.citizenid then return end
    level = level or 1
    local cfg = Config.MaintenanceLevels[level]
    if not cfg then return end

    for item, count in pairs(cfg.items) do
        if exports.ox_inventory:Search(src, 'count', item) < count then
            TriggerClientEvent('ox_lib:notify', src, { description = 'Faltan materiales de mantenimiento.', type = 'error' })
            return
        end
    end

    for item, count in pairs(cfg.items) do
        exports.ox_inventory:RemoveItem(src, item, count)
    end

    well.maintained = level
    well._ticks = 0
    MySQL.Async.execute('UPDATE oil_wells SET maintained = ? WHERE id = ?', { level, wellId })
    TriggerClientEvent('ox_lib:notify', src, { description = 'Pozo mantenido correctamente.', type = 'success' })
end)

lib.callback.register('oil:getWellOwner', function(source, wellId)
    local well = oilWells[wellId]
    return well and well.owner or nil
end)

lib.callback.register('oil:getPlayerWells', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end
    local wells = {}
    for id, well in pairs(oilWells) do
        if well.owner == Player.PlayerData.citizenid then
            wells[#wells + 1] = well
        end
    end
    return wells
end)
