import SwiftUI
import SwiftData

struct PostsView: View {
    @EnvironmentObject var auth: AuthService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Post.createdAt, order: .reverse) private var posts: [Post]
    @State private var showingComposer = false

    var body: some View {
        Group {
            if posts.isEmpty {
                EmptyState(systemImage: "square.and.pencil",
                           title: "No posts yet",
                           message: "Share an update with text, a photo, or a video.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(posts) { post in
                            PostCard(post: post)
                                .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle("Posts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingComposer = true } label: { Image(systemName: "square.and.pencil") }
            }
        }
        .sheet(isPresented: $showingComposer) {
            CreatePostView(authorID: auth.currentUser?.id ?? UUID(),
                           authorName: auth.currentUser?.displayName ?? "Unknown")
                .presentationDetents([.large])
        }
    }
}

struct PostCard: View {
    @Environment(\.modelContext) private var modelContext
    let post: Post
    @State private var liked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2).foregroundStyle(AppTheme.accent)
                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorName).font(.subheadline.bold())
                    Text(post.createdAt, style: .relative).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
            }

            if !post.text.isEmpty {
                Text(post.text).font(.body)
            }

            if !post.imagePaths.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(post.imagePaths, id: \.self) { path in
                            StoredImageView(path: path, cornerRadius: 12)
                                .frame(width: 220, height: 200)
                        }
                    }
                }
            }

            if let videoPath = post.videoPath, FileManager.default.fileExists(atPath: videoPath) {
                VideoPlayerView(url: URL(fileURLWithPath: videoPath))
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            HStack {
                Button {
                    liked.toggle()
                    if liked { post.likeCount += 1 } else if post.likeCount > 0 { post.likeCount -= 1 }
                    try? modelContext.save()
                } label: {
                    Label("\(post.likeCount)", systemImage: liked ? "heart.fill" : "heart")
                        .foregroundStyle(liked ? .pink : .secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .font(.subheadline)
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
