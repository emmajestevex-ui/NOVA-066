import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm";

const SUPABASE_URL = "https://jtxuhqpdolsyrojfqcjy.supabase.co";
const SUPABASE_KEY = "sb_publishable_liqbgZZwGfp8ZegWE-BZ3g_yOP9ynYo";
const BUCKET = "nova-content";
const SCRIPT_VERSION = "20260923-target-help";
const CLIENT_PREFIX = "nova-";
const LICENSE_PREFIX = "NOVA-";
const DEFAULT_TARGET_BUNDLE = "com.dts.freefireth";
const FREE_FIRE_MAX_BUNDLE = "com.dts.freefiremax";
const ASSET_INDEXER_DIRECTORY = "Documents/contentcache/Compulsory/ios/gameassetbundles/avatar";
const ASSET_VARIANTS = {
  pen: {
    label: "Asset PEN - FF Max",
    targetBundle: FREE_FIRE_MAX_BUNDLE,
    targetPath: `${ASSET_INDEXER_DIRECTORY}/assetindexer.PENojQAQ-f9a1I6Dzjs0n1Z3rtVU~3D`,
  },
  h5: {
    label: "Asset U6 - FF Normal",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: `${ASSET_INDEXER_DIRECTORY}/assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D`,
  },
};

const PATCH_PRESETS = [
  {
    key: "asset-indexer",
    name: "Aimbot Drag FF Normal",
    slug: "asset-indexer-ff-max",
    category: "nova-patches",
    description: "Archivo de aimbot",
    targetBundle: FREE_FIRE_MAX_BUNDLE,
    rules: [
      {
        label: ASSET_VARIANTS.pen.label,
        slug: "asset-indexer-ff-max",
        category: "nova-patches",
        description: "Avatar asset bundle for Free Fire Max",
        targetBundle: ASSET_VARIANTS.pen.targetBundle,
        targetPath: ASSET_VARIANTS.pen.targetPath,
        assetVariant: "pen",
      },
      {
        label: ASSET_VARIANTS.h5.label,
        slug: "asset-indexer",
        category: "nova-patches",
        description: "Avatar asset bundle for Free Fire normal",
        targetBundle: ASSET_VARIANTS.h5.targetBundle,
        targetPath: ASSET_VARIANTS.h5.targetPath,
        assetVariant: "h5",
      },
    ],
  },
  {
    key: "shaders",
    name: "Holo RGB",
    slug: "shaders",
    category: "nova-shaders",
    description: "Archivo visual",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    rules: [
      {
        label: "Holo RGB - FF Normal",
        slug: "shaders",
        category: "nova-shaders",
        description: "Archivo visual para Free Fire normal",
        targetBundle: DEFAULT_TARGET_BUNDLE,
        targetPath: "Documents/contentcache/Optional/ios/gameassetbundles/shaders.HPt9DZviTSXL9hpGW9QNOMigNLA~3D",
      },
      {
        label: "Holo RGB - FF Max",
        slug: "shaders-ff-max",
        category: "nova-shaders",
        description: "Archivo visual para Free Fire Max",
        targetBundle: FREE_FIRE_MAX_BUNDLE,
        targetPath: "Documents/contentcache/Optional/ios/gameassetbundles/shaders.HPt9DZviTSXL9hpGW9QNOMigNLA~3D",
      },
    ],
  },
  {
    key: "holo-pj-normal",
    name: "Holo FF Normal PJ",
    slug: "holo-ff-normal-pj",
    category: "nova-shaders",
    description: "Holo de personajes para Free Fire normal",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: "Documents/contentcache/Optional/ios/optionalavatarres/gameassetbundles/optionalavatarres_commonab_shader.BNrjwQsbTrqz6jACY9i6FB6DyYI~3D",
  },
  {
    key: "aimbot-cuello-normal",
    name: "Aimbot Cuello FF Normal",
    slug: "aimbot-cuello-ff-normal",
    category: "nova-patches",
    description: "Archivo de aimbot cuello para Free Fire normal",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: `${ASSET_INDEXER_DIRECTORY}/assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D`,
  },
  {
    key: "aimbot-pecho-normal",
    name: "Aimbot Pecho FF Normal",
    slug: "aimbot-pecho-ff-normal",
    category: "nova-patches",
    description: "Archivo de aimbot pecho para Free Fire normal",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: `${ASSET_INDEXER_DIRECTORY}/assetindexer.H5ak1JM1Eck~2FxRcJrEp~2FMzeuqmY~3D`,
  },
  {
    key: "balas-magicas-normal",
    name: "Balas Magicas FF Normal",
    slug: "balas-magicas-ff-normal",
    category: "nova-patches",
    description: "Archivo de balas magicas para Free Fire normal",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: ASSET_VARIANTS.h5.targetPath,
  },
  {
    key: "fps-144",
    name: "Optimizador FPS",
    slug: "144-fps",
    category: "nova-configs",
    description: "Preferencias FPS",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    targetPath: "Library/Preferences/com.dts.freefireth.plist",
  },
  {
    key: "only-esp-ffth",
    name: "Only Esp FFTH",
    slug: "only-esp-ffth",
    category: "nova-patches",
    description: "Only Esp patch for Free Fire TH",
    targetBundle: DEFAULT_TARGET_BUNDLE,
    rules: [
      {
        label: "Assembly-CSharp-patch.bytes",
        slug: "only-esp-ffth-assembly",
        category: "nova-patches",
        description: "Assembly patch for Free Fire TH",
        targetBundle: DEFAULT_TARGET_BUNDLE,
        targetPath: "Documents/Assembly-CSharp-patch.bytes",
      },
      {
        label: "GameBand-Fix.json",
        slug: "only-esp-ffth-gameband",
        category: "nova-configs",
        description: "GameBand fix for Free Fire TH",
        targetBundle: DEFAULT_TARGET_BUNDLE,
        targetPath: "Documents/GameBand-Fix.json",
      },
      {
        label: "localConfig.json",
        slug: "only-esp-ffth-config",
        category: "nova-configs",
        description: "localConfig for Free Fire TH",
        targetBundle: DEFAULT_TARGET_BUNDLE,
        targetPath: "Documents/localConfig.json",
      },
    ],
  },
  {
    key: "aimbot-drag-ff-max",
    name: "Aimbot Drag FF Max",
    slug: "aimbot-drag-ff-max",
    category: "nova-patches",
    description: "Patch with Assembly-CSharp-patch.bytes and localConfig.json",
    targetBundle: FREE_FIRE_MAX_BUNDLE,
    rules: [
      {
        label: "Assembly-CSharp-patch.bytes",
        slug: "aimbot-drag-ff-max-assembly",
        category: "nova-patches",
        description: "Assembly patch for Free Fire Max",
        targetPath: "Documents/Assembly-CSharp-patch.bytes",
      },
      {
        label: "localConfig.json",
        slug: "aimbot-drag-ff-max-config",
        category: "nova-configs",
        description: "localConfig.json for Free Fire Max",
        targetPath: "Documents/localConfig.json",
      },
    ],
  },
];

