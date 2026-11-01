import Foundation
import CryptoKit
import Combine

struct RemoteContentFile: Codable, Identifiable, Equatable {
    let id: String
    let slug: String
    let name: String
    let version: Int
    let category: String
    let description: String?
    let targetBundle: String?
    let targetPath: String?
    let fileName: String
    let mimeType: String?
    let byteSize: Int64
    let sha256: String
    let storagePath: String
    let isActive: Bool
    let deletedAt: String?
    let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case version
        case category
        case description
        case targetBundle = "target_bundle"
        case targetPath = "target_path"
        case fileName = "file_name"
        case mimeType = "mime_type"
        case byteSize = "byte_size"
        case sha256
        case storagePath = "storage_path"
        case isActive = "is_active"
        case deletedAt = "deleted_at"
        case publishedAt = "published_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug = ((try? container.decode(String.self, forKey: .slug)) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        id = ((try? container.decode(String.self, forKey: .id)) ?? slug).trimmingCharacters(in: .whitespacesAndNewlines)
        name = ((try? container.decode(String.self, forKey: .name)) ?? slug).trimmingCharacters(in: .whitespacesAndNewlines)
        version = (try? container.decode(Int.self, forKey: .version)) ?? 0
        category = ((try? container.decode(String.self, forKey: .category)) ?? "files").trimmingCharacters(in: .whitespacesAndNewlines)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        targetBundle = (try? container.decodeIfPresent(String.self, forKey: .targetBundle))?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        targetPath = (try? container.decodeIfPresent(String.self, forKey: .targetPath))?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        fileName = ((try? container.decode(String.self, forKey: .fileName)) ?? slug).trimmingCharacters(in: .whitespacesAndNewlines)
        mimeType = try? container.decodeIfPresent(String.self, forKey: .mimeType)
        byteSize = (try? container.decode(Int64.self, forKey: .byteSize)) ?? 0
        sha256 = ((try? container.decode(String.self, forKey: .sha256)) ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        storagePath = ((try? container.decode(String.self, forKey: .storagePath)) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        isActive = (try? container.decode(Bool.self, forKey: .isActive)) ?? true
        deletedAt = try? container.decodeIfPresent(String.self, forKey: .deletedAt)
        publishedAt = try? container.decodeIfPresent(String.self, forKey: .publishedAt)
    }

    init(
        id: String,
        slug: String,
        name: String,
        version: Int,
        category: String,
        description: String?,
        targetBundle: String?,
        targetPath: String?,
        fileName: String,
        mimeType: String?,
        byteSize: Int64,
        sha256: String,
        storagePath: String,
        isActive: Bool = true,
        deletedAt: String? = nil,
        publishedAt: String?
    ) {
        self.id = id
        self.slug = slug
        self.name = name
        self.version = version
        self.category = category
        self.description = description
        self.targetBundle = targetBundle?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.targetPath = targetPath?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.fileName = fileName
        self.mimeType = mimeType
        self.byteSize = byteSize
        self.sha256 = sha256.lowercased()
        self.storagePath = storagePath
        self.isActive = isActive
        self.deletedAt = deletedAt
        self.publishedAt = publishedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(slug, forKey: .slug)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(targetBundle, forKey: .targetBundle)
        try container.encodeIfPresent(targetPath, forKey: .targetPath)
        try container.encode(fileName, forKey: .fileName)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encode(byteSize, forKey: .byteSize)
        try container.encode(sha256, forKey: .sha256)
        try container.encode(storagePath, forKey: .storagePath)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
        try container.encodeIfPresent(publishedAt, forKey: .publishedAt)
    }

    var localRelativePath: String {
        if let cleanTargetPath = Self.safeRelativePath(targetPath), !cleanTargetPath.isEmpty {
            return cleanTargetPath
        }

        return [
            Self.safeComponent(category, fallback: "files"),
            Self.safeComponent(slug, fallback: id),
            Self.safeComponent(fileName, fallback: "content.bin")
        ].joined(separator: "/")
    }

    var cacheRelativePath: String {
        [
            "_files",
            Self.safeComponent(id, fallback: slug),
            Self.safeComponent(fileName, fallback: "content.bin")
        ].joined(separator: "/")
    }

    var displaySize: String {
        ByteCountFormatter.string(fromByteCount: byteSize, countStyle: .file)
    }

    var targetBundleID: String {
        let clean = (targetBundle ?? "com.dts.freefireth").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return clean.isEmpty ? "com.dts.freefireth" : clean
    }

    var isAvailable: Bool {
        isActive && deletedAt == nil
    }

    private static func safeComponent(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = trimmed.isEmpty ? fallback : trimmed
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~+"))
        let scalars = source.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let collapsed = String(scalars).replacingOccurrences(of: "--+", with: "-", options: .regularExpression)
        let clean = collapsed.trimmingCharacters(in: CharacterSet(charactersIn: ".-"))
        return clean.isEmpty ? "content" : clean
    }

    private static func safeRelativePath(_ value: String?) -> String? {
        let parts = (value ?? "")
            .replacingOccurrences(of: "\\", with: "/")
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
            .filter { $0 != "." && $0 != ".." }
            .map { safeComponent($0, fallback: "content") }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: "/")
    }
}

