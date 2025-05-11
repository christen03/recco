//
//  self.swift
//  Recco
//
//  Created by Christen Xie on 8/25/24.
//

import Foundation
import Network

enum ListVisibility: String, CaseIterable {
    // Named global becuase 'public' is a reserved keyword
    case global = "Public"
    case friends = "All Friends"
    case restricted = "Restricted"
    
    var emoji: String{
        switch self {
        case .global: return "🌐"
        case .friends: return "👥"
        case .restricted: return "🔒"
        }
    }
    
    
    var description: String {
        switch self{
        case .global:
            return "Everyone can see this list on your profile, but it only appears on your friends’ feeds."
            
        case .friends:
            return "All friends can see this list on your profile and their feeds."
            
        case .restricted:
            return "Only select friends can see this list on your profile and their feeds."
        }
    }
}

enum PriceRange: String, Decodable{
    case free
    case one
    case two
    case three
}

class ListViewModel: ObservableObject {
    
    
    private var saveWorkItem: DispatchWorkItem? = nil
    private let saveDelay: TimeInterval = 2.0
    private let networkMonitor = NWPathMonitor()

    var isListCreated: Bool = false
    private var userDataViewModel: UserDataViewModel? = nil
    @Published var list: List { didSet { scheduleSave() } }
    @Published var lastSaveDate: Date? = nil
    
    private var observers: [UUID: (List)-> Void] = [:]
    struct UIState {
        var isShowingVisibilitySheet: Bool = false
    }
    @Published var uiState: UIState = UIState()
    
    @Published var isShowingCreateListSheet: Bool = false
    @Published var isShowingEmojiPicker: Bool = false
    @Published var canCreateList: Bool = false
    @Published var toast: Toast? = nil
    
    
    @Published var isNetworkAvailable: Bool = false
    @Published var isSaving: Bool = false
    
    var isInitialized: Bool = false
    var hasUnsectioned: Bool {
        return !list.unsectionedItems.isEmpty
    }
    
    static func empty() -> ListViewModel {
        return ListViewModel(list: List.empty())
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            let isAvailable = path.status == .satisfied
        }
    }
    
    
    init(list: List){
        var listWithItem = list
        if list.sections.isEmpty && list.unsectionedItems.isEmpty {
            listWithItem.unsectionedItems.append(Item(name: "", description: ""))
        }
        self.list=listWithItem
    }
    
    
    func toggleVisibilitySheet(){
        self.uiState.isShowingVisibilitySheet.toggle()
    }
    
    func addObserver(id: UUID, handler: @escaping (List) -> Void){
        observers[id] = handler
    }
    
    func removeObserver(id: UUID){
        observers.removeValue(forKey: id)
    }
    
    func createNewItemInSection(at index: Int) {
        var updatedList = self.list
        guard index >= 0 && index < updatedList.sections.count else {return}
        updatedList.sections[index].items.append(Item(name: "", description: ""))
        self.list=updatedList
    }
    
    func updateList(_ newList: List){
        self.list=newList
        for(_, handler) in observers {
            handler(self.list)
        }
    }
    
    func updateSection(at index: Int, with newSection: Section) {
            var updatedList = self.list
            if index < updatedList.sections.count {
                updatedList.sections[index] = newSection
                updateList(updatedList)
            }
        }
        
        func updateUnsectionedItem(at index: Int, with newItem: Item) {
            var updatedList = self.list
            if index < updatedList.unsectionedItems.count {
                updatedList.unsectionedItems[index] = newItem
                updateList(updatedList)
            }
        }
    
    func updateListVisibilty(_ visibilty: ListVisibility){
        guard visibilty != self.list.visibility else { return }
        var updatedList = self.list
        updatedList.visibility=visibilty
        self.list=updatedList
    }
    
    
    private func scheduleSave(){
        saveWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            Task { [weak self] in
                await self?.saveListToSupabase()
            }
        }
        
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + saveDelay, execute: workItem)
    }
    
    @MainActor
    private func saveListToSupabase() async {
        guard !isSaving else {return}
        defer {isSaving = false}
        
        isSaving = true
        
        if(self.list.unsectionedItems.count == 1 && self.list.sections.isEmpty && self.list.unsectionedItems[0].name=="" && self.list.unsectionedItems[0].description=="") { return }
        do {
            let updateListParams = UpdateListParams(list: self.list)
            try await supabase.rpc(SupabaseFunctions.updateList.rawValue, params: updateListParams)
                .execute()
                .value
                lastSaveDate = Date();
        } catch {
            print("Error saving list, \(error)")
                self.toast=Toast(style: ToastStyle.error, message: "Error saving list")
        }
    }
    
    @MainActor
    func deleteList() async {
        do  {
            try await supabase.from("lists").delete().eq("id", value: self.list.id.uuidString).execute().value
        } catch {
            print("Error deleting list, \(error)")
            self.toast = Toast(style: ToastStyle.error, message: "Error deleting list")
        }
    }
    
    func saveNow() {
        saveWorkItem?.cancel()
        saveWorkItem = nil
        Task{
            await saveListToSupabase()
        }
    }
    
}
