import UIKit
import AVKit

class CustomVideoPlayer: UIView {

    var player: AVPlayer?
    var playerLayer = AVPlayerLayer()
    var videoLink: String?

    override var bounds: CGRect {
        didSet {
            playerLayer.frame = self.bounds
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addPlayerToView(self)
    }

    private func addPlayerToView(_ view: UIView) {
        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.insertSublayer(playerLayer, at: 0)
        self.playerLayer = playerLayer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerEndPlay),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }

    func play() {
        guard let videoLink = self.videoLink else { return }
        if player?.currentItem == nil {
            guard let url = URL(string: videoLink) else {
                print("\(Self.self) error: we have not url")
                return }
            let playerItem = AVPlayerItem(url: url)
            player?.replaceCurrentItem(with: playerItem)
        }

        player?.play()
    }

    func pause() {
        player?.pause()
    }

    @objc func playerEndPlay() {
    }
}
