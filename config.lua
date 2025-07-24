Config = {}

Config.OilLocations = {
    { id = 1, coords = vec3(1532.19, -2537.52, 57.93), price = 20000 },
    { id = 2, coords = vec3(1508.45, -2542.54, 56.05), price = 25000 }
}

-- Precio por defecto si una localización no indica "price"
Config.DefaultWellPrice = 20000

-- Mostrar blips de los pozos en el mapa (si tienen dueño solo los verá su propietario)
Config.ShowBlips = true
Config.BlipSprite = 415 -- icono de gasolinera
Config.BlipColor = 5
Config.BlipScale = 0.8
Config.BlipLabel = 'Pozo Petrolero'
