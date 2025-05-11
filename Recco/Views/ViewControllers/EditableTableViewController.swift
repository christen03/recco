//
//  EditableTableViewController.swift
//  Recco
//
//  Created by Christen Xie on 2/5/25.
//

import UIKit
import ElegantEmojiPicker


struct Recommendation {
    var name: String
    var description: String
}

class EditableTableViewController: UITableViewController, UITextViewDelegate, KeyboardAccessoryViewDelegate, EditableSectionHeaderDelegate, EditableTableViewCellDelegate {
    
    let listViewModel: ListViewModel
    private let observerId = UUID()
    private var isUpdating = false

    init(viewModel: ListViewModel){
        self.listViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        listViewModel.addObserver(id: observerId) { [weak self] newList in
            guard let self = self, !self.isUpdating else { return }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let placeholderItem = "Add a recommendation"
    let placeholderDesc = "Add a description"
    var sections: [Section] {
        return listViewModel.list.sections
    }
    
    var unsectionedItems: [Item]{
        return listViewModel.list.unsectionedItems
    }
    
    private var isDeletingItem = false
    weak var dataDelegate: EditableTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listViewModel.addObserver(id: observerId) { [weak self] newList in
            guard let self = self, !self.isUpdating else { return }
        }
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
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
    
    deinit {
        listViewModel.removeObserver(id: observerId)
    }
    
    private func notifyDataChanged() {
        dataDelegate?.tableViewControllerDidUpdateData(self, sections: sections, unsectionedItems: unsectionedItems)
    }
    
    // MARK: - TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         let hasUnsectioned = !(listViewModel.list.unsectionedItems.isEmpty)
         let sectionCount = listViewModel.list.sections.count
         return sectionCount + (hasUnsectioned ? 1 : 0)
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         let hasUnsectioned = !(listViewModel.list.unsectionedItems.isEmpty)
         
         if hasUnsectioned && section == 0 {
             return listViewModel.list.unsectionedItems.count
         } else {
             let sectionIndex = hasUnsectioned ? section - 1 : section
             return listViewModel.list.sections[sectionIndex].items.count
         }
     }
    
    func updateSectionTitle(_ title: String, forSectionAt index: Int) {
          isUpdating = true
          
          var section = sections[index]
          section.name = title
          listViewModel.updateSection(at: index, with: section)
          
          isUpdating = false
      }
      
      func updateItem(_ item: Item, at indexPath: IndexPath) {
         
          isUpdating = true
          
          let hasUnsectioned = !unsectionedItems.isEmpty
          
          if hasUnsectioned && indexPath.section == 0 {
              listViewModel.updateUnsectionedItem(at: indexPath.row, with: item)
          } else {
              let sectionIndex = hasUnsectioned ? indexPath.section - 1 : indexPath.section
              var section = listViewModel.list.sections[sectionIndex]
              section.items[indexPath.row] = item
              listViewModel.updateSection(at: sectionIndex, with: section)
          }
          
          isUpdating = false
      }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if listViewModel.hasUnsectioned && section == 0 {
            return nil
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! SectionHeaderView
        headerView.delegate = self
        let title: String
        let emoji: String?
        
        let sectionIndex = listViewModel.hasUnsectioned ? section - 1 : section
        title = sections[sectionIndex].name
        emoji = sections[sectionIndex].emoji
        
    headerView.configure(title: title, emoji: emoji, sectionIndex: sectionIndex)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return listViewModel.hasUnsectioned && section == 0 ? 0 : 44
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? { return nil }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return 0 }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditableTableViewCell
        cell.separatorInset = .zero

        // Get the item from the view model based on indexPath
        let item: Item
        
        let hasUnsectioned = !(listViewModel.list.unsectionedItems.isEmpty)
        
        if hasUnsectioned && indexPath.section == 0 {
            // Item is in unsectioned items
            item = unsectionedItems[indexPath.row]
        } else {
            // Item is in a section
            let sectionIndex = hasUnsectioned ? indexPath.section - 1 : indexPath.section
            item = sections[sectionIndex].items[indexPath.row]
        }

        // Configure the cell with the item
        cell.item = item
        
        // Set up delegates
        cell.itemNameTextField.delegate = self
        cell.descriptionTextView.delegate = self
        cell.delegate = self

        // Set up keyboard accessory views
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

        // Get the item from the view model
        let item: Item
        
        let hasUnsectioned = !(listViewModel.list.unsectionedItems.isEmpty)
        
        if hasUnsectioned && indexPath.section == 0 {
            // Item is in unsectioned items
            item = listViewModel.list.unsectionedItems[indexPath.row]
        } else {
            // Item is in a section
            let sectionIndex = hasUnsectioned ? indexPath.section - 1 : indexPath.section
            item = listViewModel.list.sections[sectionIndex].items[indexPath.row]
        }

        // Name field
        if item.name.isEmpty && !cell.itemNameTextField.isFirstResponder {
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
        if listViewModel.list.unsectionedItems.isEmpty {
            update(&listViewModel.list.sections[indexPath.section].items[indexPath.row])
        } else {
            if indexPath.section == 0 {
                update(&listViewModel.list.unsectionedItems[indexPath.row])
            } else {
                update(&listViewModel.list.sections[indexPath.section - 1].items[indexPath.row])
            }
        }
    }
    
    // MARK: EditableSectionHeaderDelegate
    
    
    func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int) {
        guard !title.isEmpty && title != "Section Title" else { return }
        
        // Update the section title in your data model
        if index >= 0 && index < listViewModel.list.sections.count {
            listViewModel.list.sections[index].name = title
        }
    }
    
