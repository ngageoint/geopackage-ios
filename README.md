# GeoPackage iOS

### GeoPackage iOS Lib ####

The [GeoPackage Libraries](http://ngageoint.github.io/GeoPackage/) were developed at the [National Geospatial-Intelligence Agency (NGA)](http://www.nga.mil/) in collaboration with [BIT Systems](http://www.bit-sys.com/). The government has "unlimited rights" and is releasing this software to increase the impact of government investments by providing developers with the opportunity to take things in new directions. The software use, modification, and distribution rights are stipulated within the [MIT license](http://choosealicense.com/licenses/mit/).


### Pull Requests ###
If you'd like to contribute to this project, please make a pull request. We'll review the pull request and discuss the changes. All pull request contributions to this project will be released under the MIT license.

Software source code previously released under an open source license and then modified by NGA staff is considered a "joint work" (see 17 USC § 101); it is partially copyrighted, partially public domain, and as a whole is protected by the copyrights of the non-government authors and must be released according to the terms of the original open source license.

### About ###

[GeoPackage iOS](http://ngageoint.github.io/geopackage-ios/) is a [GeoPackage Library](http://ngageoint.github.io/GeoPackage/) Objective-C SDK implementation of the Open Geospatial Consortium [GeoPackage](http://www.geopackage.org/) [spec](http://www.geopackage.org/spec/).  It is listed as an [OGC GeoPackage Implementation](http://www.geopackage.org/#implementations_nga) by the National Geospatial-Intelligence Agency.

<a href='http://www.opengeospatial.org/resource/products/details/?pid=1552'>
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

    pod 'geopackage-ios', '~> 3.2.0'

Pull from GitHub via CocoaPods:

    pod 'geopackage-ios', :git => 'https://github.com/ngageoint/geopackage-ios.git', :branch => 'master'
    pod 'geopackage-ios', :git => 'https://github.com/ngageoint/geopackage-ios.git', :tag => '3.2.0'

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

// NSString * geoPackageFile = ...;
// MKMapView *mapView = ...;

// Get a manager
GPKGGeoPackageManager * manager = [GPKGGeoPackageFactory getManager];

// Available databases
NSArray * databases = [manager databases];

// Import database
BOOL imported = [manager importGeoPackageFromPath:geoPackageFile];

// Open database
GPKGGeoPackage * geoPackage = [manager open:[databases objectAtIndex:0]];

// GeoPackage Table DAOs
GPKGSpatialReferenceSystemDao * srsDao = [geoPackage getSpatialReferenceSystemDao];
GPKGContentsDao * contentsDao =  [geoPackage getContentsDao];
GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
GPKGTileMatrixSetDao * tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
GPKGTileMatrixDao * tileMatrixDao = [geoPackage getTileMatrixDao];
GPKGDataColumnsDao *dataColumnsDao = [geoPackage getDataColumnsDao];
GPKGDataColumnConstraintsDao * dataColumnConstraintsDao = [geoPackage getDataColumnConstraintsDao];
GPKGMetadataDao * metadataDao = [geoPackage getMetadataDao];
GPKGMetadataReferenceDao * metadataReferenceDao = [geoPackage getMetadataReferenceDao];
GPKGExtensionsDao * extensionsDao = [geoPackage getExtensionsDao];

// Feature and tile tables
NSArray * features = [geoPackage getFeatureTables];
NSArray * tiles = [geoPackage getTileTables];

// Query Features
NSString * featureTable = [features objectAtIndex:0];
GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:featureDao.projection];
GPKGResultSet * featureResults = [featureDao queryForAll];
@try {
    while([featureResults moveToNext]){
        GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResults];
        GPKGGeometryData * geometryData = [featureRow getGeometry];
        SFGeometry * geometry = geometryData.geometry;
        GPKGMapShape * shape = [converter toShapeWithGeometry:geometry];
        GPKGMapShape * mapShape = [GPKGMapShapeConverter addMapShape:shape toMapView:mapView];
        // ...
    }
}@finally {
    [featureResults close];
}

// Query Tiles
NSString * tileTable = [tiles objectAtIndex:0];
GPKGTileDao * tileDao = [geoPackage getTileDaoWithTableName:tileTable];
GPKGResultSet * tileResults = [tileDao queryForAll];
@try {
    while([tileResults moveToNext]){
        GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
        NSData * tileBytes = [tileRow getTileData];
        UIImage * tileImage = [tileRow getTileDataImage];
        // ...
    }
}@finally {
    [tileResults close];
}

// Tile Overlay (GeoPackage or Standard API)
MKTileOverlay * tileOverlay = [GPKGOverlayFactory tileOverlayWithTileDao:tileDao];
tileOverlay.canReplaceMapContent = false;
[mapView addOverlay:tileOverlay];

// Feature Tile Overlay (dynamically draw tiles from features)
GPKGFeatureTiles * featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao];
GPKGFeatureOverlay * featureOverlay = [[GPKGFeatureOverlay alloc] initWithFeatureTiles:featureTiles];
[mapView addOverlay:featureOverlay];

GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] init];
SFPProjection * projection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];

// URL Tile Generator (generate tiles from a URL)
GPKGTileGenerator * urlTileGenerator = [[GPKGUrlTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:@"url_tile_table" andTileUrl:@"http://url/{z}/{x}/{y}.png" andMinZoom:2 andMaxZoom:7 andBoundingBox:boundingBox andProjection:projection];
int urlTileCount = [urlTileGenerator generateTiles];

// Feature Tile Generator (generate tiles from features)
GPKGTileGenerator * featureTileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"%@_tiles", featureTable] andFeatureTiles:featureTiles andMinZoom:10 andMaxZoom:15 andBoundingBox:boundingBox andProjection:projection];
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

