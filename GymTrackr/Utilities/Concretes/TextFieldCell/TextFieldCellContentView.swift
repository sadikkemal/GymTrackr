//
//  TextFieldCellContentView.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - TextFieldCellContentView
final class TextFieldCellContentView: UIView, UIContentView {

    // MARK: Types
    typealias Configuration = TextFieldCellContentConfiguration

    // MARK: Internal
    var configuration: UIContentConfiguration {
        didSet { update(for: configuration) }
    }

    var didChangeTextPublisher: PassthroughSubject<String, Never> {
        generateDidChangeTextPublisher()
    }

    var didBeginEditingTextPublisher: PassthroughSubject<String, Never> {
        generateDidBeginEditingTextPublisher()
    }

    var didEndEditingTextPublisher: PassthroughSubject<String, Never> {
        generateDidEndEditingTextPublisher()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }

    // MARK: Private
    private var didChangeTextPublisherCancellable: AnyCancellable?
    private var didBeginEditingTextPublisherCancellable: AnyCancellable?
    private var didEndEditingTextPublisherCancellable: AnyCancellable?

    private weak var textField: UITextField!

    // MARK: Lifecycle
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        loadTextField()
        loadConstraints()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views
private extension TextFieldCellContentView {

    func loadTextField() {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.font = .preferredFont(forTextStyle: .body)
        addSubview(textField)
        self.textField = textField
    }
}

// MARK: - Constraints
private extension TextFieldCellContentView {

    func loadConstraints() {
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Helpers
private extension TextFieldCellContentView {

    func update(for configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }

        textField.placeholder = configuration.placeholderText
        textField.text = configuration.text
        textField.keyboardType = configuration.keyboardType
    }

    func generateDidChangeTextPublisher() -> PassthroughSubject<String, Never> {
        didChangeTextPublisherCancellable?.cancel()
        let publisher = PassthroughSubject<String, Never>()
        didChangeTextPublisherCancellable = textField.didChangeTextPublisher
            .sink { text in
                publisher.send(text)
            }
        return publisher
    }

    func generateDidBeginEditingTextPublisher() -> PassthroughSubject<String, Never> {
        didBeginEditingTextPublisherCancellable?.cancel()
        let publisher = PassthroughSubject<String, Never>()
        didBeginEditingTextPublisherCancellable = textField.didBeginEditingTextPublisher
            .sink { text in
                publisher.send(text)
            }
        return publisher
    }

    func generateDidEndEditingTextPublisher() -> PassthroughSubject<String, Never> {
        didEndEditingTextPublisherCancellable?.cancel()
        let publisher = PassthroughSubject<String, Never>()
        didEndEditingTextPublisherCancellable = textField.didEndEditingTextPublisher
            .sink { text in
                publisher.send(text)
            }
        return publisher
    }
}

// MARK: - API
extension TextFieldCellContentView {

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        if super.becomeFirstResponder() {
            return true
        } else {
            textField.becomeFirstResponder()
            return false
        }
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        if super.resignFirstResponder() {
            return true
        } else {
            textField.resignFirstResponder()
            return false
        }
    }
}
