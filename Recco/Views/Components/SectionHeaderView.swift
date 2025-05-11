//
//  SectionHeaderView.swift
//  Recco
//
//  Created by Christen Xie on 3/11/25.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView, UITextViewDelegate {
    public let titleTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont(name: Fonts.sfProDisplaySemibold, size: 20)
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.setContentOffset(.zero, animated: false)
        return textView
    }()
    
    private let emojiButton: UIButton = {
          let button = UIButton(type: .system)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.setTitle("", for: .normal)
          button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
          button.setTitleColor(.label, for: .normal)
          button.layer.cornerRadius = 15
          button.layer.borderColor = UIColor.systemGray4.cgColor
          button.backgroundColor = UIColor.systemBackground
          return button
      }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let placeholderText = "Section Title"
    private var isCreatingOrDeleting = false
    
    weak var delegate: EditableSectionHeaderDelegate?
    var sectionIndex: Int = 0
    
    private func setupViews() {
        let stackView = UIStackView(arrangedSubviews: [emojiButton, titleTextView])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            emojiButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 30),
            emojiButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.systemBackground
        self.backgroundView = backgroundView
        
        titleTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        contentView.addGestureRecognizer(tapGesture)
        
        emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
    }
    
    @objc private func headerTapped() {
        titleTextView.becomeFirstResponder()
    }
    
    @objc private func emojiButtonTapped(){
//        delegate?.sectionHeaderDidRequestEmojiPicker(self, forSectionAt: sectionIndex)
    }
    
    func configure(title: String, emoji: String?, sectionIndex: Int) {
        self.sectionIndex=sectionIndex
        if(sectionIndex == -1)  {return}
        
        if title.isEmpty && !titleTextView.isFirstResponder {
            titleTextView.text = placeholderText
            titleTextView.textColor = .lightGray
        } else {
            titleTextView.text = title
            titleTextView.textColor = .darkGray
        }
        
        if let emoji = emoji, !emoji.isEmpty {
                   emojiButton.setTitle(emoji, for: .normal)
               } else {
                   emojiButton.setTitle("➕", for: .normal)
        }
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = UIColor(Colors.ListItemGray)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isCreatingOrDeleting {
            textView.text = placeholderText
        } else {
            delegate?.sectionHeader(self, didChangeTitleTo: textView.text, forSectionAt: sectionIndex)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            focusOnFirstItemInSection()
            return false
        }
        
        if text.isEmpty && textView.text.isEmpty {
            isCreatingOrDeleting = true
            delegate?.sectionHeaderWillRemoveSection(self, atIndex: sectionIndex)
            isCreatingOrDeleting = false
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        invalidateIntrinsicContentSize()
        delegate?.sectionHeaderDidChangeSize(self)
    }
    
    private func getUITableView() -> UITableView?{
        var view: UIView? = self
        var tableView: UITableView?
        while view != nil {
            if let foundTableView = view as? UITableView {
                tableView = foundTableView
                break
            }
            view = view?.superview
        }
        return tableView
    }
    
    private func focusOnFirstItemInSection(){
        if sectionIndex < 0 { return }
        guard let tableView = getUITableView() else { return }
        guard let tableViewController = tableView.delegate as? EditableTableViewController else { return }
        
        
        let sectionHasItems = !tableViewController.sections[sectionIndex].items.isEmpty
        if sectionHasItems {
            let indexPath = IndexPath(row: 0, section: sectionIndex+1)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if let cell = tableView.cellForRow(at: indexPath) as? EditableTableViewCell {
                    cell.itemNameTextField.becomeFirstResponder()
                }
            }
        } else {
            tableViewController.listViewModel.createNewItemInSection(at: sectionIndex)
            let indexPath = IndexPath(row: 0, section: sectionIndex+1)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .top)
            DispatchQueue.main.async{
                if let cell = tableView.cellForRow(at: indexPath) as? EditableTableViewCell {
                    cell.itemNameTextField.becomeFirstResponder()
                }
            }
            tableView.endUpdates()
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

protocol EditableSectionHeaderDelegate: AnyObject {
    func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int)
//    func sectionHeader(_ header: SectionHeaderView, didSelectEmoji emoji: String, forSectionAt index: Int)
    func sectionHeaderDidChangeSize(_ header: SectionHeaderView)
    func sectionHeaderWillRemoveSection(_ header: SectionHeaderView, atIndex index: Int)
//    func sectionHeaderDidRequestEmojiPicker(_ header: SectionHeaderView, forSectionAt index: Int)
    
}
