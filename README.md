# vxp_oilwell

Sistema de pozos petroleros compatible con QBCore (o QBox), ox_lib, ox_inventory y oxmysql.

El cliente y el servidor detectan automáticamente si se está utilizando `qb-core` o `qbx-core`.

## Instalación

1. Importe `schema.sql` en su base de datos.
2. Coloque el recurso en la carpeta `resources` de su servidor.
3. Asegúrese de tener `ox_lib`, `ox_inventory`, `oxmysql`, `ox_target` y `qb-core` o `qbx-core` instalados.
4. Inicie el recurso desde `server.cfg`.
