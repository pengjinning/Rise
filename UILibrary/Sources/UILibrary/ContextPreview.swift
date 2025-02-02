import UIKit.UIViewController
import Core

public final class ContextPreview: UIViewController {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let contentSize = CGSize(width: 300, height: 250)
    public override var preferredContentSize: CGSize {
        get { contentSize }
        set { log(.warning, "Attempt to change preferredContentSize!") }
    }
    
    public struct State {
        public init(image: UIImage? = nil,
                    title: String,
                    description: String
        ) {
            self.image = image
            self.title = title
            self.description = description
        }

        let image: UIImage?
        let title: String
        let description: String
    }
    private(set) var state: State?
    public func setState(_ state: State) {
        imageView.image = state.image
        titleLabel.text = state.title
        descriptionLabel.text = state.description
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)

        view.addConstraints([
            view.heightAnchor.constraint(equalToConstant: contentSize.height),
            view.widthAnchor.constraint(equalToConstant: contentSize.width),

            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16),

            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 20),

            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 20)
        ])
    }
}
