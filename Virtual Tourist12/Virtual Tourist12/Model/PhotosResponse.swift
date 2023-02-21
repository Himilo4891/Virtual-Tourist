//
//  Extension.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 20/02/23.
//
import Foundation
 
struct Fotos: Codable {
 let photos: PhotosClass
 let stat: String
 
}
struct PhotosClass: Codable {
let page, pages, perpage, total: Int
let photo: [Photo]

}
struct Photo: Codable {
    
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let urlM: String
    let heightM, widthM: Int
    
    enum CodingKeys: String, CodingKey {
          case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
          case urlM = "url_m"
          case heightM = "height_m"
          case widthM = "width_m"
      }
}