struct RemoteContentManifest: Codable, Equatable {
    let success: Bool
    let message: String
    let version: Int
    let publishedAt: String?
    let files: [RemoteContentFile]

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case version
        case publishedAt = "published_at"
        case files
    }

    init(
        success: Bool = true,
        message: String = "",
        version: Int = 0,
        publishedAt: String? = nil,
        files: [RemoteContentFile] = []
    ) {
        self.success = success
        self.message = message
        self.version = version
        self.publishedAt = publishedAt
        self.files = files
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = (try? container.decode(Bool.self, forKey: .success)) ?? true
        message = (try? container.decode(String.self, forKey: .message)) ?? ""
        version = (try? container.decode(Int.self, forKey: .version)) ?? 0
        publishedAt = try? container.decodeIfPresent(String.self, forKey: .publishedAt)
        files = (try? container.decode([RemoteContentFile].self, forKey: .files)) ?? []
    }
}

enum RemoteContentSyncError: LocalizedError {
    case missingLicense
    case badURL
    case badResponse
    case server(String)
    case invalidManifest(String)
    case hashMismatch(String)
    case rollbackFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingLicense:
            return "No active key is stored on this device."
        case .badURL:
            return "Could not prepare the Supabase URL."
        case .badResponse:
            return "Supabase did not return a valid response."
        case .server(let message):
            return message
        case .invalidManifest(let message):
            return message
        case .hashMismatch(let name):
            return "Integrity check failed for \(name)."
        case .rollbackFailed(let message):
            return "Update failed and rollback could not finish: \(message)"
        }
    }
}

@MainActor
final class RemoteContentStore: ObservableObject {
    @Published private(set) var installedFiles: [RemoteContentFile] = []
    @Published private(set) var remoteVersion = 0
    @Published private(set) var statusText = "Listo"
    @Published private(set) var detailText = "Los archivos remotos se guardan dentro de NOVA X66."
    @Published private(set) var progress: Double?
    @Published private(set) var lastChecked: Date?
    @Published private(set) var isBusy = false

    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let minimumAutomaticInterval: TimeInterval = 10 * 60
    private var lastAutomaticAttempt: Date?

    init(session: URLSession = .shared) {
        self.session = session
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        loadLocalState()
    }

    func loadLocalState() {
        guard let manifest = try? loadLocalManifest() else {
            installedFiles = []
            remoteVersion = 0
            return
        }
        installedFiles = manifest.files.filter(\.isAvailable)
        remoteVersion = manifest.version
    }

    func syncIfPossible(force: Bool = false) {
        loadLocalState()
        guard !isBusy else { return }
        if !force,
           let lastAutomaticAttempt,
           Date().timeIntervalSince(lastAutomaticAttempt) < minimumAutomaticInterval {
            return
        }
        lastAutomaticAttempt = Date()
        Task { await sync(force: force) }
    }

