import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.appLanguage) private var language
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
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
        Group {
            if horizontalSizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
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

    private var regularLayout: some View {
        NavigationSplitView {
            List {
                ForEach(featureVisibility.visibleSections) { section in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            tabNavigation.select(section.rawValue)
                        }
                    } label: {
                        Label(language.text(section.titleKey), systemImage: section.systemImage)
                            .fontWeight(section.rawValue == tabNavigation.selectedTab ? .semibold : .regular)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        section.rawValue == tabNavigation.selectedTab
                            ? AppTheme.accent.opacity(0.14)
                            : Color.clear
                    )
                    .accessibilityAddTraits(
                        section.rawValue == tabNavigation.selectedTab ? .isSelected : []
                    )
                }
            }
            .navigationTitle("NOVA X66")
            .navigationSplitViewColumnWidth(min: 210, ideal: 240, max: 300)
        } detail: {
            sectionContent(selectedVisibleSection)
                .id(selectedVisibleSection.rawValue)
        }
        .navigationSplitViewStyle(.balanced)
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
        case .cleaner:
            CleanerView()
        case .wallpapers:
            WallpaperLabView()
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
        case .cleaner: return "tab.cleaner"
        case .wallpapers: return "tab.wallpapers"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .files: return "folder.fill"
        case .patches: return "shippingbox.fill"
        case .cleaner: return "sparkles"
        case .wallpapers: return "photo.on.rectangle.angled"
        }
    }
}

private struct DashboardView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState
    @State private var showSettings = false
    @State private var showLogs = false
    @Binding var cleanerEnabled: Bool
    @Binding var wallpapersEnabled: Bool
    let wallpapersSupported: Bool
    let onOpenPatches: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    dashboardHero
                }

                Section {
                    Button(action: onOpenPatches) {
                        Label("Open Patches", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    HomePatchRow(
                        icon: "shippingbox.fill",
                        title: "Asset Indexer",
                        subtitle: "Avatar asset bundle",
                        tint: AppTheme.accent
                    )
                    HomePatchRow(
                        icon: "sparkles",
                        title: "Shaders",
                        subtitle: "Optional visual bundle",
                        tint: Color(red: 0.26, green: 0.72, blue: 1.0)
                    )
                    HomePatchRow(
                        icon: "speedometer",
                        title: "144 fps",
                        subtitle: "Preferences file",
                        tint: .green
                    )
                } header: {
                    Text("Built-in patches")
                }

                deviceSection

                if appState.kernelExploitApplicable && AppInfo.versionTuple.major < 26 {
                    kernelSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .tint(AppTheme.accent)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showLogs = true } label: {
                        Image(systemName: "apple.terminal")
                    }
                    .accessibilityLabel(language.text("accessibility.open_logs"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(language.text("accessibility.open_settings"))
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .sheet(isPresented: $showLogs) { LogView() }
        }
    }

    private var dashboardHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                AppLogo(size: 64)
                    .shadow(color: AppTheme.accent.opacity(0.35), radius: 12)

                VStack(alignment: .leading, spacing: 5) {
                    Text("NOVA X66")
                        .font(.system(size: 29, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text("Private patch control")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Label(appState.isSupported ? "Ready" : "Check", systemImage: appState.isSupported ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(appState.isSupported ? .green : AppTheme.accent)
            }

            Divider()

            HStack(spacing: 0) {
                HomeMetric(value: "3", title: "Patches")
                HomeMetric(value: "1", title: "Bundle")
                HomeMetric(value: appState.isSupported ? "OK" : "Wait", title: "Status")
            }
        }
    }

    private var deviceSection: some View {
        Section {
            LabeledContent(language.text("dashboard.hardware_model")) {
                Text(AppInfo.displayMachineName)
                    .font(.body.monospaced())
            }
            LabeledContent(language.text("settings.ios_version")) {
                Text("\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                    .font(.body.monospaced())
            }
            HStack {
                Text(language.text("settings.compatibility"))
                Spacer()
                Text(language.text(appState.isSupported ? "settings.supported" : "settings.unsupported"))
                    .fontWeight(.semibold)
                    .foregroundColor(appState.isSupported ? .green : AppTheme.accent)
            }
        } header: {
            Text(language.text("common.device"))
        } footer: {
            Text(language.text("settings.supported_range_summary"))
        }
    }

    private var kernelSection: some View {
        Section(language.text("dashboard.exploit_access")) {
            HStack {
                Label(language.text("dashboard.kernel_status"), systemImage: "apple.terminal")
                Spacer()
                if appState.kernelExploitRunning {
                    ProgressView().controlSize(.small)
                    Text(language.text("dashboard.kernel_running"))
                        .foregroundStyle(.secondary)
                } else {
                    Text(language.text(appState.exploitStatus.isSuccess ? "dashboard.kernel_active" : "dashboard.kernel_inactive"))
                        .foregroundColor(appState.exploitStatus.isSuccess ? .green : .secondary)
                }
            }
        }
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
                .foregroundColor(.green)
        }
        .padding(.vertical, 2)
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
