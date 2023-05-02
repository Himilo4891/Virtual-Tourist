//  Client.swift
//  Virtual Tourist 12
//
//  Created by abdiqani on 13/03/23.
//

import Foundation
import CoreData

class Client {
    
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
    
    class func taskforFlickerPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        //Prepare URL Request Object - Why?
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //Set HTTP Request Header - Why? is this neecessary? why do we set HTTPheader field? when is this necessary?
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //Encoding a JSON body from a codable struct
        request.httpBody = try? JSONEncoder().encode(body)
        
        //why do we use this URLsession.shared? what purpose this line of code serve?
        let session = URLSession.shared
        
        //what does this line of code involving task serve, what do those components {data, response, error} serve? why are they always in the same pattern?
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
    
    class func SearchPhoto (longitude: Double, Latitude: Double, _ completion: @escaping ([Images], Error?) -> Void) {
        
        let apiURLAddress = Endpoints.Base.StringValue + Endpoints.SearchPhotos.StringValue + "&api_key=\(PhotoRequest.api_key)" + "&lat=\(Latitude)" + "&lon=\(longitude)" + "&page=3&per_page=30&format=json&nojsoncallback=1"
        
        let searchURL = URL(string:apiURLAddress)!
        
        let searchRequest = PhotoRequest(lat: Latitude, lon: longitude)
        

        taskforFlickerPOSTRequest(url: searchURL, responseType: PhotoResponse.self, body: searchRequest) { response, error in
            
            if error == nil {
                completion((response?.photos.photo)!, nil)
            } else {
                completion([], error)
                print(error!)
            }
        }
    }
    
}
