import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @State private var tabNavigation: AppTabNavigationState
    @AppStorage(FeatureVisibility.cleanerStorageKey) private var cleanerEnabled = true
    @AppStorage(FeatureVisibility.wallpapersStorageKey) private var wallpapersEnabled = true

    init() {
#if targetEnvironment(simulator)
        let arguments = ProcessInfo.processInfo.arguments
        let initialTab: Int
        if arguments.contains("--simulate-files-tab") {
            initialTab = 1
        } else if arguments.contains("--simulate-patch-tab") {
            initialTab = 2
        } else if arguments.contains("--simulate-cleaner-tab") {
            initialTab = 3
        } else if arguments.contains("--simulate-wallpaper-tab") {
            initialTab = 4
        } else {
            initialTab = AppSection.home.rawValue
        }
        _tabNavigation = State(initialValue: AppTabNavigationState(selectedTab: initialTab))
#else
        _tabNavigation = State(initialValue: AppTabNavigationState())
#endif
    }

    var body: some View {
        compactLayout
        .tint(AppTheme.accent)
        .imageScale(.small)
        .onChange(of: patchDraftCoordinator.request?.id) { requestID in
            if requestID != nil { tabNavigation.select(AppSection.patches.rawValue) }
        }
        .onChange(of: patchDraftCoordinator.importRequest?.id) { requestID in
            if requestID != nil { tabNavigation.select(AppSection.patches.rawValue) }
        }
        .onChange(of: cleanerEnabled) { _ in
            tabNavigation.reconcileSelection(with: featureVisibility)
        }
        .onChange(of: wallpapersEnabled) { _ in
            tabNavigation.reconcileSelection(with: featureVisibility)
        }
        .onAppear {
            tabNavigation.reconcileSelection(with: featureVisibility)
        }
    }

    private var compactLayout: some View {
        TabView(selection: tabSelection) {
            ForEach(featureVisibility.visibleSections) { section in
                sectionContent(section)
                    .tabItem {
                        CompactTabLabel(
                            title: language.text(section.titleKey),
                            systemImage: section.systemImage
                        )
                    }
                    .tag(section.rawValue)
            }
        }
    }

    @ViewBuilder
    private func sectionContent(_ section: AppSection) -> some View {
        switch section {
        case .home:
            DashboardView(
                cleanerEnabled: $cleanerEnabled,
                wallpapersEnabled: $wallpapersEnabled,
                wallpapersSupported: wallpapersSupported,
                onOpenPatches: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        tabNavigation.select(AppSection.patches.rawValue)
                    }
                }
            )
        case .files:
            AppDataBrowserView(
                tabSession: filesTabSession
            )
        case .patches:
            PatchProjectsView()
        case .social:
            SocialHubView()
        case .cleaner:
            CleanerView()
        case .wallpapers:
            WallpaperLabView()
        case .remoteContent:
            RemoteContentView()
        }
    }

    private var tabSelection: Binding<Int> {
        Binding(
            get: { tabNavigation.selectedTab },
            set: { tabNavigation.select($0) }
        )
    }

    private var filesTabSession: Binding<FilesTabSession> {
        Binding(
            get: { tabNavigation.filesTabs },
            set: { tabNavigation.setFilesTabs($0) }
        )
    }

    private var featureVisibility: FeatureVisibility {
        FeatureVisibility(
            cleanerEnabled: cleanerEnabled,
            wallpapersEnabled: wallpapersEnabled,
            wallpapersSupported: wallpapersSupported
        )
    }

    private var wallpapersSupported: Bool {
        WallpaperFeatureSupportPolicy.isSupported(major: AppInfo.versionTuple.major)
    }

    private var selectedVisibleSection: AppSection {
        guard let section = AppSection(rawValue: tabNavigation.selectedTab),
              featureVisibility.isVisible(section) else {
            return .home
        }
        return section
    }
}

private struct CompactTabLabel: View {
    let title: String
    let systemImage: String

    @ViewBuilder
    var body: some View {
        if let image = UIImage(
            systemName: systemImage,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        )?.withRenderingMode(.alwaysTemplate) {
            Image(uiImage: image)
        } else {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
        }
        Text(title)
    }
}

private extension AppSection {
    var titleKey: String {
        switch self {
        case .home: return "tab.home"
        case .files: return "tab.files"
        case .patches: return "tab.patches"
        case .social: return "Redes"
        case .cleaner: return "tab.cleaner"
        case .wallpapers: return "tab.wallpapers"
        case .remoteContent: return "Actualizar"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .files: return "folder.fill"
        case .patches: return "shippingbox.fill"
        case .social: return "link.circle.fill"
        case .cleaner: return "sparkles"
        case .wallpapers: return "photo.on.rectangle.angled"
        case .remoteContent: return "icloud.and.arrow.down.fill"
        }
    }
}

private struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var remoteContentStore: RemoteContentStore
    @Binding var cleanerEnabled: Bool
    @Binding var wallpapersEnabled: Bool
    let wallpapersSupported: Bool
    let onOpenPatches: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    dashboardHero

                    VStack(alignment: .leading, spacing: 10) {
                        LCNSectionTitle("Archivos principales")
                        VStack(spacing: 0) {
                            Button(action: onOpenPatches) {
                                Label("Abrir laboratorio", systemImage: "rectangle.stack.badge.play.fill")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.accentGlow)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.bottom, 12)

                            HomePatchRow(icon: "scope", title: "Aimbot Drag", subtitle: "Archivo de avatar", tint: AppTheme.accent)
                            HomePatchRow(icon: "person.crop.circle.badge.checkmark", title: "Aimbot Cuello", subtitle: "Preset integrado", tint: AppTheme.accentGlow)
                            HomePatchRow(icon: "target", title: "Aimbot Pecho", subtitle: "Listo para aplicar", tint: AppTheme.mint)
                        }
                        .padding(16)
                        .background(LCNPanelBackground())
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        LCNSectionTitle("Actualizaciones")
                        VStack(spacing: 14) {
                            RemoteContentDashboardRow()
                            Button {
                                remoteContentStore.syncIfPossible(force: true)
                            } label: {
                                Label("Sincronizar archivos", systemImage: "arrow.clockwise.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(AppTheme.accentGlow, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .foregroundStyle(.black)
                            }
                            .disabled(remoteContentStore.isBusy)
                            Text("Los archivos publicados desde el panel de NOVA X66 llegan a esta app al actualizar.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(LCNPanelBackground())
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        LCNSectionTitle("Redes")
                        VStack(spacing: 0) {
                            SocialLinkRow(title: "TikTok", subtitle: "NOVA X66", systemImage: "play.rectangle.fill", url: "https://www.tiktok.com")
                            SocialLinkRow(title: "WhatsApp", subtitle: "Grupo oficial", systemImage: "bubble.left.and.bubble.right.fill", url: "https://chat.whatsapp.com/JoXSQN6z2jAH7WHNqFN6Ew?s=cl&p=i&mlu=4&ilr=4&iam=2")
                            SocialLinkRow(title: "WhatsApp directo", subtitle: "+1 829 957 2375", systemImage: "phone.fill", url: "tel:+18299572375")
                            SocialLinkRow(title: "YouTube", subtitle: "NOVA X66", systemImage: "tv.fill", url: "https://www.youtube.com")
                        }
                        .padding(16)
                        .background(LCNPanelBackground())
                    }
                }
                .padding(.horizontal, AppTheme.pageInset)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppTheme.accent)
            .onAppear {
                remoteContentStore.loadLocalState()
            }
        }
    }

    private var dashboardHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                AppLogo(size: 64)
                    .shadow(color: Color.black.opacity(0.10), radius: 14)

                VStack(alignment: .leading, spacing: 5) {
                    Text("NOVA X66")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("Control privado de archivos")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(appState.isSupported ? "Listo" : "Revisar", systemImage: appState.isSupported ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(appState.isSupported ? AppTheme.mint : AppTheme.amber)
            }

            Divider()

            HStack(spacing: 0) {
                HomeMetric(value: "AIM", title: "Archivos")
                HomeMetric(value: "FF", title: "Destino")
                HomeMetric(value: appState.isSupported ? "OK" : "...", title: "Estado")
            }
        }
        .padding(18)
        .background(LCNPanelBackground())
    }

}

private struct SocialHubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Redes oficiales")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                        Text("Canales de soporte, comunidad y actualizaciones de NOVA X66.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 18)

                    VStack(spacing: 0) {
                        SocialLinkRow(title: "TikTok", subtitle: "NOVA X66", systemImage: "play.rectangle.fill", url: "https://www.tiktok.com")
                        SocialLinkRow(title: "WhatsApp", subtitle: "Grupo oficial", systemImage: "bubble.left.and.bubble.right.fill", url: "https://chat.whatsapp.com/JoXSQN6z2jAH7WHNqFN6Ew?s=cl&p=i&mlu=4&ilr=4&iam=2")
                        SocialLinkRow(title: "WhatsApp directo", subtitle: "+1 829 957 2375", systemImage: "phone.fill", url: "tel:+18299572375")
                        SocialLinkRow(title: "YouTube", subtitle: "NOVA X66", systemImage: "tv.fill", url: "https://www.youtube.com")
                    }
                    .padding(16)
                    .background(LCNPanelBackground())
                }
                .padding(.horizontal, AppTheme.pageInset)
                .padding(.bottom, 28)
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Redes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct LCNSectionTitle: View {
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

private struct LCNPanelBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
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
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.accent.opacity(0.45), AppTheme.accent.opacity(0.12), Color.black.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

private struct RemoteContentDashboardRow: View {
    @EnvironmentObject private var remoteContentStore: RemoteContentStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                AppRowIcon(
                    systemName: remoteContentStore.isBusy ? "arrow.triangle.2.circlepath" : "icloud.fill",
                    tint: AppTheme.accentGlow,
                    symbolSize: 16,
                    frameSize: 32
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(remoteContentStore.statusText)
                        .font(.subheadline.weight(.semibold))
                    Text(remoteContentStore.detailText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("v\(remoteContentStore.remoteVersion)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(AppTheme.accentGlow)
                    Text(remoteContentStore.installedFiles.count == 1 ? "1 file" : "\(remoteContentStore.installedFiles.count) files")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            if let progress = remoteContentStore.progress, remoteContentStore.isBusy {
                ProgressView(value: progress)
                    .tint(AppTheme.accentGlow)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct HomePatchRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            AppRowIcon(systemName: icon, tint: tint, symbolSize: 16, frameSize: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(AppTheme.mint)
        }
        .padding(.vertical, 2)
    }
}

private struct SocialLinkRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                AppRowIcon(systemName: systemImage, tint: AppTheme.accentGlow, symbolSize: 16, frameSize: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

private struct HomeMetric: View {
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
