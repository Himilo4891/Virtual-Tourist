////
////  ViewController.swift
////  Virtual Tourist 12
////
////  Created by abdiqani on 13/03/23.
////
//
//import UIKit
//import MapKit
//import CoreLocation
//import CoreData
//class MapViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
//
//    @IBOutlet weak var MapView: MKMapView!
//    var LocationManager = CLLocationManager()
//    var indicator: ActivtyViewIndicator!
//    var dateController: DataController!
//    var fetchedResultsController: NSFetchedResultsController<Pin>!
//    var annotations = [MKAnnotation]()
//    var mapViewIsShift = false
//    var selectedAnnotation: MKPointAnnotation?
//    var  regionins: Double = 10000
//    let geoCoder = CLGeocoder()
//    let places = CLLocation()
//
//
//
//    fileprivate func setUpFetchedResultsController() {
//
//        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//
//        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        dateController = appDelegate.dataController
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dateController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
//
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch cannot be performed: \(error.localizedDescription)")
//        }
//
//
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setUpFetchedResultsController()
//        MapView.delegate = self
//
//        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
//
//        gestureRecognizer.minimumPressDuration = 1.5
//        gestureRecognizer.delegate = self
//        MapView.addGestureRecognizer(gestureRecognizer)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setUpFetchedResultsController()
//        reloadInputViews()
//    }
//
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        fetchedResultsController = nil
//    }
//    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
//
//            let location = gestureRecognizer.location(in: MapView)
//            let coordinate = MapView.convert(location, toCoordinateFrom: MapView)
//
//
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            MapView.addAnnotation(annotation)
//
//            addPin(annotation: annotation)
//
//            findAddress(annotation: annotation) { (String) in
//
//                let pinView = Pin(context: DataController.shared.viewContext)
//
//                pinView.latitude = annotation.coordinate.latitude
//                pinView.longitude = annotation.coordinate.longitude
//                pinView.creationDate = Date()
//
//                try? DataController.shared.viewContext.save()
//                print("findaddress executed")
//                print(pinView.self)
//
//            }
//        }
//        func findAddress(annotation: MKPointAnnotation, completionHandler: @escaping (String) -> Void) {
//
//            let locationforAdress = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//
//            geoCoder.reverseGeocodeLocation(locationforAdress, completionHandler: { (placemarks, error) -> Void in
//
//                if (error) == nil {
//
//                    var placeMark: CLPlacemark!
//                    placeMark = placemarks?[0]
//
//                    let address = "\(placeMark?.country ?? ""),\(placeMark?.subAdministrativeArea ?? ""), \(placeMark?.thoroughfare ?? ""), \(placeMark?.postalCode ?? "")"
//                    annotation.title = address
//
//                    completionHandler(address)
//
//                }
//
//            })
//
//
//        }
//
////        func addPin(annotation: MKPointAnnotation) {
////
////            let pin
////            func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
////                if sender.state != UIGestureRecognizer.State.began { return }
////                let touchLocation = sender.location(in: MapView)
////                let locationCoordinate = MapView.convert(touchLocation, toCoordinateFrom: MapView)
////
////            }
//
//            func addPin(annotation: MKPointAnnotation) {
//
//                let pinView = Pin(context: DataController.shared.viewContext)
//
//
//                pinView.latitude = annotation.coordinate.latitude
//                pinView.longitude = annotation.coordinate.longitude
//                pinView.creationDate = Date()
//
//
//                try? DataController.shared.viewContext.save()
//
//                MapView.addAnnotation(annotation)
//                print(pinView.self)
//
//                addPhotos(Pin: pinView, longitude: pinView.longitude, latitude: pinView.latitude)
//
//            }
//
//            func addPhotos (Pin: Pin, longitude: Double, latitude: Double) {
//
//                self.indicator!.start()
//
//                Client.SearchPhoto(longitude: longitude, Latitude: latitude) { (photo, error) in
//
//                    print("SearchPhoto API Executed")
//
//                    if photo.count == 0 {
//
//                        let alertVC = UIAlertController(title: "No Images", message: "No Image to display", preferredStyle: .alert)
//                        self.present(alertVC, animated: true, completion: nil)
//
//                    } else {
//
//                        for images in photo {
//
//                            let photoS = Photo(context: DataController.shared.viewContext)
//
//
//                            let ImageURLAddress = URL(string:"https://farm\(images.farm).staticflickr.com/\(images.server)/\(images.id)_\(images.secret).jpg")!
//
//                            photoS.pin = Pin
//                            photoS.creationDate = Pin.creationDate
//
//                            if let data = try? Data(contentsOf: ImageURLAddress) {
//                                print("activity indicator called")
//
//                                photoS.image = data
//                                print(photoS.image!)
//                                self.indicator!.stop()
//                            }
//
//                            print(photo)
//                            try? DataController.shared.viewContext.save()
//                        }
//                    }
//                }
//            }
//        }
//        // MARK: - Add Pin
//        func addingPin(latitude: Double, longitude: Double) -> Pin? {
//            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(value: latitude), NSNumber(value: longitude))
//            var pin: Pin?
//            do {
//                try pin = Pinins(predicate)
//            } catch {
//                print(error)
//            }
//            return pin
//        }
//
//        func Pinins(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
//            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
//            fr.predicate = predicate
//            if let sorting = sorting {
//                fr.sortDescriptors = [sorting]
//            }
//            guard let pin = (try DataController.shared.viewContext.fetch(fr) as! [Pin]).first else {
//                return nil
//            }
//            return pin
//        }
//
//
//        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//            guard let pin = anObject as? Pin else {
//                preconditionFailure("All changes observed in the TravelLocationsViewController should be for Pin instances")
//            }
//
//            switch type {
//            case .insert:
//                MapView.addAnnotation(pin as! MKAnnotation)
//            case .delete:
//                MapView.removeAnnotation(pin as! MKAnnotation)
//            case .update:
//                MapView.removeAnnotation(pin as! MKAnnotation)
//                MapView.addAnnotation(pin as! MKAnnotation)
//            case .move:
//                fatalError("How did we move a point? We have a stable sort")
//            @unknown default:
//                fatalError()
//            }
//        }
//
//
//        func reloadMapView() {
//
//            if !annotations.isEmpty {
//                MapView.removeAnnotations(annotations)
//                annotations.removeAll()
//            }
//
//            if let pins = fetchedResultsController.fetchedObjects {
//                for pin in pins {
//
//                    let lat = pin.latitude
//                    let long = pin.longitude
//                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//                    let annotation = MKPointAnnotation()
//                    annotation.coordinate = coordinate
//                    annotations.append(annotation)
//                    performUIUpdatesOnMain {
//                        self.MapView.addAnnotation(self.annotations as! MKAnnotation)
//                    }
//                }
//            }
//        }
//
//        // CONFIGURE MKAnnotation VIEW
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            let reuseId = "pin"
//
//            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
//
//            if pinView == nil {
//                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//                pinView?.canShowCallout = true
//                pinView?.tintColor = .red
//                pinView?.animatesWhenAdded = true
//                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//
//            } else {
//                pinView?.annotation = annotation
//            }
//            return pinView
//        }
//
//        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//
//
//            let selectedAnnotation = view.annotation
//            let selectedAnnotationLat = selectedAnnotation?.coordinate.latitude
//            let selectedAnnotationLong = selectedAnnotation?.coordinate.longitude
//            var selectedPin: Pin
//
//            if let result = fetchedResultsController.fetchedObjects {
//
//                for pin in result {
//                    if pin.latitude == selectedAnnotationLat && pin.longitude == selectedAnnotationLong {
//                        selectedPin = pin
//                        prepare(pin: selectedPin) { (photoAlbumVC) in
//                            self.navigationController?.pushViewController(photoAlbumVC, animated: true)
//                        }
//                    }
//                }
//            }
//        }
//        func prepare(pin: Pin, _ completionHandler: @escaping (_ photoAlbumVC: PhotoAlbumViewController) -> Void) {
//            let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumViewController
//            photoAlbumVC.pin = pin
//            photoAlbumVC.dataController = dateController
//            completionHandler(photoAlbumVC)
//        }
//
//
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let location = locations.last else { return }
//
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionins, longitudinalMeters: regionins)
//            MapView.setRegion(region, animated: true)
//
//
//        }
//        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//            checkLocationAuthorization()
//        }
//        func LocationServices() {
//            if CLLocationManager.locationServicesEnabled() {
//                setupLocationManager()
//                checkLocationAuthorization()
//
//            } else {
//            }
//            func ActivityIndicator (message: String) {
//
//                indicator = ActivtyViewIndicator(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: message)
//                self.view.addSubview(indicator!)
//
//            }
//
//            func setupLocationManager() {
//                locationManager.delegate = self
//                locationManager.desiredAccuracy = kCLLocationAccuracyBest
//
//            }
//
//            func centerViewUserLocation() {
//                if let location = locationManager.location?.coordinate {
//                    let region = MKCoordinateRegion.init(center:location, latitudinalMeters: regionins, longitudinalMeters: regionins)
//                    MapView.setRegion(region, animated: true)
//
//
//                }
//            }
//
//
//            func checkLocationServices() {
//                if CLLocationManager.locationServicesEnabled() {
//                    setupLocationManager()
//                    checkLocationAuthorization()
//
//                } else {
//                }
//            }
//
//            func checkLocationAuthorization() {
//                switch CLLocationManager.authorizationStatus() {
//
//                case .authorizedWhenInUse:
//                    centerViewUserLocation()
//                    locationManager.startUpdatingLocation()
//
//                    break
//                case .denied:
//                    break
//                case .notDetermined:
//                    locationManager.requestWhenInUseAuthorization()
//                    break
//                case .restricted:
//
//                    break
//                case .authorizedAlways:
//                    break
//
//                @unknown default:
//                    fatalError()
//                    break
//                }
//            }
//
//        }
//    }
//}
//
//  MapViewController.swift
//  Virtual-Tourist
//
//  Created by Do Hyung Joo on 14/6/20.
//  Copyright © 2020 Do Hyung Joo. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreData


