# NOVA X66 — Beta 3 style Patch editor

Esta variante conserva la base moderna del proyecto y restaura el flujo visual de reglas usado en 3105 v1.0.0-beta.3: abre un proyecto Patch, pulsa **Edit**, luego **Add Rule** (o una regla existente) y aparecerá **Replacement File → Choose File**.

Incluye:
- NOVA X66 branding y tema oscuro/dorado.
- Supabase para licencias.
- ID persistente en Keychain.
- GitHub Actions corregido con scheme `3105`.
- AppIcon 1024x1024.

## Reemplazo en GitHub
1. Haz copia de tu repo actual.
2. Borra el contenido del repo (o crea otro repo de prueba).
3. Sube TODO el contenido de esta carpeta, incluida `.github`.
4. Ve a Actions > Build NOVA X66 IPA.
5. Ejecuta Run workflow o espera el build automático del push.
6. Descarga el artifact LA-COSA-NOSTRA-unsigned.

## Flujo Choose File
Patches > abre proyecto > Edit > Add Rule > Destination > Replacement File > Choose File > Done.
