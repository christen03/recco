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

class EditableTableViewController: UITableViewController, UITextViewDelegate, KeyboardAccessoryViewDelegate, EditableSectionHeaderDelegate,  ElegantEmojiPickerDelegate {
    
    
    let listViewModel: ListViewModel
    private let observerId = UUID()
    private var isUpdating = false
    private var pendingEmojiSectionIndex: Int?
    
    
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
    let placeholderDesc = ""
    var sections: [Section] {
        return listViewModel.list.sections
    }
    
    var unsectionedItems: [Item]{
        return listViewModel.list.unsectionedItems
    }
    
    private var isDeletingItem = false
    weak var dataDelegate: EditableTableViewControllerDelegate?
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
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
        NotificationCenter.default.removeObserver(self)
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
        
        let item: Item
        
        let hasUnsectioned = !(listViewModel.list.unsectionedItems.isEmpty)
        
        if hasUnsectioned && indexPath.section == 0 {
            // Item is in unsectioned items
            item = listViewModel.list.unsectionedItems[indexPath.row]
        } else {
            let sectionIndex = hasUnsectioned ? indexPath.section - 1 : indexPath.section
            item = listViewModel.list.sections[sectionIndex].items[indexPath.row]
        }
        
        cell.descriptionTextView.isHidden = false
        
        // Name field
        if item.name.isEmpty && !cell.itemNameTextField.isFirstResponder {
            cell.itemNameTextField.text = self.placeholderItem
        } else {
            cell.itemNameTextField.text = item.name
        }
        