final class MapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var indicator: ActivtyViewIndicator!
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    let regioninMeters: Double = 10000
    let places = CLLocation()
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetched could not be executed: \(error.localizedDescription)")
        }
    }
    
    
    private func loadPin(latitude: Double, longitude: Double) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(value: latitude), NSNumber(value: longitude))
         var pin: Pin?
         do {
             try pin = fetchPin(predicate)
         } catch {
             print(error)
         }
         return pin
     }
    
    func fetchPin(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
          let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
          fr.predicate = predicate
          if let sorting = sorting {
              fr.sortDescriptors = [sorting]
          }
        guard let pin = (try DataController.shared.viewContext.fetch(fr) as! [Pin]).first else {
              return nil
          }
          return pin
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        
        gestureRecognizer.minimumPressDuration = 1.5
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        mapView.delegate = self
        checkLocationServices()
        setupFetchedResultsController()
        
        changeActivityIndicatorMessage(message: "Downloading")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        

    }
    
    func changeActivityIndicatorMessage (message: String) {
        
        indicator = ActivtyViewIndicator(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: message)
            self.view.addSubview(indicator!)
        
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func centerViewUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center:location, latitudinalMeters: regioninMeters, longitudinalMeters: regioninMeters)
            mapView.setRegion(region, animated: true)
            
            
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
            //show alert to user to inform they have to turn location manager on
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            //make changes to fix the initial location for the app here
            //mapView.showsUserLocation = true
            centerViewUserLocation()
            locationManager.startUpdatingLocation()
            
            break
        case .denied:
            // show alert instructing them how to turn on permission
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            //show alert instruction them how to turn on permission
            break
        case .authorizedAlways:
            break
            
        @unknown default:
            fatalError()
            break
        }
    }
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizer.State.ended {
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        

        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

            
        //Add annotation to Pin Data model
        addPin(annotation: annotation)
            
        findAddress(annotation: annotation) { (String) in
               
            let pinView = Pin(context: DataController.shared.viewContext)
                            
            
            pinView.latitude = annotation.coordinate.latitude
            pinView.longitude = annotation.coordinate.longitude
            pinView.creationDate = Date()
                            
                    try? DataController.shared.viewContext.save()
                    print("findaddress executed")
                    print(pinView.self)
            
            }
        }
        
    }
    

    func findAddress(annotation: MKPointAnnotation, completionHandler: @escaping (String) -> Void) {
        
        let locationforAdress = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(locationforAdress, completionHandler: { (placemarks, error) -> Void in
            
                if (error) == nil {
                        
                        // Place details
                        var placeMark: CLPlacemark!
                        placeMark = placemarks?[0]
                        
                        let address = "\(placeMark?.country ?? ""),\(placeMark?.subAdministrativeArea ?? ""), \(placeMark?.thoroughfare ?? ""), \(placeMark?.postalCode ?? "")"
                        annotation.title = address
                
                completionHandler(address)
                    
            }
            
        })
        
        
    }
    
    func addPin(annotation: MKPointAnnotation) {
            
        let pinView = Pin(context: DataController.shared.viewContext)
        
        pinView.latitude = annotation.coordinate.latitude
        pinView.longitude = annotation.coordinate.longitude
        pinView.creationDate = Date()
        
        
        try? DataController.shared.viewContext.save()
        
        mapView.addAnnotation(annotation)
        print(pinView.self)
        
        getphoto(Pin: pinView, longitude: pinView.longitude, latitude: pinView.latitude)
        
    }
    
    func getphoto (Pin: Pin, longitude: Double, latitude: Double) {
        
        self.indicator!.start()
        
        Client.SearchPhoto(longitude: longitude, Latitude: latitude) { (photo, error) in
            
            print("SearchPhoto API Executed")
            
            if photo.count == 0 {
                
                let alertVC = UIAlertController(title: "No Images", message: "No Image to display", preferredStyle: .alert)
                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                for images in photo {
                
                let photoView = Photo(context: DataController.shared.viewContext)
                
                
                    
                let ImageURLAddress = URL(string:"https://farm\(images.farm).staticflickr.com/\(images.server)/\(images.id)_\(images.secret).jpg")!

                    photoView.pin = Pin
                    photoView.creationDate = Pin.creationDate
 
                if let data = try? Data(contentsOf: ImageURLAddress) {
                            print("activity indicator called")
                            
                    photoView.image = data
                        print(photoView.image!)
                        self.indicator!.stop()
                    }

                print(photoView)
                try? DataController.shared.viewContext.save()
                }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regioninMeters, longitudinalMeters: regioninMeters)
        mapView.setRegion(region, animated: true)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pin = MKPointAnnotation()
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView

        if pinView == nil {
            
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.tintColor = .red
            pinView!.isDraggable = true
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            
        } else {
            
            pinView!.annotation = annotation
        }
        
        mapView.addAnnotation(pin)
        
        return pinView

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        if newState == MKAnnotationView.DragState.ending || newState ==  MKAnnotationView.DragState.canceling {
            
            view.dragState = MKAnnotationView.DragState.none
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = view.annotation!.coordinate
            mapView.removeAnnotation(view.annotation!)
            
            findAddress(annotation: newAnnotation) { (String) in
                
                let pinView = Pin(context: DataController.shared.viewContext)
                                
                       
                        pinView.latitude = newAnnotation.coordinate.latitude
                        pinView.longitude = newAnnotation.coordinate.longitude
                        pinView.creationDate = Date()
                                
                        try? DataController.shared.viewContext.save()
                        mapView.addAnnotation(newAnnotation)
                        print(pinView.self)
                
                self.getphoto(Pin: pinView, longitude: pinView.longitude, latitude: pinView.latitude)
                
            }
            

        }
        
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        switch (newState) {
        case .starting:
            view.dragState = .dragging
            print("dragging started")
        case .ending, .canceling:
            view.dragState = .none
            print("dragstate ending started")
        default: break
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        //TBD to segue to PhotoAlbumView Controller
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let PhotoAlbumViewController = storyBoard.instantiateViewController(withIdentifier: "PhotoAlbumView") as! PhotoAlbumViewController
        
        
        let annotation = mapView.selectedAnnotations[0]
         
        let lat = annotation.coordinate.latitude
        let long = annotation.coordinate.longitude
        
        let pinDataUponClick = loadPin(latitude: lat, longitude: long)
        
        PhotoAlbumViewController.pin = pinDataUponClick
        
        self.present(PhotoAlbumViewController, animated: true, completion: nil)
     
    }
    
}

