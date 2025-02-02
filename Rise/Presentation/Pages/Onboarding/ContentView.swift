//
//  ContentView.swift
//  Rise
//
//  Created by Vladimir Korolev on 11.09.2021.
//  Copyright © 2021 VladimirBrejcha. All rights reserved.
//

import UIKit

extension Onboarding.View {

    final class ContentView: UIView {

        struct Model {
            let title: String
            let image: String
            let animationTransform: CGAffineTransform
            let description: String
        }

        private let model: Model

        // MARK: - Subviews

        private lazy var descriptionLabel: UILabel = {
            let label = UILabel()
            label.applyStyle(.onTopOfRich)
            label.layer.applyStyle(
                .init(shadow: .onboardingShadow)
            )
            label.numberOfLines = 0
            label.attributedText = .descriptionOnTopOfRich(text: model.description)
            return label
        }()

        private lazy var title: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.applyStyle(.boldBigTitle)
            label.layer.applyStyle(
                .init(shadow: .onboardingShadow)
            )
            label.attributedText = .onTopOfRich(text: model.title)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.7
            return label
        }()

        private lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 30
            stack.alignment = .fill
            stack.distribution = .equalSpacing
            return stack
        }()

        private lazy var imageView: UIImageView = {
            let view = UIImageView(
                image: UIImage(
                    systemName: model.image
                )?.withRenderingMode(.alwaysTemplate)
            )
            view.layer.applyStyle(.gloomingIcon)
            view.contentMode = .scaleAspectFit
            view.tintColor = .white
            return view
        }()

        // MARK: - LifeCycle

        init(model: Model) {
            self.model = model
            super.init(frame: .zero)
            setupViews()
            setupLayout()
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupViews() {
            addSubviews(stackView)
            stackView.addArrangedSubviews(
                imageView,
                title,
                descriptionLabel
            )
        }

        func animate(_ animate: Bool) {
            guard animate else {
                imageView.stopAnimating()
                return
            }
            UIView.animate(withDuration: 1,
                           delay: 0,
                           options: [.autoreverse, .repeat, .curveEaseInOut]
            ) { [self] in
                imageView.transform = model.animationTransform
            }
        }

        // MARK: - Layout

        private func setupLayout() {
            stackView.activateConstraints {
                [$0.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                $0.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                $0.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32)]
            }
            imageView.activateConstraints {
                [$0.heightAnchor.constraint(equalToConstant: 70)]
            }
        }
    }
}
