////
////  PhotoAlbumViewController.swift
////  Virtual Tourist 12
////
////  Created by abdiqani on 22/03/23.
////
//
//import Foundation
//import UIKit
//import MapKit
//import CoreData
//
//class photoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//    var pin: Pin!
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//    @IBOutlet weak var MapView: MKMapView!
//    @IBOutlet weak var ImageCollaction: UIImageView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var newCollectionButton: UIButton!
//    @IBOutlet weak var noImagesLabel: UILabel!
//
//
//    enum CollectionViewConstants {
//        static let cellsCount: Int = 21
//    }
//    enum ViewControllerConstants {
//        static let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
//    }
//
//    var dataController: DataController!
//    var annotation: MKAnnotation?
//    //    var flickrImages = [FlickrImage]()
//    var photoCount: Int = 0
//    var fetchedResultsController: NSFetchedResultsController<Photo>!
//    let cellId = "cellId"
//    var annotations = [MKAnnotation]()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set the title of the view controller to the location name of the annotation
//        title = annotation?.title ?? "Unknown Location"
//
//        // Set the delegate and data source of the collection view to self
//        collectionView.delegate = self
//        collectionView.dataSource = self
//
//        // Disable the new collection button while images are being downloaded
//        newCollectionButton.isEnabled = false
//
//        setUpCollectionViewFlowLayout()
//
//
//
//
//        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellId)
//
//        // Download Flickr images associated with the latitude and longitude of the annotation
//        //        FlickrAPI.getImagesForLocation(latitude: annotation?.coordinate.latitude ?? 0, longitude: annotation?.coordinate.longitude ?? 0) { result in
//        //            switch result {
//        //            case .success(let flickrImages):
//        //                self.flickrImages = flickrImages
//        DispatchQueue.main.async {
//            self.collectionView.reloadData()
//            self.newCollectionButton.isEnabled = true
//            //                    self.noImagesLabel.isHidden = !flickrImages.isEmpty
//        }
//        //            case .failure(let error):
//        //                print("Error downloading Flickr images: \(error.localizedDescription)")
//        DispatchQueue.main.async {
//            self.noImagesLabel.isHidden = false
//        }
//    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        collectionView.reloadData()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        // Removes fetchedResultsController when view disappears to unsubscribe to notifications for changes in the dataController's view context
//        fetchedResultsController = nil
//    }
//    // MARK: UICollectionViewDataSource
//
//    fileprivate func setUpFetchedResultsController() {
//
//        // 3a. Create Fetch Request
//        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
//
//        // 3b. Filter to right pin
//        if let pin = pin {
//            let predicate = NSPredicate(format: "pin == %@", pin)
//            fetchRequest.predicate = predicate
//        }
//
//        // 3b. Configure the Fetch Request with Sort Rules
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
//
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        // 3c. Instantiate the fetchResultsController using fetchRequest
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "cellPhotos")
//
//        // 3d. Perform Fetch to Load Data
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            // Fatal Error is Thrown if Fetch Fails
//            fatalError("The fetch cannot be performed: \(error.localizedDescription)")
//        }
//
//        func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            if self.photoCount > 0 {
//                DispatchQueue.main.async {
//                    self.noImagesLabel.isHidden = true
//                }
//                return self.photoCount
//            } else {
//                DispatchQueue.main.async {
//                    self.noImagesLabel.isHidden = false
//                }
//                return self.photoCount
//            }
//        }
//
//        fileprivate func downloadPhotos() {
//            var downloadCount: Int = 0
//
//            while downloadCount < CollectionViewConstants.cellsCount {
//                addPhoto()
//                downloadCount += 1
//            }
//
//        }
//
//
//        func bottomButtonPressed(_ sender: Any) {
//
//            if newCollectionButton.titleLabel?.text == "Remove Selected Images" {
//                deleteImages { (success) in
//                    if success {
//                        self.newCollectionButton.setTitle("New Collection", for: .normal)
//                    }
//                }
//            }
//
//            if newCollectionButton.titleLabel?.text == "New Collection" {
//
//                downloadPhotos()
//                if fetchedResultsController.fetchedObjects?.count == CollectionViewConstants.cellsCount {
//                    ViewControllerConstants.alert.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
//
//        func deleteImages(completionHandler: @escaping(_ success: Bool) -> Void) {
//
//            // UUID of selected items
//            var uuidArray: [String] = []
//
//            // Get all selected objects in collectionView
//            if let indexPathForSelectedItems = collectionView.in {
//
//                for indexPath in indexPathForSelectedItems {
//
//                    // Get image to delete
//                    let imageToDelete = fetchedResultsController.object(at: indexPath)
//
//                    // Get UUID of imageToDelete
//                    if let uuidToDelete = imageToDelete.uuid {
//                        uuidArray.append(uuidToDelete)
//                    }
//                }
//
//                for uuid in uuidArray {
//
//                    if let imagesToDelete = fetchedResultsController.fetchedObjects {
//                        for imageToDelete in imagesToDelete {
//                            if imageToDelete.uuid == uuid {
//                                dataController.viewContext.delete(imageToDelete)
//
//                                do {
//                                    try dataController.viewContext.save()
//                                    completionHandler(true)
//                                } catch {
//                                    debugPrint("Cannot delete photo!")
//                                    completionHandler(false)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//
//        func deleteAllImages() {
//
//            collectionView.isScrollEnabled = false
//
//            for cell in collectionView.visibleCells {
//                if let cell = cell as? CollectionViewCell {
//                    cell.colorOverlay.backgroundColor = UIColor.rgb(red: 55, green: 54, blue: 56, alpha: 0.85)
//                    cell.loader.startAnimating()
//                }
//            }
//
//            if let imagesToDelete = fetchedResultsController.fetchedObjects {
//                for imageToDelete in imagesToDelete {
//                    dataController.viewContext.delete(imageToDelete)
//                    do {
//                        try dataController.viewContext.save()
//                    } catch {
//                        debugPrint("Cannot delete image!")
//                    }
//                }
//                collectionView.isScrollEnabled = true
//            }
//        }
//    }
//}
//    extension PhotoAlbumViewController: MKMapViewDelegate {
//
//        func reloadMapView() {
//
//            if !annotations.isEmpty {
//                MapView.removeAnnotations(annotations)
//                annotations.removeAll()
//            }
//
//            // 1. Retrieve Location Data from passed pin
//            let lat = pin.latitude
//            let long = pin.longitude
//
//            // 2. Configure the MKPointAnnotation
//            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//
//            // 3. Add the Annotation
//            annotations.append(annotation)
//
//            // 4. Adjust the region to the pin's coordinates
//            let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
//
//            // 4. DISPLAY THE ANNOTATIONS
//            performUIUpdatesOnMain {
//                self.MapView.addAnnotations(self.annotations)
//                self.MapView.region = region
//            }
//
//        }
//
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//            return fetchedResultsController.sections?[section].numberOfObjects ?? CollectionViewConstants.cellsCount
//
//        }
//        func addPhoto() {
//
//            // Try to put this guard statement back
//            guard (fetchedResultsController.fetchedObjects?.isEmpty)! else {
//                return
//            }
//
//            FlickrClient.sharedInstance().downloadPhoto(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude, dataController: dataController, pin: pin) { (success, error) in
//                if success {
//                    debugPrint("Success!")
//                }
//            }
//        }
//
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CollectionViewCell
//
//
//        //GUARD TO BE USED AND NEEDED
//        // This is guard away the unneccesary redownloading of photos when the
//        // persistent store already exists
//            guard !(self.fetchedResultsController.fetchedObjects?.isEmpty)! else {
//                return cell
//            }
//
//            // Download Photo Block
//
//            let aPhoto = self.fetchedResultsController.object(at: indexPath)
//
//            if aPhoto.imageDate == nil {
//                cell.checkmark.isHidden = true
//                cell.colorOverlay.backgroundColor = UIColor.rgb(red: 55, green: 54, blue: 56, alpha: 1)
//                cell.loader.startAnimating()
//
//                DispatchQueue.global(qos: .background).async {
//                    self.downloadImageData(imageURL: aPhoto.imageURL, completionHandlerForDownloadImageData: { (success, imageData, error) in
//                        if success {
//                            debugPrint("Success!")
//
//                            performUIUpdatesOnMain {
//                                if let imageData = imageData {
//                                    aPhoto.imageData = imageData
//
//                                    do {
//                                        try self.dataController.viewContext.save()
//                                    } catch {
//                                        debugPrint("Cannot save photo!")
//                                    }
//                                    let image = UIImage(data: imageData)
//                                    cell.imageView.image = image
//                                    cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//                                    self.updateSelectUI(cell: cell)
//                                    cell.loader.stopAnimating()
//                                }
//                            }
//                        }
//                    })
//                }
//            }
//
//            if aPhoto.imageData != nil {
//
//                performUIUpdatesOnMain {
//                    if let imageData = aPhoto.imageData {
//                        let image = UIImage(data: imageData)
//                        cell.imageView.image = image
//                        cell.colorOverlay.backgroundColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//                        self.updateSelectUI(cell: cell)
//                        cell.loader.stopAnimating()
//                    }
//                }
//            }
//        return cell
//    }
//
//        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//            let cell = collectionView.cellForItem(at: indexPath) as! ImageCollectionViewCell
//            let selectedOverlayColor = UIColor.rgb(red: 242, green: 242, blue: 242, alpha: 0.85)
//
//            updateSelectUI(cell: cell)
//            updateButtonLabel()
//
//        }
//        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
//            return true
//        }
//
//        func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//            return true
//        }
//
//        //Set size of cells relative to the view size
//        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//            let width = ((view.frame.width) - (3 * itemSpacing))/3
//            let height = width
//
//            return CGSize(width: width, height: height)
//        }
//        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//            let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
//            let deselectedOverlayColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//
//            updateSelectUI(cell: cell)
//            updateButtonLabel()
//
//
//        }
//        func updateButtonLabel() {
//
//            if (collectionView.indexPathsForSelectedItems?.isEmpty)! {
//                newCollectionButton.setTitle("New Collection", for: .normal)
//            } else {
//                newCollectionButton.setTitle("Remove Selected Images", for: .normal)
//            }
//        }}
//
//        fileprivate func setUpCollectionViewFlowLayout() {
//            // Flow Layout
//            let layout = UICollectionViewFlowLayout()
//            let space: CGFloat = 3.0
//            let dimension = (view.frame.width - (2 * space)) / 3.0
//
//            layout.itemSize = CGSize(width: 125, height: 125)
//            layout.minimumInteritemSpacing = space
//            layout.minimumLineSpacing = space
//            layout.itemSize = CGSize(width: dimension, height: dimension)
//            collectionView.collectionViewLayout = layout
//
//
//        }
//    }
//    extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
//
//        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//            switch type {
//            case .insert:
//                collectionView.insertItems(at: [newIndexPath!])
//            case .delete:
//                collectionView.deleteItems(at: [indexPath!])
//            case .update:
//                collectionView.reloadItems(at: [newIndexPath!])
//
//                break
//            default:
//                break
//            }
//        }
//    }
//
//    extension PhotoAlbumViewController {
//
//        func updateSelectUI(cell: CollectionViewCell) {
//
//            let selectedOverlayColor = UIColor.rgb(red: 242, green: 242, blue: 242, alpha: 0.85)
//            let deselectedOverlayColor = UIColor.rgb(red: 255, green: 255, blue: 255, alpha: 0)
//
//            if cell.isSelected {
//                cell.colorOverlay.backgroundColor = selectedOverlayColor
//                cell.checkmark.isHidden = false
//            } else {
//                cell.colorOverlay.backgroundColor = deselectedOverlayColor
//                cell.checkmark.isHidden = true
//            }
//        }
//
//        func downloadImageData(imageURL: URL?, completionHandlerForDownloadImageData: @escaping(_ success: Bool, _ imageData: Data?, _ error: String?) -> Void) {
//            if let imageURL = imageURL, let imageData = try? Data(contentsOf: imageURL) {
//                completionHandlerForDownloadImageData(true, imageData, nil)
//            } else {
//                completionHandlerForDownloadImageData(false, nil, "Cannot download image!")
//            }
//        }
//
//    }
//