// let geoPackageFile: String = ...;
// let mapView: MKMapView = ...;

// Get a manager
let manager: GPKGGeoPackageManager = GPKGGeoPackageFactory.getManager();

// Available databases
let databases: NSArray = manager.databases() as NSArray;

// Import database
let imported: Bool = manager.importGeoPackage(fromPath: geoPackageFile);

// Open database
let geoPackage: GPKGGeoPackage = manager.open(databases.object(at: 0) as! String);

// GeoPackage Table DAOs
let srsDao: GPKGSpatialReferenceSystemDao = geoPackage.getSpatialReferenceSystemDao();
let contentsDao: GPKGContentsDao = geoPackage.getContentsDao();
let geometryColumnsDao: GPKGGeometryColumnsDao = geoPackage.getGeometryColumnsDao();
let tileMatrixSetDao: GPKGTileMatrixSetDao = geoPackage.getTileMatrixSetDao();
let tileMatrixDao: GPKGTileMatrixDao = geoPackage.getTileMatrixDao();
let dataColumnsDao: GPKGDataColumnsDao = geoPackage.getDataColumnsDao();
let dataColumnConstraintsDao: GPKGDataColumnConstraintsDao = geoPackage.getDataColumnConstraintsDao();
let metadataDao: GPKGMetadataDao = geoPackage.getMetadataDao();
let metadataReferenceDao: GPKGMetadataReferenceDao = geoPackage.getMetadataReferenceDao();
let extensionsDao: GPKGExtensionsDao = geoPackage.getExtensionsDao();

// Feature and tile tables
let features: NSArray = geoPackage.getFeatureTables() as NSArray;
let tiles: NSArray = geoPackage.getTileTables() as NSArray;

// Query Features
let featureTable: String = features.object(at: 0) as! String;
let featureDao: GPKGFeatureDao = geoPackage.getFeatureDao(withTableName: featureTable);
let converter: GPKGMapShapeConverter = GPKGMapShapeConverter(projection: featureDao.projection);
let featureResults: GPKGResultSet = featureDao.queryForAll();
while(featureResults.moveToNext()){
    let featureRow: GPKGFeatureRow = featureDao.getFeatureRow(featureResults);
    let geometryData: GPKGGeometryData = featureRow.getGeometry();
    let geometry: SFGeometry = geometryData.geometry;
    let shape: GPKGMapShape = converter.toShape(with: geometry);
    let mapShape = GPKGMapShapeConverter.add(shape, to: mapView);
    // ...
}
featureResults.close();

// Query Tiles
let tileTable: String = tiles.object(at: 0) as! String;
let tileDao: GPKGTileDao = geoPackage.getTileDao(withTableName: tileTable);
let tileResults: GPKGResultSet = tileDao.queryForAll();
while(tileResults.moveToNext()){
    let tileRow: GPKGTileRow = tileDao.getTileRow(tileResults);
    let tileBytes: Data = tileRow.getTileData();
    let tileImage: UIImage = tileRow.getTileDataImage();
    // ...
}
tileResults.close();

// Tile Overlay (GeoPackage or Standard API)
let tileOverlay: MKTileOverlay = GPKGOverlayFactory.getTileOverlay(with: tileDao);
tileOverlay.canReplaceMapContent = false;
mapView.add(tileOverlay);

// Feature Tile Overlay (dynamically draw tiles from features)
let featureTiles: GPKGFeatureTiles = GPKGFeatureTiles(featureDao: featureDao);
let featureOverlay = GPKGFeatureOverlay(featureTiles: featureTiles);
mapView.add(featureOverlay!);

var boundingBox: GPKGBoundingBox = GPKGBoundingBox();
boundingBox = GPKGTileBoundingBoxUtils.boundWgs84BoundingBox(withWebMercatorLimits: boundingBox);
boundingBox = SFPProjectionTransform.init(fromEpsg: PROJ_EPSG_WORLD_GEODETIC_SYSTEM, andToEpsg: PROJ_EPSG_WEB_MERCATOR).transform(with: boundingBox);

// URL Tile Generator (generate tiles from a URL)
let urlTileGenerator: GPKGTileGenerator = GPKGUrlTileGenerator(geoPackage: geoPackage, andTableName: "url_tile_table", andTileUrl: "http://url/{z}/{x}/{y}.png", andMinZoom: 2, andMaxZoom: 7, andBoundingBox:boundingBox, andProjection:SFPProjectionFactory.projectionWithEpsg(PROJ_EPSG_WEB_MERCATOR));
let urlTileCount: Int32 = urlTileGenerator.generateTiles();

// Feature Tile Generator (generate tiles from features)
let featureTileGenerator: GPKGTileGenerator = GPKGFeatureTileGenerator(geoPackage: geoPackage, andTableName: featureTable + "_tiles", andFeatureTiles: featureTiles, andMinZoom: 10, andMaxZoom: 15, andBoundingBox:boundingBox, andProjection:SFPProjectionFactory.projectionWithEpsg(PROJ_EPSG_WEB_MERCATOR));
let featureTileCount: Int32 = featureTileGenerator.generateTiles();

// Close database when done
geoPackage.close();

// Close manager when done
manager.close();
```

### Developing ###

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
* [Simple Features Projection](https://github.com/ngageoint/simple-features-proj-ios) (The MIT License (MIT)) - Simple Features Projection Lib
* [OGC API Features JSON](https://github.com/ngageoint/ogc-api-features-json-ios) (The MIT License (MIT)) - OGC API Features JSON Lib
* [TIFF](https://github.com/ngageoint/tiff-ios) (The MIT License (MIT)) - Tagged Image File Format Lib