    func sectionHeader(_ header: SectionHeaderView, didSelectEmoji emoji: String, forSectionAt index: Int){
        var section = listViewModel.list.sections[index]
        section.emoji = emoji
        listViewModel.updateSection(at: index, with: section)
        let tableSection = listViewModel.hasUnsectioned ? index+1 : index
        tableView.reloadSections([tableSection], with: .automatic)
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
                if (listViewModel.list.unsectionedItems.count == 1 && listViewModel.list.sections.isEmpty) { return false }
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
                    
                if !unsectionedItems.isEmpty && indexPath.section == 0 {
                    // Remove from unsectioned items
                    listViewModel.list.unsectionedItems.remove(at: indexPath.row)
                    let wasLastUnsectionedItem = listViewModel.list.unsectionedItems.isEmpty
                    
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        if wasLastUnsectionedItem {
                            tableView.deleteSections(IndexSet(integer: 0), with: .automatic)
                        }
                    }, completion: { _ in
                        self.isDeletingItem = false
                    })
                } else {
                    // Remove from a section
                    let sectionIndex = unsectionedItems.isEmpty ? indexPath.section : indexPath.section - 1
                    listViewModel.list.sections[sectionIndex].items.remove(at: indexPath.row)
                    
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }, completion: { _ in
                        self.isDeletingItem = false
                    })
                }
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
                        listViewModel.list.unsectionedItems.append(newItem)
                    } else {
                        let sectionIndex = unsectionedItems.isEmpty ? section : section - 1
                        listViewModel.list.sections[sectionIndex].items.append(newItem)
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
        guard !isDeletingItem else { return }
        
        var cell: EditableTableViewCell?
        var indexPath: IndexPath?
        
        for visibleCell in tableView.visibleCells {
            if let editableCell = visibleCell as? EditableTableViewCell,
               (editableCell.itemNameTextField == textView || editableCell.descriptionTextView == textView) {
                cell = editableCell
                indexPath = tableView.indexPath(for: visibleCell)
                break
            }
        }
        
        guard let cell = cell, let indexPath = indexPath else { return }
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if textView == cell.itemNameTextField {
                textView.text = placeholderItem
                textView.textColor = UIColor(Colors.ListItemGray)
            } else {
                textView.text = placeholderDesc
                textView.textColor = UIColor(Colors.MediumGray)
            }
        } else {
            // Get the current item and update it
            if let currentItem = getItemAt(indexPath) {
                var updatedItem = currentItem
                
                if textView == cell.itemNameTextField {
                    updatedItem.name = textView.text
                } else {
                    updatedItem.description = textView.text
                }
                
                // Update the item in the view model
                updateItem(updatedItem, at: indexPath)
            }
        }
    }

    // Helper to get an item at a specific index path
    func getItemAt(_ indexPath: IndexPath) -> Item? {
        
        let hasUnsectioned = !unsectionedItems.isEmpty
        
        if hasUnsectioned && indexPath.section == 0 {
            return unsectionedItems[indexPath.row]
        } else {
            let sectionIndex = hasUnsectioned ? indexPath.section - 1 : indexPath.section
            return sections[sectionIndex].items[indexPath.row]
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
                let textViewRect = textView.convert(textView.bounds, to: tableView)
                           let isTextViewVisible = tableView.bounds.contains(textViewRect)
                           
                if !isTextViewVisible {
                    tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                }
                
                if let currentItem = getItemAt(indexPath){
                    var updatedItem = currentItem
                    if textView == editableCell.itemNameTextField {
                        updatedItem.name = textView.text
                    } else {
                        updatedItem.description = textView.text
                    }
                    
                    
                    if textView.text != placeholderItem && textView.text != placeholderDesc {
                        updateItem(updatedItem, at: indexPath)
                    }
                }
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
        
        var newSection = Section(name: "", emoji: nil, items: [])
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
                listViewModel.list.unsectionedItems.removeSubrange(currentItemIndex+1..<unsectionedItems.count)
            }
            listViewModel.list.sections.insert(newSection, at: 0)
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
                listViewModel.list.sections[currentSectionIndex].items.removeSubrange((currentItemIndex+1)..<sections[currentSectionIndex].items.count)
            }
            listViewModel.list.sections.insert(newSection, at: currentSectionIndex+1)
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
            listViewModel.list.unsectionedItems.append(contentsOf: deletedSectionItems)
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
            listViewModel.list.sections[previousSectionIndex].items.append(contentsOf: deletedSectionItems)
            lastItemIndex = sections[previousSectionIndex].items.count - deletedSectionItems.count - 1
        }
        
        // Remove the section from data model
        let lastIndexPath = IndexPath(row: lastItemIndex, section: focusSectionIndex)
            if let cell = self.tableView.cellForRow(at: lastIndexPath) as? EditableTableViewCell {
                cell.descriptionTextView.becomeFirstResponder()
        }

        listViewModel.list.sections.remove(at: index)

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
