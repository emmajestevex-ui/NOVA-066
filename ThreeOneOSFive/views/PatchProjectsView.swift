import CryptoKit
import SwiftUI

struct PatchProjectsView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var remoteContentStore: RemoteContentStore
    @StateObject private var store = PatchProjectStore()
    @State private var searchText = ""

    private var filteredItems: [PatchLibraryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.items }
        return store.items.filter { item in
            if item.packageURL.lastPathComponent.localizedCaseInsensitiveContains(query) {
                return true
            }
            guard let project = item.project else { return false }
            return project.name.localizedCaseInsensitiveContains(query)
                || project.allBundleIdentifiers.contains {
                    $0.localizedCaseInsensitiveContains(query)
                }
                || project.rules.contains {
                    $0.relativePath.localizedCaseInsensitiveContains(query)
                        || $0.replacementFilename.localizedCaseInsensitiveContains(query)
                }
        }
    }

    private var remotePatchFiles: [RemoteContentFile] {
        []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppSearchField(
                    text: $searchText,
                    prompt: "Buscar archivos de NOVA X66",
                    clearLabel: language.text("common.clear")
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        PatchListHeader(count: store.items.count + remotePatchFiles.count)

                        if store.items.isEmpty && !store.isBusy {
                            emptyState
                        } else if filteredItems.isEmpty && !store.isBusy {
                            searchEmptyState
                        } else {
                            LCNFilesSectionTitle("Archivos integrados")
                            ForEach(filteredItems) { item in
                                itemRow(item)
                            }
                        }

                        if !remotePatchFiles.isEmpty {
                            LCNFilesSectionTitle("Actualizaciones remotas")
                            ForEach(remotePatchFiles) { file in
                                RemotePatchRow(file: file)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.pageInset)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Archivos de NOVA X66")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if store.isBusy {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ProgressView()
                    }
                }
            }
            .sheet(item: $store.passwordRequest, onDismiss: store.cancelUnlock) { _ in
                PatchUnlockView(store: store)
            }
            .alert(item: $store.alert) { alert in
                Alert(
                    title: Text(language.text(alert.titleKey)),
                    message: Text(alert.message(language: language)),
                    dismissButton: .default(Text(language.text("common.ok")))
                )
            }
            .onAppear {
                remoteContentStore.loadLocalState()
                BundledPatchSeeder.seedIfNeeded()
                store.reload()
            }
        }
    }

    @ViewBuilder
    private func itemRow(_ item: PatchLibraryItem) -> some View {
        if item.isLocked {
            Button { store.requestUnlock(for: item) } label: {
                PatchProjectRow(item: item, language: language)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink {
                PatchProjectDetailView(store: store, projectID: item.id)
            } label: {
                PatchProjectRow(item: item, language: language)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light))
                .foregroundStyle(AppTheme.accent)
            Text(language.text("patch.empty_title"))
                .font(.headline)
            Text(language.text("patch.bundled_missing_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 54)
        .padding(.horizontal, 20)
        .background(LCNFilePanel())
    }

    private var searchEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light))
                .foregroundStyle(.secondary)
            Text(language.text("patch.search_empty"))
                .font(.headline)
            Text(language.text("patch.search_empty_message"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 54)
        .padding(.horizontal, 20)
        .background(LCNFilePanel())
    }
}

private struct LCNFilesSectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title.uppercased())
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.accentGlow)
            .tracking(1.1)
            .padding(.horizontal, 2)
    }
}

private struct PatchListHeader: View {
    let count: Int

    var body: some View {
        HStack(spacing: 14) {
            AppLogo(size: 46)
            VStack(alignment: .leading, spacing: 4) {
                Text("Centro NOVA X66")
                    .font(.title3.weight(.black))
                Text("Aimbots y archivos privados")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(.title3.weight(.black))
                    .foregroundColor(AppTheme.accentGlow)
                Text(count == 1 ? "archivo" : "archivos")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(LCNFilePanel())
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentGlow, AppTheme.mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 118, height: 3)
                .padding(.leading, 16)
                .padding(.bottom, 10)
        }
    }
}

private struct PatchProjectRow: View {
    let item: PatchLibraryItem
    let language: AppLanguage

    private var fileCount: Int {
        guard let project = item.project else { return 0 }
        return project.rules.count + project.directories.count
    }

