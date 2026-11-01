import SwiftUI

struct PatchProjectsView: View {
    @Environment(\.appLanguage) private var language
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppSearchField(
                    text: $searchText,
                    prompt: language.text("patch.search"),
                    clearLabel: language.text("common.clear")
                )
                Divider()
                List {
                    Section {
                        PatchListHeader(count: store.items.count)
                    }

                    if store.items.isEmpty && !store.isBusy {
                        emptyState
                            .listRowSeparator(.hidden)
                    } else if filteredItems.isEmpty && !store.isBusy {
                        searchEmptyState
                            .listRowSeparator(.hidden)
                    } else {
                        Section("Built-in patches") {
                            ForEach(filteredItems) { item in
                                itemRow(item)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle(language.text("patch.title"))
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
        .padding(.vertical, 64)
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
        .padding(.vertical, 64)
    }
}

private struct PatchListHeader: View {
    let count: Int

    var body: some View {
        HStack(spacing: 14) {
            AppLogo(size: 46)
            VStack(alignment: .leading, spacing: 4) {
                Text("NOVA X66 client")
                    .font(.headline)
                Text("Asset Indexer, Shaders, and 144 fps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(count)")
                    .font(.title3.weight(.black))
                    .foregroundColor(AppTheme.accent)
                Text(count == 1 ? "patch" : "patches")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
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
                Text(fileCount == 1 ? "1 file" : "\(fileCount) files")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
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
        List {
            if let project = item?.project {
                Section {
                    PatchDetailHeader(project: project, style: detailStyle)
                }

                Section {
                    ForEach(project.allBundleIdentifiers, id: \.self) { bundleID in
                        Label {
                            Text(bundleID)
                                .font(.subheadline.monospaced())
                        } icon: {
                            Image(systemName: "app.dashed")
                                .foregroundColor(detailStyle.tint)
                        }
                    }
                    LabeledContent(language.text("patch.files")) {
                        Text("\(project.rules.count)")
                            .fontWeight(.semibold)
                    }
                } header: {
                    Text(language.text("patch.target_bundle"))
                }

                Section {
                    ForEach(project.rules) { rule in
                        PatchRuleSummary(rule: rule, style: detailStyle)
                    }
                } header: {
                    Text(language.text("patch.rules"))
                } footer: {
                    Text(language.text("patch.client_rules_footer"))
                }

                Section {
                    Button(action: apply) {
                        actionLabel("patch.apply", subtitle: "Write the selected preset", systemImage: "checkmark.shield.fill")
                    }
                    .disabled(isWorking)

                    if receipt != nil {
                        Button(role: .destructive, action: restore) {
                            actionLabel("patch.restore", subtitle: "Bring back the saved original", systemImage: "arrow.uturn.backward.circle")
                        }
                        .disabled(isWorking)
                    }
                } footer: {
                    Text(language.text("patch.apply_footer"))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(item?.project?.name ?? language.text("patch.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isWorking {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProgressView()
                }
            } else {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("patch.edit_name")) {
                        showNameEditor = true
                    }
                    .disabled(item?.project == nil)
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

    private func actionLabel(_ key: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(language.text(key))
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

private struct PatchDetailHeader: View {
    let project: PatchProject
    let style: PatchVisualStyle

    var body: some View {
        HStack(spacing: 14) {
            AppRowIcon(systemName: style.icon, tint: style.tint, symbolSize: 20, frameSize: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.title2.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(style.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(project.rules.count == 1 ? "1 file" : "\(project.rules.count) files")
                .font(.caption.weight(.semibold))
                .foregroundColor(style.tint)
        }
        .padding(.vertical, 8)
    }
}

private struct PatchRuleSummary: View {
    let rule: PatchRule
    let style: PatchVisualStyle

    private var targetFilename: String {
        rule.relativePath.split(separator: "/").last.map(String.init) ?? rule.relativePath
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
            tint = Color.green
            subtitle = "FPS preferences"
            detail = "Library preferences"
        } else if searchable.contains("shader") {
            icon = "sparkles"
            tint = Color(red: 0.26, green: 0.72, blue: 1.0)
            subtitle = "Shader bundle"
            detail = "Optional visual content"
        } else {
            icon = "shippingbox.fill"
            tint = AppTheme.accent
            subtitle = "Avatar asset bundle"
            detail = "Compulsory avatar content"
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
