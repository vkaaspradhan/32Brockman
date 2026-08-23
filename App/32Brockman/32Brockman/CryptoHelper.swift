import Foundation
import CryptoKit

func hashPassword(_ password: String) -> String {
    let data = Data(password.utf8)
    let digest = SHA256.hash(data: data)
    return digest.map { String(format: "%02x", $0) }.joined()
}
