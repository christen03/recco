//
//  ListEditView.swift
//  Recco
//
//  Created by Christen Xie on 11/7/24.
//

import SwiftUI
import UIKit

protocol EditableTableViewControllerDelegate: AnyObject {
    func tableViewControllerDidUpdateData(_ controller: EditableTableViewController,
                                         sections: [EditableTableViewController.TableSection],
                                         unsectionedItems: [Item])
}

struct EditableTableViewControllerRepresentable: UIViewControllerRepresentable {
    
    @ObservedObject var listViewModel: ListViewModel
    func makeUIViewController(context: Context) -> EditableTableViewController {
        let controller = EditableTableViewController()
        controller.dataDelegate=context.coordinator
        controller.listViewModel = listViewModel
        context.coordinator.tableViewController = controller
        populateController(controller)
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EditableTableViewController, context: Context) {
            populateController(uiViewController)
    }
    
    private func populateController(_ controller: EditableTableViewController) {
        // Convert list sections to controller's TableSection format
        var tableSections: [EditableTableViewController.TableSection] = []
        
        // Add all sections from the list
        for section in listViewModel.list.sections {
            let tableSection = EditableTableViewController.TableSection(
                title: section.name,
                emoji: section.emoji,
                items: section.items
            )
            tableSections.append(tableSection)
        }
        
        // Set the data in the controller
        controller.sections = tableSections
        controller.unsectionedItems = listViewModel.list.unsectionedItems
        
        // Reload the table to reflect the new data
        controller.tableView.reloadData()
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, EditableSectionHeaderDelegate, EditableTableViewControllerDelegate {
        var parent: EditableTableViewControllerRepresentable
        weak var tableViewController: EditableTableViewController?
        
        init(_ parent: EditableTableViewControllerRepresentable){
            self.parent=parent
        }
        
        func tableViewControllerDidUpdateData(_ controller: EditableTableViewController, sections: [EditableTableViewController.TableSection], unsectionedItems: [Item]) {
            var updatedList = parent.listViewModel.list
            updatedList.sections = sections.map { section in
                Section(name: section.title, emoji: section.emoji, items: section.items)
            }
            
            updatedList.unsectionedItems = unsectionedItems
            DispatchQueue.main.async{
                self.parent.listViewModel.list = updatedList
            }
        }
        
        func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int) {
            tableViewController?.sectionHeader(header, didChangeTitleTo: title, forSectionAt: index)
            
            guard index >= 0, index < parent.listViewModel.list.sections.count else { return }
            
            var updatedSections = parent.listViewModel.list.sections
            updatedSections[index].name = title
            
            var updatedList = parent.listViewModel.list
            updatedList.sections = updatedSections
            
            parent.listViewModel.list = updatedList
        }
        
        func sectionHeaderDidChangeSize(_ header: SectionHeaderView) {
            tableViewController?.sectionHeaderDidChangeSize(header)
        }
        
        func sectionHeaderWillRemoveSection(_ header: SectionHeaderView, atIndex index: Int) {
              tableViewController?.sectionHeaderWillRemoveSection(header, atIndex: index)
              
              guard index >= 0, index < parent.listViewModel.list.sections.count else { return }
              
              let itemsToMove = parent.listViewModel.list.sections[index].items
              
              var updatedList = parent.listViewModel.list
              var updatedSections = updatedList.sections
              
              if index == 0 {
                  var updatedUnsectionedItems = updatedList.unsectionedItems
                  updatedUnsectionedItems.append(contentsOf: itemsToMove)
                  updatedList.unsectionedItems = updatedUnsectionedItems
              } else {
                  updatedSections[index - 1].items.append(contentsOf: itemsToMove)
              }
              
              updatedSections.remove(at: index)
              updatedList.sections = updatedSections
              parent.listViewModel.list = updatedList
          }
        
    }
}

struct ListEditView: View {
    
    @StateObject var listViewModel: ListViewModel
    @State private var isKeyboardVisible = false
    @State var toast: Toast? = nil
    @State var isShowingEmojiPicker: Bool = false
    @State var isShowingVisibilitySheet = false
    
    init(list: List){
        _listViewModel = StateObject(wrappedValue: ListViewModel(list: list))
    }
    
    var body: some View {
        VStack{
            Text(listViewModel.list.emoji ?? "")
                .font(.system(size: 50))
                .onTapGesture {
                    self.isShowingEmojiPicker = true
                }
            
            TitleText(listViewModel.list.name)
                .foregroundColor(Colors.DarkGray)
                .padding(.bottom, 2)
            
            // Visibilty button
            HStack {
                FontedText(listViewModel.list.visibility.emoji, size: 13)
                FontedText(listViewModel.list.visibility.rawValue, size: 13)
                    .foregroundColor(Colors.MediumGray)
            }
            .fontWeight(.light)
            .onTapGesture {
//                listViewModel.toggleVisibilitySheet()
                self.isShowingVisibilitySheet = true
            }
            
            EditableTableViewControllerRepresentable(listViewModel: listViewModel)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $isShowingVisibilitySheet) {
            VisibilitySelectView(listViewModel: listViewModel, isShowingVisibiltySheet: $isShowingVisibilitySheet)
        }
       
        .sheet(isPresented: $isShowingEmojiPicker) {
            ElegantEmojiPickerView(selectedEmoji: $listViewModel.list.emoji)
        }
        .navigationBarItems(trailing: keyboardDoneButton)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                  isKeyboardVisible = true
              }
              .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                  isKeyboardVisible = false
              }
        
              .onChange(of: listViewModel.uiState.isShowingVisibilitySheet) { newValue in
                  print("Sheet visibilty changed to \(newValue)")
                  print("Current list has \(listViewModel.list.sections.count) sections and \(listViewModel.list.unsectionedItems[0].name)")
              }
    }
    
    private var keyboardDoneButton: some View {
        Group {
            if isKeyboardVisible {
                Button("Done"){
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .foregroundColor(.blue)
            }
        }
    }
    
}


#Preview {
    //    ListEditView()
}
