local items = {
    barrel = {
        label = 'Barrel',
        weight = 5000,
        stack = true,
        description = 'Contenedor para almacenar petroleo crudo'
    },
    crude_oil = {
        label = 'Crude Oil',
        weight = 1000,
        stack = true,
        description = 'Barril de petroleo sin refinar'
    },
    wrench = {
        label = 'Wrench',
        weight = 500,
        stack = false,
        description = 'Llave inglesa para mantenimiento'
    },
    oil_filter = {
        label = 'Oil Filter',
        weight = 250,
        stack = true,
        description = 'Filtro de aceite para pozos'
    },
    advanced_oil_kit = {
        label = 'Advanced Oil Kit',
        weight = 750,
        stack = false,
        description = 'Kit especializado para mantenimiento avanzado'
    }
}

return items
