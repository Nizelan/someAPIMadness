import UIKit

enum SelectedAlbum: Int {
    case mostViral = 2
    case following = 1
}

class MostViralCollectionVC: UICollectionViewController,
AlbumTableVCDelegate, CustomCollectionLayoutDelegate, CustomTitleViewDelegate {

    private let galleryService = GalleryService()

    var albums: [Post] = []
    var selectedAlbum = 2
    var customTitle = CustomTitleView()
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.titleView = customTitle
        columnCountChange(columns: selectedAlbum)
        customTitle.delegate = self
        self.collectionView.register(UINib(
            nibName: "MostViralCell",
            bundle: nil
        ), forCellWithReuseIdentifier: "MostViralCell")
        mostViralPressed()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        customTitle.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        customTitle.isHidden = false
    }

    func scrollToRow(currentRow: Int) {
        let index = IndexPath(row: currentRow, section: 0)
        collectionView.scrollToItem(at: index, at: .bottom, animated: false)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MostViralCell", for: indexPath) as? MostViralCell else {
                return UICollectionViewCell()
        }

        if indexPath.item == (albums.count - 6) {
            galleryService.page += 1
            if selectedAlbum == 2 {
                galleryService.fetchGalleryAlbums(selectedAlbum: .mostViral) { galleryResponse in
                    self.albums += galleryResponse.data
                    self.collectionView.reloadData()
                }
                self.collectionView.reloadData()
            } else if selectedAlbum == 1 {
                galleryService.fetchGalleryAlbums(selectedAlbum: .following) { galleryResponse in
                    self.albums += galleryResponse.data
                    self.collectionView.reloadData()
                }
                self.collectionView.reloadData()
            }
        }
        cell.currentIndexPath = indexPath
        cell.setup(with: self.albums[indexPath.item]) { () -> Bool in
            return indexPath == cell.currentIndexPath
        }

        return cell
    }

    func mostViralPressed() {
        albums.removeAll()
        selectedAlbum = 2
        columnCountChange(columns: selectedAlbum)
        galleryService.fetchGalleryAlbums(selectedAlbum: .mostViral) { galleryResponse in
            self.albums += galleryResponse.data
            self.collectionView.reloadData()
        }
    }

    func follovingTapt() {
        albums.removeAll()
        selectedAlbum = 1
        columnCountChange(columns: selectedAlbum)
        galleryService.fetchGalleryAlbums(selectedAlbum: .following) { galleryResponse in
            self.albums += galleryResponse.data
            self.collectionView.reloadData()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAlbum = indexPath.row
        performSegue(withIdentifier: "ShowAlbum", sender: Any?.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAlbum" {
            guard let destination = segue.destination as? AlbumTableViewController else { return }
            destination.selectedAlbum = selectedAlbum
            destination.albums = albums
            destination.delegate = self
        }
    }

    override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if actualPosition.y > 0 {
            hideTabBar(bool: false)
        } else {
            hideTabBar(bool: true)
        }
    }

    func hideTabBar(bool: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            if bool {
                if var fabricBottomFrame = self.tabBarController?.tabBar.frame {
                    fabricBottomFrame.origin.y += fabricBottomFrame.size.height

                    self.tabBarController?.tabBar.frame = fabricBottomFrame
                }
            } else {
                if var fabricBottomFrame = self.tabBarController?.tabBar.frame {
                    fabricBottomFrame.origin.y -= fabricBottomFrame.size.height

                    self.tabBarController?.tabBar.frame = fabricBottomFrame
                }
            }
        }, completion: { _ in
        })
    }

    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let cellWidth = collectionView.frame.width / 2 - 12
        let captionHeight = 49
        return cellWidth / albums[indexPath.row].aspectRatio + CGFloat(captionHeight)
    }

    func columnCountChange(columns: Int) {
        if let layout = collectionView?.collectionViewLayout as? CustomCollectionLayout {
            layout.delegate = self
            layout.numberOfColumns = columns
        }
    }
}