    private var style: PatchVisualStyle {
        PatchVisualStyle(item: item)
    }

    var body: some View {
        HStack(spacing: 12) {
            AppRowIcon(
                systemName: item.isLocked ? "lock.doc.fill" : style.icon,
                tint: style.tint,
                symbolSize: 17,
                frameSize: 34
            )
            VStack(alignment: .leading, spacing: 3) {
                Text(item.project?.name ?? language.text("patch.locked_project"))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(item.isLocked ? language.text("patch.tap_to_unlock") : style.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            if item.summary.isPasswordProtected {
                Image(systemName: "key.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel(language.text("patch.password_protected"))
            } else if !item.isLocked {
                Text(fileCount == 1 ? "1 archivo" : "\(fileCount) archivos")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(LCNFilePanel(cornerRadius: 18))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(style.tint)
                .frame(width: 3)
                .padding(.vertical, 14)
        }
    }
}

private struct RemotePatchRow: View {
    let file: RemoteContentFile

    var body: some View {
        HStack(spacing: 12) {
            AppRowIcon(
                systemName: "icloud.and.arrow.down.fill",
                tint: Color(red: 0.26, green: 0.72, blue: 1.0),
                symbolSize: 17,
                frameSize: 34
            )
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(file.name)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text("v\(file.version)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(AppTheme.accentGlow)
                }
                Text(file.localRelativePath)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Remoto")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(AppTheme.accentGlow)
                Text(file.displaySize)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(LCNFilePanel(cornerRadius: 18))
    }
}

private struct LCNFilePanel: View {
    var cornerRadius: CGFloat = 22

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                        AppTheme.cardBackground,
                        AppTheme.pageBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.accent.opacity(0.45),
                                AppTheme.accent.opacity(0.12),
                                Color.black.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.07), radius: 14, x: 0, y: 8)
    }
}

private struct PatchUnlockView: View {
    @Environment(\.appLanguage) private var language
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: PatchProjectStore
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField(language.text("patch.password"), text: $password)
                        .textContentType(.password)
                        .submitLabel(.done)
                        .onSubmit(unlock)
                        .onChange(of: password) { _ in
                            store.clearUnlockError()
                        }
                    if let errorKey = store.unlockErrorKey {
                        Text(language.text(errorKey))
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text(language.text("patch.password_once_message"))
                }
            }
            .navigationTitle(language.text("patch.unlock"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(language.text("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(language.text("patch.unlock"), action: unlock)
                        .disabled(password.isEmpty || store.isBusy)
                }
            }
        }
    }

    private func unlock() {
        guard !password.isEmpty else { return }
        store.unlock(password: password)
    }
}

private struct PatchProjectDetailView: View {
    @Environment(\.appLanguage) private var language
    @ObservedObject var store: PatchProjectStore
    let projectID: UUID
    @State private var isWorking = false
    @State private var showNameEditor = false
    @State private var actionAlert: PatchStoreAlert?
    @State private var assetVariant = BundledPatchSeeder.selectedAssetIndexerVariant
    @State private var targetBundleChoice = BundledPatchSeeder.TargetBundleChoice.freeFireTH

    private var item: PatchLibraryItem? {
        store.items.first(where: { $0.id == projectID })
    }

    private var receipt: PatchTransactionReceipt? {
        DevicePatchService.latestReceipt(projectID: projectID)
    }

    private var detailStyle: PatchVisualStyle {
        guard let project = item?.project else { return PatchVisualStyle.locked }
        return PatchVisualStyle(project: project)
    }