    private func sync(force: Bool) async {
        isBusy = true
        progress = nil
        statusText = "Buscando cambios"
        detailText = force ? "Actualizacion manual iniciada." : "Actualizacion automatica iniciada."

        do {
        let manifest = Self.scopedManifest(try await fetchManifest())
            try validate(manifest)
            let localManifest = try? loadLocalManifest()
            let plan = try makePlan(remote: manifest, local: localManifest)

            if plan.changed.isEmpty && plan.obsolete.isEmpty {
                try saveLocalManifest(manifest)
                BundledPatchSeeder.seedIfNeeded()
                installedFiles = manifest.files.filter(\.isAvailable)
                remoteVersion = manifest.version
                progress = 1
                statusText = "Actualizado"
                detailText = manifest.files.isEmpty
                    ? "Todavia no hay archivos publicados."
                    : "\(installedFiles.count) archivo(s) remoto(s) instalados."
                lastChecked = Date()
                isBusy = false
                return
            }

            let backupURL = try createBackup()
            let stagingRoot = try resetStagingRoot()
            var stagedDownloads: [String: URL] = [:]
            let totalSteps = max(plan.changed.count + plan.obsolete.count + 1, 1)
            var completedSteps = 0

            do {
                for file in plan.changed {
                    statusText = "Descargando \(file.name)"
                    let stagedURL = try await download(file, into: stagingRoot)
                    stagedDownloads[file.id] = stagedURL
                    completedSteps += 1
                    progress = Double(completedSteps) / Double(totalSteps)
                }

                statusText = "Instalando archivos"
                try install(
                    manifest: manifest,
                    previousManifest: localManifest,
                    stagedDownloads: stagedDownloads,
                    obsoleteFiles: plan.obsolete
                )
                completedSteps += 1
                progress = Double(completedSteps) / Double(totalSteps)
                try cleanupBackup(backupURL)
            } catch {
                try restoreBackup(backupURL)
                throw error
            }

            try saveLocalManifest(manifest)
            BundledPatchSeeder.seedIfNeeded()
            installedFiles = manifest.files.filter(\.isAvailable)
            remoteVersion = manifest.version
            progress = 1
            statusText = "Archivos actualizados"
            detailText = "\(plan.changed.count) descargado(s), \(plan.obsolete.count) quitado(s)."
            lastChecked = Date()
        } catch {
            progress = nil
            statusText = "Fallo la actualizacion"
            detailText = error.localizedDescription
            lastChecked = Date()
        }

        isBusy = false
    }

    private struct SyncPlan {
        let changed: [RemoteContentFile]
        let obsolete: [RemoteContentFile]
    }

    private func fetchManifest() async throws -> RemoteContentManifest {
        let licenseKey = UserDefaults.standard.string(forKey: "nova.license.key")?.normalizedLicenseKey ?? ""
        guard !licenseKey.isEmpty else { throw RemoteContentSyncError.missingLicense }

        var components = URLComponents(url: SupabaseLicenseConfig.projectURL, resolvingAgainstBaseURL: false)
        components?.path = "/rest/v1/rpc/get_remote_content_manifest"
        guard let url = components?.url else { throw RemoteContentSyncError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 25
        request.setValue(SupabaseLicenseConfig.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseLicenseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "p_license_key": licenseKey,
            "p_device_id": DeviceInstallationID.current()
        ])

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RemoteContentSyncError.badResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            if let rpcError = try? decoder.decode(SupabaseRPCErrorPayload.self, from: data),
               let message = rpcError.message,
               !message.isEmpty {
                throw RemoteContentSyncError.server(message)
            }
            let raw = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw RemoteContentSyncError.server(raw)
        }

