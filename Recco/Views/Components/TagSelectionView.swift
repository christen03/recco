//
//  TagSelectionView.swift
//  Recco
//
//  Created by Christen Xie on 10/27/24.
//

import SwiftUI

struct TagSelectionView: View {
    @StateObject var tagSelectionViewModel = TagSelectionViewModel()
    @ObservedObject var userDataViewModel: UserDataViewModel
    
    init(userDataViewModel: UserDataViewModel) {
        self.userDataViewModel = userDataViewModel
        
    }
    
    func formatCategory(_ category: String) -> String {
            category.replacingOccurrences(of: "_", with: " ").capitalized
        }
    
    var body: some View {
        VStack{
            HStack{
                Spacer()
                TitleText("Select Tags")
                Spacer()
                Button(action: {
                    if let currentUser = userDataViewModel.currentUser {
                        Task{
                            let success = await tagSelectionViewModel.applyTagChanges(userId: currentUser.id)
                            if(success){
                                userDataViewModel.updateUserTags(newTags: tagSelectionViewModel.selectedTags)
                            }
                        }
                    }
                },label: {
                    FontedText("Apply")
                })
            }
            .padding()
            ScrollView {
                if tagSelectionViewModel.isFetchingTags {
                    ProgressView()
                        .padding()
                } else if (tagSelectionViewModel.isTagsError != nil) {
                    Text("Error fetching tags")
                        .padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(tagSelectionViewModel.availableTags.keys.sorted(), id: \.self) { category in
                            VStack(alignment: .leading) {
                                TagFlowLayout(category: category, tags: tagSelectionViewModel.availableTags[category] ?? []) { tag in
                                    TagButton(
                                        tag: tag,
                                        isSelected: tagSelectionViewModel.selectedTags.contains(tag),
                                        action: { tagSelectionViewModel.toggleTag(tag: tag) }
                                    )
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .toastView(toast: $tagSelectionViewModel.toast)
        .task {
            await tagSelectionViewModel.fetchAllTags()
        }
    }
}

struct TagFlowLayout: View {
    let category: String
    let tags: [Tag]
    let content: (Tag) -> TagButton
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TitleText(category.replacingOccurrences(of: "_", with: " ").capitalized)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(tags) { tag in
                    content(tag)
                        .padding(4)
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        return CGSize(width: proposal.width ?? result.width, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            alignment: alignment,
            spacing: spacing
        )
        for row in result.rows {
            for element in row.elements {
                element.subview.place(
                    at: CGPoint(
                        x: bounds.minX + element.x,
                        y: bounds.minY + row.y
                    ),
                    proposal: ProposedViewSize(
                        width: element.width,
                        height: element.height
                    )
                )
            }
        }
    }
    
    struct FlowResult {
        struct Element {
            var subview: LayoutSubview
            var x: CGFloat
            var width: CGFloat
            var height: CGFloat
        }
        
        struct Row {
            var elements: [Element] = []
            var y: CGFloat = 0
            var height: CGFloat = 0
        }
        
        var rows: [Row]
        var width: CGFloat
        var height: CGFloat
        
        init(in maxWidth: CGFloat, subviews: LayoutSubviews, alignment: HorizontalAlignment, spacing: CGFloat) {
            var rows: [Row] = []
            var currentRow = Row()
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0
            var maxWidth: CGFloat = maxWidth
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, !currentRow.elements.isEmpty {
                    rows.append(currentRow)
                    currentRow = Row()
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }
                
                currentRow.elements.append(
                    Element(
                        subview: subview,
                        x: x,
                        width: size.width,
                        height: size.height
                    )
                )
                
                maxHeight = max(maxHeight, size.height)
                currentRow.height = maxHeight
                currentRow.y = y
                
                x += size.width + spacing
                maxWidth = max(maxWidth, x)
            }
            
            if !currentRow.elements.isEmpty {
                rows.append(currentRow)
            }
            
            self.rows = rows
            self.width = maxWidth
            self.height = y + maxHeight
        }
    }
}

struct TagButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                FontedText(tag.emoji)
                    .font(.system(size: 14))
                FontedText(tag.name)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .animation(.spring(response: 0.3), value: isSelected)
            .fixedSize() // This forces the view to size to its content
        }
    }
}
