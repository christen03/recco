//
//  EditListView.swift
//  Recco
//
//  Created by Christen Xie on 8/26/24.
//

import SwiftUI



struct EditListView: View {
    enum FocusField: Hashable {
        case name(Int)
        case description(Int)
    }
    
    @EnvironmentObject var listViewModel: ListViewModel
    
    
    @State private var isShowingPriceOptions: Bool = false
    @State private var currentIndex: Int?
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
    
    @FocusState private var focusedField: FocusField? {
        willSet {
            switch newValue {
            case .name(let int):
                self.currentIndex = int
            case .description(let int):
                self.currentIndex = int
            case nil:
                self.currentIndex = nil
            }
        }
    }
    
    var body: some View{
        SwiftUI.List {
            SwiftUI.Section {
                VStack {
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
                    FontedText(listViewModel.list.visibility.rawValue, size: 13)
                        .foregroundColor(Colors.MediumGray)
                        .fontWeight(.light)
                        .onTapGesture{
                            listViewModel.isShowingVisibiltySheet = true
                        }
                }
                .centerHorizontally()
                .listRowSeparator(.hidden)
            }
            if !listViewModel.list.unsectionedItems.isEmpty{
                SwiftUI.Section(header: TitleText("Unsectioned Items")
                    .foregroundStyle(Color.black)){
                        ForEach($listViewModel.list.unsectionedItems.enumerated().map { $0 }, id: \.1.id) { index, itemBinding in
                            ListItemView(
                                item: itemBinding,
                                focusedField: $focusedField,
                                index: index,
                                onNameSubmit: {
                                    self.handleNameSubmit(at: index)
                                },
                                onDescriptionSubmit: {
                                    self.handleDescriptionSubmit(at: index)
                                }
                            )
                        }
//                        .onMove { source, destination in
//                               listViewModel.moveItem(from: IndexPath(row: source.first!, section: 0), to: IndexPath(row: destination, section: 0))
//                           }
                        .onDelete(perform: listViewModel.deleteItem)
                        .listRowInsets(.init(top: 3, leading: 16, bottom: 3, trailing: 16))
                    }
            }
            
            
            ForEach($listViewModel.list.sections, id: \.id){ sectionBinding in
                SwiftUI.Section(header:
                                    HStack {
                    Button(action: {
                        self.editingEmojiSectionID = sectionBinding.id
                        listViewModel.isShowingEmojiPicker = true
                    }, label: {
                        if sectionBinding.emoji.wrappedValue != nil{
                            Text(sectionBinding.emoji.wrappedValue!)
                                .font(.system(size: 25))
                        } else {
                            AddIcon(size: 25)
                        }
                    })
                    TextField("Section title",
                              text: sectionBinding.name
                    )
                    .font(Font.custom(Fonts.sfProRoundedSemibold, size: 25))
                    .foregroundStyle(Color.black)
                })
                {ForEach(sectionBinding.items.enumerated().map { $0 }, id: \.1.id ) { index, sectionItemBinding in
                    ListItemView(
                        item: sectionItemBinding,
                        focusedField: $focusedField,
                        index: index,
                        onNameSubmit: {
                            self.handleNameSubmit(at: index)
                        },
                        onDescriptionSubmit: {
                            self.handleDescriptionSubmit(at: index)
                        }
                    )
                }
//                .onMove { source, destination in
//                    listViewModel.moveItem(from: IndexPath(row: source.first!, section: listViewModel.list.sections.firstIndex(where: { $0.id == sectionBinding.id })! + 1),
//                                           to: IndexPath(row: destination, section: listViewModel.list.sections.firstIndex(where: { $0.id == sectionBinding.id })! + 1))
//                }
                .onDelete(perform: listViewModel.deleteItem)
                .listRowInsets(.init(top: 3, leading: 16, bottom: 3, trailing: 16))
                }
                
            }
            
        }
        
        
        
        .listStyle(PlainListStyle())
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if(self.isShowingPriceOptions){
                    HStack(spacing: 1){
                        KeyboardButton(action: {self.isShowingPriceOptions=false}) {
                            Image(systemName: "xmark")
                        }
                        KeyboardButton(action: {
                            if let index = self.currentIndex{
                                listViewModel.setPriceRange(forIndex: index, to: PriceRange.free)
                            }
                        }) {
                            TitleText("Free")
                        }
                        KeyboardButton(action: {
                            if let index = self.currentIndex{
                                listViewModel.setPriceRange(forIndex: index, to: PriceRange.one)
                            }
                        }) {
                            Image(systemName: "dollarsign")
                        }
                        KeyboardButton(action: {
                            if let index = self.currentIndex{
                                listViewModel.setPriceRange(forIndex: index, to: PriceRange.two)
                            }
                        }) {
                            HStack(spacing: -2){
                                Image(systemName: "dollarsign")
                                Image(systemName: "dollarsign")
                            }
                        }
                        KeyboardButton(action: {
                            if let index = self.currentIndex {
                                listViewModel.setPriceRange(forIndex: index, to: PriceRange.three)
                            }
                        }) {
                            HStack(spacing: -2){
                                Image(systemName: "dollarsign")
                                Image(systemName: "dollarsign")
                                Image(systemName: "dollarsign")
                            }
                        }
                        Spacer()
                    }
                    // FIXME: animations
                    .animation(.easeInOut, value: isShowingPriceOptions)
                    .transition(.move(edge:.leading))
                } else {
                    HStack(spacing: 1){
                        KeyboardButton(action: { /* Create new section */ }) {
                            Image(systemName: "list.bullet.indent")
                        }
                        
                        KeyboardButton(action: { self.isShowingPriceOptions = true }) {
                            Image(systemName: "dollarsign")
                        }
                        
                        KeyboardButton(action: {
                            if let index = self.currentIndex {
                                listViewModel.toggleFavoriteForIndex(at: index)
                            }
                        }) {
                            Text("⭐️")
                                .font(.title2)
                        }
                        Spacer()
                    }
                    .animation(.easeInOut, value: isShowingPriceOptions)
                    .transition(.move(edge: .leading))
                }
            }
        }
        .padding()
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
    
    
    private func handleNameSubmit(at index: Int) {
        if !listViewModel.list.unsectionedItems[index].name.isEmpty {
            if (listViewModel.list.unsectionedItems[index].description == nil){
                listViewModel.list.unsectionedItems[index].description = ""
            }
            focusedField = .description(index)
        } else {
            handleDescriptionSubmit(at: index)
        }
    }
    
    private func handleDescriptionSubmit(at index: Int) {
        if(listViewModel.list.unsectionedItems[index].description!.isEmpty){
            listViewModel.list.unsectionedItems[index].description = nil
        }
        let newIndex = index + 1
        listViewModel.list.unsectionedItems.insert(Item(name: ""), at: newIndex)
        focusedField = .name(newIndex)
    }
    
    
}


struct KeyboardButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(height: 30)
                .padding(.horizontal, 5)
                .background(Colors.BorderGray)
                .cornerRadius(10)
                .foregroundStyle(Color.black)
        }
    }
}

struct VisibilitySelectView: View {
    let listViewModel: ListViewModel
    
    var body: some View{
        VStack{
            ForEach(ListVisibility.allCases, id: \.self){ visibility in
                Button(action:{
                    self.listViewModel.list.visibility = visibility
                }, label: {
                    FontedText(visibility.rawValue)
                }
                )
            }
        }
    }
}

#Preview {
    EditListView()
        .environmentObject(mockListVM)
}
