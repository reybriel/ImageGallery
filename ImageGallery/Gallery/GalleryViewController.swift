import UIKit

final class GalleryViewController: UIViewController {
    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .fullScreen }
        set { super.modalPresentationStyle = newValue }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    private let galleryView: GalleryView
    private let imagesURLs: [String]
    private let downloader: ImageDownloader

    private var actualURLs: [URL] {
        imagesURLs.compactMap { urlPath in
            URL(string: urlPath)
        }
    }

    // MARK: - Initializing

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        imagesURLs: [String],
        showingIndex: Int = 0,
        downloader: ImageDownloader = DefaultImageDownloader()
    ) {
        self.imagesURLs = imagesURLs
        self.downloader = downloader

        if showingIndex < imagesURLs.count {
            galleryView = GalleryView(showingIndex: showingIndex)
        } else {
            galleryView = GalleryView()
        }

        super.init(nibName: nil, bundle: nil)
        galleryView.delegate = self
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        downloader.downloadImages(fromURLs: actualURLs) { [weak self] images, error in
            guard let self = self, error == nil else { return }
            self.galleryView.display(images: images)
            self.galleryView.isImagesPageControlHidden = images.count <= 1
        }
    }

    override func willAnimateRotation(to orientation: UIInterfaceOrientation, duration _: TimeInterval) {
        switch orientation {
        case .portrait:
            galleryView.rotateToPortrait()
        case .landscapeLeft, .landscapeRight:
            galleryView.rotateToLandscape()
        default:
            break
        }
    }
}

// MARK: - GalleryViewDelegate -

extension GalleryViewController: GalleryViewDelegate {
    func didTapExitButton() {
        dismiss(animated: true)
    }
}
