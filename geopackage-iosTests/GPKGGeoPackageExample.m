//
//  GPKGGeoPackageExample.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 1/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGGeoPackageExample.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeoPackage.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGIOUtils.h"
#import "GPKGProjectionConstants.h"
#import "WKBPoint.h"
#import "WKBLineString.h"
#import "WKBPolygon.h"
#import "WKBGeometryEnvelopeBuilder.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGFeatureTiles.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"
#import "GPKGFeatureTileGenerator.h"
#import "GPKGGeometryExtensions.h"
#import "WKBCircularString.h"
#import "WKBCompoundCurve.h"
#import "WKBMultiLineString.h"
#import "WKBMultiPolygon.h"
#import "GPKGWebPExtension.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGCoverageDataPng.h"
#import "GPKGCoverageDataTiff.h"

@implementation GPKGGeoPackageExample

static NSString *GEOPACKAGE_NAME = @"example";

static BOOL FEATURES = YES;
static BOOL TILES = YES;
static BOOL ATTRIBUTES = YES;
static BOOL SCHEMA = YES;
static BOOL NON_LINEAR_GEOMETRY_TYPES = YES;
static BOOL RTREE_SPATIAL_INDEX = NO;
static BOOL WEBP = YES;
static BOOL CRS_WKT = YES;
static BOOL METADATA = YES;
static BOOL COVERAGE_DATA = YES;
static BOOL GEOMETRY_INDEX = YES;
static BOOL FEATURE_TILE_LINK = YES;

static NSString *ID_COLUMN = @"id";
static NSString *GEOMETRY_COLUMN = @"geometry";
static NSString *TEXT_COLUMN = @"text";
static NSString *REAL_COLUMN = @"real";
static NSString *BOOLEAN_COLUMN = @"boolean";
static NSString *BLOB_COLUMN = @"blob";
static NSString *INTEGER_COLUMN = @"integer";
static NSString *TEXT_LIMITED_COLUMN = @"text_limited";
static NSString *BLOB_LIMITED_COLUMN = @"blob_limited";
static NSString *DATE_COLUMN = @"date";
static NSString *DATETIME_COLUMN = @"datetime";