        // Description field
        if let description = item.description, !description.isEmpty {
            cell.descriptionTextView.text = description
            cell.descriptionTextView.isHidden = false
            cell.descriptionTextView.setNeedsLayout()
            cell.descriptionTextView.layoutIfNeeded()
            DispatchQueue.main.async {
                UIView.performWithoutAnimation{
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        } else {
            cell.descriptionTextView.isHidden = true
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
    
    func sectionHeaderDidRequestEmojiPicker(_ header: SectionHeaderView, forSectionAt index: Int) {
        self.pendingEmojiSectionIndex = index
        let picker = ElegantEmojiPicker(delegate: self)
        present(picker, animated: true)
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
            if text == "\n" {
                // TODO: Is this needed? 
                var needsLayoutUpdate = false
                if cell.descriptionTextView.isHidden {
                    cell.descriptionTextView.isHidden = false
                    needsLayoutUpdate = true
                }
                if needsLayoutUpdate {
                    UIView.performWithoutAnimation {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                    DispatchQueue.main.async{
                        cell.descriptionTextView.becomeFirstResponder()
                    }
                } else {
                    cell.descriptionTextView.becomeFirstResponder()
                }
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
                } else {
                    // Move to the next existing item
                    let nextIndexPath = IndexPath(row: nextRow, section: section)
                    
                    // Scroll to make sure it's visible
                    
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
        textView.isHidden=false
//        DispatchQueue.main.async{
//            guard textView.isFirstResponder else { return }
//            if let cell = self.getActiveCell(), let indexPath = self.tableView.indexPath(for: cell) {
//                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//            }
//        }
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
        
        if let currentItem = getItemAt(indexPath){
            var updatedItem = currentItem
            if textView == cell.itemNameTextField {
                updatedItem.name = textView.text
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    textView.text = placeholderItem
                    textView.textColor = UIColor(Colors.ListItemGray)
                }
            } else {
                updatedItem.description = textView.text
                if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    textView.isHidden=true
                    UIView.performWithoutAnimation {
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
            updateItem(updatedItem, at: indexPath)
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
        UIView.performWithoutAnimation {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

        DispatchQueue.main.async {
            guard textView.isFirstResponder,
                  let activeCell = self.getActiveCell(),
                  let indexPath = self.tableView.indexPath(for: activeCell),
                  (activeCell.itemNameTextField === textView || activeCell.descriptionTextView === textView) else {
                return
            }

            if let currentItem = self.getItemAt(indexPath) {
                var updatedItem = currentItem
                if textView === activeCell.itemNameTextField {
                    updatedItem.name = textView.text
                } else if textView === activeCell.descriptionTextView {
                    updatedItem.description = textView.text
                }
                if textView.text != self.placeholderItem && textView.text != self.placeholderDesc {
                    self.updateItem(updatedItem, at: indexPath)
                }
            }

            // shoutout gemini for this lololololol but leaving comments so i can come back and learn from this/make edits
            if let selectedRange = textView.selectedTextRange {
                // Get the caret (cursor) rectangle within the textView.
                let cursorRectInTextView = textView.caretRect(for: selectedRange.start)

                // Convert the cursor rectangle to the tableView's coordinate system.
                guard let window = textView.window else { return }
                let cursorRectInWindow = textView.convert(cursorRectInTextView, to: window)
                let cursorRectInTableView = self.tableView.convert(cursorRectInWindow, from: window)

                // Determine the actual visible area of the tableView, accounting for content insets (like the keyboard).
                let tableViewVisibleBounds = self.tableView.bounds
                let tableViewVisibleContentRect = CGRect(
                    x: tableViewVisibleBounds.origin.x + self.tableView.adjustedContentInset.left,
                    y: tableViewVisibleBounds.origin.y + self.tableView.adjustedContentInset.top,
                    width: tableViewVisibleBounds.width - self.tableView.adjustedContentInset.left - self.tableView.adjustedContentInset.right,
                    height: tableViewVisibleBounds.height - self.tableView.adjustedContentInset.top - self.tableView.adjustedContentInset.bottom
                )

                // Define a "comfortable viewing zone" within the visible content rect.
                // The cursor should ideally stay within this zone.
                // Example: Inset by 20% from the top and 30% from the bottom (giving more space near keyboard).
                // These values are crucial and should be tuned for the best feel.
                let comfortableZoneTopPadding: CGFloat = tableViewVisibleContentRect.height * 0.20
                let comfortableZoneBottomPadding: CGFloat = tableViewVisibleContentRect.height * 0.30

                let comfortableViewingZone = tableViewVisibleContentRect.inset(
                    by: UIEdgeInsets(top: comfortableZoneTopPadding, left: 0, bottom: comfortableZoneBottomPadding, right: 0)
                )

                // Check if the cursor's Y position is already within the comfortable zone.
                // We primarily care about the vertical position.
                let isCursorComfortablyVisible = cursorRectInTableView.minY >= comfortableViewingZone.minY &&
                                                 cursorRectInTableView.maxY <= comfortableViewingZone.maxY &&
                                                 tableViewVisibleContentRect.intersects(cursorRectInTableView) // Ensure it's generally visible

                if !isCursorComfortablyVisible {
                    // The cursor is outside the comfortable zone or not fully visible.
                    // We'll use scrollRectToVisible to bring it into view.
                    // Add some padding to the cursor rect so it's not right at the edge after scrolling.
                    let scrollPadding: CGFloat = 20.0 // Add 20 points of space above/below the cursor when scrolling.
                    let targetRectForCursor = cursorRectInTableView.insetBy(dx: 0, dy: -scrollPadding)

                    // Only scroll if no other scroll animation is believed to be in progress.
                    // This check helps prevent fighting between scroll commands.
                    if self.tableView.layer.animation(forKey: "bounds.origin") == nil {
                        self.tableView.scrollRectToVisible(targetRectForCursor, animated: true)
                    }
                }
            }
        }
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
    
    func textContentDidChange(in cell: EditableTableViewCell, textView: UITextView) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if let indexPath = tableView.indexPath(for: cell) {
            if let currentItem = getItemAt(indexPath) {
                var updatedItem = currentItem
                if textView == cell.itemNameTextField {
                    updatedItem.name = textView.text
                } else {
                    updatedItem.description = textView.text
                }
                
                if textView.text != placeholderItem && textView.text != placeholderDesc {
                    updateItem(updatedItem, at: indexPath)
                }
            }
        }
        let range = NSRange(location: textView.text.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
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
    
    // MARK: - ElegantEmojiPickerDelegate
    
    func emojiPicker(_ picker: ElegantEmojiPicker, didSelectEmoji emoji: Emoji?){
        picker.dismiss(animated: true)
        guard let picked = emoji?.emoji, let sectionIndex = pendingEmojiSectionIndex else { return }
        
        var newSection = listViewModel.list.sections[sectionIndex]
        newSection.emoji = picked
        listViewModel.updateSection(at: sectionIndex, with: newSection)
        let tableSection = listViewModel.hasUnsectioned ? sectionIndex + 1 : sectionIndex
        tableView.reloadSections(IndexSet(integer: tableSection), with: .automatic)
        pendingEmojiSectionIndex = nil
    }
    
    // MARK: - Helper functions
    private func createTemporaryTextViewForKeyboardFocus() -> UITextField{
        let tempTextField = UITextField(frame: CGRect.zero)
        tempTextField.autocorrectionType = .no
        view.addSubview(tempTextField)
        tempTextField.becomeFirstResponder()
        return tempTextField
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        guard let activeCell = getActiveCell() else {return}
                let activeTextView = activeCell.itemNameTextField.isFirstResponder ? activeCell.itemNameTextField : activeCell.descriptionTextView
        guard activeTextView.isFirstResponder, // Ensure we have an active text view
              let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        // The system has already adjusted contentInset by now.
        // We want to ensure the cursor in activeTextView is well-positioned.

        let cursorRectInTextView = activeTextView.caretRect(for: activeTextView.selectedTextRange?.start ?? activeTextView.endOfDocument)
        guard !cursorRectInTextView.isNull, !cursorRectInTextView.isInfinite else { return }
        
        // Convert cursor rect to table view coordinates
        let cursorRectInTableView = activeTextView.convert(cursorRectInTextView, to: self.tableView)

        // Define the target rect with padding
        let targetCursorRectWithPadding = cursorRectInTableView.insetBy(dx: 0, dy: -20) // 20pt padding

        // The truly visible frame for content, after keyboard insets are applied.
        // UITableView updates its adjustedContentInset when keyboard appears.
        let visibleRect = self.tableView.bounds.inset(by: self.tableView.adjustedContentInset)

        if !visibleRect.contains(targetCursorRectWithPadding) {
            self.tableView.scrollRectToVisible(targetCursorRectWithPadding, animated: true)
        } else {
            // Even if visible, maybe it's too close to the keyboard.
            // Check if the bottom of the padded cursor rect is close to the bottom of the visible rect.
            // (The bottom of visibleRect is effectively the top of the keyboard).
            let keyboardThreshold: CGFloat = 30 // How close to keyboard before we nudge it up
            if targetCursorRectWithPadding.maxY > visibleRect.maxY - keyboardThreshold {
                self.tableView.scrollRectToVisible(targetCursorRectWithPadding, animated: true)
            }
        }
    }
}
