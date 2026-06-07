import SwiftUI
import WebKit

/// An in-app player for an optional demo clip. Videos are off by default across the app —
/// this sheet only ever appears for a sound/sign that has a `videoURL`. It uses YouTube's
/// privacy-enhanced `youtube-nocookie.com` embed, which sets no tracking cookies until the
/// viewer presses play, so the app's offline-first, no-tracking stance is kept as much as
/// an embedded video allows.
struct VideoPlayerSheet: View {
    let title: String
    let videoURL: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let id = Self.videoID(from: videoURL) {
                    YouTubeWebView(videoID: id)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    unavailable
                }
            }
            .background(Color.black)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("Plays a video from YouTube.")
                    .font(.footnote).foregroundStyle(Theme.label3)
                    .padding(.vertical, Theme.sp2)
            }
        }
    }

    private var unavailable: some View {
        VStack(spacing: Theme.sp3) {
            Image(systemName: "video.slash").font(.largeTitle).foregroundStyle(Theme.label3)
            Text("This video can't be opened.").foregroundStyle(Theme.label2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Extract a YouTube video id from the common URL forms (watch?v=, youtu.be/, /embed/)
    /// or accept a bare 11-character id.
    static func videoID(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let comps = URLComponents(string: trimmed) else {
            return isLikelyID(trimmed) ? trimmed : nil
        }
        if let v = comps.queryItems?.first(where: { $0.name == "v" })?.value, isLikelyID(v) {
            return v
        }
        // youtu.be/<id> or .../embed/<id>
        let last = comps.path.split(separator: "/").last.map(String.init) ?? trimmed
        return isLikelyID(last) ? last : (isLikelyID(trimmed) ? trimmed : nil)
    }

    private static func isLikelyID(_ s: String) -> Bool {
        s.count == 11 && s.allSatisfy { $0.isLetter || $0.isNumber || $0 == "-" || $0 == "_" }
    }
}

/// A minimal `WKWebView` wrapper that hosts the YouTube player in an `<iframe>` and allows
/// inline playback. The player must run inside an iframe on a page with a valid origin —
/// loading the bare `.../embed/<id>` URL as the top frame makes YouTube report the video as
/// unavailable. So we load an HTML host page with a real `baseURL` origin instead.
private struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedID != videoID else { return }
        context.coordinator.loadedID = videoID
        let src = "https://www.youtube-nocookie.com/embed/\(videoID)?playsinline=1&rel=0"
        let html = """
        <!DOCTYPE html><html><head>
        <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">
        <style>html,body{margin:0;height:100%;background:#000}iframe{border:0;width:100%;height:100%}</style>
        </head><body>
        <iframe src="\(src)" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>
        </body></html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator { var loadedID: String? }
}
