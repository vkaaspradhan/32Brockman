import Foundation
import SwiftData

@Model
final class Post {
    var id: UUID
    var authorID: UUID
    var authorName: String
    var text: String
    var imagePaths: [String]
    var videoPath: String?
    var createdAt: Date
    var likeCount: Int

    init(
        id: UUID = UUID(),
        authorID: UUID,
        authorName: String,
        text: String,
        imagePaths: [String] = [],
        videoPath: String? = nil,
        createdAt: Date = .now,
        likeCount: Int = 0
    ) {
        self.id = id
        self.authorID = authorID
        self.authorName = authorName
        self.text = text
        self.imagePaths = imagePaths
        self.videoPath = videoPath
        self.createdAt = createdAt
        self.likeCount = likeCount
    }
}
