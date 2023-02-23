//
//  PhotoAlbumViewController.swift
//  Virtual Tourist12
//
//  Created by abdiqani on 20/02/23.
//
import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate{
    
    var photoURLs: [URL?] = []
  
    
    var pins: [NSManagedObject] = []
    
    var latitude : CLLocationDegrees?
    var longitude : CLLocationDegrees?
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var PhotoCollectionViewController: UICollectionView!
    @IBOutlet weak var newCollectionbutton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var CollectionFlowLayout: UICollectionViewFlowLayout!
        let collectionCellID = "CollectionViewCell"
        
        var photosArray = [String]()
        var photosDb: [NSManagedObject] = []
        
        var dataController: DataController!
        var blockOperation = BlockOperation()
        var pin: Pin!
        let activ: UIActivityIndicatorView = UIActivityIndicatorView()
        var fetchedController: NSFetchedResultsController<Photos>!
        var photo: [NSManagedObject] = []
        
        fileprivate func setUpMap() {
            //Set MapView's delegate and properties
            self.mapview.delegate = self
            self.mapview.isZoomEnabled = false
            self.mapview.isScrollEnabled = false
            print("pin's lat\(self.latitude!) and pin's long: \(self.longitude!)")
            let clocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
             MapLocation(clocation, mapView: self.mapview)
            setUpPin()
        }
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        
        
        let CellID = "CellCollectionViewCollectionViewCell"
        fileprivate func setUpGesture() {
            //Setting Gesture
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
            longPressGesture.minimumPressDuration = 0.5
            longPressGesture.delegate = self
            longPressGesture.delaysTouchesBegan = true
            PhotoCollectionViewController.addGestureRecognizer(longPressGesture)
        }
        fileprivate func setUpCollectionView() {
            //Setting Collection View
            PhotoCollectionViewController.delegate = self
            PhotoCollectionViewController.dataSource = self
            CollectionFlowLayout.scrollDirection = .vertical
            self.PhotoCollectionViewController.collectionViewLayout = self.CollectionFlowLayout
            setUpPin()
            setUPFetch()
            //deleteArrray(entity: "Photos")
        }
        override func viewDidLoad() {
            super.viewDidLoad()
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
            setUpMap()
            setUpGesture()
            setUpCollectionView()
            
            if(checkExistsPhotos(latitud: self.latitude!, longitude: self.longitude!)){
                setUPFetch()
            }else{
                fetchUrl()
            }
             
             PhotoCollectionViewController.reloadData()
        }
        
        func checkExistsPhotos(latitud: Double, longitude: Double ) -> Bool{
            let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [self.latitude!,self.longitude!])
            fetchRequest.predicate = predicate
            
            do{
                photosDb = try dataController.viewContext.fetch(fetchRequest)
                
                print("COUNT:" + String(photosDb.count))
                
                if photosDb.count == 0 {
                    return false
                }
            }catch let error{
                print(error)
            }
            
            return true
        }
       
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
            switch(gesture.state) {
            case .began:
                
                guard let selectedIndexPath = PhotoCollectionViewController.indexPathForItem(at: gesture.location(in: PhotoCollectionViewController)) else {
                    break
                }
                PhotoCollectionViewController.beginInteractiveMovementForItem(at: selectedIndexPath)
            case .changed:
                PhotoCollectionViewController.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            case .ended:
                PhotoCollectionViewController.endInteractiveMovement()
            default:
                PhotoCollectionViewController.cancelInteractiveMovement()
            }
            
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            fetchedController = nil
       
        }
        @IBAction func NewCollection(_ sender: UIButton){
            
            if let result = fetchedController.fetchedObjects {
                         for photo in result {
                             dataController.viewContext.delete(photo)
                         }
                 dataController.saveViewContext()
                }
                DispatchQueue.main.async {
                    if self.dataController.viewContext.deletedObjects.count == 0{
                        do{
                            self.fetchUrl()
                    
                        }
                    
                        }else{
                        self.deleteArrray(entity: "Photos")
                        self.dataController.saveViewContext()
                    }
                   
                }
            }
       
    func deleteArrray(entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            for object in result{
                guard let objectData = object as? NSManagedObject else{
                    continue}
                dataController.viewContext.delete(objectData)
            }
        }catch let error{
            print("borr6ar toda la data\(entity) error :",error)
        }
    }
             func setUpNewCollectionButton(isEnable: Bool) {
                 newCollectionbutton.isEnabled = isEnable
             }
        func deleteImage(index: NSIndexPath) {
            let imageToDelete = fetchedController.object(at: index as IndexPath)
            dataController.viewContext.delete(imageToDelete)
            try? dataController.viewContext.save()
        }
      
         func setUPFetch()  {
             let fetchRequest: NSFetchRequest<Photos> = Photos.fetchRequest()
             let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [self.latitude!, self.longitude!])
            fetchRequest.predicate = predicate
                      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "photoOrder", ascending: true)]

             fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                    fetchedController.delegate = self
                    do {
                          try fetchedController.performFetch()
                      } catch {
                          fatalError("The fetch could not be performed: \(error.localizedDescription)")
                      }
                      actInd.stopAnimating()
            
                  }
            
        fileprivate func fetchUrl(){
            activ.startAnimating()
            
            //newCollectionbutton.isEnabled = false
            APIManager.shared.getPhotos(lat: self.latitude!, lon: self.longitude!) { (result) in
                
                switch result {
                case .Success(let Fotos):
                    if Fotos.photos.photo.count == 0 {
                        
                        let alertVC = UIAlertController(title: "No Images", message: "No Image to display", preferredStyle: .alert)
                        self.present(alertVC, animated: true, completion: nil)
                        
                    } else {
                        DispatchQueue.main.async {
                            
                    for element in Fotos.photos.photo {
                        
                        print("***TOTAL DE FOTOS***", Fotos.photos.photo.count)
                        
                        let url =  "https://farm\(element.farm).static.flickr.com/\(element.server)/\(element.id)_\(element.secret).jpg"
                        let photos = Photo(from: self.dataController.viewContext as! Decoder)
                        photos.pin = self.pin
                        photos.latitude = self.latitude!
                        photos.longitude = self.longitude!
                        try? self.dataController.viewContext.save()
                        self.PhotoCollectionViewController.reloadData()
                        photos.url = url
                        self.photosDb.append(photos)
                        print("aqui están las fotos de la DB", self.photosDb.count)
                        self.PhotoCollectionViewController.reloadData()
                       
                        }
                            self.setUPFetch()
                    }
                        
                    }
                    
                case .Error(let error):
                    print(error)
                }
            }
            
            
            func handleDownload(data: Data?, error: Error?) {
                if error != nil {
                    print("error in downloading data from a photo")
                } else {
                    if data != nil {
                        try? dataController.viewContext.save()
                        print("one photo is saved")
                        activ.stopAnimating()
                        
                    }
                }
                
            }
        }//Zoom in to display student's choosen location prior to finishing
        private func MapLocation(_ location: CLLocation, mapView: MKMapView) {
            
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
            
        }
        
        
        private func setUpPin() {
          
        }
        
        
    }


    extension PhotoAlbumViewController: UIGestureRecognizerDelegate {
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
            return true
        }
    }
