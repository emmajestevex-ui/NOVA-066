import Foundation

enum DevicePatchService {
    static func apply(project: PatchProject) throws -> PatchTransactionReceipt {
        let project = project.resolvedForInstalledFreeFire()
        let bundleIDs = orderedBundleIdentifiers(in: project)
        return try withResolvedContainers(bundleIDs: bundleIDs) { roots in
            try PatchTransaction.apply(
                project: project,
                backupRoot: try PatchProjectLibrary.backupRootURL(),
                containerResolver: { bundleID in
                    guard let root = roots[bundleID] else {
                        throw PatchPackageError.targetAppUnavailable(bundleID)
                    }
                    return root
                }
            )
        }
    }

    static func restore(receipt: PatchTransactionReceipt) throws {
        let bundleIDs = try PatchTransaction.requiredBundleIdentifiers(for: receipt)
        try withResolvedContainers(bundleIDs: bundleIDs) { roots in
            try PatchTransaction.restore(
                receipt: receipt,
                containerResolver: { bundleID in
                    guard let root = roots[bundleID] else {
                        throw PatchPackageError.targetAppUnavailable(bundleID)
                    }
                    return root
                }
            )
        }
    }

    static func latestReceipt(projectID: UUID) -> PatchTransactionReceipt? {
        guard let backupRoot = try? PatchProjectLibrary.backupRootURL() else { return nil }
        return PatchTransaction.latestReceipt(projectID: projectID, backupRoot: backupRoot)
    }

    private static func orderedBundleIdentifiers(in project: PatchProject) -> [String] {
        project.allBundleIdentifiers
    }

    private static func withResolvedContainers<T>(
        bundleIDs: [String],
        operation: ([String: URL]) throws -> T
    ) throws -> T {
        var roots: [String: URL] = [:]

        for bundleID in bundleIDs {
            guard let path = ContainerStore.resolveAppContainerPath(bundleID: bundleID),
                  ContainerStore.isApplicationContainerPath(path) else {
                throw PatchPackageError.targetAppUnavailable(bundleID)
            }
            roots[bundleID] = PatchPathValidator.canonicalFileURL(URL(fileURLWithPath: path, isDirectory: true))
        }
        return try operation(roots)
    }

    private static let freeFireTH = "com.dts.freefireth"
    private static let freeFireMax = "com.dts.freefiremax"
    private static let assetIndexerTH = "assetindexer.U6Zffc4YIR3DslNj3cXvYGAqz58~3D"
    private static let assetIndexerMax = "assetindexer.PENojQAQ-f9a1I6Dzjs0n1Z3rtVU~3D"

    fileprivate static func resolvedFreeFireBundle(for requestedBundleID: String) -> String {
        let normalized = requestedBundleID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard normalized == freeFireTH || normalized == freeFireMax else {
            return requestedBundleID
        }

        if canResolve(normalized) {
            return normalized
        }

        let alternate = normalized == freeFireTH ? freeFireMax : freeFireTH
        if canResolve(alternate) {
            log("patch: Free Fire bundle fallback \(normalized) -> \(alternate)")
            return alternate
        }

        return normalized
    }

    private static func canResolve(_ bundleID: String) -> Bool {
        guard let path = ContainerStore.resolveAppContainerPath(bundleID: bundleID) else {
            return false
        }
        return ContainerStore.isApplicationContainerPath(path)
    }

    fileprivate static func adjustedRelativePath(_ path: String, for bundleID: String) -> String {
        switch bundleID {
        case freeFireMax:
            return path.replacingOccurrences(of: assetIndexerTH, with: assetIndexerMax)
        case freeFireTH:
            return path.replacingOccurrences(of: assetIndexerMax, with: assetIndexerTH)
        default:
            return path
        }
    }
}

private extension PatchProject {
    func resolvedForInstalledFreeFire() -> PatchProject {
        var copy = self
        copy.bundleIdentifiers = bundleIdentifiers.map {
            DevicePatchService.resolvedFreeFireBundle(for: $0)
        }
        copy.directories = directories.map { directory in
            let bundleID = DevicePatchService.resolvedFreeFireBundle(for: directory.bundleID)
            return PatchDirectory(
                id: directory.id,
                bundleID: bundleID,
                relativePath: DevicePatchService.adjustedRelativePath(
                    directory.relativePath,
                    for: bundleID
                )
            )
        }
        copy.rules = rules.map { rule in
            let bundleID = DevicePatchService.resolvedFreeFireBundle(for: rule.bundleID)
            return PatchRule(
                id: rule.id,
                bundleID: bundleID,
                relativePath: DevicePatchService.adjustedRelativePath(
                    rule.relativePath,
                    for: bundleID
                ),
                replacementFilename: rule.replacementFilename,
                replacementData: rule.replacementData
            )
        }
        return copy
    }
}
