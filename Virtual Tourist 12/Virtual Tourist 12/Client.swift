//  Client.swift
//  Virtual Tourist 12
//
//  Created by abdiqani on 13/03/23.
//

import Foundation
import CoreData
import UIKit

class Client {
    static let shared = Client()
    enum Endpoints {
        
        case SearchPhotos
        case Base
        
        var StringValue: String {
            switch self {
                
            case .Base: return
                "https://www.flickr.com/services/rest/?method="
                
            case .SearchPhotos: return "flickr.photos.search"
                
            }
        }
        
        var url: URL {
            return URL(string: StringValue)!
        }
        
    }
    
    class func taskforPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(body)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            print("task completed")
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            print(String(data: data!, encoding: .utf8)!)
            
            let decoder = JSONDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data!)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                
            }
            
        }
        task.resume()
        
    }
    
    func getphoto (Pin: Pin, longitude: Double, latitude: Double) {
        
        
        SearchPhoto(longitude: longitude, Latitude: latitude) { (photo, error) in
            
            
            if photo.count == 0 {
                
                let alertVC = UIAlertController(title: "No Images", message: "No Image to display", preferredStyle: .alert)
//                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                for images in photo {
                    
                    let photoData = Photo(context: DataController.shared.viewContext)
                    
                    
                    let ImageURLAddress = URL(string:"https://farm\(images.farm).staticflickr.com/\(images.server)/\(images.id)_\(images.secret).jpg")!
                    
                    photoData.pin = Pin
                    photoData.creationDate = Pin.creationDate
                    
                    if let data = try? Data(contentsOf: ImageURLAddress) {
                        print("activity indicator called")
                        
                        photoData.image = data
                        print(photoData.image!)
//                        self.indicator!.stop()
                    }
                    
                    print(photoData)
                    try? DataController.shared.viewContext.save()
                }
            }
        }
        
        
        func downloadImage(photoURL: URL, completion: @escaping (Data?, Error?) -> Void) {
            let task = URLSession.shared.dataTask(with: photoURL) { data, response, error in
                DispatchQueue.main.async {
                    completion(data, error)
                }
            }
            task.resume()
        }
        
        func SearchPhoto (longitude: Double, Latitude: Double, _ completion: @escaping ([Images], Error?) -> Void) {
            
            let apiURLAddress = Endpoints.Base.StringValue + Endpoints.SearchPhotos.StringValue + "&api_key=\(PhotoRequest.api_key)" + "&lat=\(Latitude)" + "&lon=\(longitude)" + "&page=3&per_page=30&format=json&nojsoncallback=1"
            
            let searchURL = URL(string:apiURLAddress)!
            
            let searchRequest = PhotoRequest(lat: Latitude, lon: longitude)
            
            
            Client.taskforPOSTRequest(url: searchURL, responseType: PhotoResponse.self, body: searchRequest) { response, error in
                
                if error == nil {
                    completion((response?.photos.photo)!, nil)
                } else {
                    completion([], error)
                    print(error!)
                }
            }
        }
        
    }
}
