# NOVA X66

Private client build with Supabase key activation and automatic bundled patches.

## What this build does

- Shows the app as `NOVA X66`.
- Requires a Supabase license key before opening the app.
- Consumes each key one time on the server and binds it to one iOS device ID.
- Re-checks the license on launch, foreground, and every 10 seconds while active.
- Syncs published remote files from Supabase Storage into NOVA X66's own app storage, using a versioned `target_path` so replacing the same route downloads only the changed file.
- Downloads only changed files, verifies SHA-256, and rolls back local content if an update fails.
- Adds a PC admin panel in `admin/` for uploading, replacing, disabling, deleting, and publishing content changes.
- Creates the internal `Asset Indexer`, `Shaders`, and `144 fps` patches automatically after activation.
- Shows the extra `LCN Especial` patch only for the special key `NOVA-ESPECIAL927394HD`.
- Lets the client use `Apply`, `Original`, and name editing only.
- Hides Files, Cleaner, Wallpapers, patch creation, import, export, and editing.

## Included private payloads

The bundled payload files live in:

```text
ThreeOneOSFive/BundledPatchPayloads/
```

Included names:

```text
assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D
shaders.HPt9DZviTSXL9hpGW9QNOMigNLA~3D
com.dts.freefireth.plist
assetindexer.nova-especial927394hd
```

Patch targets:

```text
Asset Indexer:
Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D

Shaders:
Documents/contentcache/Optional/ios/gameassetbundles/shaders.HPt9DZviTSXL9hpGW9QNOMigNLA~3D

144 fps:
Library/Preferences/com.dts.freefireth.plist

LCN Especial, only for `NOVA-ESPECIAL927394HD`:
Documents/contentcache/Compulsory/ios/gameassetbundles/avatar/assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D
```

Run `supabase/licenses_setup.sql` before using the app. It disables old numeric keys like `NOVA-1`, adds secure `NOVA-` key generation, and creates the admin RPC functions.

Run `supabase/remote_content_setup.sql` to enable remote content releases, `target_path` routing, and the `nova-content` Storage bucket. The iOS client and the PC panel both use the same Supabase project URL and publishable key; admin writes require Supabase Auth plus a row in `public.license_admins`.

See `GREEG_BUILD_GUIDE.md` for Supabase setup and GitHub Actions build steps.
