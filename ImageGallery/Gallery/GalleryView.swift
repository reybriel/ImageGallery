import UIKit

protocol GalleryViewDelegate: AnyObject {
    func didTapExitButton()
}

final class GalleryView: UIView {
    weak var delegate: GalleryViewDelegate?

    private let paggingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()

    private let exitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Exit", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .white
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 25
        button.layer.shadowOpacity = 0.8
        return button
    }()

    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        displaySubviews()
        assignSelectorToExitButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func displaySubviews() {
        addSubview(paggingScrollView)
        addSubview(exitButton)

        NSLayoutConstraint.activate([
            paggingScrollView.topAnchor.constraint(equalTo: topAnchor),
            paggingScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            paggingScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            paggingScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exitButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            exitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
    }

    private func assignSelectorToExitButton() {
        exitButton.addTarget(self, action: #selector(delegateExitButtonTap), for: .touchUpInside)
    }

    @objc
    private func delegateExitButtonTap() {
        delegate?.didTapExitButton()
    }

    // MARK: - Layouting

    override func layoutSubviews() {
        super.layoutSubviews()
        exitButton.frame = CGRect(
            origin: exitButton.frame.origin,
            size: CGSize(
                width: exitButton.frame.size.width + 20,
                height: exitButton.frame.size.height
            )
        )
    }

    // MARK: - Displaying Images

    func display(images: [UIImage]) {
        let imageViews = images.map { image -> UIImageView in
            let view = UIImageView(image: image)
            view.frame = frame
            view.contentMode = .scaleAspectFit
            return view
        }

        insertIntoScrollView(imageViews: imageViews)
    }

    private func insertIntoScrollView(imageViews: [UIImageView]) {
        paggingScrollView.contentSize = imageViews.reduce(CGSize.zero) { contentSize, imageView in
            imageView.frame = CGRect(
                origin: CGPoint(x: contentSize.width, y: 0),
                size: UIScreen.main.bounds.size
            )

            paggingScrollView.addSubview(imageView)

            return CGSize(
                width: contentSize.width + imageView.frame.width,
                height: frame.height
            )
        }
    }
}
