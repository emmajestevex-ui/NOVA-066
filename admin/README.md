# NOVA X66 Admin

Panel estatico para administrar contenido remoto propio de NOVA X66 desde una PC.

## Uso

1. Ejecuta `supabase/remote_content_setup.sql` en el SQL Editor del proyecto Supabase.
2. Los correos `2008yashirchavez@gmail.com`, `emmajestevex@gmail.com` y `grego23500@gmail.com` ya quedan incluidos como admins en ese SQL.
3. Si el backend ya estaba instalado y solo falta permiso admin, ejecuta `supabase/admin_emails_setup.sql`.
4. Abre `admin/index.html` en el navegador o sube la carpeta `admin/` a un hosting privado.
5. Entra con tu correo y contrasena de Supabase. Si todavia no tienes acceso, escribe uno de los correos admin, pon una contrasena nueva y pulsa `Crear acceso`.
6. Sube o reemplaza archivos y pulsa `Publicar cambios`.

En Windows tambien puedes abrir `admin/start-panel.cmd`; eso levanta el panel en `http://127.0.0.1:3105/` para evitar problemas del navegador con `file://`.

## Crear o reemplazar un archivo

1. Toca una plantilla en `Archivos listos`, por ejemplo `Asset Indexer` o `Aimbot Drag FF Max`.
2. El panel llena nombre, categoria, slug, `App destino` y `Ruta en NOVA X66`.
3. Selecciona el archivo nuevo desde tu PC.
4. Pulsa `Guardar cambio`.
5. Pulsa `Publicar cambios`.

Para editar uno ya publicado, pulsa `Reemplazar` en la tarjeta del archivo o vuelve a tocar la misma plantilla. Algunos archivos, como `Aimbot Drag FF Max`, tienen dos reglas dentro del mismo paquete; toca la regla que quieres reemplazar, por ejemplo `Assembly-CSharp-patch.bytes` o `localConfig.json`. Si usas la misma combinacion de `App destino` y `Ruta en NOVA X66`, el iPhone descarga solo el archivo cambiado y reemplaza esa copia local despues de verificar el SHA-256.

Para quitar un archivo integrado, pulsa `Quitar` en su plantilla y despues `Publicar cambios`. La app lo oculta despues de buscar actualizaciones. Para traerlo de vuelta, vuelve a tocar la plantilla, sube un archivo nuevo y publica.

La app iOS usa la misma publishable key y descarga solo los archivos publicados que cambien. No se incluye ninguna `service_role` ni secret key en este panel.
