import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: URL
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
            .frame(maxWidth: .infinity)
    }
}