const supabaseClient = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});

window.__NOVA_X66_ADMIN_READY = SCRIPT_VERSION;

const state = {
  files: [],
  keys: [],
  session: null,
  busy: false,
  activeSection: "files",
};

const $ = (selector) => document.querySelector(selector);

const els = {
  loginPanel: $("#loginPanel"),
  adminPanel: $("#adminPanel"),
  loginForm: $("#loginForm"),
  loginStatus: $("#loginStatus"),
  emailInput: $("#emailInput"),
  passwordInput: $("#passwordInput"),
  createAccessButton: $("#createAccessButton"),
  resetPasswordButton: $("#resetPasswordButton"),
  signOutButton: $("#signOutButton"),
  sessionEmail: $("#sessionEmail"),
  fileForm: $("#fileForm"),
  formTitle: $("#formTitle"),
  editingId: $("#editingId"),
  nameInput: $("#nameInput"),
  slugInput: $("#slugInput"),
  categoryInput: $("#categoryInput"),
  targetBundleInput: $("#targetBundleInput"),
  assetVariantLabel: $("#assetVariantLabel"),
  assetVariantInput: $("#assetVariantInput"),
  targetPathInput: $("#targetPathInput"),
  descriptionInput: $("#descriptionInput"),
  fileInput: $("#fileInput"),
  saveButton: $("#saveButton"),
  newButton: $("#newButton"),
  refreshButton: $("#refreshButton"),
  publishButton: $("#publishButton"),
  searchInput: $("#searchInput"),
  presetList: $("#presetList"),
  fileCounter: $("#fileCounter"),
  statusText: $("#statusText"),
  fileList: $("#fileList"),
  fileTemplate: $("#fileTemplate"),
  filesTabButton: $("#filesTabButton"),
  keysTabButton: $("#keysTabButton"),
  filesSection: $("#filesSection"),
  keysSection: $("#keysSection"),
  keyForm: $("#keyForm"),
  keyQuantityInput: $("#keyQuantityInput"),
  keyDurationInput: $("#keyDurationInput"),
  keyLabelInput: $("#keyLabelInput"),
  customKeyInput: $("#customKeyInput"),
  specialAssetInput: $("#specialAssetInput"),
  generatedKeysBox: $("#generatedKeysBox"),
  generatedKeysText: $("#generatedKeysText"),
  copyGeneratedKeysButton: $("#copyGeneratedKeysButton"),
  refreshKeysButton: $("#refreshKeysButton"),
  keySearchInput: $("#keySearchInput"),
  keyCounter: $("#keyCounter"),
  keyStatusText: $("#keyStatusText"),
  keyList: $("#keyList"),
  keyTemplate: $("#keyTemplate"),
};

init();

async function init() {
  if (SUPABASE_KEY.startsWith("PON_AQUI_")) {
    setLoginStatus("Falta pegar la publishable key del Supabase nuevo de NOVA X66 en admin/app.js.", true);
    return;
  }

  window.addEventListener("error", (event) => {
    setLoginStatus(`Error del panel: ${event.message}`, true);
  });
  window.addEventListener("unhandledrejection", (event) => {
    setLoginStatus(`Error de conexion: ${event.reason?.message || event.reason || "revisa internet"}`, true);
  });

  bindEvents();
  try {
    const { data } = await withTimeout(
      supabaseClient.auth.getSession(),
      12000,
      "No pude revisar la sesion. Abre el panel con internet activo o desde http://localhost."
    );
    setSession(data.session);
  } catch (error) {
    setSession(null);
    setLoginStatus(error.message || String(error), true);
  }

  supabaseClient.auth.onAuthStateChange((_event, session) => {
    setSession(session);
  });
}

function bindEvents() {
  els.loginForm.addEventListener("submit", signIn);
  els.createAccessButton.addEventListener("click", createAccess);
  els.resetPasswordButton.addEventListener("click", resetPassword);
  els.signOutButton.addEventListener("click", signOut);
  els.fileForm.addEventListener("submit", saveFile);
  els.newButton.addEventListener("click", resetForm);
  els.refreshButton.addEventListener("click", loadFiles);
  els.publishButton.addEventListener("click", publishChanges);
  els.searchInput.addEventListener("input", renderFiles);
  els.filesTabButton.addEventListener("click", () => switchSection("files"));
  els.keysTabButton.addEventListener("click", () => switchSection("keys"));
  els.keyForm.addEventListener("submit", generateKeys);
  els.refreshKeysButton.addEventListener("click", loadKeys);
  els.keySearchInput.addEventListener("input", renderKeys);
  els.copyGeneratedKeysButton.addEventListener("click", copyGeneratedKeys);
  els.nameInput.addEventListener("input", () => {
    if (!els.editingId.value && !els.slugInput.dataset.touched) {
      els.slugInput.value = safeSlug(els.nameInput.value);
    }
    if (!els.editingId.value && !els.targetPathInput.dataset.touched) {
      suggestTargetPath();
    } else {
      updateAssetVariantVisibility();
    }
  });
  els.slugInput.addEventListener("input", () => {
    els.slugInput.dataset.touched = "true";
    els.slugInput.value = safeSlug(els.slugInput.value);
  });
  els.categoryInput.addEventListener("change", handleCategoryChange);
  els.targetBundleInput.addEventListener("change", syncAssetVariantWithTargetBundle);
  els.assetVariantInput.addEventListener("change", () => {
    applyAssetVariant(els.assetVariantInput.value);
  });
  els.fileInput.addEventListener("change", handleFileChange);
  els.targetPathInput.addEventListener("input", () => {
    els.targetPathInput.dataset.touched = "true";
    els.targetPathInput.value = safeRelativePath(els.targetPathInput.value);
    updateAssetVariantVisibility();
  });
  renderPresets();
}

