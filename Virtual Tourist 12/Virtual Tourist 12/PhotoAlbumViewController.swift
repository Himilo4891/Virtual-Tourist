
import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate,CLLocationManagerDelegate {
    
    

    @IBOutlet weak var photoMapView: MKMapView!
    @IBOutlet weak var collactionView: UICollectionView!
    @IBOutlet weak var CollectionFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var ActivityIndicatorView: UIActivityIndicatorView!
    
    var pin: Pin!
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var FetchedResultsController: NSFetchedResultsController<Pin>!
    var indicator: ActivtyViewIndicator!
    let regionin: Double = 10000
    let locationManager = CLLocationManager()
    
    
    let activ: UIActivityIndicatorView = UIActivityIndicatorView()
    var poto: [NSManagedObject] = []
    var block: [BlockOperation] = []
    private var insertedIndexPaths: [IndexPath]!
    private var deletedIndexPaths: [IndexPath]!
    private var updatedIndexPaths: [IndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        setupFetchedResultsController()
        
        setupLocationManager()
        locationManager.startUpdatingLocation()
        
        photoMapView.delegate
        collactionView.delegate = self
        collactionView.dataSource = self
        
        createMapView()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        photoMapView.addAnnotation(annotation)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collactionView.reloadData()
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        FetchedResultsController = nil
        fetchedResultsController = nil
        
        
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func newCollection(_ sender: UIBarButtonItem) {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        let objects = fetchedResultsController.fetchedObjects
        
        for obj in objects!.reversed() {
            DataController.shared.viewContext.delete(obj)
        }
        
        DataController.shared.saveContext()
        
        ActivityViewIndicator(message: "refreshing")
        
        getphoto(Pin: pin, longitude: pin.longitude, latitude: pin.latitude)
        
        print("new collection button action completed")
        
    }
    
    func ActivityViewIndicator (message: String) {
        
        indicator = ActivtyViewIndicator(inview:self.view,loadingViewColor: UIColor.gray, indicatorColor: UIColor.black, msg: message)
        self.view.addSubview(indicator!)
        
    }
    
    func createMapView() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        photoMapView.addAnnotation(annotation)
        
    }
    

    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        
        return fetchedResultsController.sections?.count ?? 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections[section].numberOfObjects
        
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        ActivityViewIndicator(message: "Deleting")
        
        indicator.start()
        
        deletePhoto(at: indexPath)
        print("delete selected photo")
        
        indicator.stop()
    }

    
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
      
        let numberOfItemsPerRow: Int = 3
        let itemsPerRow = CGFloat(max(numberOfItemsPerRow,1))
        
        let totalSpacing = layout.minimumInteritemSpacing * (itemsPerRow - 1.0)
        
        var newItemSize = layout.itemSize
        
        newItemSize.width = (photoMapView.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right - totalSpacing) / itemsPerRow
        
        if layout.itemSize.height > 0 {
            let itemAspectRatio = layout.itemSize.width / layout.itemSize.height
            newItemSize.height = newItemSize.width / itemAspectRatio
        }
        
        layout.itemSize = newItemSize
        
        collactionView.collectionViewLayout = layout
    }
    
    
    
    func deletePhoto(at indexPath: IndexPath) {
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(photoToDelete)
        try? DataController.shared.viewContext.save()
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch (type) {
            case .insert:
                insertedIndexPaths.append(newIndexPath!)
                print("insert indexPath called")
            case .delete:
                deletedIndexPaths.append(indexPath!)
                print("delete indexPath called")
            case .update:
                updatedIndexPaths.append(indexPath!)
                print("update indexPath called")
            default:
                break
            }
        }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            
            block.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collactionView!.insertSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            block.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collactionView!.reloadSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
        else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            
            block.append(
                BlockOperation(block: { [weak self] in
                    if let this = self {
                        this.collactionView!.deleteSections(IndexSet(integer: sectionIndex))
                    }
                })
            )
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collactionView.reloadData()
        print("controllerDidChangeContent has been called")
    }
    
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        
        
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "nil")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetched could not be executed: \(error.localizedDescription)")
        }
        
    }
    
    fileprivate func setupfetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        FetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: nil)
        
        FetchedResultsController.delegate = self
        
        do {
            try FetchedResultsController.performFetch()
        } catch {
            fatalError("The fetched could not be executed: \(error.localizedDescription)")
        }
        
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let center = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionin, longitudinalMeters: regionin)
        photoMapView.setRegion(region, animated: true)
        
        
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        let photoCells = fetchedResultsController.object(at: indexPath)
        cell.imagephoto.image = UIImage(data: photoCells.image!)
        cell.imagephoto.contentMode = UIView.ContentMode.scaleAspectFill
        cell.backgroundColor = .white
        try? DataController.shared.viewContext.save()
        
        return cell
    }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            var pin = MKPointAnnotation()
            
            let reuseID = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
            
            
            if pinView == nil {
                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                pinView?.canShowCallout = true
                pinView?.tintColor = .red
                pinView?.animatesWhenAdded = true
                pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                pinView?.annotation = annotation
                
            } else {
                
                print("pinView no nil")
            }
            
            print("mapView")
            return pinView
            
        }
        
        
    }





