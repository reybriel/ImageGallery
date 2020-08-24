import UIKit

final class ViewController: UIViewController {
    private let galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Open gallery", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        displayGalleryButton()
        assignSelectorToGalleryButton()
    }

    private func displayGalleryButton() {
        view.addSubview(galleryButton)

        NSLayoutConstraint.activate([
            galleryButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            galleryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func assignSelectorToGalleryButton() {
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
    }

    @objc
    private func openGallery() {
        let viewController = GalleryViewController(
            imagesURLs: [
                "https://images-na.ssl-images-amazon.com/images/I/81qqrdewZlL._AC_SY450_.jpg",
                "https://www.hillspet.com.br/content/dam/cp-sites/hills/hills-pet/pt_br/general/prescription-diet/brands/hills-site-banner-ration-pack.jpg"
            ],
            showingPage: 1
        )

        present(viewController, animated: true)
    }
}