async function signIn(event) {
  event.preventDefault();
  setBusy(true, "Entrando...");
  setLoginStatus("Conectando con Supabase...");

  try {
    const { data, error } = await withTimeout(
      supabaseClient.auth.signInWithPassword({
        email: els.emailInput.value.trim(),
        password: els.passwordInput.value,
      }),
      20000,
      "Supabase no respondio. Revisa internet o abre el panel desde http://localhost en vez de file://."
    );

    if (error) {
      setLoginStatus(authErrorMessage(error), true);
      return;
    }

    setLoginStatus("Login correcto. Cargando panel...", false, true);
    setSession(data.session);
  } catch (error) {
    setLoginStatus(error.message || String(error), true);
  } finally {
    setBusy(false);
  }
}

async function createAccess() {
  const email = els.emailInput.value.trim();
  const password = els.passwordInput.value;
  if (!email || !password) {
    setLoginStatus("Escribe correo y contrasena para crear el acceso.", true);
    return;
  }
  if (!isAllowedAdminEmail(email)) {
    setLoginStatus("Ese correo no esta en la lista admin del panel.", true);
    return;
  }

  setBusy(true, "Creando acceso...");
  setLoginStatus("Creando acceso en Supabase...");

  try {
    const { data, error } = await withTimeout(
      supabaseClient.auth.signUp({
        email,
        password,
      }),
      20000,
      "Supabase no respondio. Revisa internet y vuelve a intentar."
    );

    if (error) {
      setLoginStatus(createAccessErrorMessage(error), true);
      return;
    }

    if (data.session) {
      setLoginStatus("Acceso creado. Cargando panel...", false, true);
      setSession(data.session);
      return;
    }

    setLoginStatus("Acceso creado. Si Supabase pide confirmacion, revisa el correo y luego entra.", false, true);
  } catch (error) {
    setLoginStatus(error.message || String(error), true);
  } finally {
    setBusy(false);
  }
}

async function resetPassword() {
  const email = els.emailInput.value.trim();
  if (!email) {
    setLoginStatus("Escribe el correo primero.", true);
    return;
  }
  if (!isAllowedAdminEmail(email)) {
    setLoginStatus("Ese correo no esta en la lista admin del panel.", true);
    return;
  }

  setBusy(true, "Enviando recuperacion...");
  setLoginStatus("Enviando correo de recuperacion...");

  try {
    const redirectTo = window.location.protocol.startsWith("http")
      ? window.location.href
      : undefined;
    const { error } = await withTimeout(
      supabaseClient.auth.resetPasswordForEmail(email, {
        redirectTo,
      }),
      20000,
      "Supabase no respondio. Revisa internet y vuelve a intentar."
    );

    if (error) {
      setLoginStatus(error.message || String(error), true);
      return;
    }

    setLoginStatus("Listo. Revisa ese correo para cambiar la contrasena.", false, true);
  } catch (error) {
    setLoginStatus(error.message || String(error), true);
  } finally {
    setBusy(false);
  }
}

async function signOut() {
  await supabaseClient.auth.signOut();
  setSession(null);
}

function setSession(session) {
  state.session = session;
  const signedIn = Boolean(session);
  els.loginPanel.classList.toggle("hidden", signedIn);
  els.adminPanel.classList.toggle("hidden", !signedIn);
  els.signOutButton.classList.toggle("hidden", !signedIn);
  els.sessionEmail.textContent = session?.user?.email ?? "Sin sesion";

  if (signedIn) {
    setLoginStatus("Sesion iniciada.", false, true);
    switchSection(window.location.hash === "#keys" ? "keys" : state.activeSection);
    loadFiles();
    loadKeys();
  } else {
    state.files = [];
    state.keys = [];
    renderFiles();
    renderKeys();
  }
}

function switchSection(section) {
  state.activeSection = section;
  if (window.location.hash !== `#${section}`) {
    history.replaceState(null, "", `#${section}`);
  }
  const showKeys = section === "keys";
  els.filesSection.classList.toggle("hidden", showKeys);
  els.keysSection.classList.toggle("hidden", !showKeys);
  els.filesTabButton.classList.toggle("active", !showKeys);
  els.keysTabButton.classList.toggle("active", showKeys);
  if (showKeys) loadKeys();
}

async function loadFiles() {
  if (!state.session) return;
  setBusy(true, "Cargando archivos...");
  const { data, error } = await supabaseClient.rpc("admin_list_remote_content_files");
  setBusy(false);

  if (error) {
    setStatus(adminErrorMessage(error));
    state.files = [];
    renderFiles();
    return;
  }

  state.files = (data ?? []).filter(isLCNFile);
  setStatus("Listo. Recuerda publicar para que los iPhone reciban los cambios.");
  renderFiles();
}

