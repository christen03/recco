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
                                         sections: [Section],
                                         unsectionedItems: [Item])
}

struct EditableTableViewControllerRepresentable: UIViewControllerRepresentable {
    
    @ObservedObject var listViewModel: ListViewModel
    
    func makeUIViewController(context: Context) -> EditableTableViewController {
        // Create controller with the required view model
        let controller = EditableTableViewController(viewModel: listViewModel)
        // Set up any delegate relationships
//        controller.dataDelegate = context.coordinator
        // Store reference in coordinator if needed
        context.coordinator.tableViewController = controller
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EditableTableViewController, context: Context) {
        // Handle view model reference changes if needed
        if uiViewController.listViewModel !== listViewModel {
            // If we somehow got a different view model instance, update it
            // This should be rare since we pass it in the initializer
//            uiViewController.updateViewModel(listViewModel)
        }
        
        // No need to manually sync data since the controller accesses
        // the view model directly and observes changes
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, EditableSectionHeaderDelegate {
        func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int) {}
        
        func sectionHeaderWillRemoveSection(_ header: SectionHeaderView, atIndex index: Int) {}
        
        var parent: EditableTableViewControllerRepresentable
        weak var tableViewController: EditableTableViewController?
        
        init(_ parent: EditableTableViewControllerRepresentable) {
            self.parent = parent
        }
        
        // Most data sync methods can be removed since the controller
        // now talks directly to the view model
        
        // Keep only methods needed for delegate callbacks that aren't
        // directly related to data sync
        func sectionHeaderDidChangeSize(_ header: SectionHeaderView) {
            tableViewController?.sectionHeaderDidChangeSize(header)
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