    var body: some View {
        ScrollView {
            if let project = item?.project {
                VStack(spacing: 18) {
                    PatchDetailHero(project: project, style: detailStyle, isApplied: receipt != nil)

                    Link(destination: URL(string: "https://www.tiktok.com")!) {
                        HStack(spacing: 12) {
                            AppRowIcon(systemName: "play.rectangle.fill", tint: AppTheme.accentGlow, symbolSize: 18, frameSize: 42)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("TikTok oficial")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("NOVA X66")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.accentGlow)
                        }
                        .padding(16)
                        .background(LCNFilePanel(cornerRadius: 18))
                    }

                    VStack(spacing: 12) {
                        Button(action: apply) {
                            PatchActionButtonContent(
                                title: language.text("patch.apply"),
                                subtitle: "Activar archivo",
                                systemImage: "checkmark.shield.fill"
                            )
                        }
                        .buttonStyle(PatchPrimaryActionStyle())
                        .disabled(isWorking)

                        Button(role: .destructive, action: restore) {
                            PatchActionButtonContent(
                                title: language.text("patch.restore"),
                                subtitle: "Volver al original",
                                systemImage: "arrow.uturn.backward.circle"
                            )
                        }
                        .buttonStyle(PatchSecondaryActionStyle(isEnabled: receipt != nil && !isWorking))
                        .disabled(isWorking || receipt == nil)
                    }
                }
                .padding(.horizontal, AppTheme.pageInset)
                .padding(.top, 16)
                .padding(.bottom, 28)
            }
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .navigationTitle(item?.project?.name ?? language.text("patch.title"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let project = item?.project {
                assetVariant = BundledPatchSeeder.selectedAssetIndexerVariant(for: project)
                targetBundleChoice = BundledPatchSeeder.selectedTargetBundle(for: project)
            }
        }
        .toolbar {
            if isWorking {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProgressView()
                }
            }
        }
        .sheet(isPresented: $showNameEditor) {
            if let project = item?.project {
                PatchNameEditorView(name: project.name) { newName in
                    rename(to: newName)
                }
            }
        }
        .alert(item: $actionAlert) { alert in
            Alert(
                title: Text(language.text(alert.titleKey)),
                message: Text(alert.message(language: language)),
                dismissButton: .default(Text(language.text("common.ok")))
            )
        }
    }

    private func rename(to newName: String) {
        guard var project = item?.project else { return }
        project.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        project.updatedAt = Date()
        do {
            try PatchPackageCodec.validate(project)
            store.update(project: project)
        } catch let error as PatchPackageError {
            actionAlert = PatchStoreAlert(
                titleKey: "common.failed",
                messageKey: error.localizationKey,
                messageArgument: error.localizationArgument
            )
        } catch {
            actionAlert = PatchStoreAlert(
                titleKey: "common.failed",
                messageKey: "patch.error.invalid_project"
            )
        }
    }

    private var assetVariantBinding: Binding<BundledPatchSeeder.AssetIndexerVariant> {
        Binding(
            get: { assetVariant },
            set: { newValue in
                assetVariant = newValue
                targetBundleChoice = BundledPatchSeeder.TargetBundleChoice(bundleID: newValue.bundleID) ?? targetBundleChoice
                BundledPatchSeeder.setAssetIndexerVariant(newValue, for: projectID)
                store.reload()
            }
        )
    }

    private var targetBundleBinding: Binding<BundledPatchSeeder.TargetBundleChoice> {
        Binding(
            get: { targetBundleChoice },
            set: { newValue in
                targetBundleChoice = newValue
                BundledPatchSeeder.setTargetBundle(newValue, for: projectID)
                store.reload()
            }
        )
    }

    private func apply() {
        guard let item, let project = item.project else { return }
        isWorking = true
        Task.detached(priority: .userInitiated) {
            do {
                _ = try DevicePatchService.apply(project: project)
                await MainActor.run {
                    store.reload()
                    isWorking = false
                    actionAlert = PatchStoreAlert(titleKey: "common.done", messageKey: "patch.applied_message")
                }
            } catch let error as PatchPackageError {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(
                        titleKey: "common.failed",
                        messageKey: error.localizationKey,
                        messageArgument: error.localizationArgument
                    )
                }
            } catch {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(titleKey: "common.failed", messageKey: "patch.error.apply")
                }
            }
        }
    }

    private func restore() {
        guard let receipt else { return }
        isWorking = true
        Task.detached(priority: .userInitiated) {
            do {
                try DevicePatchService.restore(receipt: receipt)
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(titleKey: "common.done", messageKey: "patch.restored_message")
                }
            } catch let error as PatchPackageError {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(
                        titleKey: "common.failed",
                        messageKey: error.localizationKey,
                        messageArgument: error.localizationArgument
                    )
                }
            } catch {
                await MainActor.run {
                    isWorking = false
                    actionAlert = PatchStoreAlert(titleKey: "common.failed", messageKey: "patch.error.restore")
                }
            }
        }
    }
}