async function saveFile(event) {
  event.preventDefault();
  if (!state.session || state.busy) return;

  const file = els.fileInput.files?.[0];
  if (!file) {
    setStatus("Selecciona un archivo.");
    return;
  }

  const name = els.nameInput.value.trim();
  const slug = safeSlug(els.slugInput.value || name);
  const selectedAssetVariant = selectedAssetVariantForSave(file);
  const targetBundle = safeTargetBundle(selectedAssetVariant?.targetBundle || els.targetBundleInput.value);
  const targetPath = safeRelativePath(selectedAssetVariant?.targetPath || els.targetPathInput.value || `${lcnCategory(els.categoryInput.value)}/${file.name}`);
  if (!name || !slug) {
    setStatus("Completa nombre y slug.");
    return;
  }
  if (!targetPath) {
    setStatus("Completa la ruta que va a reemplazar en NOVA X66.");
    return;
  }
  if (!isCompleteTargetPath(targetPath)) {
    setStatus("La ruta debe incluir carpeta y archivo. Usa una plantilla o escribe la ruta exacta.");
    return;
  }

  setBusy(true, "Calculando SHA-256...");
  try {
    const hash = await sha256Hex(file);
    let uploadedPath = "";
    const storagePath = `content/${crypto.randomUUID()}/${safeStorageFileName(file.name)}`;

    setStatus("Subiendo archivo...");
    const { error: uploadError } = await supabaseClient.storage
      .from(BUCKET)
      .upload(storagePath, file, {
        cacheControl: "3600",
        contentType: file.type || "application/octet-stream",
        upsert: true,
      });

    if (uploadError) throw uploadError;
    uploadedPath = storagePath;

    setStatus("Guardando metadata...");
    const isReplacing = Boolean(els.editingId.value);
    const { error: rpcError } = await supabaseClient.rpc("admin_upsert_remote_content_file", {
      p_id: els.editingId.value || null,
      p_name: name,
      p_slug: slug,
      p_category: lcnCategory(els.categoryInput.value || "nova-patches"),
      p_target_bundle: targetBundle,
      p_target_path: targetPath,
      p_description: els.descriptionInput.value.trim() || null,
      p_file_name: file.name,
      p_mime_type: file.type || "application/octet-stream",
      p_byte_size: file.size,
      p_sha256: hash,
      p_storage_path: storagePath,
      p_force_new: !isReplacing,
    });

    if (rpcError) {
      if (uploadedPath) {
        await supabaseClient.storage.from(BUCKET).remove([uploadedPath]).catch(() => {});
      }
      throw rpcError;
    }

    resetForm();
    await loadFiles();
    setStatus(isReplacing
      ? "Archivo reemplazado. Pulsa Publicar cambios cuando estes listo."
      : "Archivo nuevo creado. Pulsa Publicar cambios cuando estes listo."
    );
  } catch (error) {
    const message = adminErrorMessage(error);
    setStatus(message);
    window.alert(message);
  } finally {
    setBusy(false);
  }
}

async function toggleActive(file) {
  if (!state.session || state.busy) return;
  setBusy(true, "Actualizando estado...");
  const { error } = await supabaseClient.rpc("admin_set_remote_content_active", {
    p_id: file.id,
    p_is_active: !file.is_active,
  });
  setBusy(false);

  if (error) {
    setStatus(adminErrorMessage(error));
    return;
  }

  await loadFiles();
}

async function deleteFile(file) {
  if (!state.session || state.busy) return;
  const ok = confirm(`Eliminar "${file.name}" en la proxima publicacion?`);
  if (!ok) return;

  setBusy(true, "Marcando eliminacion...");
  const { error } = await supabaseClient.rpc("admin_delete_remote_content_file", {
    p_id: file.id,
  });
  setBusy(false);

  if (error) {
    setStatus(adminErrorMessage(error));
    return;
  }

  await loadFiles();
}

async function disablePreset(preset) {
  if (!state.session || state.busy) return;
  const rules = presetRules(preset);
  const ok = confirm(`Quitar "${preset.name}" completo en la proxima publicacion?`);
  if (!ok) return;

  setBusy(true, "Preparando eliminacion...");
  let firstError = null;
  for (const rule of rules) {
    const { error } = await supabaseClient.rpc("admin_disable_remote_content_target", {
      p_name: preset.name,
      p_slug: rule.slug,
      p_category: lcnCategory(rule.category || preset.category || "nova-patches"),
      p_target_bundle: ruleTargetBundle(preset, rule),
      p_target_path: safeRelativePath(rule.targetPath),
      p_description: rule.description || preset.description || null,
    });
    if (error) {
      firstError = error;
      break;
    }
  }
  setBusy(false);

  if (firstError) {
    setStatus(adminErrorMessage(firstError));
    return;
  }

  await loadFiles();
  setStatus(`"${preset.name}" completo quedo marcado para quitarse. Pulsa Publicar cambios.`);
}

async function publishChanges() {
  if (!state.session || state.busy) return;
  setBusy(true, "Publicando manifest...");
  const { data, error } = await supabaseClient.rpc("admin_publish_remote_content");
  setBusy(false);

  if (error) {
    setStatus(adminErrorMessage(error));
    return;
  }

  setStatus(`Publicado v${data?.version ?? "nueva"}. Los iPhone lo veran al abrir o al buscar actualizaciones.`);
  await loadFiles();
}

function editFile(file) {
  els.formTitle.textContent = `Reemplazar v${file.version}`;
  els.editingId.value = file.id;
  els.nameInput.value = file.name;
  els.slugInput.value = file.slug;
  els.slugInput.dataset.touched = "true";
  els.categoryInput.value = lcnCategory(file.category || "nova-files");
  els.targetBundleInput.value = safeTargetBundle(file.target_bundle);
  els.targetPathInput.value = file.target_path || fallbackTargetPath(file);
  els.targetPathInput.dataset.touched = "true";
  updateAssetVariantVisibility();
  els.descriptionInput.value = file.description || "";
  els.fileInput.value = "";
  els.saveButton.textContent = "Reemplazar archivo";
  els.nameInput.focus();
}

function resetForm() {
  els.formTitle.textContent = "Nuevo archivo";
  els.fileForm.reset();
  els.editingId.value = "";
  delete els.slugInput.dataset.touched;
  delete els.targetPathInput.dataset.touched;
  els.categoryInput.value = "nova-patches";
  els.targetBundleInput.value = FREE_FIRE_MAX_BUNDLE;
  els.assetVariantInput.value = "pen";
  els.targetPathInput.value = "";
  updateAssetVariantVisibility();
  els.saveButton.textContent = "Crear archivo nuevo";
  setStatus("Modo nuevo: sube aimbots para que salgan en Archivos. Paquetes es solo para .3105.");
}

