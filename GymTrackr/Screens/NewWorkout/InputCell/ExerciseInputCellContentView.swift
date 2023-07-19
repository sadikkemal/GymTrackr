//
//  ExerciseInputCellContentView.swift
//  GymTrackr
//
//  Created by Sadık Kemal Sarı on 19.07.2023.
//

import Combine
import UIKit

// MARK: - ExerciseInputCellContentView
final class ExerciseInputCellContentView: UIView, UIContentView {

    // MARK: Types
    typealias Configuration = ExerciseInputCellContentConfiguration

    // MARK: Internal
    var configuration: UIContentConfiguration {
        didSet { update(for: configuration) }
    }

    var didChangeTextPublisher: PassthroughSubject<String, Never> = PassthroughSubject()
    var didBeginEditingTextPublisher: PassthroughSubject<String, Never> = PassthroughSubject()
    var didEndEditingTextPublisher: PassthroughSubject<String, Never> = PassthroughSubject()
    var didSelectOptionPublisher: PassthroughSubject<Int, Never> = PassthroughSubject()

    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }

    // MARK: Private
    private weak var textField: UITextField!
    private weak var button: UIButton!

    private var cancellables: Set<AnyCancellable> = Set()
    private let options = Array(1 ..< 7)

    // MARK: Lifecycle
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        loadTextField()
        loadButton()
        loadConstraints()
        loadBindings()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Views
private extension ExerciseInputCellContentView {

    func loadTextField() {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        textField.font = .preferredFont(forTextStyle: .body)
        addSubview(textField)
        self.textField = textField
    }

    func loadButton() {
        var buttonConfiguration = UIButton.Configuration.filled()
        buttonConfiguration.buttonSize = .mini
        if #available(iOS 16.0, *) {
            buttonConfiguration.indicator = .popup
        }
        buttonConfiguration.title = "Set Count"
        let button = UIButton()
        button.configuration = buttonConfiguration
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        addSubview(button)
        self.button = button
    }
}

// MARK: - Constraints
private extension ExerciseInputCellContentView {

    func loadConstraints() {
        let constraints = [
            textField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            textField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

            button.widthAnchor.constraint(equalToConstant: 100),
            button.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Bindings
private extension ExerciseInputCellContentView {

    func loadBindings() {
        textField.didChangeTextPublisher
            .sink { [unowned self] text in
                didChangeTextPublisher.send(text)
            }
            .store(in: &cancellables)

        textField.didBeginEditingTextPublisher
            .sink { [unowned self] text in
                didBeginEditingTextPublisher.send(text)
            }
            .store(in: &cancellables)

        textField.didEndEditingTextPublisher
            .sink { [unowned self] text in
                didEndEditingTextPublisher.send(text)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Helpers
private extension ExerciseInputCellContentView {

    func update(for configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.placeholder = "Exercise Name"
        textField.text = configuration.text

        let children = options.map { option in
            action(for: option)
        }
        let moreItemMenu = UIMenu(title: "Set Count", options: .singleSelection, children: children)
        button.menu = moreItemMenu

        let selectedAction = children.first { action in
            action.title == String(configuration.selectedOption)
        }
        if let selectedAction {
            selectedAction.state = .on
            button.configuration?.title = title(for: configuration.selectedOption)
        } else {
            button.configuration?.title = "Set Count"
        }
    }

    func title(for option: Int) -> String {
        var text = String(option) + " Set"
        if option > 1 {
            text += "s"
        }
        return text
    }

    func action(for option: Int) -> UIAction {
        let action = UIAction(title: String(option)) { [unowned self] _ in
            let title = title(for: option)
            button.configuration?.title = title
            didSelectOptionPublisher.send(option)
        }
        return action
    }
}

// MARK: - API
extension ExerciseInputCellContentView {

    func clearPublishers() {
        cancellables.removeAll()
        didChangeTextPublisher = PassthroughSubject<String, Never>()
        didBeginEditingTextPublisher = PassthroughSubject<String, Never>()
        didEndEditingTextPublisher = PassthroughSubject<String, Never>()
        didSelectOptionPublisher = PassthroughSubject<Int, Never>()
        loadBindings()
    }

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
