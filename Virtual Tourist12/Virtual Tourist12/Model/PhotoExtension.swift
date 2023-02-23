//
//  PhotoExtension.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 20/02/23.
//


import UIKit
import CoreData

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       let sectionInfo = self.fetchedController.sections![section]
       print("sectionInfo.numberOfObjects\(sectionInfo.numberOfObjects)and sectionInfo: \(self.fetchedController.sections!)")
        return photosDb.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedController.sections?.count ?? 1    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.item < destinationIndexPath.item {
            for i in sourceIndexPath.item+1...destinationIndexPath.item {
                self.fetchedController.object(at: IndexPath(item: i, section: 0)).photoOrder -= 1
            }
            self.fetchedController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.item+1)
        } else {
            for i in (destinationIndexPath.item...sourceIndexPath.item-1).reversed() {
                self.fetchedController.object(at: IndexPath(item: i, section: 0)).photoOrder += 1
                
            }
            self.fetchedController.object(at: sourceIndexPath).photoOrder = Int16(destinationIndexPath.item+1)
        }
        
        //remove and insert in array in case if images are still downloading.
        if self.photoURLs.count != 0 {
            let temp = self.photoURLs[sourceIndexPath.item]
            self.photoURLs.remove(at: sourceIndexPath.item)
            self.photoURLs.insert(temp, at: destinationIndexPath.item)
        }
        
        try? self.dataController.viewContext.save()
        self.setUPFetch()
        
        
    }
    
    
    
    
    // Populate the cells
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Fetch a cell of the appropriate type.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CellCollectionViewCollectionViewCell", for: indexPath) as!  CellCollectionViewCollectionViewCell
         let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()

        do {
            photosDb = try dataController.viewContext.fetch(fetchRequest)
            for photo in photosDb {
                let photo = photo as! Photos
                self.photosArray.append(photo.url ?? "")
            }
        } catch {
            let nerror = error as NSError
            fatalError("DataController error \(nerror.localizedDescription)")
            
            print("adding a photo in the album")
        }
        
        //Downloading the Images from URLs
        DispatchQueue.main.async {
            if  self.photosArray.count != 0 {
                print("AQUI ESTAN EL ARREGLO DE FOTOS, THE PHOTOS ARRAY ARE HERE",self.photosArray.count)
                let url = URL(string: self.photosArray[indexPath.row])
                if(url == nil){
                    return
                }
                    
                cell.cellActivityIndicator.startAnimating()
                
                APIManager.downloadImage(photoURL: url!) { data, error in
                    if error != nil {
                        print("error in downloading data from a photo")
                        
                    } else {
                        
                         try? self.dataController.viewContext.save()
                        let imageData = try? Data(contentsOf: url!)
                        cell.photos.image = UIImage(data: imageData!)
                        cell.cellActivityIndicator.stopAnimating()
                    DispatchQueue.main.async {
                                cell.photos.image = UIImage(data: data!)
                                cell.cellActivityIndicator.stopAnimating()
                            //}
                        }
                    }
                }
                
        

                
            }
        }
        
        return cell
    }
 
    /*func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Fetch a cell of the appropriate type.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CellCollectionViewCollectionViewCell", for: indexPath) as!  CellCollectionViewCollectionViewCell
       if let cellPhotoData = self.fetchedController.object(at: indexPath).imageData {
                 print("adding a photo in the album")
        cell.photo.image = UIImage(data: cellPhotoData)
                  if  let cellPhoto = self.fetchedController.object(at: indexPath).imageData {
                            cell.photo.image = UIImage(data: cellPhoto)
                          } else if  self.photoURLs.count != 0 {
                            if let url = self.photoURLs[indexPath.row] {
                                       cell.cellActivityIndicator.startAnimating()
                                       APIManager.downloadImage(photoURL: url) { data, error in
                                       if error != nil {
                                           print("error in downloading data from a photo")
                                       } else {
                                           if data != nil {
                                               let cellPhoto = self.fetchedController.object(at: indexPath)
                                               cellPhoto.imageData = data
                                               try? self.dataController.viewContext.save()
                                               cell.photo.image = UIImage(data: data!)
                                               cell.cellActivityIndicator.stopAnimating()
                                               }
                                           }
                                       }
                                   }
                               }
        }
    
                                 return cell
                           }*/
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objectToDelete = fetchedController.object(at: indexPath)
         deleteImage(index: indexPath as NSIndexPath)
         collectionView.reloadData()    }
}

extension PhotoAlbumViewController: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("photo:\(indexPaths)")
    }
    
    
}
