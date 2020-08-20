import UIKit

protocol GalleryViewDelegate: AnyObject {
    func didTapExitButton()
}

final class GalleryView: UIView {
    weak var delegate: GalleryViewDelegate?

    var isImagesPageControlHidden: Bool {
        get { imagesPageControl.isHidden }
        set { imagesPageControl.isHidden = newValue }
    }

    private lazy var paggingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()

    private let exitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Exit", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .white
        return button
    }()

    private let imagesPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.pageIndicatorTintColor = UIColor.blue.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = .blue
        return pageControl
    }()

    private var previousPage: Int = 0

    // MARK: - Initializing

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        displaySubviews()
        assignSelectorToExitButton()
    }

    private func displaySubviews() {
        addSubview(paggingScrollView)
        addSubview(exitButton)
        addSubview(imagesPageControl)

        NSLayoutConstraint.activate([
            paggingScrollView.topAnchor.constraint(equalTo: topAnchor),
            paggingScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            paggingScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            paggingScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            exitButton.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            exitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            imagesPageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            imagesPageControl.centerXAnchor.constraint(equalTo: centerXAnchor)
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
        layoutExitButton()
        displayShadow(at: exitButton)
    }

    private func layoutExitButton() {
        exitButton.layer.cornerRadius = exitButton.frame.height / 2
        exitButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        exitButton.frame = CGRect(
            origin: exitButton.frame.origin,
            size: CGSize(
                width: exitButton.frame.size.width + 30,
                height: exitButton.frame.size.height
            )
        )
    }

    private func displayShadow(at view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 25
        view.layer.shadowOpacity = 0.8
    }

    // MARK: - Displaying Images

    func display(images: [UIImage]) {
        let imageViews = images.map { image -> UIImageView in
            let view = UIImageView(image: image)
            view.contentMode = .scaleAspectFit
            return view
        }

        imagesPageControl.numberOfPages = imageViews.count
        insertIntoScrollView(imageViews: imageViews)
    }

    private func insertIntoScrollView(imageViews: [UIImageView]) {
        imageViews.forEach(paggingScrollView.addSubview)
        layoutImagesScrollViewSize()
    }

    private func layoutImagesScrollViewSize() {
        let subviews = paggingScrollView.subviews

        paggingScrollView.contentSize = subviews.reduce(CGSize.zero) { contentSize, subview in
            subview.frame = CGRect(
                origin: CGPoint(x: contentSize.width, y: 0),
                size: frame.size
            )

            return CGSize(
                width: contentSize.width + frame.width,
                height: frame.height
            )
        }

        paggingScrollView.contentOffset.x = frame.width * CGFloat(previousPage)
    }

    // MARK: - Rotating

    func rotateToPortrait() {
        layoutImagesScrollViewSize()
    }

    func rotateToLandscape() {
        layoutImagesScrollViewSize()
    }
}

// MARK: - UIScrollViewDelegate -

extension GalleryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        previousPage = imagesPageControl.currentPage
        imagesPageControl.currentPage = calculateCurrentPage(
            contentOffsetX: scrollView.contentOffset.x
        )
    }

    private func calculateCurrentPage(contentOffsetX: CGFloat) -> Int {
        let frameHalfWidth = frame.width / 2
        let floatingCurrentPage = (contentOffsetX + frameHalfWidth) / frame.width
        return Int(floatingCurrentPage)
    }
}