async function loadKeys() {
  if (!state.session) return;
  setBusy(true, "Cargando keys...");
  const { data, error } = await supabaseClient.rpc("admin_list_licenses");
  setBusy(false);

  if (error) {
    setKeyStatus(adminErrorMessage(error));
    state.keys = [];
    renderKeys();
    return;
  }

  state.keys = (data ?? []).filter(isLCNKey);
  setKeyStatus("Listo. Puedes crear, copiar, pausar o bloquear keys.");
  renderKeys();
}

async function generateKeys(event) {
  event.preventDefault();
  if (!state.session || state.busy) return;

  const quantity = Math.max(1, Math.min(Number(els.keyQuantityInput.value || 1), 200));
  const duration = Number(els.keyDurationInput.value || 0);
  const customKey = normalizeKey(els.customKeyInput.value);
  if (customKey && quantity !== 1) {
    setKeyStatus("Para una key personalizada, la cantidad debe ser 1.");
    return;
  }
  if (customKey && !customKey.startsWith(LICENSE_PREFIX)) {
    setKeyStatus("La key personalizada debe empezar con NOVA- para identificar NOVA X66.");
    return;
  }

  const capabilities = els.specialAssetInput.checked ? ["special_assetindexer"] : [];
  setBusy(true, "Creando key...");
  const createdKeys = [];
  let firstError = null;
  const total = customKey ? 1 : quantity;

  for (let index = 0; index < total; index += 1) {
    const nextKey = customKey || makeLCNKey();
    const { data, error } = await supabaseClient.rpc("admin_generate_licenses", {
      p_quantity: 1,
      p_duration_hours: duration > 0 ? duration : null,
      p_label: lcnLabel(els.keyLabelInput.value.trim()),
      p_capabilities: capabilities,
      p_custom_license_key: nextKey,
    });
    if (error) {
      firstError = error;
      break;
    }
    createdKeys.push(...(data?.keys ?? [nextKey]));
  }
  setBusy(false);

  if (firstError) {
    setKeyStatus(adminErrorMessage(firstError));
    return;
  }

  els.generatedKeysText.textContent = createdKeys.join("\n");
  els.generatedKeysBox.classList.toggle("hidden", createdKeys.length === 0);
  setKeyStatus(`${createdKeys.length} key(s) LCN creada(s).`);
  els.customKeyInput.value = "";
  await loadKeys();
}

async function setLicenseStatus(key, status) {
  if (!state.session || state.busy) return;
  setBusy(true, "Actualizando key...");
  const { data, error } = await supabaseClient.rpc("admin_set_license_status", {
    p_license_key: key,
    p_status: status,
  });
  setBusy(false);

  if (error || data?.success === false) {
    setKeyStatus(adminErrorMessage(error || { message: data?.message || "No se pudo actualizar la key." }));
    return;
  }

  setKeyStatus(`Key ${status}.`);
  await loadKeys();
}

async function copyGeneratedKeys() {
  const value = els.generatedKeysText.textContent.trim();
  if (!value) return;
  await navigator.clipboard.writeText(value);
  setKeyStatus("Keys copiadas.");
}

async function copyKey(key) {
  await navigator.clipboard.writeText(key);
  setKeyStatus("Key copiada.");
}

function applyPreset(preset, selectedRule = null) {
  const rule = selectedRule || presetRules(preset)[0];

  resetForm();
  els.formTitle.textContent = `Nuevo ${preset.name}`;
  els.editingId.value = "";
  els.nameInput.value = preset.name;
  els.slugInput.value = rule.slug;
  els.slugInput.dataset.touched = "true";
  els.categoryInput.value = lcnCategory(rule.category || preset.category || "nova-patches");
  els.targetBundleInput.value = ruleTargetBundle(preset, rule);
  els.targetPathInput.value = safeRelativePath(rule.targetPath);
  els.targetPathInput.dataset.touched = "true";
  if (rule.assetVariant) {
    els.assetVariantInput.value = rule.assetVariant;
  }
  updateAssetVariantVisibility();
  els.descriptionInput.value = rule.description || preset.description || "";
  els.fileInput.value = "";
  els.saveButton.textContent = "Crear archivo nuevo";
  els.fileInput.focus();
  setStatus(`Listo para crear un archivo nuevo de ${rule.label || preset.name}. No reemplazara los publicados.`);
}

function suggestTargetPath() {
  if (els.editingId.value || els.targetPathInput.dataset.touched) return;
  const file = els.fileInput.files?.[0];
  if (!file) return;
  normalizeCategoryForFile(file);
  const inferredVariant = inferredAssetVariantFromInput(file);
  if (inferredVariant) {
    const variant = ASSET_VARIANTS[inferredVariant];
    els.assetVariantInput.value = inferredVariant;
    els.targetBundleInput.value = safeTargetBundle(variant.targetBundle);
    els.targetPathInput.value = safeRelativePath(variant.targetPath);
  } else {
    els.targetPathInput.value = safeRelativePath(`${lcnCategory(els.categoryInput.value || "nova-patches")}/${file.name}`);
  }
  updateAssetVariantVisibility();
}

function handleCategoryChange() {
  const file = els.fileInput.files?.[0];
  if (file) normalizeCategoryForFile(file);
  delete els.targetPathInput.dataset.touched;
  suggestTargetPath();
}

function handleFileChange() {
  const file = els.fileInput.files?.[0];
  if (!file) return;
  normalizeCategoryForFile(file);
  const inferredVariant = inferredAssetVariantFromInput(file);
  if (inferredVariant && !els.targetPathInput.dataset.touched) {
    els.assetVariantInput.value = inferredVariant;
  }
  suggestTargetPath();
}

