import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let _manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .satellite
        mapView.delegate = self
        let geoPackagePath:String = Bundle.main.path(forResource:"StLouis", ofType: "gpkg")!
        _manager.importGeoPackage(fromPath: geoPackagePath, andOverride: true)
        let geoPackage: GPKGGeoPackage = _manager.open("StLouis")
        
        // Query Tiles - Do this first so that they tiles display on the bottom
        let tiles: NSArray = geoPackage.tileTables() as NSArray;
        let tileTable: String = tiles.object(at: 0) as! String;
        let tileDao: GPKGTileDao = geoPackage.tileDao(withTableName: tileTable);
        
        // Tile Overlay
        let tileOverlay: MKTileOverlay = GPKGOverlayFactory.tileOverlay(with: tileDao);
        tileOverlay.canReplaceMapContent = false;
        
        // Add the tile overlay to the map on the main thread, otherwise the tiles wont show up.
        DispatchQueue.main.async { [unowned self] in
            self.mapView.addOverlay(tileOverlay);
        }
        
        
        // Query Features
        let features: NSArray = geoPackage.featureTables() as NSArray;
        for case let featureTable as String in features {
            let featureDao: GPKGFeatureDao = geoPackage.featureDao(withTableName: featureTable);
            let converter: GPKGMapShapeConverter = GPKGMapShapeConverter(projection: featureDao.projection);
            let featureResults: GPKGResultSet = featureDao.queryForAll();
            
            var icon = UIImage(named: "poi")
            if (featureTable == "Pizza") {
                icon = UIImage(named: "pizza")
            }
            
            while(featureResults.moveToNext()){
                let featureRow: GPKGFeatureRow = featureDao.featureRow(featureResults);
                let geometryData: GPKGGeometryData = featureRow.geometry();
                let shape: GPKGMapShape = converter.toShape(with: geometryData.geometry);
                
                // Add the feature to the map on the main thread, otherwise it wont show up.
                DispatchQueue.main.async { [unowned self] in
                    let mapShape = GPKGMapShapeConverter.add(shape, to: self.mapView);
                    
                    if (mapShape?.shapeType == GPKG_MST_POINT) {
                        let mapPoint:GPKGMapPoint = mapShape?.shape as! GPKGMapPoint
                        mapPoint.title = featureRow.valueString(withColumnName: "name")
                        mapPoint.options.image = icon
                    }
                }
            }
            
            featureResults.close();
        }
        
        
        // Find the data and set the bounds
        let boundingBox: GPKGBoundingBox = tileDao.boundingBox(withZoomLevel: 12)
        let transform: SFPProjectionTransform = SFPProjectionTransform.init(fromEpsg: PROJ_EPSG_WEB_MERCATOR, andToEpsg: PROJ_EPSG_WORLD_GEODETIC_SYSTEM)
        let transformedBoundingBox: GPKGBoundingBox = boundingBox.transform(transform)
        let region:MKCoordinateRegion = MKCoordinateRegion.init(center: transformedBoundingBox.center(), span: transformedBoundingBox.span())
        mapView.setRegion(region, animated: true)
        
        // Close the database and manager when you are done
        geoPackage.close();
        _manager.close();
    }


    // Override the map delegate method to hand back the correct type of renderer for our map data.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer: MKOverlayRenderer = MKOverlayRenderer.init()
        if (overlay is MKPolygon) { // Style the polygons for the park vectors
            let polygonRenderer = MKPolygonRenderer.init(polygon: overlay as! MKPolygon)
            polygonRenderer.fillColor = UIColor.init(red: 0.0, green: 1.0, blue: 0.6, alpha: 0.5)
            polygonRenderer.lineWidth = 1
            polygonRenderer.strokeColor = UIColor.black
            renderer = polygonRenderer
        } else if (overlay is MKTileOverlay) {
            renderer = MKTileOverlayRenderer.init(tileOverlay: overlay as! MKTileOverlay)
        }
        return renderer
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if (annotation.isKind(of: GPKGMapPoint.classForCoder())) {
            let mapPoint = annotation as! GPKGMapPoint
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.image = mapPoint.options.image
            annotationView?.centerOffset = mapPoint.options.imageCenterOffset
        }
        
        return annotationView
    }
}
