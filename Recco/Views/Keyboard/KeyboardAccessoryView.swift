//
//  KeyboardAccessoryView.swift
//  Recco
//
//  Created by Christen Xie on 2/20/25.
//
import UIKit

class KeyboardAccessoryView: UIView {
    
    enum KeyboardButtonState {
        case main
        case prices
    }
    
    weak var delegate: KeyboardAccessoryViewDelegate?
    
    private var currState: KeyboardButtonState = .main {
        didSet {
            rerenderButtons()
        }
    }
    
    private lazy var mainButtons: [UIButton] = {
        let sectionButton = createButton(symbolName: "list.bullet.indent", action: #selector(sectionButtonTapped))
        let priceButton = createButton(symbolName: "dollarsign", action: #selector(mainPriceButtonTapped))
        let starButton = createButton(text: "⭐️", action: #selector(starButtonTapped))
        return [sectionButton, priceButton, starButton]
    }()
    
    private lazy var priceButtons: [UIButton] = {
        let backButton = createButton(symbolName: "xmark", action: #selector(backButtonTapped))
        let freeButton = createButton(text: "Free", action: #selector(freeButtonTapped))
        let singleDollarButton = createButton(text: "$", action: #selector(singleDollarButtonTapped))
        let doubleDollarButton = createButton(text: "$$", action: #selector(doubleDollarButtonTapped))
        let tripleDollarButton = createButton(text: "$$$", action: #selector(tripleDollarButtonTapped))
        return [backButton, freeButton, singleDollarButton, doubleDollarButton, tripleDollarButton]
    }()
 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupButtons()
    }
    
    private let buttonsStackView: UIStackView = {
           let stack = UIStackView()
        stack.alignment = .fill
           stack.alignment = .center
           stack.spacing = 15
           stack.translatesAutoresizingMaskIntoConstraints = false
           return stack
       }()

    private func setupView() {
        backgroundColor = .systemGray6
        autoresizingMask = .flexibleWidth
        
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor.systemGray4
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorder)
        
        NSLayoutConstraint.activate([
            topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorder.topAnchor.constraint(equalTo: topAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            buttonsStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    private func setupButtons() {
        rerenderButtons()
    }
    
    
    private func createButton(symbolName: String? = nil, text: String? = nil, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        if let symbolName = symbolName {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            button.setImage(UIImage(systemName: symbolName, withConfiguration: config), for: .normal)
            button.tintColor = .black
        } else if let text = text {
            button.setTitle(text, for: .normal)
            button.titleLabel?.font = UIFont(name: Fonts.sfProDisplayBold, size: 18)
            button.tintColor = .black
        }
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func rerenderButtons() {
        buttonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let visibleButtons: [UIButton]
        switch self.currState {
        case .main:
            visibleButtons = mainButtons
        case .prices:
            visibleButtons = priceButtons
        }
        
        visibleButtons.forEach { buttonsStackView.addArrangedSubview($0)}
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buttonsStackView.addArrangedSubview(spacer)
        
    }
    
    // MARK: - Button Actions
    
    @objc private func sectionButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapSection(self)
    }
    
    @objc private func mainPriceButtonTapped() {
        currState = .prices
    }
    
    @objc private func starButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapStar(self)
    }
    
    @objc private func backButtonTapped() {
        currState = .main
    }
    
    @objc private func freeButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapFree(self)
    }
    
    @objc private func singleDollarButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapSingleDollar(self)
    }
    
    @objc private func doubleDollarButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapDoubleDollar(self)
    }
    
    @objc private func tripleDollarButtonTapped() {
        delegate?.keyboardAccessoryViewDidTapTripleDollar(self)
    }
}

// MARK: - Delegate Protocol

protocol KeyboardAccessoryViewDelegate: AnyObject {
    func keyboardAccessoryViewDidTapSection(_ accessoryView: KeyboardAccessoryView)
    func keyboardAccessoryViewDidTapStar(_ accessoryView: KeyboardAccessoryView)
    func keyboardAccessoryViewDidTapFree(_ accessoryView: KeyboardAccessoryView)
    func keyboardAccessoryViewDidTapSingleDollar(_ accessoryView: KeyboardAccessoryView)
    func keyboardAccessoryViewDidTapDoubleDollar(_ accessoryView: KeyboardAccessoryView)
    func keyboardAccessoryViewDidTapTripleDollar(_ accessoryView: KeyboardAccessoryView)
}

// Optional extension with default implementations
//extension KeyboardAccessoryViewDelegate {
//    func keyboardAccessoryViewDidTapCheckedList(_ accessoryView: KeyboardAccessoryView) {}
//    func keyboardAccessoryViewDidTapBulletList(_ accessoryView: KeyboardAccessoryView) {}
//    func keyboardAccessoryViewDidTapNumberedList(_ accessoryView: KeyboardAccessoryView) {}
//    func keyboardAccessoryViewDidTapIndent(_ accessoryView: KeyboardAccessoryView) {}
//    func keyboardAccessoryViewDidTapOutdent(_ accessoryView: KeyboardAccessoryView) {}
//    func keyboardAccessoryViewDidTapFormat(_ accessoryView: KeyboardAccessoryView) {}
//}
