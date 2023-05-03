//
//  ViewController.swift
//  Virtual Tourist 12
//
//  Created by abdiqani on 13/03/23.
//

import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController {

    @IBOutlet weak var MapView: MKMapView!
    var indicator: ActivtyViewIndicator!
    var dateController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    var annotations = [MKAnnotation]()
    var mapViewIsShift = false
    var selectedAnnotation: MKPointAnnotation?
    
    fileprivate func setUpFetchedResultsController() {

         let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dateController = appDelegate.dataController
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dateController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch cannot be performed: \(error.localizedDescription)")
        }

       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchedResultsController()
        MapView.delegate = self
        

        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        let regionRadius: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        MapView.setRegion(region, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchedResultsController()
        reloadMapView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @IBAction func longPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: MapView)
        let locationCoordinate = MapView.convert(touchLocation, toCoordinateFrom: MapView)
        addPin(coordinate: locationCoordinate)
    }
    
    // MARK: - Add Pin
    func addPin(coordinate: CLLocationCoordinate2D) {
        
        let pin = Pin(context: dateController.viewContext)
        
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.creationDate = Date()
        
        do {
            try dateController.viewContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the TravelLocationsViewController should be for Pin instances")
        }
        
        switch type {
        case .insert:
            MapView.addAnnotation(pin as! MKAnnotation)
        case .delete:
            MapView.removeAnnotation(pin as! MKAnnotation)
        case .update:
            MapView.removeAnnotation(pin as! MKAnnotation)
            MapView.addAnnotation(pin as! MKAnnotation)
        case .move:
            fatalError("How did we move a point? We have a stable sort")
        @unknown default:
            fatalError()
        }
    }
}
extension MapViewController: MKMapViewDelegate {
    
    func reloadMapView() {
        
        if !annotations.isEmpty {
            MapView.removeAnnotations(annotations)
            annotations.removeAll()
        }
        
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins {
                
                let lat = pin.latitude
                let long = pin.longitude
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)
                performUIUpdatesOnMain {
                    self.MapView.addAnnotation(self.annotations as! MKAnnotation)
                }
            }
        }
    }
    
    // CONFIGURE MKAnnotation VIEW
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red
            pinView?.animatesWhenAdded = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let selectedAnnotation = view.annotation
        let selectedAnnotationLat = selectedAnnotation?.coordinate.latitude
        let selectedAnnotationLong = selectedAnnotation?.coordinate.longitude
        var selectedPin: Pin
        
        if let result = fetchedResultsController.fetchedObjects {
            
            for pin in result {
                if pin.latitude == selectedAnnotationLat && pin.longitude == selectedAnnotationLong {
                    selectedPin = pin
                    prepare(pin: selectedPin) { (photoAlbumVC) in
                        self.navigationController?.pushViewController(photoAlbumVC, animated: true)
                    }
                }
            }
        }
    }
    func prepare(pin: Pin, _ completionHandler: @escaping (_ photoAlbumVC: PhotoAlbumViewController) -> Void) {
         let photoAlbumVC = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumViewController
        photoAlbumVC.pin = pin
        photoAlbumVC.dataController = dateController
        completionHandler(photoAlbumVC)
    }
}




