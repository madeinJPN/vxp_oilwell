Config = {}

Config.OilLocations = {
    { id = 1, coords = vec3(1532.19, -2537.52, 57.93), price = 20000 },
    { id = 2, coords = vec3(1508.45, -2542.54, 56.05), price = 25000 }
}

-- Mostrar blips de los pozos en el mapa (si tienen dueño solo los verá su propietario)
Config.ShowBlips = true
Config.BlipSprite = 415 -- icono de gasolinera
Config.BlipColor = 5
Config.BlipScale = 0.8
Config.BlipLabel = 'Pozo Petrolero'

-- Configuración de mantenimiento.
-- Cada nivel define cuántos litros genera cada ciclo y cuántos
-- ciclos dura antes de requerir mantenimiento nuevamente.
Config.MaintenanceLevels = {
    [1] = {
        rate = 250,      -- litros por ciclo de 10 minutos
        duration = 6,    -- cantidad de ciclos que dura (1 hora)
        items = {
            wrench = 1,
            oil_filter = 1
        }
    },
    [2] = {
        rate = 500,      -- mantenimiento avanzado
        duration = 12,   -- dura 2 horas
        items = {
            wrench = 1,
            oil_filter = 1,
            advanced_oil_kit = 1
        }
    }
}
