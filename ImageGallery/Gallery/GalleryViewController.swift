import UIKit

final class GalleryViewController: UIViewController {
    override var modalPresentationStyle: UIModalPresentationStyle {
        get { .fullScreen }
        set { super.modalPresentationStyle = newValue }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    private lazy var galleryView: GalleryView = {
        let view = GalleryView()
        view.delegate = self
        return view
    }()

    private let imagesURLs: [String]
    private let showingPage: Int
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
        showingPage: Int = 0,
        downloader: ImageDownloader = DefaultImageDownloader()
    ) {
        self.imagesURLs = imagesURLs
        self.showingPage = showingPage
        self.downloader = downloader
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        downloader.downloadImages(fromURLs: actualURLs) { [weak self, showingPage] images, error in
            guard let self = self, error == nil else { return }
            self.galleryView.display(images: images, showingPage: showingPage)
            self.galleryView.isImagesPageControlHidden = images.count <= 1
        }
    }

    override func viewWillTransition(to size: CGSize, with transitionCoordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: transitionCoordinator)
        galleryView.prepareForRotation()

        transitionCoordinator.animate(
            alongsideTransition: { _ in
                self.galleryView.performRotation(sizeAfterRotation: size)
            }
        )
    }
}

// MARK: - GalleryViewDelegate -

extension GalleryViewController: GalleryViewDelegate {
    func didTapExitButton() {
        dismiss(animated: true)
    }
}
