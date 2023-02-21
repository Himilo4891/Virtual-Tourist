//
//  PhotoAlbumViewController+CollectionView.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 21/02/23.
//

import Foundation
import UIKit

extension PhotoAlbumViewController1: UICollectionViewDelegate, UICollectionViewDataSource{
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flickrPhotos.count
    }
        
    private func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
            
        if flickrPhotos[indexPath.row].imageFile != nil {
            cell.imageView.image = UIImage(data: flickrPhotos[indexPath.row].imageFile!)
        } else {
            cell.imageView.image = UIImage(named: "photo_placeholder")
            DispatchQueue.global().async {
                FlickrClient.downloadImage(imageURL: URL(string: self.photosURL[indexPath.row].imageURL!)!) { (data, error) in
                        if let data = data {
                            cell.imageView.image = UIImage(data: data)
                            self.flickrPhotos[indexPath.row].imageFile = data
                            DataController.shared.saveViewContext()
                            if self.fetchedResultsController.fetchedObjects?.count == self.flickrPhotos.count{
                                self.newCollection.isEnabled = true
                            }
                        }
                    }
                }
            }
            return cell
    }
    
    private func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Select from indexPath which object from CollectionView should be deleted from persistent store
        let objectToDelete = fetchedResultsController.object(at: indexPath)
        flickrPhotos.remove(at: indexPath.row)
      DataController.shared.viewContext.delete(objectToDelete)
      DataController.shared.saveViewContext()
    }
}
