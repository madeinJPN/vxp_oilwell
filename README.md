# vxp_oilwell

Sistema de pozos petroleros compatible con QBCore (o QBox), ox_lib, ox_inventory y oxmysql.

El cliente y el servidor detectan automáticamente si se está utilizando `qb-core` o `qbx-core`.

Los pozos aparecen marcados en el mapa mediante blips configurables. Si un pozo tiene dueño el blip solo es visible para su propietario; de lo contrario todos los jugadores podrán ver el marcador. El script se centra únicamente en la extracción del petróleo y no incluye un sistema de venta.

Cada pozo define su propio precio dentro de `Config.OilLocations`. Al comprarlo se descuenta dicho valor del banco del jugador.

## Instalación

1. Importe `schema.sql` en su base de datos.
2. Coloque el recurso en la carpeta `resources` de su servidor.
3. Asegúrese de tener `ox_lib`, `ox_inventory`, `oxmysql`, `ox_target` y `qb-core` o `qbx-core` instalados.
4. Inicie el recurso desde `server.cfg`.
