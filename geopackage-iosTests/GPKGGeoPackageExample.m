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
        [NSException raise:@"GeoPackage " format:@"Failed to open database"];
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
    [columns addObject:[GPKGFeatureColumn createColumnWithIndex:columnNumber++ andName:TEXT_COLUMN andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
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
    
    NSString *tilesPath = @"tiles/";
    
    for (int zoom = minZoomLevel; zoom <= maxZoomLevel; zoom++) {
        
        NSString *zoomPath = [NSString stringWithFormat:@"%@%d/", tilesPath, zoom];
        
        NSNumber *tileWidth = nil;
        NSNumber *tileHeight = nil;
        
        GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithWebMercatorBoundingBox:totalBoundingBox andZoom:zoom];
        GPKGTileDao *dao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        for (int x = tileGrid.minX; x <= tileGrid.maxX; x++) {
            
            NSString *xPath = [NSString stringWithFormat:@"%@%d/", zoomPath, x];
            
            for (int y = tileGrid.minY; y <= tileGrid.maxY; y++) {
                
                NSString *yPath = [NSString stringWithFormat:@"%@%ld.%@", xPath, y, extension];
                
                @try {
                    
                    NSData *tileData = nil;
                    // TODO
                    //byte[] tileBytes = TestUtils.getAssetFileBytes(context,yPath);
                    
                    if (tileWidth == nil || tileHeight == nil) {
                        // TODO
                        //Bitmap tileImage = BitmapConverter.toBitmap(tileBytes);
                        //if (tileImage != null) {
                        //    tileHeight = tileImage.getHeight();
                        //    tileWidth = tileImage.getWidth();
                        //}
                    }
                    
                    GPKGTileRow *newRow = [dao newRow];
                    
                    [newRow setZoomLevel:zoom];
                    [newRow setTileColumn:x - tileGrid.minX];
                    [newRow setTileRow:y - tileGrid.minY];
                    [newRow setTileData:tileData];
                    
                    [dao create:newRow];
                    
                } @catch (NSException *e) {
                    // skip tile
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
        double pixelXSize = ([tileMatrixSet.maxX doubleValue] - [tileMatrixSet.minX doubleValue]) / (matrixWidth * (int)tileWidth);
        double pixelYSize = ([tileMatrixSet.maxY doubleValue] - [tileMatrixSet.minY doubleValue]) / (matrixHeight * (int)tileHeight);
        
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
        
    }
    
}

+(void) createAttributesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createGeometryIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createFeatureTileLinkExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

static int dataColumnConstraintIndex = 0;

+(void) createSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createNonLinearGeometryTypesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createWebPExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createCrsWktExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createMetadataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createCoverageDataExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createCoverageDataPngExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createCoverageDataTiffExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) createRTreeSpatialIndexExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

@end
