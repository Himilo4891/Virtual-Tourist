//
//  APIManager.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 20/02/23.
//

import Foundation

class APIManager: NSObject {
    static let shared = APIManager()
    
    enum Res<T> {
        case Success(T)
        case Error(String)
    }
    
    func getPhotos(lat: Double, lon: Double, completion:@escaping (Res<Fotos>)->Void) {
        
        let urlString = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=23aa09bd0bda6d5930e81a57a1738fc1&bbox=-10%2C-10%2C10%2C10&content_type=1&lat=" + "\(lat)" + "&lon=" + "\(lon)&page=\(Int.random(in: 0..<10))&pentr_page=100&radius=1&format=json&nojsoncallback=1"
        
        print("URL:" + urlString)
        
        // 98.9000001195652
        let url = URL(string: urlString)
        
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Fotos.self, from: data)
                    completion(.Success(result))
                    
                } catch  {
                    completion(.Error(error.localizedDescription))
                    print("there is error in decoding data\n")
                    print(error.localizedDescription)
                }
                
            }
            
        }
        task.resume()
        
    }
    
    
    class func downloadImage(photoURL: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: photoURL) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}
