//
//  EditListView.swift
//  Recco
//
//  Created by Christen Xie on 8/26/24.
//

import SwiftUI


typealias ListFocusIndex = (section: Int?, index: Int, isDescription: Bool)?


struct EditListView: View {
    enum FocusField: Hashable, Equatable{
        case name(section: Int?, index: Int)
        case description(section: Int?, index: Int)
        case section(section: Int)
    }
    
    @EnvironmentObject var listViewModel: ListViewModel
    @EnvironmentObject var homeNavigation: HomeNavigation
    
    @State private var currentIndex: ListFocusIndex = nil
    @State private var editingEmojiSectionID: UUID?
    
    var selectedEmojiBinding: Binding<String?> {
        guard let id = self.editingEmojiSectionID else {
            return Binding(
                get: { self.listViewModel.list.emoji ?? "" },
                set: { self.listViewModel.list.emoji = $0 }
            )
        }
        return Binding(
            get: { self.listViewModel.list.sections.first(where: { $0.id == id })?.emoji ?? "" },
            set: { newValue in
                if let index = self.listViewModel.list.sections.firstIndex(where: { $0.id == id }) {
                    self.listViewModel.list.sections[index].emoji = newValue
                }
            }
        )
    }
    
    @FocusState var focusedField: FocusField?
    //    {
    //        willSet {
    //            print("Setting focus field \(newValue)")
    //            switch newValue {
    //            case .name(let sectionIndex, let index):
    //                print("setting focusedField to name with section \(String(describing: sectionIndex)) and index \(index)")
    //                self.currentIndex = (section: sectionIndex, index: index) // section can be nil
    //            case .description(let sectionIndex, let index):
    //                print("setting focusedField to description with section \(String(describing: sectionIndex)) and index \(index)")
    //                self.currentIndex = (section: sectionIndex, index: index) // section can be nil
    //            case .section(let sectionIndex):
    //                print("setting focusedField to section \(sectionIndex)")
    //                self.currentIndex=nil // Set index to nil
    //            default:
    //                print("defaulting")
    //                self.currentIndex = nil
    //                break
    //            }
    //        }
    //    }
    
