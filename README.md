# vxp_oilwell

Sistema de pozos petroleros compatible con QBCore (o QBox), ox_lib, ox_inventory y oxmysql.

El cliente y el servidor detectan automáticamente si se está utilizando `qb-core` o `qbx-core`.


Los pozos aparecen marcados en el mapa mediante blips configurables. Si un pozo tiene dueño el blip solo es visible para su propietario; de lo contrario todos los jugadores podrán ver el marcador. El script se centra únicamente en la extracción del petróleo y no incluye un sistema de venta.

Cada pozo define su propio precio dentro de `Config.OilLocations`. Al comprarlo se descuenta dicho valor del banco del jugador.

## Funciones adicionales

- **Mantenimiento avanzado**: existen dos niveles de mantenimiento. El nivel avanzado genera más petróleo y dura más tiempo, pero requiere un `advanced_oil_kit` junto a las herramientas básicas.
- **Interfaz de gestión**: utilice el comando `/oilmanage` para abrir un menú con todos sus pozos y ver rápidamente su estado.
- **Menús mejorados**: tras comprar un pozo, las opciones del objetivo se actualizan al instante, mostrando qué materiales requiere cada nivel de mantenimiento.

## Ítems requeridos

Crea los siguientes ítems en tu `ox_inventory` para que el sistema funcione
correctamente:

- `barrel`: contenedor para almacenar el crudo.
- `crude_oil`: petróleo sin refinar extraído de los pozos.
- `wrench`: herramienta de mantenimiento.
- `oil_filter`: consumible necesario para el mantenimiento.
- `advanced_oil_kit`: kit adicional requerido para el mantenimiento avanzado.

Estos ítems ya se incluyen en `items.lua`, por lo que `ox_inventory` los
cargará automáticamente al iniciar el recurso.

### Materiales por nivel de mantenimiento

- Nivel básico: `wrench` x1 y `oil_filter` x1.
- Nivel avanzado: `wrench` x1, `oil_filter` x1 y `advanced_oil_kit` x1.
## Instalación

1. Importe `schema.sql` en su base de datos.
2. Coloque el recurso en la carpeta `resources` de su servidor.
3. Asegúrese de tener `ox_lib`, `ox_inventory`, `oxmysql`, `ox_target` y `qb-core`
   o `qbx-core` instalados.
4. Inicie el recurso desde `server.cfg`.
