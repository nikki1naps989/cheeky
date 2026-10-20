import UIKit
import PencilKit

/// The handwriting keyboard: write on the white pad, tap "Copy",
/// then long-press the text box and choose Paste.
final class KeyboardViewController: UIInputViewController {

    private let canvas = PKCanvasView()
    private let statusLabel = UILabel()
    private var inkColor: UIColor = .black
    private var inkWidth: CGFloat = 4
    private var colorButtons: [UIButton] = []

    private let inkColors: [UIColor] = [
        .black,
        UIColor(red: 0.10, green: 0.30, blue: 0.85, alpha: 1), // blue
        UIColor(red: 0.85, green: 0.15, blue: 0.20, alpha: 1), // red
        UIColor(red: 0.50, green: 0.20, blue: 0.75, alpha: 1), // purple
    ]

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        let isPad = traitCollection.userInterfaceIdiom == .pad
        let height = view.heightAnchor.constraint(equalToConstant: isPad ? 340 : 270)
        height.priority = .defaultHigh
        height.isActive = true

        setUpCanvas()
        let toolbar = makeToolbar()

        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.adjustsFontSizeToFitWidth = true

        let stack = UIStackView(arrangedSubviews: [toolbar, canvas, statusLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4),
            toolbar.heightAnchor.constraint(equalToConstant: 40),
            statusLabel.heightAnchor.constraint(equalToConstant: 18),
        ])

        selectColor(at: 0)
        showHint()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showHint()
    }

    private func setUpCanvas() {
        canvas.drawingPolicy = .anyInput          // Apple Pencil or finger
        canvas.backgroundColor = .white
        canvas.isOpaque = true
        canvas.overrideUserInterfaceStyle = .light
        canvas.layer.cornerRadius = 12
        canvas.layer.borderWidth = 1
        canvas.layer.borderColor = UIColor.systemGray4.cgColor
        canvas.clipsToBounds = true
        canvas.alwaysBounceVertical = false
        canvas.isScrollEnabled = false
        updateTool()
    }

    private func makeToolbar() -> UIStackView {
        var items: [UIView] = []

        if needsInputModeSwitchKey {
            let globe = iconButton("globe", label: "Next keyboard")
            globe.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
            items.append(globe)
        }

        for (index, color) in inkColors.enumerated() {
            let button = UIButton(type: .system)
            button.backgroundColor = color
            button.layer.cornerRadius = 14
            button.layer.borderColor = UIColor.systemOrange.cgColor
            button.accessibilityLabel = "Ink color \(index + 1)"
            button.tag = index
            button.widthAnchor.constraint(equalToConstant: 28).isActive = true
            button.heightAnchor.constraint(equalToConstant: 28).isActive = true
            button.addTarget(self, action: #selector(colorTapped(_:)), for: .touchUpInside)
            colorButtons.append(button)
            items.append(button)
        }

        let thickness = UISegmentedControl(items: ["Thin", "Thick"])
        thickness.selectedSegmentIndex = 0
        thickness.addTarget(self, action: #selector(thicknessChanged(_:)), for: .valueChanged)
        items.append(thickness)

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        items.append(spacer)

        let undo = iconButton("arrow.uturn.backward", label: "Undo")
        undo.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        items.append(undo)

        let clear = iconButton("trash", label: "Clear")
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        items.append(clear)

        let delete = iconButton("delete.left", label: "Delete")
        delete.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        items.append(delete)

        var config = UIButton.Configuration.filled()
        config.title = "Copy"
        config.image = UIImage(systemName: "doc.on.doc")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        let copy = UIButton(configuration: config)
        copy.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        items.append(copy)

        let toolbar = UIStackView(arrangedSubviews: items)
        toolbar.axis = .horizontal
        toolbar.spacing = 10
        toolbar.alignment = .center
        return toolbar
    }

    private func iconButton(_ symbol: String, label: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: symbol), for: .normal)
        button.accessibilityLabel = label
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        return button
    }

    // MARK: - Actions

    @objc private func colorTapped(_ sender: UIButton) {
        selectColor(at: sender.tag)
    }

    @objc private func thicknessChanged(_ sender: UISegmentedControl) {
        inkWidth = sender.selectedSegmentIndex == 0 ? 4 : 9
        updateTool()
    }

    @objc private func undoTapped() {
        var drawing = canvas.drawing
        guard !drawing.strokes.isEmpty else { return }
        drawing.strokes.removeLast()
        canvas.drawing = drawing
    }

    @objc private func clearTapped() {
        canvas.drawing = PKDrawing()
        showHint()
    }

    @objc private func deleteTapped() {
        textDocumentProxy.deleteBackward()
    }

    @objc private func copyTapped() {
        guard hasFullAccess else {
            statusLabel.text = "Turn on “Allow Full Access” in Settings › Keyboards › Handwriting"
            statusLabel.textColor = .systemRed
            return
        }
        if HandwritingExporter.copyToClipboard(canvas.drawing) {
            canvas.drawing = PKDrawing()
            statusLabel.text = "Copied! Long-press the message box › Paste"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Write something first ✍️"
            statusLabel.textColor = .secondaryLabel
        }
    }

    // MARK: - Helpers

    private func selectColor(at index: Int) {
        inkColor = inkColors[index]
        for button in colorButtons {
            button.layer.borderWidth = button.tag == index ? 3 : 0
        }
        updateTool()
    }

    private func updateTool() {
        canvas.tool = PKInkingTool(.pen, color: inkColor, width: inkWidth)
    }

    private func showHint() {
        statusLabel.text = "Write above, then tap Copy and paste it"
        statusLabel.textColor = .secondaryLabel
    }
}
