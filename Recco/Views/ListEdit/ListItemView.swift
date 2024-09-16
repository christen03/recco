//
//  ListItemView.swift
//  Recco
//
//  Created by Christen Xie on 9/1/24.
//

import SwiftUI

struct ListItemView: View {
    @Binding var item: Item
    @Binding var currentIndex: ListFocusIndex
    let sectionIndex: Int?
    let index: Int
    let onNameSubmit: () -> Void
    let onDescriptionSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: -10){
            HStack {
                HStack(spacing: 0){
                    Text("•")
                        .font(.system(size: 16))
                        .foregroundColor(Colors.ListItemGray)
                   CustomTextFieldMultiline(
                    text: $item.name,
                    placeholder: "Add a recommendation",
                    foregroundColor: Colors.ListItemGray,
                    fontString: Fonts.sfProRoundedBold,
                    selfIndex: index,
                    selfSectionIndex: sectionIndex,
                    isDescription: false,
                    currentIndex: $currentIndex,
                    onCommit: {
                        onNameSubmit()
                    })
                   .fontWeight(.bold)
            }
                if item.isStarred {
                    Text("⭐️")
                        .padding(.all, 2)
                        .font(.headline)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Colors.ListItemGray, lineWidth: 0.5)
                        )
                }
                if let priceRange = item.price {
                    priceRangeView(for: priceRange)
                        .padding(.vertical, 2)
                        .padding(.horizontal, 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Colors.DarkGray, lineWidth: 0.5)
                        )
                }
                Spacer()
            }
            if item.description != nil {
                HStack{
                    CustomTextFieldMultiline(
                        text: Binding(
                            get: { item.description ?? "" },
                            set: { item.description = $0.isEmpty ? nil : $0 }
                        ),
                        placeholder: "Add a description",
                        foregroundColor: Colors.ListItemGray,
                        fontString: Fonts.sfProRoundedLight,
                        selfIndex: index,
                        selfSectionIndex: sectionIndex,
                        isDescription: true,
                        currentIndex: $currentIndex,
                        onCommit: {
                            onDescriptionSubmit()
                        }
                    )
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    func priceRangeView(for priceRange: PriceRange) -> some View {
        switch priceRange {
        case .free:
            Text("Free")
                .font(Font.custom(Fonts.sfProRoundedSemibold, size: 20))
                .foregroundStyle(Colors.DisabledGray)
                .fontWeight(.bold)
        case .one:
            Image(systemName: "dollarsign")
                .foregroundStyle(Colors.DisabledGray)
                .fontWeight(.bold)
        case .two:
            HStack(spacing: -2) {
                Image(systemName: "dollarsign")
                    .foregroundStyle(Colors.DisabledGray)
                    .fontWeight(.bold)
                Image(systemName: "dollarsign")
                    .foregroundStyle(Colors.DisabledGray)
                    .fontWeight(.bold)
            }
        case .three:
            HStack(spacing: -2) {
                Image(systemName: "dollarsign")
                    .foregroundStyle(Colors.DisabledGray)
                    .fontWeight(.bold)
                Image(systemName: "dollarsign")
                    .foregroundStyle(Colors.DisabledGray)
                    .fontWeight(.bold)
                Image(systemName: "dollarsign")
                    .foregroundStyle(Colors.DisabledGray)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    EditListView()
        .environmentObject(mockListVM)
}
