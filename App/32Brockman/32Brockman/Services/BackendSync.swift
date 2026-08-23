import Foundation

struct BackendSync {
    static let baseURL: URL? = {
        guard let raw = ProcessInfo.processInfo.environment["BROCKMAN_API"],
              let url = URL(string: raw) else { return nil }
        return url
    }()

    static var isRemote: Bool { baseURL != nil }

    static func uploadPost(json: [String: Any]) {
        guard let url = baseURL?.appendingPathComponent("posts") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: json)
        URLSession.shared.dataTask(with: req).resume()
    }
}
