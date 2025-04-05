//
//  EditableTableViewController.swift
//  Recco
//
//  Created by Christen Xie on 2/5/25.
//

import UIKit


struct Recommendation {
    var name: String
    var description: String
}

class EditableTableViewController: UITableViewController, UITextViewDelegate, KeyboardAccessoryViewDelegate, EditableSectionHeaderDelegate, EditableTableViewCellDelegate {
    
    var listViewModel: ListViewModel?
    
    let placeholderItem = "Add a recommendation"
    let placeholderDesc = "Add a description"
    
    struct TableSection {
        var title: String
        var emoji: String?
        var items: [Item]
    }
    
    var sections: [TableSection] = []
    
    var unsectionedItems: [Item] = []
    
    
    private var isDeletingItem = false
    weak var dataDelegate: EditableTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Editable Table"
        tableView.register(EditableTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        tableView.keyboardDismissMode = .none
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 36
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = 0
        tableView.sectionHeaderTopPadding = 0
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0
    }
    
    private func notifyDataChanged() {
        dataDelegate?.tableViewControllerDidUpdateData(self, sections: sections, unsectionedItems: unsectionedItems)
    }
    
    // MARK: - TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count + (unsectionedItems.isEmpty ? 0 : 1)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if unsectionedItems.isEmpty {
            return sections[section].items.count
        } else {
            if section == 0 {
                return unsectionedItems.count
            } else {
                return sections[section - 1].items.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! SectionHeaderView
        headerView.delegate = self
        let sectionIndex: Int
        let title: String
        let emoji: String?
        
        
        sectionIndex = section-1
        title = sections[sectionIndex].title
        emoji = sections[sectionIndex].emoji
        
        headerView.configure(title: title, emoji: emoji, sectionIndex: sectionIndex)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{ return section == 0 ? 0 : 44 }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditableTableViewCell
        cell.separatorInset = .zero

        let item: Item
        if unsectionedItems.isEmpty {
            item = sections[indexPath.section].items[indexPath.row]
        } else {
            if indexPath.section == 0 {
                item = unsectionedItems[indexPath.row]
            } else {
                item = sections[indexPath.section - 1].items[indexPath.row]
            }
        }

        cell.item = item
        
        cell.itemNameTextField.delegate = self
        cell.descriptionTextView.delegate = self
        cell.delegate=self

        if let accessoryView = cell.itemNameTextField.inputAccessoryView as? KeyboardAccessoryView {
            accessoryView.delegate = self
        }
        
        if let accessoryView = cell.descriptionTextView.inputAccessoryView as? KeyboardAccessoryView {
            accessoryView.delegate = self
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? EditableTableViewCell else { return }

        let item: Item
        if unsectionedItems.isEmpty {
            item = sections[indexPath.section].items[indexPath.row]
        } else {
            item = (indexPath.section == 0) ? unsectionedItems[indexPath.row] : sections[indexPath.section - 1].items[indexPath.row]
        }

        // Name field
        if item.name.isEmpty  && !cell.itemNameTextField.isFirstResponder {
            cell.itemNameTextField.text = self.placeholderItem
        } else {
            cell.itemNameTextField.text = item.name
        }

        // Description field
        if let description = item.description, !description.isEmpty {
            cell.descriptionTextView.text = description
        } else {
                cell.descriptionTextView.text = placeholderDesc
            }
    }

    
    func getAndUpdateItem(at indexPath: IndexPath, update: (inout Item) -> Void) {
        if unsectionedItems.isEmpty {
            update(&sections[indexPath.section].items[indexPath.row])
        } else {
            if indexPath.section == 0 {
                update(&unsectionedItems[indexPath.row])
            } else {
                update(&sections[indexPath.section - 1].items[indexPath.row])
            }
        }
    }
    
    // MARK: EditableSectionHeaderDelegate
    
    func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int) {
        guard !title.isEmpty && title != "Section Title" else { return }
        
        // Update the section title in your data model
        if index >= 0 && index < sections.count {
            sections[index].title = title
        }
    }
    
    func sectionHeaderDidChangeSize(_ header: SectionHeaderView) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        // Find the current cell and index path
        var currentCell: EditableTableViewCell?
        var currentIndexPath: IndexPath?
        
        for cell in tableView.visibleCells {
            if let editableCell = cell as? EditableTableViewCell,
               (editableCell.itemNameTextField == textView || editableCell.descriptionTextView == textView) {
                currentCell = editableCell
                currentIndexPath = tableView.indexPath(for: cell)
                break
            }
        }
        
        guard let cell = currentCell, let indexPath = currentIndexPath else {
            return true
        }
        
        // Handle different textViews and key presses
        if textView == cell.itemNameTextField {
            // Handle Return key in itemNameTextField
            if text == "\n" {
                // Move to the description field
                cell.descriptionTextView.becomeFirstResponder()
                return false
            }
            
            // Handle Backspace key in empty itemNameTextField
            if text.isEmpty && textView.text.isEmpty {
                isDeletingItem = true
                if indexPath.row == 0 {
                    if let headerView = tableView.headerView(forSection: indexPath.section) as? SectionHeaderView? {
                        headerView?.titleTextView.becomeFirstResponder()
                    }
                }
                
                // Get previous cell
                    let prevRow = indexPath.row - 1
                    let prevIndexPath = IndexPath(row: prevRow, section: indexPath.section)
                    
                    if let prevCell = self.tableView.cellForRow(at: prevIndexPath) as? EditableTableViewCell { prevCell.descriptionTextView.becomeFirstResponder() }
                    
                    // Focus on previous cell's description field
                    
                    // Remove the current item
                        if !unsectionedItems.isEmpty && indexPath.section == 0 {
                            // Remove from unsectioned items
                            unsectionedItems.remove(at: indexPath.row)
                        } else {
                            // Remove from a section
                            let sectionIndex = unsectionedItems.isEmpty ? indexPath.section : indexPath.section - 1
                            sections[sectionIndex].items.remove(at: indexPath.row)
                        }
                    
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: {
                        _ in self.isDeletingItem = false
                    })
                    return false
                }
            
        } else if textView == cell.descriptionTextView {
            // Handle Return key in descriptionTextView
            if text == "\n" {
                // Calculate the next row
                let nextRow = indexPath.row + 1
                let section = indexPath.section
                
                // Check if we're at the end of the section
                let rowsInSection = tableView.numberOfRows(inSection: section)
                
                if nextRow >= rowsInSection {
                    // This is the last item in the section, add a new one
                    let newItem = Item(name: "", description: "")
                    
                    // Add the item to the appropriate collection
                    if !unsectionedItems.isEmpty && section == 0 {
                        unsectionedItems.append(newItem)
                    } else {
                        let sectionIndex = unsectionedItems.isEmpty ? section : section - 1
                        sections[sectionIndex].items.append(newItem)
                    }
                    
                    // Create new index path and insert the row
                    let newIndexPath = IndexPath(row: nextRow, section: section)
                    tableView.beginUpdates()
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                    DispatchQueue.main.async{
                        if let newCell = self.tableView.cellForRow(at: newIndexPath) as? EditableTableViewCell {
                            newCell.itemNameTextField.becomeFirstResponder()
                        }
                }
                    tableView.endUpdates()
                    tableView.scrollToRow(at: newIndexPath, at: .middle, animated: true)
                } else {
                    // Move to the next existing item
                    let nextIndexPath = IndexPath(row: nextRow, section: section)
                    
                    // Scroll to make sure it's visible
                    tableView.scrollToRow(at: nextIndexPath, at: .middle, animated: true)
                    
                    // Focus on the next cell's name field after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let nextCell = self.tableView.cellForRow(at: nextIndexPath) as? EditableTableViewCell {
                            nextCell.itemNameTextField.becomeFirstResponder()
                        }
                    }
                }
                
                return false
            }
            
            // Handle Backspace key in empty descriptionTextView
            if text.isEmpty && textView.text.isEmpty {
                cell.itemNameTextField.becomeFirstResponder()
                return false
            }
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderItem || textView.text == placeholderDesc {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard !isDeletingItem else {return}
        var cell: EditableTableViewCell?
        var indexPath: IndexPath?
        
        for visibleCell in tableView.visibleCells {
            if let editableCell = visibleCell as? EditableTableViewCell,
               (editableCell.itemNameTextField == textView || editableCell.descriptionTextView == textView){
                cell = editableCell
                indexPath = tableView.indexPath(for: visibleCell)
                break
            }
        }
        
        guard let cell = cell, let indexPath = indexPath else {return}
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if textView == cell.itemNameTextField {
                textView.text = placeholderItem
                textView.textColor = .lightGray
            } else {
                textView.text = placeholderDesc
                textView.textColor = .lightGray
            }
        } else {
            // Update the data
            getAndUpdateItem(at: indexPath) { item in
                if textView == cell.itemNameTextField {
                    item.name = textView.text
                } else {
                    item.description = textView.text
                }
            }
        }
    }
    
    // In EditableTableViewController.swift
    func textViewDidChange(_ textView: UITextView) {
        // Update table view layout
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        for cell in tableView.visibleCells {
            if let editableCell = cell as? EditableTableViewCell,
               (editableCell.itemNameTextField == textView || editableCell.descriptionTextView == textView),
               let indexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                break
            }
        }
        
        let range = NSRange(location: textView.text.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
    }
    
    // MARK: - KeyboardAccessoryViewDelegate
    
    func getActiveCell() -> EditableTableViewCell? {
        for cell in tableView.visibleCells {
            if let editableCell = cell as? EditableTableViewCell {
                if editableCell.itemNameTextField.isFirstResponder || editableCell.descriptionTextView.isFirstResponder {
                    return editableCell
                }
            }
        }
        return nil
    }
    
    func getCopyOfItem(at indexPath: IndexPath) -> Item? {
        if unsectionedItems.isEmpty {
            return sections[indexPath.section].items[indexPath.row]
        } else {
            if indexPath.section == 0 {
                return unsectionedItems[indexPath.row]
            } else {
                return sections[indexPath.section - 1].items[indexPath.row]
            }
        }
    }
    
    private func togglePrice(to price: PriceRange){
        guard let activeCell = getActiveCell() else { return }
        guard let indexPath = tableView.indexPath(for: activeCell) else { return }
        
        let isNameFocused = activeCell.itemNameTextField.isFirstResponder
        
        if var copyItem = getCopyOfItem(at: indexPath){
            copyItem.price = copyItem.price == price ? nil : price
            
            getAndUpdateItem(at: indexPath) {$0 = copyItem}
            activeCell.item = copyItem
            if isNameFocused {
                activeCell.itemNameTextField.becomeFirstResponder()
            } else {
                activeCell.descriptionTextView.becomeFirstResponder()
            }
        }
    }
    
    
    
    func keyboardAccessoryViewDidTapSection(_ accessoryView: KeyboardAccessoryView) {
        guard let activeCell = getActiveCell() else { return }
        guard let indexPath = tableView.indexPath(for: activeCell) else { return }
        
        let isNameFieldActive = activeCell.itemNameTextField.isFirstResponder
        
        let tempTextField = UITextField(frame: CGRect.zero)
        tempTextField.autocorrectionType = .no
        view.addSubview(tempTextField)
        tempTextField.becomeFirstResponder()
        
        let currentSectionIndex: Int
        let currentItemIndex = indexPath.row
        
        if unsectionedItems.isEmpty {
            currentSectionIndex = indexPath.section
        } else {
            if indexPath.section == 0 {
                currentSectionIndex = -1
            } else {
                currentSectionIndex = indexPath.section - 1
            }
        }
        
        var newSection = TableSection(title: "", emoji: nil, items: [])
        var rowsToDelete = [IndexPath]()
        var rowsToInsert = [IndexPath]()
        
        // Calculate the new section's table view index
        let newSectionTableViewIndex: Int
        if unsectionedItems.isEmpty {
            newSectionTableViewIndex = currentSectionIndex == -1 ? 0 : currentSectionIndex + 1
        } else {
            newSectionTableViewIndex = currentSectionIndex == -1 ? 1 : currentSectionIndex + 2
        }
        
        // Handle moving items
        if currentSectionIndex == -1 {
            // From unsectioned items
            if currentItemIndex < unsectionedItems.count - 1 {
                let itemsToMove = Array(unsectionedItems[(currentItemIndex+1)...])
                newSection.items = itemsToMove
                
                // Track rows to delete from current section
                for i in (currentItemIndex+1)..<unsectionedItems.count {
                    rowsToDelete.append(IndexPath(row: i, section: 0))
                }
                
                // Track rows to insert in new section
                for i in 0..<itemsToMove.count {
                    rowsToInsert.append(IndexPath(row: i, section: newSectionTableViewIndex))
                }
                
                // Update data model
                unsectionedItems.removeSubrange(currentItemIndex+1..<unsectionedItems.count)
            }
            sections.insert(newSection, at: 0)
        } else {
            if currentItemIndex < sections[currentSectionIndex].items.count - 1 {
                let itemsToMove = Array(sections[currentSectionIndex].items[(currentItemIndex+1)...])
                newSection.items = itemsToMove
                
                // Convert to table section index
                let tableSectionIndex = unsectionedItems.isEmpty ? currentSectionIndex : currentSectionIndex + 1
                
                // Track rows to delete from current section
                for i in (currentItemIndex+1)..<sections[currentSectionIndex].items.count {
                    rowsToDelete.append(IndexPath(row: i, section: tableSectionIndex))
                }
                
                // Track rows to insert in new section
                for i in 0..<itemsToMove.count {
                    rowsToInsert.append(IndexPath(row: i, section: newSectionTableViewIndex))
                }
                
                // Update data model
                sections[currentSectionIndex].items.removeSubrange((currentItemIndex+1)..<sections[currentSectionIndex].items.count)
            }
            sections.insert(newSection, at: currentSectionIndex+1)
        }
        
        tableView.performBatchUpdates({
            if !rowsToDelete.isEmpty {
                tableView.deleteRows(at: rowsToDelete, with: .automatic)
            }
            tableView.insertSections(IndexSet(integer: newSectionTableViewIndex), with: .automatic)
            DispatchQueue.main.async {
                if let headerView = self.tableView.headerView(forSection: newSectionTableViewIndex) as? SectionHeaderView {
                    headerView.titleTextView.becomeFirstResponder()
                    tempTextField.removeFromSuperview()
                }
            }
            if !rowsToInsert.isEmpty {
                tableView.insertRows(at: rowsToInsert, with: .automatic)
            }
        }, completion: { finished in
            if finished {
                let sectionHeaderRect = self.tableView.rect(forSection: newSectionTableViewIndex)
                self.tableView.scrollRectToVisible(sectionHeaderRect, animated: true)
            }
        })
    }
    
    
    func keyboardAccessoryViewDidTapStar(_ accessoryView: KeyboardAccessoryView){
        guard let activeCell = getActiveCell(),
              let indexPath = tableView.indexPath(for: activeCell) else { return }
        
        let isNameFocused = activeCell.itemNameTextField.isFirstResponder
        
        if var copyItem = getCopyOfItem(at: indexPath){
            copyItem.isStarred.toggle()
            getAndUpdateItem(at: indexPath) {$0=copyItem}
            activeCell.item=copyItem
            if isNameFocused {
                activeCell.itemNameTextField.becomeFirstResponder()
            } else {
                activeCell.descriptionTextView.becomeFirstResponder()
            }
        }
    }
    
    func keyboardAccessoryViewDidTapFree(_ accessoryView: KeyboardAccessoryView){
        togglePrice(to: .free)
    }
    
    func keyboardAccessoryViewDidTapSingleDollar(_ accessoryView: KeyboardAccessoryView){
        togglePrice(to: .one)
    }
    
    func keyboardAccessoryViewDidTapDoubleDollar(_ accessoryView: KeyboardAccessoryView) {
        togglePrice(to: .two)
    }
    
    func keyboardAccessoryViewDidTapTripleDollar(_ accessoryView: KeyboardAccessoryView) {
        togglePrice(to: .three)
    }
    
    
    // MARK: - EditableTableViewCellDelegate
    func textViewDidChangeSize(in cell: EditableTableViewCell) {
        // Update the cell height
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        if let indexPath = tableView.indexPath(for: cell){
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
    func sectionHeaderWillRemoveSection(_ header: SectionHeaderView, atIndex index: Int) {
        guard index >= 0 && index < sections.count else { return }
        
        // Track this section as being modified
        let sectionBeingDeleted = unsectionedItems.isEmpty ? index : index + 1
        
        let deletedSectionItems = sections[index].items
        var rowsToInsert = [IndexPath]()
        let focusSectionIndex: Int
        let lastItemIndex: Int
        
        // Determine where items will go and update data model
        if index == 0 {
            // Items go to unsectioned
            focusSectionIndex = 0
            let startIndex = unsectionedItems.count
            
            // Track rows to insert
            for i in 0..<deletedSectionItems.count {
                rowsToInsert.append(IndexPath(row: startIndex + i, section: focusSectionIndex))
            }
            
            // Update data model
            unsectionedItems.append(contentsOf: deletedSectionItems)
            lastItemIndex = unsectionedItems.count - deletedSectionItems.count - 1
        } else {
            // Items go to previous section
            let previousSectionIndex = index - 1
            focusSectionIndex = unsectionedItems.isEmpty ? previousSectionIndex : previousSectionIndex + 1
            let startIndex = sections[previousSectionIndex].items.count
            
            // Track rows to insert
            for i in 0..<deletedSectionItems.count {
                rowsToInsert.append(IndexPath(row: startIndex + i, section: focusSectionIndex))
            }
            
            // Update data model
            sections[previousSectionIndex].items.append(contentsOf: deletedSectionItems)
            lastItemIndex = sections[previousSectionIndex].items.count - deletedSectionItems.count - 1
        }
        
        // Remove the section from data model
        let lastIndexPath = IndexPath(row: lastItemIndex, section: focusSectionIndex)
            if let cell = self.tableView.cellForRow(at: lastIndexPath) as? EditableTableViewCell {
                cell.descriptionTextView.becomeFirstResponder()
        }

        sections.remove(at: index)

        // Perform batch updates
        tableView.performBatchUpdates({
            tableView.deleteSections(IndexSet(integer: sectionBeingDeleted), with: .automatic)
            
            if !rowsToInsert.isEmpty {
                tableView.insertRows(at: rowsToInsert, with: .automatic)
            }
        }, completion: { finished in
            if finished && lastItemIndex >= 0 {
                let indexPath = IndexPath(row: lastItemIndex, section: focusSectionIndex)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                
            }
        })
    }
    
    // MARK: - Helper functions
    private func createTemporaryTextViewForKeyboardFocus() -> UITextField{
        let tempTextField = UITextField(frame: CGRect.zero)
        tempTextField.autocorrectionType = .no
        view.addSubview(tempTextField)
        tempTextField.becomeFirstResponder()
        return tempTextField
    }
}