-(void) testExample{
    
    NSLog(@"Creating: %@", GEOPACKAGE_NAME);
    GPKGGeoPackage *geoPackage = [GPKGGeoPackageExample createGeoPackage];
    
    NSLog(@"CRS WKT Extension: %s", CRS_WKT ? "Yes" : "No");
    if (CRS_WKT) {
        [GPKGGeoPackageExample createCrsWktExtensionWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Features: %s", FEATURES ? "Yes" : "No");
    if (FEATURES) {
        
        [GPKGGeoPackageExample createFeaturesWithGeoPackage:geoPackage];
        
        NSLog(@"Schema Extension: %s", SCHEMA ? "Yes" : "No");
        if (SCHEMA) {
            [GPKGGeoPackageExample createSchemaExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"Geometry Index Extension: %s", GEOMETRY_INDEX ? "Yes" : "No");
        if (GEOMETRY_INDEX) {
            [GPKGGeoPackageExample createGeometryIndexExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"Feature Tile Link Extension: %s", FEATURE_TILE_LINK ? "Yes" : "No");
        if (FEATURE_TILE_LINK) {
            [GPKGGeoPackageExample createFeatureTileLinkExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"Non-Linear Geometry Types Extension: %s", NON_LINEAR_GEOMETRY_TYPES ? "Yes" : "No");
        if (NON_LINEAR_GEOMETRY_TYPES) {
            [GPKGGeoPackageExample createNonLinearGeometryTypesExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"RTree Spatial Index Extension: %s", RTREE_SPATIAL_INDEX ? "Yes" : "No");
        if (RTREE_SPATIAL_INDEX) {
            [GPKGGeoPackageExample createRTreeSpatialIndexExtensionWithGeoPackage:geoPackage];
        }
        
    } else {
        NSLog(@"Schema Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Geometry Index Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Feature Tile Link Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Non-Linear Geometry Types Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"RTree Spatial Index Extension: %s", FEATURES ? "Yes" : "No");
    }
    
    NSLog(@"Tiles: %s", TILES ? "Yes" : "No");
    if (TILES) {
        
        [GPKGGeoPackageExample createTilesWithGeoPackage:geoPackage];
        
        NSLog(@"WebP Extension: %s", WEBP ? "Yes" : "No");
        if (WEBP) {
            [GPKGGeoPackageExample createWebPExtensionWithGeoPackage:geoPackage];
        }
        
    } else {
        NSLog(@"WebP Extension: %s", TILES ? "Yes" : "No");
    }
    
    NSLog(@"Attributes: %s", ATTRIBUTES ? "Yes" : "No");
    if (ATTRIBUTES) {
        [GPKGGeoPackageExample createAttributesWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Metadata: %s", METADATA ? "Yes" : "No");
    if (METADATA) {
        [GPKGGeoPackageExample createMetadataExtensionWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Coverage Data: %s", COVERAGE_DATA ? "Yes" : "No");
    if (COVERAGE_DATA) {
        [GPKGGeoPackageExample createCoverageDataExtensionWithGeoPackage:geoPackage];
    }
    
    [geoPackage close];
    [GPKGGeoPackageExample exportGeoPackage];
}

+(void) exportGeoPackage{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    
    NSString *exportDirectory = [GPKGIOUtils documentsDirectory];
    
    NSString * exportedFile = [[exportDirectory stringByAppendingPathComponent:GEOPACKAGE_NAME] stringByAppendingPathExtension:GPKG_GEOPACKAGE_EXTENSION];
    [GPKGIOUtils deleteFile:exportedFile];
    
    [manager exportGeoPackage:GEOPACKAGE_NAME toDirectory:exportDirectory];
    
    NSLog(@"Created: %@", exportedFile);
}

+(GPKGGeoPackage *) createGeoPackage{
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    
    [manager delete:GEOPACKAGE_NAME];
    
    [manager create:GEOPACKAGE_NAME];
    
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    if(geoPackage == nil){
        [NSException raise:@"GeoPackage Creation" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

+(void) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem *srs = [srsDao getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    [geoPackage createGeometryColumnsTable];
    
    WKBPoint *point1 = [[WKBPoint alloc] initWithXValue:-104.801918 andYValue:39.720014];
    NSString *point1Name = @"BIT Systems";
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"point1" andType:WKB_POINT andGeometry:point1 andName:point1Name];
    
    WKBPoint *point2 = [[WKBPoint alloc] initWithXValue:-77.196736 andYValue:38.753370];
    NSString *point2Name = @"NGA";
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"point2" andType:WKB_POINT andGeometry:point2 andName:point2Name];
    
    WKBLineString *line1 = [[WKBLineString alloc] init];
    NSString *line1Name = @"East Lockheed Drive";
    [line1 addPoint:[[WKBPoint alloc] initWithXValue:-104.800614 andYValue:39.720721]];
    [line1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802174 andYValue:39.720726]];
    [line1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802584 andYValue:39.720660]];
    [line1 addPoint:[[WKBPoint alloc] initWithXValue:-104.803088 andYValue:39.720477]];
    [line1 addPoint:[[WKBPoint alloc] initWithXValue:-104.803474 andYValue:39.720209]];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"line1" andType:WKB_LINESTRING andGeometry:line1 andName:line1Name];
    
    WKBLineString *line2 = [[WKBLineString alloc] init];
    NSString *line2Name = @"NGA";
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.196650 andYValue:38.756501]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.196414 andYValue:38.755979]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195518 andYValue:38.755208]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195303 andYValue:38.755272]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195351 andYValue:38.755459]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195863 andYValue:38.755697]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.196328 andYValue:38.756069]];
    [line2 addPoint:[[WKBPoint alloc] initWithXValue:-77.196568 andYValue:38.756526]];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"line2" andType:WKB_LINESTRING andGeometry:line2 andName:line2Name];
    
    WKBPolygon *polygon1 = [[WKBPolygon alloc] init];
    NSString *polygon1Name = @"BIT Systems";
    WKBLineString *ring1 = [[WKBLineString alloc] init];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802246 andYValue:39.720343]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802246 andYValue:39.719753]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802183 andYValue:39.719754]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802184 andYValue:39.719719]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802138 andYValue:39.719694]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802097 andYValue:39.719691]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802096 andYValue:39.719648]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801646 andYValue:39.719648]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801644 andYValue:39.719722]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801550 andYValue:39.719723]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801549 andYValue:39.720207]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801648 andYValue:39.720207]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.801648 andYValue:39.720341]];
    [ring1 addPoint:[[WKBPoint alloc] initWithXValue:-104.802246 andYValue:39.720343]];
    [polygon1 addRing:ring1];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"polygon1" andType:WKB_POLYGON andGeometry:polygon1 andName:polygon1Name];
    
    WKBPolygon *polygon2 = [[WKBPolygon alloc] init];
    NSString *polygon2Name = @"NGA Visitor Center";
    WKBLineString *ring2 = [[WKBLineString alloc] init];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195299 andYValue:38.755159]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195203 andYValue:38.755080]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195410 andYValue:38.754930]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195350 andYValue:38.754884]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195228 andYValue:38.754966]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195135 andYValue:38.754889]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195048 andYValue:38.754956]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.194986 andYValue:38.754906]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.194897 andYValue:38.754976]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.194953 andYValue:38.755025]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.194763 andYValue:38.755173]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.194827 andYValue:38.755224]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195012 andYValue:38.755082]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195041 andYValue:38.755104]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195028 andYValue:38.755116]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195090 andYValue:38.755167]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195106 andYValue:38.755154]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195205 andYValue:38.755233]];
    [ring2 addPoint:[[WKBPoint alloc] initWithXValue:-77.195299 andYValue:38.755159]];
    [polygon2 addRing:ring2];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"polygon2" andType:WKB_POLYGON andGeometry:polygon2 andName:polygon2Name];
    
    NSMutableArray<WKBGeometry *> *geometries1 = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *geometries1Names = [[NSMutableArray alloc] init];
    [geometries1 addObject:point1];
    [geometries1Names addObject:point1Name];
    [geometries1 addObject:line1];
    [geometries1Names addObject:line1Name];
    [geometries1 addObject:polygon1];
    [geometries1Names addObject:polygon1Name];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"geometry1" andType:WKB_GEOMETRY andGeometries:geometries1 andNames:geometries1Names];
    
    NSMutableArray<WKBGeometry *> *geometries2 = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *geometries2Names = [[NSMutableArray alloc] init];
    [geometries2 addObject:point2];
    [geometries2Names addObject:point2Name];
    [geometries2 addObject:line2];
    [geometries2Names addObject:line2Name];
    [geometries2 addObject:polygon2];
    [geometries2Names addObject:polygon2Name];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"geometry2" andType:WKB_GEOMETRY andGeometries:geometries2 andNames:geometries2Names];
    
}

+(void) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs andTableName: (NSString *) tableName andType: (enum WKBGeometryType) type andGeometry: (WKBGeometry *) geometry andName: (NSString *) name{
    
    NSMutableArray<WKBGeometry *> *geometries = [[NSMutableArray alloc] init];
    [geometries addObject:geometry];
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];
    [names addObject:name];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:tableName andType:type andGeometries:geometries andNames:names];
}

