//
//  SupabaseAuth.swift
//  Recco
//
//  Created by Christen Xie on 8/12/24.
//

import Foundation
import SwiftUI
import PhotosUI
import Supabase

// TODO: Reset fields when user gets signed in, validate strings when user hits back
class SupabaseAuthViewModel: ObservableObject {
    
    let supabaseUserManager = SupabaseUserManager()
    var formattedPhoneNumber: String {
        return "1"+self.phone
    }
    
    @Published var isSigningUp: Bool = false
    @Published var authMethod: AuthOptions? = nil
    // Authorization fields
    @Published var email: String = "" {
        didSet{
            validateEmail()
        }
    }
    @Published var phone: String = "" {
        didSet {
            validatePhoneNumber()
        }
    }
    @Published var code: String = ""
    
    // UI related
    @Published var isLoading: Bool = false
    @Published var toast: Toast? = nil
    
    // User data
    var userId: UUID? = nil
    @Published var firstName: String = "" {
        didSet{
            validateNames()
        }
    }
    
    @Published var lastName: String = "" {
        didSet {
            validateNames()
        }
    }
    
    @Published var username: String = "" {
        didSet {
            validateUsername()
        }
    }
    
    @Published private(set) var imageState: ImageState = .empty
    @Published var imageSelection: PhotosPickerItem? = nil{
        didSet{
            if let imageSelection {
                let progress = loadTransferrable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    // Default profile picture URL
    @Published var profilePictureUrl: URL = Constants.DEFAULT_PROFILE_PICTURE_URL
    
    // Validation fields
    @Published var isPhoneValid: Bool = false
    @Published var isEmailValid: Bool = false
    @Published var areNamesValid: Bool = false
    @Published var isUsernameValid: Bool = false
    
    func setIsSigningUp(_ isSigningUp: Bool){
        self.isSigningUp = isSigningUp
    }
    
    func setAuthOption(option: AuthOptions){
        self.authMethod = option
    }
    
    @MainActor
    func signUpButtonTapped() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            try await Task.detached(priority: .userInitiated) {
                if(self.authMethod == .email){
                    try await supabase.auth.signInWithOTP(
                        email: self.email,
                    )
                } else {
                    try await supabase.auth.signInWithOTP(
                        phone: self.formattedPhoneNumber,
                    )
                }
            }.value
            return true
        } catch let error as AuthError{
            toast = Toast(style: .error, message: error.localizedDescription)
            return false
        } catch {
            toast = Toast(style: .error, message: error.localizedDescription)
            return false
        }
    }
    
    @MainActor
    func verifyCodeButtonTapped() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let authResp: AuthResponse
            
            if self.authMethod == .email {
                authResp = try await supabase.auth.verifyOTP(
                    email: self.email,
                    token: self.code,
                    type: .email
                )
            } else {
                authResp = try await supabase.auth.verifyOTP(
                    phone: self.formattedPhoneNumber,
                    token: self.code,
                    type: .sms
                )
            }
            self.userId = authResp.user.id
            return true
        } catch {
            toast = Toast(style: .error, message: error.localizedDescription)
            return false
        }
    }
    
    @MainActor
    func fetchUserFromSupabase() async throws -> User? {
        isLoading = true
        defer {isLoading = false}
        do{
            let user: User = try await supabase
                .from("users")
                .select()
                .eq("user_id", value: UUID())
                .single()
                .execute()
                .value
            return user
        }
        catch{
            if let error = error as? PostgrestError {
                if(error.code == "PGRST116"){
                    return nil
                }
            }
            throw error
        }
    }
    
    @MainActor
    func verifyUsernameIsUniqueAndCreateUser() async -> User? {
        isLoading = true
        defer { isLoading = false }
        do{
            if self.userId == nil {
                self.userId = try await supabase.auth.session.user.id
            }
            
            guard let userId = self.userId else {
                return nil
            }
        
            let newUser = User(
                id: userId,
                firstName: self.firstName,
                lastName: self.lastName,
                username: self.username,
                profilePictureUrl: self.profilePictureUrl,
                email: self.email,
                phoneNumber: self.phone,
                tags: []
            )
            let createUserParams = CreateUserParams(
                id: userId,
                firstName: self.firstName,
                lastName: self.lastName,
                username: self.username,
                profilePictureUrl: self.profilePictureUrl,
                email: self.email,
                phoneNumber: self.phone
            )
            try await self.supabaseUserManager.createUserInSupabase(userData: createUserParams)
//            UserDefaults.standard.saveUser(newUser, forKey: UserDefaults.UserDefaultKeys.currentUser.rawValue)
            return newUser
        } catch {
            toast = Toast(style: .error, message: error.localizedDescription)
            return nil
        }
    }
    
    @MainActor
    func continueProfilePageButtonTapped() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        // If no image is selected, no need to do anything
        guard case .success(let profileImage) = imageState,
              let uiImage = profileImage.uiImage,
              let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            return true
        }
        do {
            try await Task.detached(priority: .userInitiated) {
                let newImageUrl = try await self.supabaseUserManager.uploadProfilePictureToSupabase(imageData: imageData)
                await MainActor.run{
                    self.profilePictureUrl=newImageUrl
                }
            }.value
            return true
        } catch {
            print(error)
            toast = Toast(style: .error, message: error.localizedDescription)
            return false
        }
        
    }
    
    // Image helper function and enum:
    
    enum ImageState{
        case empty, loading(Progress), success(ProfileImage), failure(Error)
    }
    
    private func loadTransferrable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else { return }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success(profileImage)
                case .success(nil):
                    self.imageState = .empty
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
    // MARK: Validation functions
    private func validatePhoneNumber(){
        // I got this from chatgpt LOL
        // This is a basic validation. You might want to use a more sophisticated regex
        // or a phone number formatting library for production use.
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        self.isPhoneValid =  phonePredicate.evaluate(with: phone)
    }
    
    private func validateEmail(){
        if(email.isEmpty){
            self.isEmailValid = false
            return
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        self.isEmailValid = emailPredicate.evaluate(with: email)
    }
    
    private func validateNames(){
        let isFirstNameValid = !self.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isLastNameValid = !self.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        self.areNamesValid = isFirstNameValid && isLastNameValid
    }
    
    private func validateUsername(){
        let usernamePattern = "^[a-zA-Z0-9_]{3,20}$"
        let regex = try! NSRegularExpression(pattern: usernamePattern)
        let range = NSRange(location: 0, length: username.utf16.count)
        self.isUsernameValid = regex.firstMatch(in: username, options: [], range: range) != nil
    }
}