        return try decoder.decode(RemoteContentManifest.self, from: data)
    }

    private func validate(_ manifest: RemoteContentManifest) throws {
        guard manifest.success else {
            throw RemoteContentSyncError.server(manifest.message.isEmpty ? "Remote content unavailable." : manifest.message)
        }

        for file in manifest.files where file.isAvailable {
            guard !file.id.isEmpty,
                  !file.slug.isEmpty,
                  !file.fileName.isEmpty,
                  !file.storagePath.isEmpty,
                  file.sha256.range(of: #"^[a-f0-9]{64}$"#, options: .regularExpression) != nil else {
                throw RemoteContentSyncError.invalidManifest("Remote manifest contains an invalid file.")
            }
        }

        let ids = manifest.files.map(\.id)
        guard Set(ids).count == ids.count else {
            throw RemoteContentSyncError.invalidManifest("Remote manifest contains duplicate files.")
        }

        let cachePaths = manifest.files.filter(\.isAvailable).map(\.cacheRelativePath)
        guard Set(cachePaths).count == cachePaths.count else {
            throw RemoteContentSyncError.invalidManifest("Remote manifest contains duplicate cache paths.")
        }
    }

    private func makePlan(remote: RemoteContentManifest, local: RemoteContentManifest?) throws -> SyncPlan {
        let remoteFiles = remote.files.filter(\.isAvailable)
        let localFiles = (local?.files ?? []).filter(\.isAvailable)
        let localByID = Dictionary(uniqueKeysWithValues: localFiles.map { ($0.id, $0) })
        let remoteIDs = Set(remoteFiles.map(\.id))
        var changed: [RemoteContentFile] = []

        for file in remoteFiles {
            let installed = localByID[file.id]
            let targetURL = localURL(for: file)
            let metadataChanged = installed?.version != file.version
                || installed?.sha256 != file.sha256
                || installed?.storagePath != file.storagePath
                || installed?.cacheRelativePath != file.cacheRelativePath
            let missing = !FileManager.default.fileExists(atPath: targetURL.path)
            let digestChanged: Bool
            if !missing && !metadataChanged {
                digestChanged = ((try? sha256Hex(for: targetURL)) ?? "") != file.sha256
            } else {
                digestChanged = false
            }

            if metadataChanged || missing || digestChanged {
                changed.append(file)
            }
        }

        let obsolete = localFiles.filter { !remoteIDs.contains($0.id) }
        return SyncPlan(changed: changed, obsolete: obsolete)
    }

    private func download(_ file: RemoteContentFile, into stagingRoot: URL) async throws -> URL {
        let sourceURL = try objectURL(for: file.storagePath)
        var request = URLRequest(url: sourceURL)
        request.timeoutInterval = 60
        request.setValue(SupabaseLicenseConfig.publishableKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseLicenseConfig.publishableKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Accept")

        let (temporaryURL, response) = try await session.download(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw RemoteContentSyncError.server("Could not download \(file.name).")
        }

        let stagedURL = url(inside: stagingRoot, relativePath: file.cacheRelativePath)
        try FileManager.default.createDirectory(
            at: stagedURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? FileManager.default.removeItem(at: stagedURL)
        try FileManager.default.moveItem(at: temporaryURL, to: stagedURL)

        let digest = try sha256Hex(for: stagedURL)
        guard digest == file.sha256 else {
            throw RemoteContentSyncError.hashMismatch(file.name)
        }
        return stagedURL
    }

    private func install(
        manifest: RemoteContentManifest,
        previousManifest: RemoteContentManifest?,
        stagedDownloads: [String: URL],
        obsoleteFiles: [RemoteContentFile]
    ) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: currentRootURL, withIntermediateDirectories: true)
        let previousByID = Dictionary(uniqueKeysWithValues: (previousManifest?.files ?? []).map { ($0.id, $0) })

        for file in manifest.files where file.isAvailable {
            guard let stagedURL = stagedDownloads[file.id] else { continue }
            let destinationURL = localURL(for: file)
            try fileManager.createDirectory(at: destinationURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? fileManager.removeItem(at: destinationURL)
            try fileManager.moveItem(at: stagedURL, to: destinationURL)

            if let previous = previousByID[file.id],
               previous.cacheRelativePath != file.cacheRelativePath {
                try? fileManager.removeItem(at: localURL(for: previous))
            }
        }

        for file in obsoleteFiles {
            try? fileManager.removeItem(at: localURL(for: file))
        }
    }

    private func loadLocalManifest() throws -> RemoteContentManifest {
        let data = try Data(contentsOf: manifestURL)
        return try decoder.decode(RemoteContentManifest.self, from: data)
    }

    private func saveLocalManifest(_ manifest: RemoteContentManifest) throws {
        try FileManager.default.createDirectory(at: storeRootURL, withIntermediateDirectories: true)
        let data = try encoder.encode(manifest)
        try data.write(to: manifestURL, options: .atomic)
    }

    private func createBackup() throws -> URL {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: backupsRootURL, withIntermediateDirectories: true)
        let backupURL = backupsRootURL.appendingPathComponent(Self.backupName(), isDirectory: true)
        try fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)

        if fileManager.fileExists(atPath: currentRootURL.path) {
            try fileManager.copyItem(
                at: currentRootURL,
                to: backupURL.appendingPathComponent("current", isDirectory: true)
            )
        }
        if fileManager.fileExists(atPath: manifestURL.path) {
            try fileManager.copyItem(
                at: manifestURL,
                to: backupURL.appendingPathComponent("manifest.json", isDirectory: false)
            )
        }
        return backupURL
    }

    private func restoreBackup(_ backupURL: URL) throws {
        let fileManager = FileManager.default
        do {
            try? fileManager.removeItem(at: currentRootURL)
            try? fileManager.removeItem(at: manifestURL)

            let backupCurrent = backupURL.appendingPathComponent("current", isDirectory: true)
            if fileManager.fileExists(atPath: backupCurrent.path) {
                try fileManager.copyItem(at: backupCurrent, to: currentRootURL)
            }

            let backupManifest = backupURL.appendingPathComponent("manifest.json", isDirectory: false)
            if fileManager.fileExists(atPath: backupManifest.path) {
                try fileManager.createDirectory(at: storeRootURL, withIntermediateDirectories: true)
                try fileManager.copyItem(at: backupManifest, to: manifestURL)
            }
        } catch {
            throw RemoteContentSyncError.rollbackFailed(error.localizedDescription)
        }
    }

    private func cleanupBackup(_ backupURL: URL) throws {
        try? FileManager.default.removeItem(at: backupURL)
    }

    private func resetStagingRoot() throws -> URL {
        let fileManager = FileManager.default
        let stagingURL = storeRootURL.appendingPathComponent("staging", isDirectory: true)
        try? fileManager.removeItem(at: stagingURL)
        try fileManager.createDirectory(at: stagingURL, withIntermediateDirectories: true)
        return stagingURL
    }

    private func localURL(for file: RemoteContentFile) -> URL {
        url(inside: currentRootURL, relativePath: file.cacheRelativePath)
    }

    private func objectURL(for storagePath: String) throws -> URL {
        let allowed = CharacterSet.urlPathAllowed
        let encodedPath = storagePath
            .split(separator: "/", omittingEmptySubsequences: true)
            .map { String($0).addingPercentEncoding(withAllowedCharacters: allowed) ?? String($0) }
            .joined(separator: "/")
        let base = SupabaseLicenseConfig.projectURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = URL(string: "\(base)/storage/v1/object/nova-content/\(encodedPath)") else {
            throw RemoteContentSyncError.badURL
        }
        return url
    }

    private func url(inside root: URL, relativePath: String) -> URL {
        relativePath
            .split(separator: "/", omittingEmptySubsequences: true)
            .reduce(root) { partial, component in
                partial.appendingPathComponent(String(component), isDirectory: false)
            }
    }

    private func sha256Hex(for url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }

        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 1_024 * 1_024) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }

        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    private var storeRootURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return base.appendingPathComponent("LaCosaNostraRemoteContent", isDirectory: true)
    }

    private var currentRootURL: URL {
        storeRootURL.appendingPathComponent("current", isDirectory: true)
    }

    private var backupsRootURL: URL {
        storeRootURL.appendingPathComponent("backups", isDirectory: true)
    }

    private var manifestURL: URL {
        storeRootURL.appendingPathComponent("manifest.json", isDirectory: false)
    }

    private static func backupName() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return "\(formatter.string(from: Date()))-\(UUID().uuidString)"
    }

    private static func scopedManifest(_ manifest: RemoteContentManifest) -> RemoteContentManifest {
        RemoteContentManifest(
            success: manifest.success,
            message: manifest.message,
            version: manifest.version,
            publishedAt: manifest.publishedAt,
            files: manifest.files.filter { file in
                file.category.lowercased().hasPrefix("nova-")
                    || file.slug.lowercased().hasPrefix("nova-")
            }
        )
    }
}

