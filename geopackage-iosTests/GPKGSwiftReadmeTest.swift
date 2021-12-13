//
//  GPKGSwiftReadmeTest.swift
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

import XCTest

/**
* README example tests
*/
class SFWTSwiftReadmeTest: XCTestCase{
    
    /**
     * README example tests
     */
    func testGeoPackage(){
        GPKGGeoPackageFactory.manager()?.delete(GPKG_TEST_IMPORT_DB_NAME)
        testGeoPackage( NSURL(fileURLWithPath:Bundle(for: GPKGManagerTestCase.self).resourcePath!).appendingPathComponent(GPKG_TEST_IMPORT_DB_FILE_NAME)?.absoluteString,
                        MKMapView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0)))
    }
    
    /**
     * Test write
     *
     * @param geometry
     *            geometry
     * @return text
     */
    func testGeoPackage(_ geoPackageFile: String?, _ mapView: MKMapView){
        
        // let geoPackageFile: String = ...
        // let mapView: MKMapView = ...

        // Get a manager
        let manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.manager()

        // Available databases
        let databases: NSArray = manager.databases() as NSArray

        // Import database
        let imported: Bool = manager.importGeoPackage(fromPath: geoPackageFile)

        // Open database
        let geoPackage: GPKGGeoPackage = manager.open(databases.object(at: 0) as? String)

        // GeoPackage Table DAOs
        let srsDao: GPKGSpatialReferenceSystemDao = geoPackage.spatialReferenceSystemDao()
        let contentsDao: GPKGContentsDao = geoPackage.contentsDao()
        let geometryColumnsDao: GPKGGeometryColumnsDao = geoPackage.geometryColumnsDao()
        let tileMatrixSetDao: GPKGTileMatrixSetDao = geoPackage.tileMatrixSetDao()
        let tileMatrixDao: GPKGTileMatrixDao = geoPackage.tileMatrixDao()
        let schemaExtension : GPKGSchemaExtension = GPKGSchemaExtension.init(geoPackage: geoPackage)
        let dataColumnsDao: GPKGDataColumnsDao = schemaExtension.dataColumnsDao()
        let dataColumnConstraintsDao: GPKGDataColumnConstraintsDao = schemaExtension.dataColumnConstraintsDao()
        let metadataExtension : GPKGMetadataExtension = GPKGMetadataExtension.init(geoPackage: geoPackage)
        let metadataDao: GPKGMetadataDao = metadataExtension.metadataDao()
        let metadataReferenceDao: GPKGMetadataReferenceDao = metadataExtension.metadataReferenceDao()
        let extensionsDao: GPKGExtensionsDao = geoPackage.extensionsDao()

        // Feature and tile tables
        let features: NSArray = geoPackage.featureTables() as NSArray
        let tiles: NSArray = geoPackage.tileTables() as NSArray

        // Query Features
        let featureTable: String = features.object(at: 0) as! String
        let featureDao: GPKGFeatureDao = geoPackage.featureDao(withTableName: featureTable)
        let converter: GPKGMapShapeConverter = GPKGMapShapeConverter(projection: featureDao.projection)
        let featureResults: GPKGResultSet = featureDao.queryForAll()
        do{
            defer{featureResults.close()}
            while(featureResults.moveToNext()){
                let featureRow: GPKGFeatureRow = featureDao.featureRow(featureResults)
                let geometryData: GPKGGeometryData! = featureRow.geometry()
                if(geometryData != nil && !geometryData.empty){
                    let geometry: SFGeometry = geometryData.geometry
                    let shape: GPKGMapShape = converter.toShape(with: geometry)
                    let mapShape = GPKGMapShapeConverter.add(shape, to: mapView)
                    // ...
                }
            }
        }

        // Query Tiles
        let tileTable: String = tiles.object(at: 0) as! String
        let tileDao: GPKGTileDao = geoPackage.tileDao(withTableName: tileTable)
        let tileResults: GPKGResultSet = tileDao.queryForAll()
        do{
            defer{tileResults.close()}
            while(tileResults.moveToNext()){
                let tileRow: GPKGTileRow = tileDao.tileRow(tileResults)
                let tileData: Data = tileRow.tileData()
                let tileImage: UIImage = tileRow.tileDataImage()
                // ...
            }
        }

        // Tile Overlay (GeoPackage or Standard API)
        let tileOverlay: MKTileOverlay = GPKGOverlayFactory.tileOverlay(with: tileDao)
        tileOverlay.canReplaceMapContent = false
        mapView.addOverlay(tileOverlay)

        // Feature Tile Overlay (dynamically draw tiles from features)
        let featureTiles: GPKGFeatureTiles = GPKGFeatureTiles(featureDao: featureDao)
        let featureOverlay = GPKGFeatureOverlay(featureTiles: featureTiles)
        mapView.addOverlay(featureOverlay!)

        let boundingBox: GPKGBoundingBox = GPKGBoundingBox.worldWebMercator()
        let projection: PROJProjection = PROJProjectionFactory.projection(withEpsgInt: PROJ_EPSG_WEB_MERCATOR)

        // URL Tile Generator (generate tiles from a URL)
        let urlTileGenerator: GPKGTileGenerator = GPKGUrlTileGenerator(geoPackage: geoPackage, andTableName: "url_tile_table", andTileUrl: "http://url/{z}/{x}/{y}.png", andMinZoom: 1, andMaxZoom: 2, andBoundingBox:boundingBox, andProjection:projection)
        let urlTileCount: Int32 = urlTileGenerator.generateTiles()

        // Feature Tile Generator (generate tiles from features)
        let featureTileGenerator: GPKGTileGenerator = GPKGFeatureTileGenerator(geoPackage: geoPackage, andTableName: featureTable + "_tiles", andFeatureTiles: featureTiles, andMinZoom: 1, andMaxZoom: 2, andBoundingBox:boundingBox, andProjection:projection)
        let featureTileCount: Int32 = featureTileGenerator.generateTiles()

        // Close database when done
        geoPackage.close()

        // Close manager when done
        manager.close()
        
    }
    
}