+(void) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs andTableName: (NSString *) tableName andType: (enum WKBGeometryType) type andGeometries: (NSArray<WKBGeometry *> *) geometries andNames: (NSArray<NSString *> *) names{

    WKBGeometryEnvelope *envelope = nil;
    for(WKBGeometry *geometry in geometries){
        if(envelope == nil){
            envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
        }else{
            [WKBGeometryEnvelopeBuilder buildEnvelope:envelope andGeometry:geometry];
        }
    }
    
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    
    GPKGContents *contents = [[GPKGContents alloc] init];
    [contents setTableName:tableName];
    [contents setContentsDataType:GPKG_CDT_FEATURES];
    [contents setIdentifier:tableName];
    [contents setTheDescription:[NSString stringWithFormat:@"example: %@", tableName]];
    [contents setMinX:envelope.minX];
    [contents setMinY:envelope.minY];
    [contents setMaxX:envelope.maxX];
    [contents setMaxY:envelope.maxY];
    [contents setSrs:srs];
    
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    int columnNumber = 0;
    [columns addObject:[GPKGFeatureColumn createPrimaryKeyColumnWithIndex:columnNumber++ andName:ID_COLUMN]];
    [columns addObject:[GPKGFeatureColumn createGeometryColumnWithIndex:columnNumber++ andName:GEOMETRY_COLUMN andGeometryType:type andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:TEXT_COLUMN andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:REAL_COLUMN andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BOOLEAN_COLUMN andDataType:GPKG_DT_BOOLEAN andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BLOB_COLUMN andDataType:GPKG_DT_BLOB andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:INTEGER_COLUMN andDataType:GPKG_DT_INTEGER andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:TEXT_LIMITED_COLUMN andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BLOB_LIMITED_COLUMN andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:DATE_COLUMN andDataType:GPKG_DT_DATE andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:DATETIME_COLUMN andDataType:GPKG_DT_DATETIME andNotNull:NO andDefaultValue:nil]];

    GPKGFeatureTable *table = [[GPKGFeatureTable alloc] initWithTable:tableName andColumns:columns];
    [geoPackage createFeatureTable:table];
    
    [contentsDao create:contents];
    
    GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setContents:contents];
    [geometryColumns setColumnName:GEOMETRY_COLUMN];
    [geometryColumns setGeometryType:type];
    [geometryColumns setSrs:srs];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumnsDao create:geometryColumns];
    
    GPKGFeatureDao *dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
    
    for (int i = 0; i < geometries.count; i++) {
        
        WKBGeometry *geometry = [geometries objectAtIndex:i];
        NSString *name = nil;
        if(names != nil){
            name = [names objectAtIndex:i];
        }else{
            name = [[NSProcessInfo processInfo] globallyUniqueString];
        }

        GPKGFeatureRow *newRow = [dao newRow];
        
        GPKGGeometryData *geometryData = [[GPKGGeometryData alloc] initWithSrsId:geometryColumns.srsId];
        [geometryData setGeometry:geometry];
        [newRow setGeometry:geometryData];
        
        [newRow setValueWithColumnName:TEXT_COLUMN andValue:name];
        [newRow setValueWithColumnName:REAL_COLUMN andValue:[[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDoubleLessThan:5000.0]]];
        [newRow setValueWithColumnName:BOOLEAN_COLUMN andValue:[NSNumber numberWithBool:([GPKGTestUtils randomDouble] < .5 ? false : true)]];
        [newRow setValueWithColumnName:BLOB_COLUMN andValue:[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding]];
        [newRow setValueWithColumnName:INTEGER_COLUMN andValue:[NSNumber numberWithInt:[GPKGTestUtils randomIntLessThan:500]]];
        [newRow setValueWithColumnName:TEXT_LIMITED_COLUMN andValue:[[NSProcessInfo processInfo] globallyUniqueString]];
        [newRow setValueWithColumnName:BLOB_LIMITED_COLUMN andValue:[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding]];
        [newRow setValueWithColumnName:DATE_COLUMN andValue:[GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:[NSDate date] andType:GPKG_DT_DATE]]];
        [newRow setValueWithColumnName:DATETIME_COLUMN andValue:[NSDate date]];
        
        [dao create:newRow];
        
    }
    
}

+(void) createTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    [geoPackage createTileMatrixSetTable];
    [geoPackage createTileMatrixTable];
    
    GPKGBoundingBox *bitsBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-11667347.997449303 andMinLatitudeDouble:4824705.2253603265 andMaxLongitudeDouble:-11666125.00499674 andMaxLatitudeDouble:4825928.217812888];
    [self createTilesWithGeoPackage:geoPackage andName:@"bit_systems" andBoundingBox:bitsBoundingBox andMinZoom:15 andMaxZoom:17 andExtension:@"png"];
    
    GPKGBoundingBox *ngaBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-8593967.964158937 andMinLatitudeDouble:4685284.085768163 andMaxLongitudeDouble:-8592744.971706374 andMaxLatitudeDouble:4687730.070673289];
    [self createTilesWithGeoPackage:geoPackage andName:@"nga" andBoundingBox:ngaBoundingBox andMinZoom:15 andMaxZoom:16 andExtension:@"png"];
    
}

