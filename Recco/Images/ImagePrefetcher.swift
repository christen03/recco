//
//  ImagePrefetcher.swift
//  Recco
//
//  Created by Christen Xie on 8/17/24.
//

import Foundation
import Kingfisher

enum PrefetcherKeys {
    case defaultProfile
}

final class ImagePrefetcher{
    
    // TODO: ?? Prefetch for a newly set profile picture image
    
    static let fetcher = ImagePrefetcher()
    
    let prefetchers: [PrefetcherKeys: Kingfisher.ImagePrefetcher]
    = [PrefetcherKeys.defaultProfile : Kingfisher.ImagePrefetcher(urls: [Constants.DEFAULT_PROFILE_PICTURE_URL])]
    
    func startPrefetchingForKey(key: PrefetcherKeys){
        prefetchers[key]?.start()
    }
    
    func stopPrefetchingForKey(key: PrefetcherKeys){
        prefetchers[key]?.stop()
    }
}