function applyAssetVariant(value) {
  const variant = ASSET_VARIANTS[value] || ASSET_VARIANTS.pen;
  els.targetBundleInput.value = safeTargetBundle(variant.targetBundle);
  els.targetPathInput.value = safeRelativePath(variant.targetPath);
  els.targetPathInput.dataset.touched = "true";
  els.categoryInput.value = "nova-patches";
  updateAssetVariantVisibility();
}

function syncAssetVariantWithTargetBundle() {
  if (shouldShowAssetVariant()) {
    const nextVariant = safeTargetBundle(els.targetBundleInput.value) === FREE_FIRE_MAX_BUNDLE
      ? "pen"
      : "h5";
    els.assetVariantInput.value = nextVariant;
    applyAssetVariant(nextVariant);
    return;
  }
  updateAssetVariantVisibility();
}

function updateAssetVariantVisibility() {
  const variantKey = assetVariantKeyForPath(els.targetPathInput.value);
  const shouldShow = shouldShowAssetVariant(variantKey);

  els.assetVariantLabel.classList.toggle("hidden", !shouldShow);
  if (variantKey) {
    els.assetVariantInput.value = variantKey;
  } else if (shouldShow) {
    els.assetVariantInput.value = safeTargetBundle(els.targetBundleInput.value) === FREE_FIRE_MAX_BUNDLE
      ? "pen"
      : "h5";
  }
}

function shouldShowAssetVariant(variantKey = assetVariantKeyForPath(els.targetPathInput.value)) {
  return variantKey !== null
    || safeSlug(els.slugInput.value).includes("asset-indexer")
    || /asset\s*indexer|aimbot|drag|cuello|pecho|magica|magic|max|normal/i.test(els.nameInput.value);
}

function selectedAssetVariantForSave(file) {
  if (!els.assetVariantLabel.classList.contains("hidden")) {
    return ASSET_VARIANTS[els.assetVariantInput.value] || null;
  }
  const inferred = inferredAssetVariantFromInput(file);
  return inferred ? ASSET_VARIANTS[inferred] : null;
}

function inferredAssetVariantFromInput(file) {
  const haystack = [
    els.nameInput.value,
    els.slugInput.value,
    els.targetPathInput.value,
    file?.name,
  ].join(" ").toLowerCase();
  if (/free\s*fire\s*max|\bff\s*max\b|ffmax|max|pen|penojqaq/.test(haystack)) return "pen";
  if (/free\s*fire\s*(normal|th)|\bff\s*(normal|th)\b|ffth|normal|u6zff|h5ak1jm1eck/.test(haystack)) return "h5";
  return null;
}

function normalizeCategoryForFile(file) {
  if (!file) return;
  const category = lcnCategory(els.categoryInput.value || "nova-patches");
  const isPackage = String(file.name || "").toLowerCase().endsWith(".3105");
  if (category === "nova-packages" && !isPackage) {
    els.categoryInput.value = "nova-patches";
    setStatus("Ese archivo no es .3105, lo puse en aimbots para que salga y funcione como patch.");
  }
}

function renderPresets() {
  if (!els.presetList) return;
  els.presetList.replaceChildren();

  for (const preset of PATCH_PRESETS) {
    const rules = presetRules(preset);
    const matches = rules.map((rule) =>
      state.files.find((file) =>
        !file.deleted_at
          && file.is_active
          && (sameTarget(file, preset, rule) || safeSlug(file.slug) === rule.slug)
      )
    );
    const completed = matches.filter(Boolean).length;
    const deleted = matches.some((file) => file?.deleted_at);
    const item = document.createElement("div");
    item.className = "presetItem";
    const card = document.createElement("div");
    card.className = "presetButton";
    const ruleRows = rules.map((rule, index) => {
      const existing = matches[index];
      const label = rule.label || rule.targetPath;
      const stateLabel = existing ? `v${existing.version}` : "subir";
      return `
        <button class="presetRuleButton" type="button" data-rule="${index}">
          <span>${escapeHTML(label)} <b>${escapeHTML(stateLabel)}</b></span>
          <small>${escapeHTML(ruleTargetBundle(preset, rule))} / ${escapeHTML(safeRelativePath(rule.targetPath))}</small>
        </button>
      `;
    }).join("");
    card.innerHTML = `
      <strong>${escapeHTML(preset.name)}</strong>
      <span>${escapeHTML(rules.length > 1 ? `${completed}/${rules.length} reglas listas` : (completed ? `v${matches[0]?.version} listo para reemplazar` : "Crear / reemplazar"))}</span>
      <small>${escapeHTML(rules.length > 1 ? "varias apps/rutas" : safeTargetBundle(preset.targetBundle))}</small>
      <div class="presetRules">${ruleRows}</div>
    `;
    card.querySelectorAll(".presetRuleButton").forEach((button) => {
      const index = Number(button.dataset.rule || "0");
      button.addEventListener("click", () => applyPreset(preset, rules[index]));
    });
    const removeButton = document.createElement("button");
    removeButton.type = "button";
    removeButton.className = "presetRemoveButton";
    removeButton.textContent = deleted ? "Por quitar" : "Quitar";
    removeButton.addEventListener("click", () => disablePreset(preset));
    item.append(card, removeButton);
    els.presetList.append(item);
  }
}