+(void) createTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage andName: (NSString *) name andBoundingBox: (GPKGBoundingBox *) boundingBox andMinZoom: (int) minZoomLevel andMaxZoom: (int) maxZoomLevel andExtension: (NSString *) extension{

    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = [srsDao getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGTileGrid *totalTileGrid = [GPKGTileBoundingBoxUtils getTileGridWithWebMercatorBoundingBox:boundingBox andZoom:minZoomLevel];
    GPKGBoundingBox *totalBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithTileGrid:totalTileGrid andZoom:minZoomLevel];
    
    GPKGContentsDao *contentsDao = [geoPackage getContentsDao];
    
    GPKGContents *contents = [[GPKGContents alloc] init];
    [contents setTableName:name];
    [contents setContentsDataType:GPKG_CDT_TILES];
    [contents setIdentifier:name];
    [contents setTheDescription:name];
    [contents setMinX:totalBoundingBox.minLongitude];
    [contents setMinY:totalBoundingBox.minLatitude];
    [contents setMaxX:totalBoundingBox.maxLongitude];
    [contents setMaxY:totalBoundingBox.maxLatitude];
    [contents setSrs:srs];
    
    GPKGTileTable *tileTable = [GPKGTestUtils buildTileTableWithTableName:contents.tableName];
    [geoPackage createTileTable:tileTable];
    
    [contentsDao create:contents];
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    
    GPKGTileMatrixSet *tileMatrixSet = [[GPKGTileMatrixSet alloc] init];
    [tileMatrixSet setContents:contents];
    [tileMatrixSet setSrs:srs];
    [tileMatrixSet setMinX:contents.minX];
    [tileMatrixSet setMinY:contents.minY];
    [tileMatrixSet setMaxX:contents.maxX];
    [tileMatrixSet setMaxY:contents.maxY];
    [tileMatrixSetDao create:tileMatrixSet];
    
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
    
    NSString *resourcePath  = [[NSBundle bundleForClass:[GPKGGeoPackageExample class]] resourcePath];
    
    GPKGTileGrid *tileGrid = totalTileGrid;
    
    for (int zoom = minZoomLevel; zoom <= maxZoomLevel; zoom++) {
        
        NSString *zoomPath = [NSString stringWithFormat:@"%@/%d_", resourcePath, zoom];
        
        NSNumber *tileWidth = nil;
        NSNumber *tileHeight = nil;
        
        GPKGTileDao *dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        for (int x = tileGrid.minX; x <= tileGrid.maxX; x++) {
            
            NSString *xPath = [NSString stringWithFormat:@"%@%d_", zoomPath, x];
            
            for (int y = tileGrid.minY; y <= tileGrid.maxY; y++) {
                
                NSString *yPath = [NSString stringWithFormat:@"%@%d.%@", xPath, y, extension];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:yPath]){
                    
                    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:yPath];
                    
                    if (tileWidth == nil || tileHeight == nil) {
                        UIImage * tileImage = [UIImage imageWithContentsOfFile:yPath];
                        if (tileImage != nil) {
                            tileHeight = [NSNumber numberWithInt:tileImage.size.height];
                            tileWidth = [NSNumber numberWithInt:tileImage.size.width];
                        }
                    }
                    
                    GPKGTileRow *newRow = [dao newRow];
                    
                    [newRow setZoomLevel:zoom];
                    [newRow setTileColumn:x - tileGrid.minX];
                    [newRow setTileRow:y - tileGrid.minY];
                    [newRow setTileData:tileData];
                    
                    [dao create:newRow];
                }

            }
        }
        
        if (tileWidth == nil) {
            tileWidth = [NSNumber numberWithInt:256];
        }
        if (tileHeight == nil) {
            tileHeight = [NSNumber numberWithInt:256];
        }
        
        long matrixWidth = tileGrid.maxX - tileGrid.minX + 1;
        long matrixHeight = tileGrid.maxY - tileGrid.minY + 1;
        double pixelXSize = ([tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue]) / (matrixWidth * [tileWidth intValue]);
        double pixelYSize = ([tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue]) / (matrixHeight * [tileHeight intValue]);
        
        GPKGTileMatrix *tileMatrix = [[GPKGTileMatrix alloc] init];
        [tileMatrix setContents:contents];
        [tileMatrix setZoomLevel:[NSNumber numberWithInt:zoom]];
        [tileMatrix setMatrixWidth:[NSNumber numberWithLong:matrixWidth]];
        [tileMatrix setMatrixHeight:[NSNumber numberWithLong:matrixHeight]];
        [tileMatrix setTileWidth:tileWidth];
        [tileMatrix setTileHeight:tileHeight];
        [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:pixelXSize]];
        [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:pixelYSize]];
        [tileMatrixDao create:tileMatrix];
        
        tileGrid = [GPKGTileBoundingBoxUtils tileGrid:tileGrid zoomIncrease:1];
        
    }
    
}

+(void) createAttributesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    int columnNumber = 1;
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:TEXT_COLUMN andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:REAL_COLUMN andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BOOLEAN_COLUMN andDataType:GPKG_DT_BOOLEAN andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BLOB_COLUMN andDataType:GPKG_DT_BLOB andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:INTEGER_COLUMN andDataType:GPKG_DT_INTEGER andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:TEXT_LIMITED_COLUMN andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:BLOB_LIMITED_COLUMN andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:DATE_COLUMN andDataType:GPKG_DT_DATE andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:DATETIME_COLUMN andDataType:GPKG_DT_DATETIME andNotNull:NO andDefaultValue:nil]];
    
    GPKGAttributesTable *attributesTable = [geoPackage createAttributesTableWithTableName:@"attributes" andAdditionalColumns:columns];
    
    GPKGAttributesDao *attributesDao = [geoPackage getAttributesDaoWithTableName:attributesTable.tableName];
    
    for (int i = 0; i < 10; i++) {
        
        GPKGAttributesRow *newRow = [attributesDao newRow];
        
        [newRow setValueWithColumnName:TEXT_COLUMN andValue:[[NSProcessInfo processInfo] globallyUniqueString]];
        [newRow setValueWithColumnName:REAL_COLUMN andValue:[[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDoubleLessThan:5000.0]]];
        [newRow setValueWithColumnName:BOOLEAN_COLUMN andValue:[NSNumber numberWithBool:([GPKGTestUtils randomDouble] < .5 ? false : true)]];
        [newRow setValueWithColumnName:BLOB_COLUMN andValue:[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding]];
        [newRow setValueWithColumnName:INTEGER_COLUMN andValue:[NSNumber numberWithInt:[GPKGTestUtils randomIntLessThan:500]]];
        [newRow setValueWithColumnName:TEXT_LIMITED_COLUMN andValue:[[NSProcessInfo processInfo] globallyUniqueString]];
        [newRow setValueWithColumnName:BLOB_LIMITED_COLUMN andValue:[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding]];
        [newRow setValueWithColumnName:DATE_COLUMN andValue:[GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:[NSDate date] andType:GPKG_DT_DATE]]];
        [newRow setValueWithColumnName:DATETIME_COLUMN andValue:[NSDate date]];
        
        [attributesDao create:newRow];
        
    }
    
}

+(void) createGeometryIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray *featureTables = [geoPackage getFeatureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureIndexManager *indexer = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [indexer setIndexLocation:GPKG_FIT_GEOPACKAGE];
        [indexer index];
    }
    
}

+(void) createFeatureTileLinkExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray *featureTables = [geoPackage getFeatureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao];
        
        GPKGFeatureIndexManager *indexer = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        [featureTiles setIndexManager:indexer];
        
        GPKGBoundingBox *boundingBox = [featureDao getBoundingBox];
        GPKGProjection *projection = featureDao.projection;
        
        GPKGProjection *requestProjection = [GPKGProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        GPKGProjectionTransform *transform = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
        GPKGBoundingBox *requestBoundingBox = [transform transformWithBoundingBox:boundingBox];
        
        int zoomLevel = [GPKGTileBoundingBoxUtils getZoomLevelWithWebMercatorBoundingBox:requestBoundingBox];
        zoomLevel = MIN(zoomLevel, 19);
        
        int minZoom = zoomLevel - 2;
        int maxZoom = zoomLevel + 2;
        
        GPKGTileGenerator *tileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"%@_tiles", featureTable] andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:requestBoundingBox andProjection:requestProjection];
        
        [tileGenerator generateTiles];
    }
    
}

