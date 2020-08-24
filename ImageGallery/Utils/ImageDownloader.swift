import Foundation
import class UIKit.UIImage

typealias ImageDownloadCallbackFunction = ([UIImage], Error?) -> Void
private typealias ImageDownloadFunction = () throws -> [UIImage]

protocol ImageDownloader {
    func downloadImages(fromURLs: [URL], completion: @escaping ImageDownloadCallbackFunction)
}

struct DefaultImageDownloader: ImageDownloader {
    private var downloadQueue: DispatchQueue {
        .global()
    }

    private var mainQueue: DispatchQueue {
        .main
    }

    func downloadImages(fromURLs urls: [URL], completion: @escaping ImageDownloadCallbackFunction) {
        let download = createDownloadFunction(urls: urls)

        downloadQueue.async { [download, mainQueue] in
            do {
                let images = try download()

                mainQueue.async {
                    completion(images, nil)
                }
            } catch {
                mainQueue.async {
                    completion([], error)
                }
            }
        }
    }

    private func createDownloadFunction(urls: [URL]) -> ImageDownloadFunction {
        {
            try urls.map { url in
                try Data(contentsOf: url)
            }
            .compactMap { data in
                UIImage(data: data)
            }
        }
    }
}