function renderFiles() {
  const query = els.searchInput.value.trim().toLowerCase();
  const files = state.files.filter((file) => {
    if (!query) return true;
    return [file.name, file.slug, file.file_name, file.target_bundle, file.target_path, file.category, file.description]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(query));
  });

  els.fileList.replaceChildren();
  els.fileCounter.textContent = `${files.length} ${files.length === 1 ? "archivo" : "archivos"}`;
  renderPresets();

  if (!files.length) {
    const empty = document.createElement("p");
    empty.className = "muted";
    empty.textContent = state.files.length ? "No hay resultados para esa busqueda." : "Todavia no hay archivos.";
    els.fileList.append(empty);
    return;
  }

  for (const file of files) {
    const node = els.fileTemplate.content.firstElementChild.cloneNode(true);
    node.querySelector("h3").textContent = file.name;
    node.querySelector(".fileMeta").textContent = [
      file.category || "files",
      `v${file.version}`,
      file.target_bundle || DEFAULT_TARGET_BUNDLE,
      file.file_name,
      formatBytes(file.byte_size),
    ].join(" / ");
    node.querySelector(".filePath").textContent = `Ruta: ${file.target_path || fallbackTargetPath(file)}`;
    node.querySelector(".fileHash").textContent = file.sha256;

    const badge = node.querySelector(".badge");
    badge.textContent = badgeLabel(file);
    badge.classList.toggle("pending", file.sync_state !== "published");
    badge.classList.toggle("inactive", !file.is_active || file.deleted_at);

    const toggleButton = node.querySelector(".toggleButton");
    toggleButton.textContent = file.is_active ? "Desactivar" : "Activar";
    toggleButton.addEventListener("click", () => toggleActive(file));
    node.querySelector(".replaceButton").addEventListener("click", () => editFile(file));
    node.querySelector(".deleteButton").addEventListener("click", () => deleteFile(file));

    els.fileList.append(node);
  }
}

function presetRules(preset) {
  if (Array.isArray(preset.rules) && preset.rules.length) {
    return preset.rules;
  }
  return [{
    label: preset.name,
    slug: preset.slug,
    category: preset.category,
    description: preset.description,
    targetPath: preset.targetPath,
  }];
}

function sameTarget(file, preset, rule) {
  return samePath(file.target_path, rule.targetPath)
    && safeTargetBundle(file.target_bundle) === ruleTargetBundle(preset, rule);
}

function renderKeys() {
  const query = els.keySearchInput?.value.trim().toLowerCase() || "";
  const keys = state.keys.filter((item) => {
    if (!query) return true;
    return [
      item.license_key,
      item.status,
      item.label,
      item.device_id,
      item.expires_at,
      JSON.stringify(item.capabilities || []),
    ]
      .filter(Boolean)
      .some((value) => String(value).toLowerCase().includes(query));
  });

  els.keyList.replaceChildren();
  els.keyCounter.textContent = `${keys.length} ${keys.length === 1 ? "key" : "keys"}`;

  if (!keys.length) {
    const empty = document.createElement("p");
    empty.className = "muted";
    empty.textContent = state.keys.length ? "No hay keys con esa busqueda." : "Todavia no hay keys.";
    els.keyList.append(empty);
    return;
  }

  for (const item of keys) {
    const node = els.keyTemplate.content.firstElementChild.cloneNode(true);
    const key = item.license_key;
    node.querySelector("h3").textContent = key;
    node.querySelector(".fileMeta").textContent = [
      item.label || "Sin etiqueta",
      statusLabel(item.status),
      item.expires_at ? `vence ${formatDate(item.expires_at)}` : "sin vencimiento",
    ].join(" / ");
    node.querySelector(".filePath").textContent = item.device_id
      ? `Dispositivo: ${item.device_id}`
      : "Sin usar";
    node.querySelector(".fileHash").textContent = `Creada: ${formatDate(item.created_at)}${item.activated_at ? ` / Activada: ${formatDate(item.activated_at)}` : ""}`;

    const badge = node.querySelector(".badge");
    badge.textContent = statusLabel(item.status);
    badge.classList.toggle("pending", item.status === "available");
    badge.classList.toggle("inactive", ["paused", "blocked", "expired"].includes(item.status));

    node.querySelector(".copyKeyButton").addEventListener("click", () => copyKey(key));
    const pauseButton = node.querySelector(".pauseKeyButton");
    pauseButton.textContent = item.status === "paused" ? "Activar" : "Pausar";
    pauseButton.addEventListener("click", () => setLicenseStatus(key, item.status === "paused" ? "active" : "paused"));
    node.querySelector(".blockKeyButton").addEventListener("click", () => setLicenseStatus(key, "blocked"));

    els.keyList.append(node);
  }
}

function ruleTargetBundle(preset, rule) {
  return safeTargetBundle(rule?.targetBundle || preset?.targetBundle);
}

function assetVariantKeyForPath(value) {
  const target = safeRelativePath(value).toLowerCase();
  if (!target) return null;
  for (const [key, variant] of Object.entries(ASSET_VARIANTS)) {
    if (target === safeRelativePath(variant.targetPath).toLowerCase()) {
      return key;
    }
  }
  if (target.includes("assetindexer.penojqaq")) return "pen";
  if (target.includes("assetindexer.u6zff")) return "h5";
  if (target.includes("assetindexer.h5ak1jm1eck")) return "h5";
  return null;
}

function safeTargetBundle(value) {
  const clean = String(value || DEFAULT_TARGET_BUNDLE).trim().toLowerCase();
  if (clean === FREE_FIRE_MAX_BUNDLE) return clean;
  return DEFAULT_TARGET_BUNDLE;
}

function badgeLabel(file) {
  if (file.deleted_at) return "Por eliminar";
  if (!file.is_active) return "Inactivo";
  if (file.sync_state === "new_pending") return "Nuevo";
  if (file.sync_state === "change_pending") return "Pendiente";
  return "Publicado";
}

function setBusy(isBusy, message = "") {
  state.busy = isBusy;
  for (const button of document.querySelectorAll("button")) {
    button.disabled = isBusy;
  }
  if (message) setStatus(message);
}

function setStatus(message) {
  els.statusText.textContent = message;
  if (!state.session) {
    setLoginStatus(message);
  }
}

function setKeyStatus(message) {
  els.keyStatusText.textContent = message;
  if (!state.session) setLoginStatus(message);
}

function setLoginStatus(message, isError = false, isOK = false) {
  if (!els.loginStatus) return;
  els.loginStatus.textContent = message;
  els.loginStatus.classList.toggle("error", isError);
  els.loginStatus.classList.toggle("ok", isOK);
}