static int dataColumnConstraintIndex = 0;

+(void) createSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    [geoPackage createDataColumnConstraintsTable];
    
    GPKGDataColumnConstraintsDao *dao = [geoPackage getDataColumnConstraintsDao];
    
    GPKGDataColumnConstraints * sampleRange = [[GPKGDataColumnConstraints alloc] init];
    [sampleRange setConstraintName:@"sampleRange"];
    [sampleRange setDataColumnConstraintType:GPKG_DCCT_RANGE];
    [sampleRange setMin: [[NSDecimalNumber alloc] initWithDouble:1.0]];
    [sampleRange setMinIsInclusiveValue:true];
    [sampleRange setMax: [[NSDecimalNumber alloc] initWithDouble:10.0]];
    [sampleRange setMaxIsInclusiveValue:true];
    [sampleRange setTheDescription:@"sampleRange description"];
    [dao create:sampleRange];
    
    GPKGDataColumnConstraints * sampleEnum1 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum1 setConstraintName:@"sampleEnum"];
    [sampleEnum1 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum1 setValue:@"1"];
    [sampleEnum1 setTheDescription:@"sampleEnum description"];
    [dao create:sampleEnum1];
    
    GPKGDataColumnConstraints * sampleEnum3 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum3 setConstraintName:sampleEnum1.constraintName];
    [sampleEnum3 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum3 setValue:@"3"];
    [sampleEnum3 setTheDescription:sampleEnum1.theDescription];
    [dao create:sampleEnum3];
    
    GPKGDataColumnConstraints * sampleEnum5 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum5 setConstraintName:sampleEnum1.constraintName];
    [sampleEnum5 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum5 setValue:@"5"];
    [sampleEnum5 setTheDescription:sampleEnum1.theDescription];
    [dao create:sampleEnum5];
    
    GPKGDataColumnConstraints * sampleEnum7 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum7 setConstraintName:sampleEnum1.constraintName];
    [sampleEnum7 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum7 setValue:@"7"];
    [sampleEnum7 setTheDescription:sampleEnum1.theDescription];
    [dao create:sampleEnum7];
    
    GPKGDataColumnConstraints * sampleEnum9 = [[GPKGDataColumnConstraints alloc] init];
    [sampleEnum9 setConstraintName:sampleEnum1.constraintName];
    [sampleEnum9 setDataColumnConstraintType:GPKG_DCCT_ENUM];
    [sampleEnum9 setValue:@"9"];
    [sampleEnum9 setTheDescription:sampleEnum1.theDescription];
    [dao create:sampleEnum9];
    
    GPKGDataColumnConstraints * sampleGlob = [[GPKGDataColumnConstraints alloc] init];
    [sampleGlob setConstraintName:@"sampleGlob"];
    [sampleGlob setDataColumnConstraintType:GPKG_DCCT_GLOB];
    [sampleGlob setValue:@"[1-2][0-9][0-9][0-9]"];
    [sampleGlob setTheDescription:@"sampleGlob description"];
    [dao create:sampleGlob];
    
    [geoPackage createDataColumnsTable];
    
    GPKGDataColumnsDao *dataColumnsDao = [geoPackage getDataColumnsDao];
    
    NSArray *featureTables = [geoPackage getFeatureTables];
    for (NSString *featureTable in featureTables) {
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        
        GPKGFeatureTable *table = [featureDao getFeatureTable];
        for (GPKGFeatureColumn *column in table.columns) {
            
            if(!column.primaryKey && column.dataType == GPKG_DT_INTEGER){
                
                GPKGDataColumns *dataColumns = [[GPKGDataColumns alloc] init];
                GPKGGeometryColumnsDao *geometryColumnsDao = [geoPackage getGeometryColumnsDao];
                [dataColumns setContents:[geometryColumnsDao getContents:featureDao.geometryColumns]];
                [dataColumns setColumnName:column.name];
                [dataColumns setName:featureTable];
                [dataColumns setTitle:@"TEST_TITLE"];
                [dataColumns setTheDescription:@"TEST_DESCRIPTION"];
                [dataColumns setMimeType:@"TEST_MIME_TYPE"];
                
                enum GPKGDataColumnConstraintType constraintType = (enum GPKGDataColumnConstraintType) dataColumnConstraintIndex;
                dataColumnConstraintIndex++;
                if (dataColumnConstraintIndex >= 3) {
                    dataColumnConstraintIndex = 0;
                }
                
                int value = 0;
                
                NSString *constraintName = nil;
                switch (constraintType) {
                    case GPKG_DCCT_RANGE:
                        constraintName = sampleRange.constraintName;
                        value = 1 + (int) ([GPKGTestUtils randomDouble] * 10);
                        break;
                    case GPKG_DCCT_ENUM:
                        constraintName = sampleEnum1.constraintName;
                        value = 1 + ((int) ([GPKGTestUtils randomDouble] * 5) * 2);
                        break;
                    case GPKG_DCCT_GLOB:
                        constraintName = sampleGlob.constraintName;
                        value = 1000 + (int) ([GPKGTestUtils randomDouble] * 2000);
                        break;
                    default:
                        [NSException raise:@"Constraint Type" format:@"Unexpected Constraint Type: %u", constraintType];
                }
                [dataColumns setConstraintName:constraintName];
                
                GPKGContentValues *values = [[GPKGContentValues alloc] init];
                [values putKey:column.name withValue:[NSNumber numberWithInt:value]];
                [featureDao updateWithValues:values andWhere:nil andWhereArgs:nil];
                
                [dataColumnsDao create:dataColumns];
                
                break;
            }
        }
    }
    
}

+(void) createNonLinearGeometryTypesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem *srs = [srsDao getOrCreateWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGGeometryExtensions *extensions = [[GPKGGeometryExtensions alloc] initWithGeoPackage:geoPackage];
    
    NSString *tableName = @"non_linear_geometries";
    
    NSMutableArray *geometries = [[NSMutableArray alloc] init];
    NSMutableArray *geometryNames = [[NSMutableArray alloc] init];
    
    WKBCircularString *circularString = [[WKBCircularString alloc] init];
    [circularString addPoint:[[WKBPoint alloc] initWithXValue:-122.358 andYValue:47.653]];
    [circularString addPoint:[[WKBPoint alloc] initWithXValue:-122.348 andYValue:47.649]];
    [circularString addPoint:[[WKBPoint alloc] initWithXValue:-122.348 andYValue:47.658]];
    [circularString addPoint:[[WKBPoint alloc] initWithXValue:-122.358 andYValue:47.658]];
    [circularString addPoint:[[WKBPoint alloc] initWithXValue:-122.358 andYValue:47.653]];
    
    for(int i = (int)WKB_CIRCULARSTRING; i <= (int)WKB_SURFACE; i++){
        
        enum WKBGeometryType geometryType = i;
        [extensions getOrCreateWithTable:tableName andColumn:GEOMETRY_COLUMN andType:geometryType];
        
        WKBGeometry *geometry = nil;
        NSString *name = [WKBGeometryTypes name:geometryType];
        
        switch (geometryType) {
            case WKB_CIRCULARSTRING:
                geometry = circularString;
                break;
            case WKB_COMPOUNDCURVE:
                {
                    WKBCompoundCurve *compoundCurve = [[WKBCompoundCurve alloc] init];
                    [compoundCurve addLineString:circularString];
                    geometry = compoundCurve;
                }
                break;
            case WKB_CURVEPOLYGON:
                {
                    WKBCurvePolygon *curvePolygon = [[WKBCurvePolygon alloc] init];
                    [curvePolygon addRing:circularString];
                    geometry = curvePolygon;
                }
                break;
            case WKB_MULTICURVE:
                {
                    WKBMultiLineString *multiCurve = [[WKBMultiLineString alloc] init];
                    [multiCurve addLineString:circularString];
                    geometry = multiCurve;
                }
                break;
            case WKB_MULTISURFACE:
                {
                    WKBMultiPolygon *multiSurface = [[WKBMultiPolygon alloc] init];
                    WKBPolygon *polygon = [[WKBPolygon alloc] init];
                    [polygon addRing:circularString];
                    [multiSurface addPolygon:polygon];
                    geometry = multiSurface;
                }
                break;
            case WKB_CURVE:
                {
                    WKBCompoundCurve *curve = [[WKBCompoundCurve alloc] init];
                    [curve addLineString:circularString];
                    geometry = curve;
                }
                break;
            case WKB_SURFACE:
                {
                    WKBCurvePolygon *surface = [[WKBCurvePolygon alloc] init];
                    [surface addRing:circularString];
                    geometry = surface;
                }
                break;
            default:
                [NSException raise:@"Geometry Type" format:@"Unexpected Geometry Type: %u", geometryType];
        }
        
        [geometries addObject:geometry];
        [geometryNames addObject:name];
        
    }
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:tableName andType:WKB_GEOMETRY andGeometries:geometries andNames:geometryNames];
    
}

+(void) createWebPExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGWebPExtension *webpExtension = [[GPKGWebPExtension alloc] initWithGeoPackage:geoPackage];
    NSString *tableName = @"webp_tiles";
    [webpExtension getOrCreateWithTableName:tableName];

    [geoPackage createTileMatrixSetTable];
    [geoPackage createTileMatrixTable];
    
    GPKGBoundingBox *bitsBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-11667347.997449303 andMinLatitudeDouble:4824705.2253603265 andMaxLongitudeDouble:-11666125.00499674 andMaxLatitudeDouble:4825928.217812888];
    [self createTilesWithGeoPackage:geoPackage andName:tableName andBoundingBox:bitsBoundingBox andMinZoom:15 andMaxZoom:15 andExtension:@"webp"];
    
}

+(void) createCrsWktExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGCrsWktExtension *wktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage];
    [wktExtension getOrCreate];
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    
    GPKGSpatialReferenceSystem *srs = [srsDao queryForOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGSpatialReferenceSystem *testSrs = [[GPKGSpatialReferenceSystem alloc] init];
    [testSrs setSrsName:@"test"];
    [testSrs setSrsId:[NSNumber numberWithInt:12345]];
    [testSrs setOrganization:@"test_org"];
    [testSrs setOrganizationCoordsysId:testSrs.srsId];
    [testSrs setDefinition:srs.definition];
    [testSrs setTheDescription:srs.theDescription];
    [testSrs setDefinition_12_063:srs.definition_12_063];
    [srsDao create:testSrs];
    
    GPKGSpatialReferenceSystem *testSrs2 = [[GPKGSpatialReferenceSystem alloc] init];
    [testSrs2 setSrsName:@"test2"];
    [testSrs2 setSrsId:[NSNumber numberWithInt:54321]];
    [testSrs2 setOrganization:@"test_org"];
    [testSrs2 setOrganizationCoordsysId:testSrs2.srsId];
    [testSrs2 setDefinition:srs.definition];
    [testSrs2 setTheDescription:srs.theDescription];
    [srsDao create:testSrs2];
    
}

