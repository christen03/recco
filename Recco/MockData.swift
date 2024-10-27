//
//  MockData.swift
//  Recco
//
//  Created by Christen Xie on 8/27/24.
//

import Foundation


let mockItems = [
    Item(name: "McDonald's",
         description: "Iconic iron lattice tower on the Champ de Mars in Paris"),
    Item(name: "Try authentic Italian pizza",
         description: "Thin crust, wood-fired pizza from Naples"),
    Item(name: "Explore the Great Barrier Reef",
         description: "World's largest coral reef system off the coast of Australia"),
    Item(name: "Watch a Broadway show in New York",
         description: "Experience world-class theater performances"),
    Item(name: "",
         description: "Ancient Incan citadel set high in the Andes Mountains"),
    Item(name: "Chipotle",
         description: "Natural light display in Earth's sky, predominantly seen in high-latitude regions"),
    Item(name: "Visit the Louvre Museum",
         description: "World's largest art museum and home to many famous works including the Mona Lisa"),
    Item(name: "Ride a gondola in Venice",
         description: "Traditional Venetian rowing boat, perfect for exploring the city's canals")
]

let mockSections:[Section] = [
    Section(
        name: "Groceries",
        emoji: "🛒",
        items: [
            Item(name: "Apples", description: "A bag of fresh apples", price: PriceRange.one, isStarred: true),
            Item(name: "Milk", description: "1 gallon of whole milk", price: PriceRange.two),
            Item(name: "Bread", description: "Whole grain bread", price: PriceRange.one)
        ]
    ),
    Section(
        name: "Electronics",
        emoji: "📱",
        items: [
            Item(name: "iPhone", description: "Latest iPhone model", price: PriceRange.three, isStarred: true),
            Item(name: "Headphones", description: "Noise-cancelling headphones", price: PriceRange.two),
            Item(name: "Laptop", description: "15-inch laptop", price: PriceRange.three, isStarred: true)
        ]
    ),
    Section(
        name: "Books",
        emoji: "📚",
        items: [
            Item(name: "The Great Gatsby", description: "Classic novel by F. Scott Fitzgerald", price: PriceRange.one, isStarred: true),
            Item(name: "Swift Programming", description: "Learn Swift programming", price: PriceRange.two, isStarred: true),
            Item(name: "Cookbook", description: "Recipes for healthy eating", price: PriceRange.two)
        ]
    )
]

let mockUser: User = User(id: UUID(), firstName: "Christen", lastName: "Xie", username: "chris10", profilePictureUrl: URL(string: "https://pejyorpsrmoywwcerlkc.supabase.co/storage/v1/object/public/profile_pictures/BA83880C-E5EA-4F16-AB72-5D573517EFC1.jpg")!, email: "christenxie@gmail.com", phoneNumber: "5103345535",
                          tags: [Tag(id: 1, name: "Food", emoji: "🍝", category: "Food"),
                                 Tag(id: 2, name: "Cafes", emoji: "☕️", category: "Food")]
)

//let mockListVM = ListViewModel(userId: "123",selectedEmoji: "🫶", listName: "Christen's Recs", sections: mockSections, items: mockItems)