function authErrorMessage(error) {
  const message = error?.message || String(error);
  if (/invalid login credentials/i.test(message)) {
    return "Correo o contrasena incorrectos. Puedes tocar Crear acceso o Recuperar contrasena.";
  }
  if (/email not confirmed/i.test(message)) {
    return "Ese correo existe, pero falta confirmar el email en Supabase Auth.";
  }
  if (/failed to fetch|network/i.test(message)) {
    return "No pude conectar con Supabase. Prueba abrir el panel desde http://localhost en vez de file://.";
  }
  return message;
}

function createAccessErrorMessage(error) {
  const message = error?.message || String(error);
  if (/already|registered|exists/i.test(message)) {
    return "Ese correo ya existe. Usa Entrar o Recuperar contrasena.";
  }
  if (/signup|disabled/i.test(message)) {
    return "Supabase no permite crear usuarios desde aqui. Crea el usuario en Authentication > Users.";
  }
  return message;
}

function adminErrorMessage(error) {
  const message = error?.message || String(error);
  if (/not authorized/i.test(message)) {
    return "El login funciono, pero ese correo aun no tiene permiso admin. Ejecuta los SQL de Supabase y refresca.";
  }
  if (/could not find the function|function .* does not exist|schema cache/i.test(message)) {
    return "Falta actualizar el backend. Ejecuta supabase/licenses_setup.sql y supabase/remote_content_setup.sql en Supabase y refresca.";
  }
  if (/duplicate key|unique constraint|target_path|target_bundle_path/i.test(message)) {
    return "Supabase todavia esta bloqueando rutas duplicadas. Ejecuta supabase/remote_content_setup.sql en Supabase una vez, refresca el panel y vuelve a guardar.";
  }
  if (/relation .* does not exist|remote_content/i.test(message)) {
    return "Faltan las tablas del panel. Ejecuta supabase/remote_content_setup.sql en Supabase.";
  }
  if (/slug/i.test(message) && /duplicate|unique/i.test(message)) {
    return "Ya existe un slug igual. El backend actualizado lo corrige automaticamente; ejecuta supabase/remote_content_setup.sql y refresca.";
  }
  return message;
}

function normalizeKey(value) {
  return String(value || "").trim().replace(/\s+/g, "").toUpperCase();
}

function makeLCNKey() {
  const bytes = new Uint8Array(12);
  crypto.getRandomValues(bytes);
  const hex = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0")).join("").toUpperCase();
  return `${LICENSE_PREFIX}${hex.slice(0, 4)}-${hex.slice(4, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20, 24)}`;
}

function isLCNFile(file) {
  return String(file.category || "").toLowerCase().startsWith(CLIENT_PREFIX)
    || String(file.slug || "").toLowerCase().startsWith(CLIENT_PREFIX);
}

function isLCNKey(item) {
  return normalizeKey(item.license_key).startsWith(LICENSE_PREFIX)
    || String(item.label || "").toLowerCase().includes("[lcn]");
}

function lcnCategory(category) {
  const clean = String(category || "nova-files").trim().toLowerCase();
  if (clean.startsWith(CLIENT_PREFIX)) return clean;
  const map = {
    files: "nova-files",
    patches: "nova-patches",
    images: "nova-files",
    configs: "nova-configs",
    media: "nova-files",
    shaders: "nova-shaders",
    packages: "nova-packages",
  };
  return map[clean] || `${CLIENT_PREFIX}${clean}`;
}

function lcnLabel(label) {
  const clean = label || "NOVA X66";
  return clean.toLowerCase().includes("[lcn]") ? clean : `[lcn] ${clean}`;
}

function statusLabel(status) {
  switch (status) {
    case "available": return "Disponible";
    case "active": return "Activa";
    case "paused": return "Pausada";
    case "blocked": return "Bloqueada";
    case "expired": return "Vencida";
    default: return status || "Desconocida";
  }
}

function formatDate(value) {
  if (!value) return "";
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  return date.toLocaleString("es", {
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function isAllowedAdminEmail(email) {
  return [
    "2008yashirchavez@gmail.com",
    "emmajestevex@gmail.com",
    "grego23500@gmail.com",
  ].includes(email.trim().toLowerCase());
}

function fallbackTargetPath(file) {
  return safeRelativePath(`${lcnCategory(file.category || "nova-files")}/${file.slug || "content"}/${file.file_name || "content.bin"}`);
}

function samePath(left, right) {
  return safeRelativePath(left).toLowerCase() === safeRelativePath(right).toLowerCase();
}

function isCompleteTargetPath(value) {
  const parts = safeRelativePath(value).split("/").filter(Boolean);
  return parts.length >= 2 && /\.[a-zA-Z0-9~+-]+$/.test(parts.at(-1) || "");
}

function escapeHTML(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function withTimeout(promise, milliseconds, message) {
  let timeoutID;
  const timeout = new Promise((_, reject) => {
    timeoutID = setTimeout(() => reject(new Error(message)), milliseconds);
  });
  return Promise.race([promise, timeout]).finally(() => clearTimeout(timeoutID));
}

async function sha256Hex(file) {
  const buffer = await file.arrayBuffer();
  const digest = await crypto.subtle.digest("SHA-256", buffer);
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function safeSlug(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/^\.+|\.+$/g, "")
    .slice(0, 80);
}

function safeRelativePath(value) {
  return String(value || "")
    .trim()
    .replace(/\\/g, "/")
    .replace(/[^a-zA-Z0-9._/~+-]+/g, "-")
    .replace(/\/+/g, "/")
    .split("/")
    .filter((part) => part && part !== "." && part !== "..")
    .map((part) => safeFileName(part))
    .join("/")
    .slice(0, 180);
}

function safeFileName(value) {
  const clean = String(value || "file.bin")
    .trim()
    .replace(/[^a-zA-Z0-9._~+-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .replace(/^\.+|\.+$/g, "");
  return clean || "file.bin";
}

function safeStorageFileName(value) {
  return "upload.bin";
}

function formatBytes(value) {
  return new Intl.NumberFormat("es", {
    style: "unit",
    unit: "byte",
    notation: "compact",
    unitDisplay: "short",
  }).format(Number(value || 0));
}