enum RemoteContentLibrary {
    static func loadManifest(fileManager: FileManager = .default) -> RemoteContentManifest? {
        let url = manifestURL(fileManager: fileManager)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(RemoteContentManifest.self, from: data)
    }

    static func installedFile(
        matching relativePath: String,
        slugs: Set<String> = [],
        bundleID: String = "com.dts.freefireth",
        fileManager: FileManager = .default
    ) -> (file: RemoteContentFile, url: URL)? {
        let requestedPath = safeRelativePath(relativePath)
        let requestedBundle = safeBundleID(bundleID)
        let requestedSlugs = Set(slugs.map(safeSlug))
        guard let file = loadManifest(fileManager: fileManager)?.files.first(where: { file in
            guard file.isAvailable else { return false }
            if !requestedSlugs.isEmpty {
                return requestedSlugs.contains { slugMatches(safeSlug(file.slug), expected: $0) }
                    && safeBundleID(file.targetBundleID) == requestedBundle
            }
            return safeBundleID(file.targetBundleID) == requestedBundle
                && safeRelativePath(file.localRelativePath) == requestedPath
        }) else {
            return nil
        }

        let url = url(inside: currentRootURL(fileManager: fileManager), relativePath: file.cacheRelativePath)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return (file, url)
    }

    static func isBuiltInDisabled(
        bundleID: String = "com.dts.freefireth",
        relativePath: String,
        slugs: Set<String> = [],
        fileManager: FileManager = .default
    ) -> Bool {
        let requestedBundle = safeBundleID(bundleID)
        let requestedPath = safeRelativePath(relativePath)
        let requestedSlugs = Set(slugs.map(safeSlug))
        return loadManifest(fileManager: fileManager)?.files.contains(where: { file in
            guard !file.isAvailable else { return false }
            if !requestedSlugs.isEmpty {
                return requestedSlugs.contains { slugMatches(safeSlug(file.slug), expected: $0) }
                    && safeBundleID(file.targetBundleID) == requestedBundle
            }
            return safeBundleID(file.targetBundleID) == requestedBundle
                && safeRelativePath(file.localRelativePath) == requestedPath
        }) ?? false
    }

