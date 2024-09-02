//
//  ListItemView.swift
//  Recco
//
//  Created by Christen Xie on 9/1/24.
//

import SwiftUI

struct ListItemView: View {
    @Binding var item: Item
    @FocusState.Binding var focusedField: EditListView.FocusField?
    let index: Int
    let onNameSubmit: () -> Void
    let onDescriptionSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                HStack{
                    Text("•")
                        .font(.system(size: 16))
                        .foregroundColor(Colors.ListItemGray)
                    TextField("Add a recommendation",
                              text: $item.name
                    )
                    .foregroundColor(Colors.ListItemGray)
                    .font(.custom(Fonts.sfProRounded, size: 16))
                    .fontWeight(.bold)
                    .fixedSize()
                    .focused($focusedField, equals: .name(index))
                    .onSubmit {
                        onNameSubmit()
                    }
                }
                .onTapGesture {
                    self.focusedField = .name(index)
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
            if let description = item.description {
                TextField("Add a description",
                          text: Binding(
                            get: { description },
                            set: { item.description = $0 }
                          ),
                          axis: .vertical)
                .padding(.leading, 20)
                .foregroundColor(Colors.ListItemGray)
                .font(.custom(Fonts.sfProRoundedLight, size: 14))
                .focused($focusedField, equals: .description(index))
                .onSubmit {
                    onDescriptionSubmit()
                }
            }
        }
        .listRowSeparator(.hidden)
        .onTapGesture {
            self.focusedField = .description(index)
        }
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
