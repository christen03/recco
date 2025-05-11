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
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, EditableSectionHeaderDelegate {
        func sectionHeaderDidRequestEmojiPicker(_ header: SectionHeaderView, forSectionAt index: Int) {}
        
        func sectionHeader(_ header: SectionHeaderView, didChangeTitleTo title: String, forSectionAt index: Int) {}
        
        func sectionHeaderWillRemoveSection(_ header: SectionHeaderView, atIndex index: Int) {}
        
        var parent: EditableTableViewControllerRepresentable
        weak var tableViewController: EditableTableViewController?
        
        init(_ parent: EditableTableViewControllerRepresentable) {
            self.parent = parent
        }
        
        func sectionHeaderDidChangeSize(_ header: SectionHeaderView) {
            tableViewController?.sectionHeaderDidChangeSize(header)
        }
    }
}

struct ListEditView: View {
    
    @StateObject var listViewModel: ListViewModel
    @EnvironmentObject var homeNavigation: HomeNavigation
    @State private var isKeyboardVisible = false
    @State var toast: Toast? = nil
    @State var isShowingEmojiPicker: Bool = false
    @State var isShowingVisibilitySheet = false
    @State var isShowingDeleteAlert: Bool = false
    
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
        
        .alert(isPresented: $isShowingDeleteAlert) {
                   Alert(
                       title: Text("Delete List"),
                       message: Text("Are you sure you want to delete '\(listViewModel.list.name)'? This action cannot be undone."),
                       primaryButton: .destructive(Text("Delete")) {
                           Task {
                               await listViewModel.deleteList()
                           }
                           homeNavigation.back()
                       },
                       secondaryButton: .cancel()
                   )
               }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                  isKeyboardVisible = true
              }
              .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                  isKeyboardVisible = false
              }
              .onDisappear {
                  listViewModel.saveNow()
              }
    }
    
    private var keyboardDoneButton: some View {
        Group {
            if isKeyboardVisible {
                Button("Done"){
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        listViewModel.saveNow()
                }
                .foregroundColor(.blue)
            } else {
                menuButton
            }
        }
    }
    
    private var menuButton: some View {
            Menu {
                Button {
                    self.isShowingVisibilitySheet.toggle()
                } label:{
                    HStack {
                        FontedText("Show Visibility")
                        Image(systemName: "lock")
                    }
                }
                
                Button {
                   print("Coming soon")
                } label : {
                    HStack {
                        FontedText("Ask for recs")
                        Image(systemName: "list.clipboard.fill")
                    }
                }
                
                Button {
                    print("Coming soon")
                } label: {
                    HStack {
                        FontedText("Share link")
                        Image(systemName: "link")
                    }
                }
                
                Button {
                    self.isShowingDeleteAlert = true
                } label : {
                    HStack {
                      FontedText("Delete")
                        Image(systemName: "trash")
                    }
                }
                
            } label: {
                Image(systemName: "ellipsis")
            }
    }
    
    
    private func formatDate(_ date: Date) -> String {
          let formatter = DateFormatter()
          formatter.timeStyle = .short
          return formatter.string(from: date)
      }
    
}


#Preview {
    //    ListEditView()
}
