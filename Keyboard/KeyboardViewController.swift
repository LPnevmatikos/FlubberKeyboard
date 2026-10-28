import UIKit

final class KeyboardViewController: UIInputViewController {
    private var deck = WordDeck()
    private var wordButtons: [KeyboardButton] = []
    private var wordRows: [UIStackView] = []
    private var heightConstraint: NSLayoutConstraint?
    private var utilityButtons: [KeyboardButton] = []
    private let root = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        (view as? UIInputView)?.allowsSelfSizing = true
        root.axis = .vertical
        root.spacing = 6
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            root.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -6),
            root.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            root.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6)
        ])

        for rowIndex in 0..<3 {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.distribution = .fillEqually
            for column in 0..<3 {
                let index = rowIndex * 3 + column
                let button = KeyboardButton(accented: index == 2)
                button.tag = index
                button.accessibilityIdentifier = "word-\(index)"
                button.addTarget(self, action: #selector(insertWord(_:)), for: .touchUpInside)
                row.addArrangedSubview(button)
                wordButtons.append(button)
            }
            root.addArrangedSubview(row)
            wordRows.append(row)
        }
        wordRows[1].heightAnchor.constraint(equalTo: wordRows[0].heightAnchor).isActive = true
        // Hide the last row in compact layouts without a required height conflict.
        let lastRowHeight = wordRows[2].heightAnchor.constraint(equalTo: wordRows[0].heightAnchor)
        lastRowHeight.priority = .defaultHigh
        lastRowHeight.isActive = true

        let utilityRow = UIStackView()
        utilityRow.axis = .horizontal
        utilityRow.spacing = 6
        let globe = KeyboardButton()
        globe.setImage(UIImage(systemName: "globe"), for: .normal)
        globe.accessibilityLabel = "Next keyboard"
        globe.accessibilityHint = "Touch and hold to show the keyboard picker."
        globe.accessibilityIdentifier = "next-keyboard"
        globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        globe.onAccessibilityActivate = { [weak self] in self?.advanceToNextInputMode() }

        let space = KeyboardButton()
        space.setTitle("Space", for: .normal)
        space.accessibilityLabel = "Space"
        space.addTarget(self, action: #selector(insertSpace), for: .touchUpInside)

        let delete = KeyboardButton()
        delete.setImage(UIImage(systemName: "delete.left"), for: .normal)
        delete.accessibilityLabel = "Delete"
        delete.addTarget(self, action: #selector(deleteOnce), for: .touchUpInside)
        utilityButtons = [globe, space, delete]
        utilityButtons.forEach { utilityRow.addArrangedSubview($0) }
        root.addArrangedSubview(utilityRow)
        NSLayoutConstraint.activate([
            utilityRow.heightAnchor.constraint(equalToConstant: 44),
            globe.widthAnchor.constraint(equalToConstant: 54),
            delete.widthAnchor.constraint(equalToConstant: 60),
            space.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        let height = view.heightAnchor.constraint(equalToConstant: 230)
        height.priority = UILayoutPriority(999)
        height.isActive = true
        heightConstraint = height
        refreshAllLabels()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deck = WordDeck()
        refreshAllLabels()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adaptLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        adaptLayout()
    }

    private func adaptLayout() {
        guard !wordRows.isEmpty else { return }
        let compact = traitCollection.verticalSizeClass == .compact || view.bounds.width > 500
        let accessible = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        wordRows[2].isHidden = compact
        let panelHeight: CGFloat = compact ? (accessible ? 210 : 180) : (accessible ? 278 : 230)
        let height = panelHeight + view.safeAreaInsets.top + view.safeAreaInsets.bottom
        if heightConstraint?.constant != height { heightConstraint?.constant = height }
        let fontSize = min(20, UIFontMetrics.default.scaledValue(for: 16))
        (wordButtons + utilityButtons).forEach {
            $0.titleLabel?.font = .systemFont(ofSize: fontSize)
        }
    }

    @objc private func insertWord(_ sender: UIButton) {
        guard let text = deck.tap(at: sender.tag) else { return }
        textDocumentProxy.insertText(text)
        updateLabel(at: sender.tag)
    }

    @objc private func insertSpace() { textDocumentProxy.insertText(" ") }
    @objc private func deleteOnce() { textDocumentProxy.deleteBackward() }

    private func refreshAllLabels() {
        for index in wordButtons.indices { updateLabel(at: index) }
    }

    private func updateLabel(at index: Int) {
        let word = deck.visibleWords[index]
        wordButtons[index].setTitle(word, for: .normal)
        wordButtons[index].accessibilityLabel = "Insert \(word)"
    }
}

/// No animations or repeat timers: every touch-up is handled immediately.
private final class KeyboardButton: UIButton {
    private let accented: Bool
    var onAccessibilityActivate: (() -> Void)?
    private static let accent = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.29, blue: 0.45, alpha: 1)
            : UIColor(red: 0.86, green: 0.82, blue: 0.92, alpha: 1)
    }

    init(accented: Bool = false) {
        self.accented = accented
        super.init(frame: .zero)
        layer.cornerRadius = 9
        tintColor = .label
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byCharWrapping
        // Character wrapping keeps long words readable in two lines at 320pt width.
        contentEdgeInsets = UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3)
        // A hidden landscape row must be allowed to collapse to zero.
        // Visible rows are sized above 44pt by the panel constraints.
        let minimumHeight = heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        minimumHeight.priority = .defaultHigh
        minimumHeight.isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        updateBackground()
    }

    required init?(coder: NSCoder) { fatalError("Use init(accented:)") }

    override var isHighlighted: Bool {
        didSet { updateBackground() }
    }

    override func accessibilityActivate() -> Bool {
        if let onAccessibilityActivate {
            onAccessibilityActivate()
            return true
        }
        return super.accessibilityActivate()
    }

    private func updateBackground() {
        backgroundColor = isHighlighted ? .tertiarySystemFill : (accented ? Self.accent : .secondarySystemGroupedBackground)
    }
}
