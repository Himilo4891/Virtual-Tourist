
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognizer:)))
        
        gestureRecognizer.minimumPressDuration = 1.5
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        
        mapView.delegate = self
        LocationServices()
        setupFetchedResultsController()
        
        ActivityIndicator(message: "Downloading")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        

    }
    
    func ActivityIndicator (message: String) {
        
        indicator = ActivtyViewIndicator(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: message)
            self.view.addSubview(indicator!)
        
    }
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
    
    
    private func Pinis(latitude: Double, longitude: Double) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", NSNumber(value: latitude), NSNumber(value: longitude))
         var pin: Pin?
         do {
             try pin = fPin(predicate)
         } catch {
             print(error)
         }
         return pin
     }
    
    func fPin(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
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
    
    
    func LocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            LocationAuthorization()
        }
    }
    
    func LocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            
            centerViewUserLocation()
            locationManager.startUpdatingLocation()
            
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)

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
        
        Client.shared.getphoto(Pin: pinView, longitude: pinView.longitude, latitude: pinView.latitude)
        
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
        LocationAuthorization()
        
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
        
        let pinDataUponClick = Pinis(latitude: lat, longitude: long)
        
        PhotoAlbumViewController.pin = pinDataUponClick
        
        self.present(PhotoAlbumViewController, animated: true, completion: nil)
     
    }
    
}