+(void) createMetadataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [geoPackage createMetadataTable];
    GPKGMetadataDao *metadataDao = [geoPackage getMetadataDao];
    
    GPKGMetadata *metadata1 = [[GPKGMetadata alloc] init];
    [metadata1 setId:[NSNumber numberWithInt:1]];
    [metadata1 setMetadataScopeType:GPKG_MST_DATASET];
    [metadata1 setStandardUri:@"TEST_URI_1"];
    [metadata1 setMimeType:@"text/xml"];
    [metadata1 setMetadata:@"TEST METADATA 1"];
    [metadataDao create:metadata1];
    
    GPKGMetadata *metadata2 = [[GPKGMetadata alloc] init];
    [metadata2 setId:[NSNumber numberWithInt:2]];
    [metadata2 setMetadataScopeType:GPKG_MST_FEATURE_TYPE];
    [metadata2 setStandardUri:@"TEST_URI_2"];
    [metadata2 setMimeType:@"text/xml"];
    [metadata2 setMetadata:@"TEST METADATA 2"];
    [metadataDao create:metadata2];
    
    GPKGMetadata *metadata3 = [[GPKGMetadata alloc] init];
    [metadata3 setId:[NSNumber numberWithInt:3]];
    [metadata3 setMetadataScopeType:GPKG_MST_TILE];
    [metadata3 setStandardUri:@"TEST_URI_3"];
    [metadata3 setMimeType:@"text/xml"];
    [metadata3 setMetadata:@"TEST METADATA 3"];
    [metadataDao create:metadata3];
    
    [geoPackage createMetadataReferenceTable];
    GPKGMetadataReferenceDao *metadataReferenceDao = [geoPackage getMetadataReferenceDao];
    
    GPKGMetadataReference *reference1 = [[GPKGMetadataReference alloc] init];
    [reference1 setReferenceScopeType:GPKG_RST_GEOPACKAGE];
    [reference1 setMetadata:metadata1];
    [metadataReferenceDao create:reference1];
    
    NSArray *tileTables = [geoPackage getTileTables];
    if(tileTables.count > 0){
        NSString *table = [tileTables objectAtIndex:0];
        GPKGMetadataReference *reference2 = [[GPKGMetadataReference alloc] init];
        [reference2 setReferenceScopeType:GPKG_RST_TABLE];
        [reference2 setTableName:table];
        [reference2 setMetadata:metadata2];
        [reference2 setParentMetadata:metadata1];
        [metadataReferenceDao create:reference2];
    }
    
    NSArray *featureTables = [geoPackage getFeatureTables];
    if (featureTables.count > 0) {
        NSString *table = [featureTables objectAtIndex:0];
        GPKGMetadataReference *reference3 = [[GPKGMetadataReference alloc] init];
        [reference3 setReferenceScopeType:GPKG_RST_ROW_COL];
        [reference3 setTableName:table];
        [reference3 setColumnName:GEOMETRY_COLUMN];
        [reference3 setRowIdValue:[NSNumber numberWithInt:1]];
        [reference3 setMetadata:metadata3];
        [metadataReferenceDao create:reference3];
    }
    
}

+(void) createCoverageDataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self createCoverageDataPngExtensionWithGeoPackage:geoPackage];
    [self createCoverageDataTiffExtensionWithGeoPackage:geoPackage];
    
}

+(void) createCoverageDataPngExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGBoundingBox *bbox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-11667347.997449303 andMinLatitudeDouble:4824705.2253603265 andMaxLongitudeDouble:-11666125.00499674 andMaxLatitudeDouble:4825928.217812888];
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *contentsSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    GPKGSpatialReferenceSystem *tileMatrixSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGProjectionTransform *transform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D];
    GPKGBoundingBox *contentsBoundingBox = [transform transformWithBoundingBox:bbox];
    
    GPKGCoverageDataPng *coverageData = [GPKGCoverageDataPng createTileTableWithGeoPackage:geoPackage andTableName:@"coverage_png" andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrs.srsId andTileMatrixSetBoundingBox:bbox andTileMatrixSetSrsId:tileMatrixSrs.srsId];
    GPKGTileDao *tileDao = [coverageData tileDao];
    GPKGTileMatrixSet *tileMatrixSet = [coverageData tileMatrixSet];
    
    GPKGGriddedCoverageDao *griddedCoverageDao = [coverageData griddedCoverageDao];
    
    GPKGGriddedCoverage *griddedCoverage = [[GPKGGriddedCoverage alloc] init];
    [griddedCoverage setTileMatrixSet:tileMatrixSet];
    [griddedCoverage setGriddedCoverageDataType:GPKG_GCDT_INTEGER];
    [griddedCoverage setDataNull:[[NSDecimalNumber alloc] initWithDouble:SHRT_MAX - SHRT_MIN]];
    [griddedCoverage setGridCellEncodingType:GPKG_GCET_CENTER];
    [griddedCoverageDao create:griddedCoverage];
    
    GPKGGriddedTileDao *griddedTileDao = [coverageData griddedTileDao];
    
    int width = 1;
    int height = 1;
    int tileWidth = 3;
    int tileHeight = 3;
    
    NSMutableArray *tilePixels = [[NSMutableArray alloc] initWithCapacity:tileHeight];
    
    NSMutableArray *row0 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row0 addObject:[NSNumber numberWithUnsignedShort:1661.95]];
    [row0 addObject:[NSNumber numberWithUnsignedShort:1665.40]];
    [row0 addObject:[NSNumber numberWithUnsignedShort:1668.19]];
    [tilePixels addObject:row0];
    
    NSMutableArray *row1 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row1 addObject:[NSNumber numberWithUnsignedShort:1657.18]];
    [row1 addObject:[NSNumber numberWithUnsignedShort:1663.39]];
    [row1 addObject:[NSNumber numberWithUnsignedShort:1669.65]];
    [tilePixels addObject:row1];
    
    NSMutableArray *row2 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row2 addObject:[NSNumber numberWithUnsignedShort:1654.78]];
    [row2 addObject:[NSNumber numberWithUnsignedShort:1660.31]];
    [row2 addObject:[NSNumber numberWithUnsignedShort:1666.44]];
    [tilePixels addObject:row2];
    
    NSData *imageData = [coverageData drawTileDataWithDoubleArrayPixelValues:tilePixels];
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
    
    GPKGTileMatrix *tileMatrix = [[GPKGTileMatrix alloc] init];
    [tileMatrix setContents:[tileMatrixSetDao getContents:tileMatrixSet]];
    [tileMatrix setMatrixHeight:[NSNumber numberWithInt:height]];
    [tileMatrix setMatrixWidth:[NSNumber numberWithInt:width]];
    [tileMatrix setTileHeight:[NSNumber numberWithInt:tileHeight]];
    [tileMatrix setTileWidth:[NSNumber numberWithInt:tileWidth]];
    [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:([bbox.maxLongitude doubleValue] - [bbox.minLongitude doubleValue]) / width / tileWidth]];
    [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:([bbox.maxLatitude doubleValue] - [bbox.minLatitude doubleValue]) / height / tileHeight]];
    [tileMatrix setZoomLevel:[NSNumber numberWithInt:15]];
    [tileMatrixDao create:tileMatrix];
    
    GPKGTileRow *tileRow = [tileDao newRow];
    [tileRow setTileColumn:0];
    [tileRow setTileRow:0];
    [tileRow setZoomLevel:[tileMatrix.zoomLevel intValue]];
    [tileRow setTileData:imageData];
    
    long long tileId = [tileDao create:tileRow];
    
    GPKGGriddedTile *griddedTile = [[GPKGGriddedTile alloc] init];
    [griddedTile setContents:[tileMatrixSetDao getContents:tileMatrixSet]];
    [griddedTile setTableId:[NSNumber numberWithLongLong:tileId]];
    
    [griddedTileDao create:griddedTile];
    
}