    var body: some View{
        SwiftUI.List {
            SwiftUI.Section {
                VStack {
                    Text("Current index: \(String(describing: currentIndex))")
                    Text(listViewModel.list.emoji!)
                        .font(.system(size: 50))
                        .onTapGesture {
                            self.editingEmojiSectionID = nil
                            listViewModel.isShowingEmojiPicker = true
                            print("Emoji Picker button pressed")
                        }
                    TitleText(listViewModel.list.name)
                        .foregroundColor(Colors.DarkGray)
                        .padding(.bottom, 2)
                    HStack{
                        FontedText(listViewModel.list.visibility.emoji, size: 13)
                        FontedText(listViewModel.list.visibility.rawValue, size: 13)
                            .foregroundColor(Colors.MediumGray)
                    }
                    .fontWeight(.light)
                    .onTapGesture{
                        listViewModel.isShowingVisibiltySheet = true
                    }
                }
                .centerHorizontally()
                .listRowSeparator(.hidden)
            }
            if !listViewModel.list.unsectionedItems.isEmpty{
                SwiftUI.Section
                {
                    ForEach($listViewModel.list.unsectionedItems, id: \.id) { itemBinding in
                        let itemIndex = listViewModel.list.unsectionedItems.firstIndex(where: { $0.id == itemBinding.id }) ?? 0
                        ListItemView(
                            item: itemBinding,
                            currentIndex: $currentIndex,
                            sectionIndex: nil,
                            index: itemIndex,
                            onNameSubmit: {
                                handleNameSubmit(sectionIndex: nil, itemIndex: itemIndex)
                            },
                            onDescriptionSubmit: {
                                handleDescriptionSubmit(sectionIndex: nil, itemIndex: itemIndex)
                            }
                        )
                    }
                    .onMove(perform: listViewModel.move)
                    .onDelete(perform: listViewModel.deleteItem)
                    .listRowInsets(.init(top: -4, leading: 16, bottom: -4, trailing: 16))
                }
            }
            
            ForEach(Array($listViewModel.list.sections.enumerated()), id: \.1.id) { sectionIndex, sectionBinding in
                SwiftUI.Section(
                    header: HStack {
                        Button(action: {
                            self.editingEmojiSectionID = sectionBinding.id
                            listViewModel.isShowingEmojiPicker = true
                        }, label: {
                            if let emoji = sectionBinding.emoji.wrappedValue {
                                Text(emoji)
                                    .font(.system(size: 25))
                            } else {
                                AddIcon(size: 25)
                            }
                        })
                        TextField("Section title", text: sectionBinding.name)
                            .font(Font.custom(Fonts.sfProRoundedSemibold, size: 25))
                            .foregroundColor(.black)
                            .onSubmit {
                                handleSectionSubmit(atSection: sectionIndex)
                            }
                    },
                    content: {
                        ForEach(Array(sectionBinding.items.enumerated()), id: \.1.id) { itemIndex, sectionItemBinding in
                            ListItemView(
                                item: sectionItemBinding,
                                currentIndex: $currentIndex,
                                sectionIndex: sectionIndex,
                                index: itemIndex,
                                onNameSubmit: {
                                    handleNameSubmit(sectionIndex: sectionIndex, itemIndex: itemIndex)
                                },
                                onDescriptionSubmit: {
                                    handleDescriptionSubmit(sectionIndex: sectionIndex, itemIndex: itemIndex)
                                }
                            )
                        }
                        .onMove(perform: listViewModel.move)
                        .onDelete(perform: listViewModel.deleteItem)
                        .listRowInsets(.init(top: -4, leading: 16, bottom: -4, trailing: 16))
                    }
                )
            }
        }
        .padding(.bottom)
        .listStyle(InsetListStyle())
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    homeNavigation.back()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.black)
                }
            }
            
            ToolbarItem (placement: .topBarTrailing){
                HStack{
                    Button(action: {
                        listViewModel.isShowingVisibiltySheet.toggle()
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.black)
                    }
                    if(self.currentIndex != nil){
                        Button(action: {
                            self.currentIndex = nil
                        }) {
                            FontedText("Done")
                                .foregroundStyle(Color.black)
                        }
                    }
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                ListKeyboardButtons(currentIndex: self.currentIndex)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear{
            if (listViewModel.list.unsectionedItems.isEmpty){
                listViewModel.list.unsectionedItems.append(Item(name: ""))
            }
        }
        .sheet(isPresented: $listViewModel.isShowingVisibiltySheet, content: {
            VisibilitySelectView(listViewModel: listViewModel)
        })
        .sheet(isPresented: $listViewModel.isShowingEmojiPicker, content: {
            ElegantEmojiPickerView(selectedEmoji: self.selectedEmojiBinding)
        })
    }
    
    func handleNameSubmit(sectionIndex: Int?, itemIndex: Int) {
        let newIndex = self.listViewModel.handleNameSubmit(atSection: sectionIndex, atIndex: itemIndex)
        DispatchQueue.main.async{
            self.currentIndex = newIndex
        }
    }
    
    func handleDescriptionSubmit(sectionIndex: Int?, itemIndex: Int) {
        let newIndex =  self.listViewModel.handleDescriptionSubmit(atSection: sectionIndex, atIndex: itemIndex)
        DispatchQueue.main.async{
            self.currentIndex = newIndex
            self.listViewModel.setPreviousDescriptionToNilIfEmpty(atSection: sectionIndex, atIndex: itemIndex)
        }
    }
    
    func handleSectionSubmit(atSection: Int){
        print("Handled section submit")
    }
    
}




struct VisibilitySelectView: View {
    @StateObject var listViewModel: ListViewModel
    
    var body: some View{
        VStack{
            ZStack{
                HStack {
                    Spacer()
                    Button(action: { self.listViewModel.isShowingVisibiltySheet = false }) {
                        FontedText("Done")
                            .foregroundStyle(Color.black)
                    }
                }
                FontedText("Visibility")
            }
            
            VStack (alignment: .leading){
                ForEach(ListVisibility.allCases, id: \.self){ visibility in
                    Button(action:{
                        self.listViewModel.list.visibility = visibility
                    }, label: {
                        HStack(alignment: .center){
                            Text(visibility.emoji)
                                .font(.system(size: 50))
                                .frame(width: 50, height: 50, alignment: .center)
                            VStack(alignment: .leading){
                                FontedText(visibility.rawValue)
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                FontedText(visibility.description, size: 14)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                            }
                            .foregroundStyle(Color.black)
                        }
                        .padding(.vertical)
                        .background(self.listViewModel.list.visibility == visibility ? Colors.LightGray : Color.clear)
                        .cornerRadius(10)
                    }
                    )
                }
                TitleText("Friends coming soon! 🎉")
            }
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}

#Preview {
    EditListView()
        .environmentObject(mockListVM)
}
