# GeoPackage iOS

### GeoPackage iOS Lib ####

The [GeoPackage Libraries](http://ngageoint.github.io/GeoPackage/) were developed at the [National Geospatial-Intelligence Agency (NGA)](http://www.nga.mil/) in collaboration with [BIT Systems](http://www.bit-sys.com/). The government has "unlimited rights" and is releasing this software to increase the impact of government investments by providing developers with the opportunity to take things in new directions. The software use, modification, and distribution rights are stipulated within the [MIT license](http://choosealicense.com/licenses/mit/).


### Pull Requests ###
If you'd like to contribute to this project, please make a pull request. We'll review the pull request and discuss the changes. All pull request contributions to this project will be released under the MIT license.

Software source code previously released under an open source license and then modified by NGA staff is considered a "joint work" (see 17 USC § 101); it is partially copyrighted, partially public domain, and as a whole is protected by the copyrights of the non-government authors and must be released according to the terms of the original open source license.

### About ###

[GeoPackage iOS](http://ngageoint.github.io/geopackage-ios/) is a [GeoPackage Library](http://ngageoint.github.io/GeoPackage/) Objective-C SDK implementation of the Open Geospatial Consortium [GeoPackage](http://www.geopackage.org/) [spec](http://www.geopackage.org/spec/).  It is listed as an [OGC GeoPackage Implementation](http://www.geopackage.org/#implementations_nga) by the National Geospatial-Intelligence Agency.

<a href='http://www.opengeospatial.org/resource/products/details/?pid=1627'>
    <img src="https://github.com/ngageoint/GeoPackage/raw/master/docs/images/ogc.gif" height=50>
</a>

The GeoPackage SDK provides the ability to manage GeoPackage files providing read, write, import, export, share, and open support. Open GeoPackage files provide read and write access to features and tiles. Feature support includes Well-Known Binary and iOS Map shape translations. Tile generation supports creation by URL or features. Tile providers supporting GeoPackage format, standard tile API, and feature tile generation.

### Getting Started ###

**IMPORTANT** -
Be sure your Mac has the `autoconf`, `automake`, and `glibtoolize` utilities.  These are required to build
the [proj4-ios](https://cocoapods.org/?q=proj4-ios) dependency.  Without them, `pod install` will fail.  The easiest way to get these is to [`brew install`](https://brew.sh/) them:
```
brew install automake
brew install libtool
```

Include this repository by specifying it in a Podfile using a supported option.

Pull from [CocoaPods](https://cocoapods.org/pods/geopackage-ios):

    pod 'geopackage-ios', '~> 5.0.0'

Pull from GitHub via CocoaPods:

    pod 'geopackage-ios', :git => 'https://github.com/ngageoint/geopackage-ios.git', :branch => 'master'
    pod 'geopackage-ios', :git => 'https://github.com/ngageoint/geopackage-ios.git', :tag => '5.0.0'

Include as local project:

    pod 'geopackage-ios', :path => '../geopackage-ios'

### Usage ###

View the latest [Appledoc](http://ngageoint.github.io/geopackage-ios/docs/api/).

#### Example Apps ####

The following projects demonstrate usage of geopackage-ios in a host app.

##### GeoPackage MapCache #####

The [GeoPackage MapCache](https://github.com/ngageoint/geopackage-mapcache-ios) app provides an extensive standalone example on how to use the SDK.

##### MAGE #####

The [Mobile Awareness GEOINT Environment (MAGE)](https://github.com/ngageoint/mage-ios) app provides mobile situational awareness capabilities. It [uses the SDK](https://github.com/ngageoint/mage-ios/search?q=GeoPackage&type=Code) to provide GeoPackage functionality.

##### DICE #####

The [Disconnected Interactive Content Explorer (DICE)](https://github.com/ngageoint/disconnected-content-explorer-iOS) app allows users to load and display interactive content without a network connection. It [uses the SDK](https://github.com/ngageoint/disconnected-content-explorer-iOS/search?q=GeoPackage&type=Code) to provide GeoPackage functionality on the map and within reports.

#### Objective-C Example ####
```objectivec

// NSString *geoPackageFile = ...;
// MKMapView *mapView = ...;

// Get a manager
GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];

// Available databases
NSArray *databases = [manager databases];

// Import database
BOOL imported = [manager importGeoPackageFromPath:geoPackageFile];

// Open database
GPKGGeoPackage *geoPackage = [manager open:[databases objectAtIndex:0]];

// GeoPackage Table DAOs
GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
GPKGContentsDao *contentsDao =  [geoPackage contentsDao];
GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage geometryColumnsDao];
GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage tileMatrixSetDao];
GPKGTileMatrixDao *tileMatrixDao = [geoPackage tileMatrixDao];
GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
GPKGDataColumnsDao *dataColumnsDao = [schemaExtension dataColumnsDao];
GPKGDataColumnConstraintsDao *dataColumnConstraintsDao = [schemaExtension dataColumnConstraintsDao];
GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
GPKGMetadataReferenceDao *metadataReferenceDao = [metadataExtension metadataReferenceDao];
GPKGExtensionsDao *extensionsDao = [geoPackage extensionsDao];

// Feature and tile tables
NSArray *features = [geoPackage featureTables];
NSArray *tiles = [geoPackage tileTables];

// Query Features
NSString *featureTable = [features objectAtIndex:0];
GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:featureTable];
GPKGMapShapeConverter *converter = [[GPKGMapShapeConverter alloc] initWithProjection:featureDao.projection];
GPKGResultSet *featureResults = [featureDao queryForAll];
@try {
    while([featureResults moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao featureRow:featureResults];
        GPKGGeometryData *geometryData = [featureRow geometry];
        if(geometryData != nil && !geometryData.empty){
            SFGeometry *geometry = geometryData.geometry;
            GPKGMapShape *shape = [converter toShapeWithGeometry:geometry];
            GPKGMapShape *mapShape = [GPKGMapShapeConverter addMapShape:shape toMapView:mapView];
            // ...
        }
    }
}@finally {
    [featureResults close];
}

// Query Tiles
NSString *tileTable = [tiles objectAtIndex:0];
GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:tileTable];
GPKGResultSet *tileResults = [tileDao queryForAll];
@try {
    while([tileResults moveToNext]){
        GPKGTileRow *tileRow = [tileDao tileRow:tileResults];
        NSData *tileData = [tileRow tileData];
        UIImage *tileImage = [tileRow tileDataImage];
        // ...
    }
}@finally {
    [tileResults close];
}

// Tile Overlay (GeoPackage or Standard API)
MKTileOverlay *tileOverlay = [GPKGOverlayFactory tileOverlayWithTileDao:tileDao];
tileOverlay.canReplaceMapContent = false;
[mapView addOverlay:tileOverlay];

// Feature Tile Overlay (dynamically draw tiles from features)
GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao];
GPKGFeatureOverlay *featureOverlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
[mapView addOverlay:featureOverlay];

GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] init];
SFPProjection *projection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];

// URL Tile Generator (generate tiles from a URL)
GPKGTileGenerator *urlTileGenerator = [[GPKGUrlTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:@"url_tile_table" andTileUrl:@"http://url/{z}/{x}/{y}.png" andMinZoom:1 andMaxZoom:2 andBoundingBox:boundingBox andProjection:projection];
int urlTileCount = [urlTileGenerator generateTiles];

// Feature Tile Generator (generate tiles from features)
GPKGTileGenerator *featureTileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"%@_tiles", featureTable] andFeatureTiles:featureTiles andMinZoom:1 andMaxZoom:2 andBoundingBox:boundingBox andProjection:projection];
int featureTileCount = [featureTileGenerator generateTiles];

// Close database when done
[geoPackage close];

// Close manager when done
[manager close];

```

#### Swift Example ####

To use from Swift, import the geopackage-ios bridging header from the Swift project's bridging header

    #import "geopackage-ios-Bridging-Header.h"

```swift

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

let boundingBox: GPKGBoundingBox = GPKGBoundingBox()
let projection: SFPProjection = SFPProjectionFactory.projection(withEpsgInt: PROJ_EPSG_WORLD_GEODETIC_SYSTEM)

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

```

### Build ###

[![Build & Test](https://github.com/ngageoint/geopackage-ios/workflows/Build%20&%20Test/badge.svg)](https://github.com/ngageoint/geopackage-ios/actions?query=workflow%3A%22Build+%26+Test%22)

Build this repository using Xcode and/or CocoaPods:

    pod repo update
    pod install

See the above note about `automake` and `glibtoolize`.

Open geopackage-ios.xcworkspace in Xcode or build from command line:

    xcodebuild -workspace 'geopackage-ios.xcworkspace' -scheme geopackage-ios build

Run tests from Xcode or from command line:

    xcodebuild test -workspace 'geopackage-ios.xcworkspace' -scheme geopackage-ios -destination 'platform=iOS Simulator,name=iPhone 6s'

### Remote Dependencies ###

* [Simple Features WKB](https://github.com/ngageoint/simple-features-wkb-ios) (The MIT License (MIT)) - Simple Features Well Known Binary Lib
* [Simple Features WKT](https://github.com/ngageoint/simple-features-wkt-ios) (The MIT License (MIT)) - Simple Features Well Known Text Lib
* [Simple Features Projection](https://github.com/ngageoint/simple-features-proj-ios) (The MIT License (MIT)) - Simple Features Projection Lib
* [OGC API Features JSON](https://github.com/ngageoint/ogc-api-features-json-ios) (The MIT License (MIT)) - OGC API Features JSON Lib
* [TIFF](https://github.com/ngageoint/tiff-ios) (The MIT License (MIT)) - Tagged Image File Format Lib
