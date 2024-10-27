//
//  EditListView.swift
//  Recco
//
//  Created by Christen Xie on 8/26/24.
//

import SwiftUI


typealias ListFocusIndex = (section: Int?, index: Int, isDescription: Bool, isSectionTitle: Bool)?
enum ListItemType {
   case sectionTitle
    case itemName
    case itemDescription
}

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
    
    
    var body: some View{
        SwiftUI.List {
            SwiftUI.Section {
                VStack {
                    Button(action: {
                        listViewModel.printOutDebug()
                    }, label: {
                        Text("Current index: \(String(describing: currentIndex))")
                    })
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
                            onCommit: { listItemType in
                                handleNewLine(sectionIndex: nil, itemIndex: itemIndex, listItemType: listItemType)
                            },
                            onBackspaceEmptyString: { listItemType in
                                handleBackspaceEmptyString(sectionIndex: nil, itemIndex: itemIndex, listItemType: listItemType)
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
                        CustomTextFieldMultiline(
                            text: sectionBinding.name,
                            placeholder: "Section Title",
                            foregroundColor: Color.black,
                            fontString: Fonts.sfProRoundedBold,
                            selfIndex: -1,
                            selfSectionIndex: sectionIndex,
                            isDescription: false,
                            isSectionTitle: true,
                            currentIndex: $currentIndex,
                            onCommit: {
                                handleNewLine(sectionIndex: sectionIndex, itemIndex: -1, listItemType: .sectionTitle)
                            },
                            onBackspaceEmptyString: {
                                handleBackspaceEmptyString(sectionIndex: sectionIndex, itemIndex: -1, listItemType: .sectionTitle)
                            }
                        )
                    },
                    content: {
                        ForEach(Array(sectionBinding.items.enumerated()), id: \.1.id) { itemIndex, sectionItemBinding in
                            ListItemView(
                                item: sectionItemBinding,
                                currentIndex: $currentIndex,
                                sectionIndex: sectionIndex,
                                index: itemIndex,
                                onCommit: { listItemType in
                                    handleNewLine(sectionIndex: sectionIndex, itemIndex: itemIndex, listItemType: listItemType)
                                },
                                onBackspaceEmptyString: { listItemType in
                                    handleBackspaceEmptyString(sectionIndex: sectionIndex, itemIndex: itemIndex, listItemType: listItemType)
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
        .environmentObject(listViewModel)
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
    
    func handleNewLine(sectionIndex: Int?, itemIndex: Int, listItemType: ListItemType){
        let newIndex = self.listViewModel.handleNewLine(atSection: sectionIndex, atIndex: itemIndex, listItemType: listItemType);
        DispatchQueue.main.async{
            self.currentIndex = newIndex
            if(listItemType == .itemDescription ){
                self.listViewModel.setPreviousDescriptionToNilIfEmpty(atSection: sectionIndex, atIndex: itemIndex)
            }
        }
    }
    func handleBackspaceEmptyString(sectionIndex: Int?, itemIndex: Int, listItemType: ListItemType){
        let newIndex = self.listViewModel.handleBackspaceEmptyString(atSection: sectionIndex, atIndex: itemIndex, listItemType: listItemType)
        DispatchQueue.main.async {
            self.currentIndex = newIndex
        }
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

//#Preview {
//    EditListView()
//        .environmentObject(mockListVM)
//}