    static func localFileURL(
        for file: RemoteContentFile,
        fileManager: FileManager = .default
    ) -> URL? {
        let url = url(inside: currentRootURL(fileManager: fileManager), relativePath: file.cacheRelativePath)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    private static func safeRelativePath(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "/")
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
            .filter { $0 != "." && $0 != ".." }
            .joined(separator: "/")
            .lowercased()
    }

    private static func safeBundleID(_ value: String) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return clean.isEmpty ? "com.dts.freefireth" : clean
    }

    private static func safeSlug(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func slugMatches(_ actual: String, expected: String) -> Bool {
        actual == expected || actual.hasPrefix(expected + "-")
    }

    private static func url(inside root: URL, relativePath: String) -> URL {
        relativePath
            .split(separator: "/", omittingEmptySubsequences: true)
            .reduce(root) { partial, component in
                partial.appendingPathComponent(String(component), isDirectory: false)
            }
    }

    private static func storeRootURL(fileManager: FileManager) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return base.appendingPathComponent("LaCosaNostraRemoteContent", isDirectory: true)
    }

    private static func currentRootURL(fileManager: FileManager) -> URL {
        storeRootURL(fileManager: fileManager).appendingPathComponent("current", isDirectory: true)
    }

    private static func manifestURL(fileManager: FileManager) -> URL {
        storeRootURL(fileManager: fileManager).appendingPathComponent("manifest.json", isDirectory: false)
    }
}

private struct SupabaseRPCErrorPayload: Decodable {
    let message: String?
}