+(void) createCoverageDataTiffExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGBoundingBox *bbox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-8593967.964158937 andMinLatitudeDouble:4685284.085768163 andMaxLongitudeDouble:-8592744.971706374 andMaxLatitudeDouble:4687730.070673289];
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *contentsSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    GPKGSpatialReferenceSystem *tileMatrixSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    
    GPKGProjectionTransform *transform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D];
    GPKGBoundingBox *contentsBoundingBox = [transform transformWithBoundingBox:bbox];
    
    GPKGCoverageDataTiff *coverageData = [GPKGCoverageDataTiff createTileTableWithGeoPackage:geoPackage andTableName:@"coverage_tiff" andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrs.srsId andTileMatrixSetBoundingBox:bbox andTileMatrixSetSrsId:tileMatrixSrs.srsId];
    GPKGTileDao *tileDao = [coverageData tileDao];
    GPKGTileMatrixSet *tileMatrixSet = [coverageData tileMatrixSet];
    
    GPKGGriddedCoverageDao *griddedCoverageDao = [coverageData griddedCoverageDao];
    
    GPKGGriddedCoverage *griddedCoverage = [[GPKGGriddedCoverage alloc] init];
    [griddedCoverage setTileMatrixSet:tileMatrixSet];
    [griddedCoverage setGriddedCoverageDataType:GPKG_GCDT_FLOAT];
    [griddedCoverage setDataNull:[[NSDecimalNumber alloc] initWithDouble:FLT_MAX]];
    [griddedCoverage setGridCellEncodingType:GPKG_GCET_CENTER];
    [griddedCoverageDao create:griddedCoverage];
    
    GPKGGriddedTileDao *griddedTileDao = [coverageData griddedTileDao];
    
    int width = 1;
    int height = 1;
    int tileWidth = 4;
    int tileHeight = 4;
    
    NSMutableArray *tilePixels = [[NSMutableArray alloc] initWithCapacity:tileHeight];
    
    NSMutableArray *row0 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row0 addObject:[NSNumber numberWithFloat:71.78]];
    [row0 addObject:[NSNumber numberWithFloat:74.31]];
    [row0 addObject:[NSNumber numberWithFloat:70.19]];
    [row0 addObject:[NSNumber numberWithFloat:68.07]];
    [tilePixels addObject:row0];
    
    NSMutableArray *row1 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row1 addObject:[NSNumber numberWithFloat:61.01]];
    [row1 addObject:[NSNumber numberWithFloat:69.66]];
    [row1 addObject:[NSNumber numberWithFloat:68.65]];
    [row1 addObject:[NSNumber numberWithFloat:72.02]];
    [tilePixels addObject:row1];
    
    NSMutableArray *row2 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row2 addObject:[NSNumber numberWithFloat:41.58]];
    [row2 addObject:[NSNumber numberWithFloat:69.46]];
    [row2 addObject:[NSNumber numberWithFloat:67.56]];
    [row2 addObject:[NSNumber numberWithFloat:70.42]];
    [tilePixels addObject:row2];
    
    NSMutableArray *row3 = [[NSMutableArray alloc] initWithCapacity:tileWidth];
    [row3 addObject:[NSNumber numberWithFloat:54.03]];
    [row3 addObject:[NSNumber numberWithFloat:71.32]];
    [row3 addObject:[NSNumber numberWithFloat:57.61]];
    [row3 addObject:[NSNumber numberWithFloat:54.96]];
    [tilePixels addObject:row3];
    
    NSData *imageData = [coverageData drawTileDataWithDoubleArrayPixelValues:tilePixels];
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage getTileMatrixSetDao];
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage getTileMatrixDao];
    
    GPKGTileMatrix *tileMatrix = [[GPKGTileMatrix alloc] init];
    [tileMatrix setContents:[tileMatrixSetDao getContents:tileMatrixSet]];
    [tileMatrix setMatrixHeight:[NSNumber numberWithInt:height]];
    [tileMatrix setMatrixWidth:[NSNumber numberWithInt:width]];
    [tileMatrix setTileHeight:[NSNumber numberWithInt:tileHeight]];
    [tileMatrix setTileWidth:[NSNumber numberWithInt:tileWidth]];
    [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:([bbox.maxLongitude doubleValue] - [bbox.minLongitude doubleValue]) / width / tileWidth]];
    [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:([bbox.maxLatitude doubleValue] - [bbox.minLatitude doubleValue]) / height / tileHeight]];
    [tileMatrix setZoomLevel:[NSNumber numberWithInt:15]];
    [tileMatrixDao create:tileMatrix];
    
    GPKGTileRow *tileRow = [tileDao newRow];
    [tileRow setTileColumn:0];
    [tileRow setTileRow:0];
    [tileRow setZoomLevel:[tileMatrix.zoomLevel intValue]];
    [tileRow setTileData:imageData];
    
    long long tileId = [tileDao create:tileRow];
    
    GPKGGriddedTile *griddedTile = [[GPKGGriddedTile alloc] init];
    [griddedTile setContents:[tileMatrixSetDao getContents:tileMatrixSet]];
    [griddedTile setTableId:[NSNumber numberWithLongLong:tileId]];
    
    [griddedTileDao create:griddedTile];
    
}

+(void) createRTreeSpatialIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGRTreeIndexExtension *extension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray *featureTables = [geoPackage getFeatureTables];
    for (NSString *tableName in featureTables) {
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:tableName];
        GPKGFeatureTable *featureTable = [featureDao getFeatureTable];
        
        [extension createWithFeatureTable:featureTable];
    }
    
}

@end
