import SwiftUI

struct RemoteContentView: View {
    @EnvironmentObject private var store: RemoteContentStore
    @State private var searchText = ""

    private var filteredFiles: [RemoteContentFile] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return store.installedFiles }
        return store.installedFiles.filter { file in
            file.name.localizedCaseInsensitiveContains(query)
                || file.slug.localizedCaseInsensitiveContains(query)
                || file.fileName.localizedCaseInsensitiveContains(query)
                || file.category.localizedCaseInsensitiveContains(query)
                || file.localRelativePath.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AppSearchField(text: $searchText, prompt: "Buscar actualizaciones", clearLabel: "Limpiar")
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RemoteContentStatusCard()

                        if store.installedFiles.isEmpty && !store.isBusy {
                            emptyState
                        } else if filteredFiles.isEmpty && !store.isBusy {
                            searchEmptyState
                        } else {
                            Text("ARCHIVOS INSTALADOS")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                                .tracking(1.1)
                                .padding(.horizontal, 2)

                            ForEach(filteredFiles) { file in
                                RemoteContentFileRow(file: file)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.pageInset)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Centro NOVA X66")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.syncIfPossible(force: true)
                    } label: {
                        if store.isBusy {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(store.isBusy)
                    .accessibilityLabel("Sincronizar archivos")
                }
            }
            .onAppear {
                store.loadLocalState()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "icloud.and.arrow.down")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light))
                .foregroundStyle(AppTheme.accent)
            Text("No hay archivos de NOVA X66")
                .font(.headline)
            Text("Publica desde el panel y toca Sincronizar para bajarlos.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 54)
        .padding(.horizontal, 20)
        .background(LCNRemotePanel())
    }

    private var searchEmptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: AppTheme.emptyIconSize, weight: .light))
                .foregroundStyle(.secondary)
            Text("No se encontro nada")
                .font(.headline)
            Text("Prueba con otro nombre, ruta o archivo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 54)
        .padding(.horizontal, 20)
        .background(LCNRemotePanel())
    }
}

private struct RemoteContentStatusCard: View {
    @EnvironmentObject private var store: RemoteContentStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                AppRowIcon(
                    systemName: store.isBusy ? "arrow.triangle.2.circlepath" : "icloud.fill",
                    tint: store.isBusy ? AppTheme.accentGlow : AppTheme.mint,
                    symbolSize: 18,
                    frameSize: 42
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(store.statusText)
                        .font(.headline)
                    Text(store.detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("v\(store.remoteVersion)")
                        .font(.headline.weight(.black))
                        .foregroundColor(AppTheme.accentGlow)
                    Text(store.installedFiles.count == 1 ? "1 archivo" : "\(store.installedFiles.count) archivos")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            if let progress = store.progress, store.isBusy {
                ProgressView(value: progress)
                    .tint(AppTheme.accentGlow)
            }

            HStack {
                Button {
                    store.syncIfPossible(force: true)
                } label: {
                    Label("Sincronizar", systemImage: "arrow.clockwise.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(store.isBusy)

                if let lastChecked = store.lastChecked {
                    Text(lastChecked.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(LCNRemotePanel())
    }
}

private struct RemoteContentFileRow: View {
    let file: RemoteContentFile

    var body: some View {
        HStack(spacing: 12) {
            AppRowIcon(systemName: icon, tint: tint, symbolSize: 17, frameSize: 34)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(file.name)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                    Text("v\(file.version)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(tint)
                }

                Text(file.localRelativePath)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                if let description = file.description, !description.isEmpty {
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(displayCategory)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(tint)
                    .lineLimit(1)
                Text(file.displaySize)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(LCNRemotePanel(cornerRadius: 18))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(tint)
                .frame(width: 3)
                .padding(.vertical, 14)
        }
    }

    private var displayCategory: String {
        let normalized = file.category
            .replacingOccurrences(of: "nova-", with: "")
            .replacingOccurrences(of: "-", with: " ")
        return normalized.isEmpty ? "archivos" : normalized
    }

    private var icon: String {
        if file.mimeType?.hasPrefix("image/") == true { return "photo.fill" }
        if file.mimeType?.contains("json") == true { return "curlybraces" }
        if file.mimeType?.hasPrefix("text/") == true { return "doc.text.fill" }
        return "doc.fill"
    }

    private var tint: Color {
        switch file.category.lowercased() {
        case "images", "image", "media", "nova-shaders":
            return AppTheme.mint
        case "configs", "config", "nova-configs":
            return AppTheme.amber
        default:
            return AppTheme.accentGlow
        }
    }
}

private struct LCNRemotePanel: View {
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
