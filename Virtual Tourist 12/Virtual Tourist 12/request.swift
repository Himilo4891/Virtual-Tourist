//
//  request.swift
//  Virtual Tourist 12
//
//  Created by abdiqani on 01/05/23.
//

import Foundation
import CoreData

struct PhotoRequest: Codable {
    
    static let api_key: String = "8f7087ed10dd7c828b3911e41c54598f"
    
    let lat: Double
    let lon: Double
    
}

struct PhotoResponse: Codable {
    
    let photos: Photos
    let stat: String?
   
}

struct Photos: Codable {
    
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Images]
}

struct Images: Codable {
    
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
}
