//
//  EditableTableViewCell.swift
//  Recco
//
//  Created by Christen Xie on 2/5/25.
//

import UIKit


class AutoGrowingTextView: UITextView {
    override var text: String! {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let textWidth = frame.width - textContainerInset.left - textContainerInset.right
        let newSize = sizeThatFits(CGSize(width: textWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: frame.width, height: newSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
}

class EditableTableViewCell: UITableViewCell {
    
    var item: Item? {
        didSet {
            rerender()
        }
    }
    
    let itemNameTextField: UITextView = {
        let title = UITextView()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: Fonts.sfProDisplayMedium, size: 16 )
        title.isScrollEnabled = false
        title.textColor = UIColor(Colors.ListItemGray)
        title.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        return title
    }()
    
    let descriptionTextView: AutoGrowingTextView = {
        let desc = AutoGrowingTextView()
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.font = UIFont(name: Fonts.sfProDisplayLight, size: 14)
        desc.isScrollEnabled = false
        desc.textColor = UIColor(Colors.MediumGray)
        desc.textContainerInset = .zero
        return desc
    }()
    
    let starContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.ListItemGray.cgColor
        view.alpha=0
        view.isUserInteractionEnabled = false
        return view
    }()
    
    let priceContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 0.5
        view.layer.borderColor = Colors.ListItemGray.cgColor
        view.alpha=0
        view.isUserInteractionEnabled = false
        return view
    }()

    let starLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "⭐️"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.alpha=0
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.alpha=0
        label.isUserInteractionEnabled = false
        label.font = UIFont(name: Fonts.sfProDisplayBold, size: 16)
        label.textColor = UIColor(Colors.ListItemGray)
        return label
    }()

    private let keyboardAccessoryView = KeyboardAccessoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = UIEdgeInsets.zero
        self.contentView.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
        self.preservesSuperviewLayoutMargins = false
        self.contentView.preservesSuperviewLayoutMargins = false
        // Configure container views first
        starContainerView.addSubview(starLabel)
        priceContainerView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            starLabel.topAnchor.constraint(equalTo: starContainerView.topAnchor, constant: 2),
            starLabel.bottomAnchor.constraint(equalTo: starContainerView.bottomAnchor, constant: -2),
            starLabel.leadingAnchor.constraint(equalTo: starContainerView.leadingAnchor, constant: 4),
            starLabel.trailingAnchor.constraint(equalTo: starContainerView.trailingAnchor, constant: -4),
            
            priceLabel.topAnchor.constraint(equalTo: priceContainerView.topAnchor, constant: 2),
            priceLabel.bottomAnchor.constraint(equalTo: priceContainerView.bottomAnchor, constant: -2),
            priceLabel.leadingAnchor.constraint(equalTo: priceContainerView.leadingAnchor, constant: 4),
            priceLabel.trailingAnchor.constraint(equalTo: priceContainerView.trailingAnchor, constant: -4),
        ])
        
        
        priceContainerView.setContentHuggingPriority(.required, for: .horizontal)
        starContainerView.setContentHuggingPriority(.required, for: .horizontal)
        priceContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        starContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        itemNameTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let badgesStackView = UIStackView(arrangedSubviews: [priceContainerView, starContainerView])
           badgesStackView.translatesAutoresizingMaskIntoConstraints = false
           badgesStackView.axis = .horizontal
           badgesStackView.spacing = 8
           badgesStackView.alignment = .center
           
           // Add this offset to compensate for the text inset
           let badgesOffset: CGFloat = -5
           
           let titleStackView = UIStackView(arrangedSubviews: [itemNameTextField, badgesStackView])
           titleStackView.translatesAutoresizingMaskIntoConstraints = false
           titleStackView.axis = .horizontal
           titleStackView.spacing = 8
           titleStackView.alignment = .center
           
           // Apply transform to move the badges up
           badgesStackView.transform = CGAffineTransform(translationX: 0, y: badgesOffset)
           
           contentView.addSubview(titleStackView)
           contentView.addSubview(descriptionTextView)
           NSLayoutConstraint.activate([
               titleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
               titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
           ])

           NSLayoutConstraint.activate([
               descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
               descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
               descriptionTextView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: -6),
               descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
               titleStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15)
           ])
           
        setupKeyboardButtons()
        self.selectionStyle = .none
    }

    
    func rerender() {
            guard let item = item else { return }
            
            if item.isStarred {
                starContainerView.alpha=1
                starLabel.alpha=1
            } else {
                starContainerView.alpha=0
                starLabel.alpha=0;
            }
            
            if let price = item.price {
                priceLabel.alpha=1
                priceContainerView.alpha=1
                switch price {
                case .free: priceLabel.text = "Free"
                case .one: priceLabel.text = "$"
                case .two: priceLabel.text = "$$"
                case .three: priceLabel.text = "$$$"
                }
            } else {
                priceContainerView.alpha = 0
                priceLabel.alpha = 0
            }
        
        }
    
    private func toggleItemVisibility(container: UIView, label: UILabel){
        if(container.alpha == 0){
            container.alpha = 1
            label.alpha = 1
        } else {
            container.alpha = 0
            label.alpha = 0
        }
    }
    
    private func setupKeyboardButtons() {
        itemNameTextField.inputAccessoryView = keyboardAccessoryView
        descriptionTextView.inputAccessoryView = keyboardAccessoryView
        keyboardAccessoryView.frame.size.height=44
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
