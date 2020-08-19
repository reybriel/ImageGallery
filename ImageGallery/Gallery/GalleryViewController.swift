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

    // MARK: - Initializing

    private var actualURLs: [URL] {
        imagesURLs.compactMap { urlPath in
            URL(string: urlPath)
        }
    }

    init(imagesURLs: [String]) {
        self.imagesURLs = imagesURLs
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = galleryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        downloadImages { [weak self] images, error in
            guard let self = self, error == nil else { return }
            DispatchQueue.main.async {
                self.galleryView.display(images: images)
            }
        }
    }

    private func downloadImages(completion: @escaping ([UIImage], Error?) -> Void) {
        DispatchQueue.global().async { [actualURLs] in
            do {
                let images = try actualURLs.map { url in
                    try Data(contentsOf: url)
                }
                .compactMap { data in
                    UIImage(data: data)
                }

                completion(images, nil)
            } catch {
                completion([], error)
            }
        }
    }
}

// MARK: - GalleryViewDelegate

extension GalleryViewController: GalleryViewDelegate {
    func didTapExitButton() {
        dismiss(animated: true)
    }
}
