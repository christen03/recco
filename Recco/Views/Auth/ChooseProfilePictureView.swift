//
//  ChooseProfilePictureView.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import PhotosUI
import SwiftUI

struct ChooseProfilePictureView: View {
    @EnvironmentObject var supabaseSignUp: SupabaseAuthViewModel
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var authNavigation: AuthNavigation
    
    var body: some View {
        VStack{
            Spacer()
            
            TitleText("Add a profile picture")
                .padding(.bottom, 20)
            
            switch supabaseSignUp.imageState {
            case .empty:
                ImageLoader(imageUrl: Constants.DEFAULT_PROFILE_PICTURE_URL)
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(alignment: .bottomTrailing) {
                        photoPickerButton
                    }
                
            case .loading(let progress):
                ProgressView(value: progress.fractionCompleted)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(alignment: .bottomTrailing) {
                        photoPickerButton
                    }
                
            case .success(let profileImage):
                profileImage.imageState
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(alignment: .bottomTrailing) {
                        photoPickerButton
                    }
                
            case .failure:
                Text("Failed to load image")
                    .foregroundColor(.red)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .shadow(radius: 10)
                    .overlay(alignment: .bottomTrailing) {
                        photoPickerButton
                    }
            }
            
            Button(action: {
                Task{
                    let success = await supabaseSignUp.continueProfilePageButtonTapped()
                    if(success) {
                        // TODO: combine this into one function, this feels messy
                        userDataViewModel.updateUserProfilePictureLocally(
                            newUrl: supabaseSignUp.profilePictureUrl
                        )
                        userDataViewModel.login()
                    }
                }
            }, label: {
                FontedText(supabaseSignUp.isLoading ? "Loading..." : "Continue")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(supabaseSignUp.isLoading ? Color(.systemGray4) : Color.black)
                    .cornerRadius(10)
            })
            .padding(.top, 30)
            .padding(.horizontal, 20)
            .disabled(supabaseSignUp.isLoading)
            
            Spacer()
        }
        .toastView(toast: $supabaseSignUp.toast)
        .padding()
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(
            selection: $supabaseSignUp.imageSelection,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Image(systemName: "pencil.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 30))
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.borderless)
    }
}

struct ProfileImage: Transferable {
    let imageState: Image
    let uiImage: UIImage?
    
    enum ProfileImageError: Error {
        case importError
    }
    
    static var transferRepresentation: some TransferRepresentation{
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw ProfileImageError.importError
            }
            let image = Image(uiImage: uiImage)
            return ProfileImage(imageState: image, uiImage: uiImage)
        }
    }
}


#Preview {
    ChooseProfilePictureView()
}
