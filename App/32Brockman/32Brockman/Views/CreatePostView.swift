import SwiftUI
import SwiftData

struct CreatePostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let authorID: UUID
    let authorName: String

    @State private var text = ""
    @State private var selectedImages: [Data] = []
    @State private var showImagePicker = false
    @State private var pendingImage: Data?
    @State private var videoURL: URL?
    @State private var showVideoPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("What's on your mind?", text: $text, axis: .vertical)
                        .lineLimit(3...8)
                        .font(.body)
                        .padding(12)
                        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedImages.indices, id: \.self) { i in
                                    if let ui = UIImage(data: selectedImages[i]) {
                                        Image(uiImage: ui)
                                            .resizable().scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .overlay(alignment: .topTrailing) {
                                                Button {
                                                    selectedImages.remove(at: i)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundStyle(.white, AppTheme.accent)
                                                }
                                                .padding(4)
                                            }
                                    }
                                }
                            }
                        }
                    }

                    if let videoURL {
                        HStack {
                            Image(systemName: "video.fill").foregroundStyle(AppTheme.accent)
                            Text(videoURL.lastPathComponent).font(.caption).lineLimit(1)
                            Spacer()
                            Button { self.videoURL = nil } label: { Image(systemName: "xmark.circle.fill") }
                        }
                        .padding(10)
                        .background(.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    HStack(spacing: 14) {
                        Button { showImagePicker = true } label: {
                            Label("Photo", systemImage: "photo").font(.subheadline)
                        }
                        Button { showVideoPicker = true } label: {
                            Label("Video", systemImage: "video").font(.subheadline)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") { publish(); dismiss() }
                        .disabled(text.isEmpty && selectedImages.isEmpty && videoURL == nil)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageData: $pendingImage, isPresented: $showImagePicker)
            }
            .sheet(isPresented: $showVideoPicker) {
                VideoPicker(videoURL: $videoURL, isPresented: $showVideoPicker)
            }
            .onChange(of: pendingImage) { _, new in
                if let new { selectedImages.append(new) }
            }
        }
    }

    private func publish() {
        var imagePaths: [String] = []
        for data in selectedImages {
            if let p = MediaStore.shared.saveImage(data) { imagePaths.append(p) }
        }
        let vPath = videoURL.flatMap { MediaStore.shared.saveVideo(at: $0) }

        let post = Post(authorID: authorID,
                        authorName: authorName,
                        text: text,
                        imagePaths: imagePaths,
                        videoPath: vPath)
        modelContext.insert(post)
        try? modelContext.save()

        // Optional remote sync extension point.
        if BackendSync.isRemote {
            BackendSync.uploadPost(json: [
                "authorName": authorName, "text": text,
                "imageCount": imagePaths.count, "hasVideo": vPath != nil
            ])
        }
    }
}
