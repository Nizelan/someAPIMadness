import UIKit

protocol AccFavoritesCellDelegate: class {
    func playButtonPressed(cell: UITableViewCell)
}

class AccFavoritesCell: UITableViewCell {

    @IBOutlet weak var favoriteImageView: ScalingImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var ups: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goToVideos: UIButton!
    weak var delegate: AccFavoritesCellDelegate?

    func setup(with album: FavoritePost) {
        self.layer.cornerRadius = 10
        setupImage(with: album)
        self.ups.text = String(album.points)

        if let title = album.title {
            self.title.text = title
        } else {
            self.title.isHidden = true
        }
    }

    private func setupImage(with album: FavoritePost) {
        let imageLink = album.link

        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false
        favoriteImageView.imageSize = album.coverSize
        self.setNeedsLayout()
        self.layoutIfNeeded()

        if album.images[0].mp4 != nil {
            goToVideos.isHidden = false
            favoriteImageView.image = UIImage(named: "playVideo")
            stopActivity()
        } else {
            goToVideos.isHidden = true
            self.startActivity()
            favoriteImageView.loadImage(from: imageLink, completion: { success in
                self.stopActivity()
                if success {
                    print("successfully loaded image with url: \(imageLink)")
                } else {
                    print("failed to load image with url: \(imageLink)")
                }
            }, shouldAssignImage: nil)
        }
    }

    @IBAction func goToVideo(_ sender: Any) {
        delegate?.playButtonPressed(cell: self)
    }

    private func startActivity() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func stopActivity() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
