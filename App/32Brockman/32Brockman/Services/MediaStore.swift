import Foundation
import SwiftUI
import UniformTypeIdentifiers

final class MediaStore {
    static let shared = MediaStore()

    private let mediaDir: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        mediaDir = docs.appendingPathComponent("Media", isDirectory: true)
        try? FileManager.default.createDirectory(at: mediaDir, withIntermediateDirectories: true)
    }

    func saveImage(_ data: Data, ext: String = "jpg") -> String? {
        let name = "\(UUID().uuidString).\(ext)"
        let url = mediaDir.appendingPathComponent(name)
        guard (try? data.write(to: url)) != nil else { return nil }
        return url.path
    }

    func saveVideo(at sourceURL: URL) -> String? {
        let name = "\(UUID().uuidString).\(sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension)"
        let dest = mediaDir.appendingPathComponent(name)
        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.copyItem(at: sourceURL, to: dest)
            return dest.path
        } catch {
            print("Video copy failed: \(error)")
            return nil
        }
    }

    func image(from path: String) -> UIImage? {
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return UIImage(contentsOfFile: path)
    }

    func remove(at path: String) {
        try? FileManager.default.removeItem(atPath: path)
    }
}
