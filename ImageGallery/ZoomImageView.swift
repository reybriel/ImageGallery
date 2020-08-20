import UIKit

final class ZoomImageView: UIImageView {
    override var isUserInteractionEnabled: Bool {
        get { true }
        set { super.isUserInteractionEnabled = newValue }
    }

    private let referenceCenter: CGPoint

    // MARK: - Initializing

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(image: UIImage, referenceCenter: CGPoint) {
        self.referenceCenter = referenceCenter
        super.init(image: image)
        addPinchRecognizer()
        addPanRecognizer()
    }

    // MARK: - Recognizing gestures

    private func addPinchRecognizer() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(updateScaling(_:)))
        pinchRecognizer.delegate = self
        addGestureRecognizer(pinchRecognizer)
    }

    private func addPanRecognizer() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(updatePosition(_:)))
        panRecognizer.delegate = self
        addGestureRecognizer(panRecognizer)
    }

    // MARK: - Zooming

    @objc
    private func updateScaling(_ pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .began, .changed:
            applyZoomIfNeeded(scale: pinchRecognizer.scale)
        default:
            restoreOriginalScale()
        }
    }

    private func applyZoomIfNeeded(scale: CGFloat) {
        if scale >= 1 {
            let zoomScale = 1.0 + scale / 2
            transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        }
    }

    private func restoreOriginalScale() {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
            self.transform = .identity
        }
        .startAnimation()
    }

    // MARK: - Sliding

    @objc
    private func updatePosition(_ panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .began, .changed:
            applyTranslation(panRecognizer)
        default:
            restoreOriginalCenter(panRecognizer)
        }
    }

    private func applyTranslation(_ panRecognizer: UIPanGestureRecognizer) {
        let translation = panRecognizer.translation(in: self)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        panRecognizer.setTranslation(.zero, in: self)
    }

    private func restoreOriginalCenter(_ panRecognizer: UIPanGestureRecognizer) {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) { [referenceCenter] in
            self.center = referenceCenter
            panRecognizer.setTranslation(.zero, in: self)
        }
        .startAnimation()
    }
}

// MARK: - UIGestureRecognizerDelegate -

extension ZoomImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }
}