private struct PatchDetailHero: View {
    let project: PatchProject
    let style: PatchVisualStyle
    let isApplied: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 14) {
                AppRowIcon(systemName: style.icon, tint: style.tint, symbolSize: 21, frameSize: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.title2.weight(.black))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                    Text("Control privado")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack {
                Label(isApplied ? "Aplicado" : "Listo", systemImage: isApplied ? "checkmark.seal.fill" : "circle.dashed")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isApplied ? AppTheme.mint : AppTheme.accentGlow)
                Spacer()
                Text(isApplied ? "ON" : "OK")
                    .font(.title3.weight(.black))
                    .foregroundStyle(isApplied ? AppTheme.mint : AppTheme.accentGlow)
            }
            .padding(14)
            .background(AppTheme.cardBackground.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(18)
        .background(LCNFilePanel())
    }
}

private struct PatchActionButtonContent: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3.weight(.bold))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.black))
                Text(subtitle)
                    .font(.caption.weight(.semibold))
                    .opacity(0.82)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 60)
        .padding(.horizontal, 18)
    }
}

private struct PatchPrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.black)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: configuration.isPressed
                                ? [AppTheme.accent.opacity(0.78), AppTheme.accentGlow.opacity(0.78)]
                                : [AppTheme.accent, AppTheme.accentGlow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

private struct PatchSecondaryActionStyle: ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? AppTheme.accentGlow : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.accent.opacity(isEnabled ? (configuration.isPressed ? 0.18 : 0.10) : 0.035))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.accentGlow.opacity(isEnabled ? 0.32 : 0.10), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
    }
}

private struct PatchRuleSummary: View {
    let rule: PatchRule
    let style: PatchVisualStyle

    private var targetFilename: String {
        rule.relativePath.split(separator: "/").last.map(String.init) ?? rule.relativePath
    }

    private var replacementFingerprint: String {
        SHA256.hash(data: rule.replacementData)
            .prefix(6)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(targetFilename)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
            Text(rule.relativePath)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(3)
            Label(rule.replacementFilename, systemImage: "arrow.triangle.2.circlepath")
                .font(.caption.weight(.medium))
                .foregroundColor(style.tint)
                .lineLimit(2)
            Text("\(rule.replacementData.count) bytes - SHA \(replacementFingerprint)")
                .font(.caption2.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

private struct PatchVisualStyle {
    let icon: String
    let tint: Color
    let subtitle: String
    let detail: String

    static let locked = PatchVisualStyle(
        icon: "lock.doc.fill",
        tint: Color.gray,
        subtitle: "Locked preset",
        detail: "Password protected"
    )

    private init(icon: String, tint: Color, subtitle: String, detail: String) {
        self.icon = icon
        self.tint = tint
        self.subtitle = subtitle
        self.detail = detail
    }

    init(item: PatchLibraryItem) {
        if let project = item.project {
            self.init(project: project)
        } else {
            self = PatchVisualStyle.locked
        }
    }

    init(project: PatchProject) {
        let searchable = ([project.name] + project.rules.flatMap {
            [$0.relativePath, $0.replacementFilename]
        })
        .joined(separator: " ")
        .lowercased()

        if searchable.contains("plist") || searchable.contains("144") {
            icon = "speedometer"
            tint = AppTheme.amber
            subtitle = "Preferencias FPS"
            detail = "Preferencias internas"
        } else if searchable.contains("shader") {
            icon = "sparkles"
            tint = AppTheme.mint
            subtitle = "Archivo visual"
            detail = "Contenido opcional"
        } else {
            icon = "cube.transparent.fill"
            tint = AppTheme.accentGlow
            subtitle = "Archivo de aimbot"
            detail = "Contenido de avatar"
        }
    }
}

private struct PatchNameEditorView: View {
    @Environment(\.appLanguage) private var language
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    let onSave: (String) -> Void

    init(name: String, onSave: @escaping (String) -> Void) {
        _name = State(initialValue: name)
        self.onSave = onSave
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(language.text("patch.project")) {
                    TextField(language.text("patch.project_name"), text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit(save)
                }
            }
            .navigationTitle(language.text("patch.edit_name"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(language.text("common.cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(language.text("common.done"), action: save)
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard !trimmedName.isEmpty else { return }
        onSave(trimmedName)
        dismiss()
    }
}
