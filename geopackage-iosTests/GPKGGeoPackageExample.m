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
#import "SFPProjectionConstants.h"
#import "SFPoint.h"
#import "SFLineString.h"
#import "SFPolygon.h"
#import "SFGeometryEnvelopeBuilder.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGFeatureTiles.h"
#import "SFPProjectionFactory.h"
#import "SFPProjectionTransform.h"
#import "GPKGFeatureTileGenerator.h"
#import "GPKGGeometryExtensions.h"
#import "SFCircularString.h"
#import "SFCompoundCurve.h"
#import "SFMultiLineString.h"
#import "SFMultiPolygon.h"
#import "GPKGWebPExtension.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGCoverageDataPng.h"
#import "GPKGCoverageDataTiff.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGRelatedTablesUtils.h"
#import "GPKGDublinCoreMetadata.h"
#import "GPKGGeoPackageExtensions.h"
#import "GPKGNGAExtensions.h"
#import "GPKGSchemaExtension.h"
#import "GPKGMetadataExtension.h"
#import "GPKGFeatureTileTableLinker.h"
#import "GPKGTileTableScaling.h"
#import "GPKGPropertiesExtension.h"
#import "GPKGContentsIdExtension.h"
#import "GPKGFeatureStyleExtension.h"
#import "GPKGPropertyNames.h"
#import "GPKGColorConstants.h"
#import "GPKGFeatureTableStyles.h"

@implementation GPKGGeoPackageExample

static NSString *GEOPACKAGE_NAME = @"example";

static BOOL FEATURES = YES;
static BOOL TILES = YES;
static BOOL ATTRIBUTES = YES;
static BOOL SCHEMA = YES;
static BOOL NON_LINEAR_GEOMETRY_TYPES = YES;
static BOOL RTREE_SPATIAL_INDEX = YES;
static BOOL WEBP = YES;
static BOOL CRS_WKT = YES;
static BOOL METADATA = YES;
static BOOL COVERAGE_DATA = YES;
static BOOL RELATED_TABLES_MEDIA = YES;
static BOOL RELATED_TABLES_FEATURES = YES;
static BOOL RELATED_TABLES_SIMPLE_ATTRIBUTES = YES;
static BOOL GEOMETRY_INDEX = YES;
static BOOL FEATURE_TILE_LINK = YES;
static BOOL TILE_SCALING = YES;
static BOOL PROPERTIES = YES;
static BOOL CONTENTS_ID = YES;
static BOOL FEATURE_STYLE = YES;

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

/**
 * Test making the GeoPackage example
 */
-(void) testExample{
    
    [self create];
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager delete:GEOPACKAGE_NAME]];
}

/**
 * Test the GeoPackage example extensions
 */
-(void) testExampleExtensions{
    
    [self create];
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    
    [self validateExtensionsWithGeoPackage:geoPackage andHas:YES];
    [self validateNGAExtensionsWithGeoPackage:geoPackage andHas:YES];
    
    [GPKGGeoPackageExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    [self validateExtensionsWithGeoPackage:geoPackage andHas:NO];
    [self validateNGAExtensionsWithGeoPackage:geoPackage andHas:NO];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager delete:GEOPACKAGE_NAME]];
}

-(void) testExampleNGAExtensions{
    
    [self create];
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory getManager];
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    
    [self validateExtensionsWithGeoPackage:geoPackage andHas:YES];
    [self validateNGAExtensionsWithGeoPackage:geoPackage andHas:YES];
    
    [GPKGNGAExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    [self validateExtensionsWithGeoPackage:geoPackage andHas:YES];
    [self validateNGAExtensionsWithGeoPackage:geoPackage andHas:NO];
    
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager delete:GEOPACKAGE_NAME]];
}

-(void) validateExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andHas: (BOOL) has{
    
    GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
    
    [GPKGTestUtils assertEqualBoolWithValue:has && RTREE_SPATIAL_INDEX andValue2:[[[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && (RELATED_TABLES_FEATURES || RELATED_TABLES_MEDIA || RELATED_TABLES_SIMPLE_ATTRIBUTES) andValue2:[[[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && COVERAGE_DATA andValue2:[extensionsDao tableExists] && [extensionsDao countByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_GRIDDED_COVERAGE_EXTENSION_NAME]] > 0];
    
    [GPKGTestUtils assertEqualBoolWithValue:has && SCHEMA andValue2:[[[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && METADATA andValue2:[[[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && NON_LINEAR_GEOMETRY_TYPES andValue2:[extensionsDao tableExists] && [extensionsDao countByExtension:[GPKGGeometryExtensions getExtensionName:SF_CIRCULARSTRING]] > 0];
    [GPKGTestUtils assertEqualBoolWithValue:has && WEBP andValue2:[extensionsDao tableExists] && [extensionsDao countByExtension:[GPKGExtensions buildDefaultAuthorExtensionName:GPKG_WEBP_EXTENSION_NAME]] > 0];
    [GPKGTestUtils assertEqualBoolWithValue:has && CRS_WKT andValue2:[[[GPKGCrsWktExtension alloc] initWithGeoPackage:geoPackage] has]];
    
}

-(void) validateNGAExtensionsWithGeoPackage: (GPKGGeoPackage *) geoPackage andHas: (BOOL) has{
    
    GPKGExtensionsDao *extensionsDao = [geoPackage getExtensionsDao];
    
    [GPKGTestUtils assertEqualBoolWithValue:has && GEOMETRY_INDEX andValue2:[extensionsDao tableExists] && [extensionsDao countByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR]] > 0];
    [GPKGTestUtils assertEqualBoolWithValue:has && FEATURE_TILE_LINK andValue2:[[[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && TILE_SCALING andValue2:[extensionsDao tableExists] && [extensionsDao countByExtension:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR]] > 0];
    [GPKGTestUtils assertEqualBoolWithValue:has && PROPERTIES andValue2:[[[GPKGPropertiesExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && CONTENTS_ID andValue2:[[[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage] has]];
    [GPKGTestUtils assertEqualBoolWithValue:has && FEATURE_STYLE andValue2:[[[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage] has]];
    
}

-(void) create{
    
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
        
        NSLog(@"Feature Style Extension: %s", FEATURE_STYLE ? "Yes" : "No");
        if (FEATURE_STYLE) {
            [GPKGGeoPackageExample createFeatureStyleExtensionWithGeoPackage:geoPackage];
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
        
        NSLog(@"Related Tables Media Extension: %s", RELATED_TABLES_MEDIA ? "Yes" : "No");
        if (RELATED_TABLES_MEDIA) {
            [GPKGGeoPackageExample createRelatedTablesMediaExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"Related Tables Features Extension: %s", RELATED_TABLES_FEATURES ? "Yes" : "No");
        if (RELATED_TABLES_FEATURES) {
            [GPKGGeoPackageExample createRelatedTablesFeaturesExtensionWithGeoPackage:geoPackage];
        }
        
    } else {
        NSLog(@"Schema Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Geometry Index Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Feature Style Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Feature Tile Link Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Non-Linear Geometry Types Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"RTree Spatial Index Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Related Tables Media Extension: %s", FEATURES ? "Yes" : "No");
        NSLog(@"Related Tables Features Extension: %s", FEATURES ? "Yes" : "No");
    }
    
    NSLog(@"Tiles: %s", TILES ? "Yes" : "No");
    if (TILES) {
        
        [GPKGGeoPackageExample createTilesWithGeoPackage:geoPackage];
        
        NSLog(@"WebP Extension: %s", WEBP ? "Yes" : "No");
        if (WEBP) {
            [GPKGGeoPackageExample createWebPExtensionWithGeoPackage:geoPackage];
        }
        
        NSLog(@"Tile Scaling Extension: %s", TILE_SCALING ? "Yes" : "No");
        if (TILE_SCALING) {
            [GPKGGeoPackageExample createTileScalingExtensionWithGeoPackage:geoPackage];
        }
        
    } else {
        NSLog(@"WebP Extension: %s", TILES ? "Yes" : "No");
        NSLog(@"Tile Scaling Extension: %s", TILES ? "Yes" : "No");
    }
    
    NSLog(@"Attributes: %s", ATTRIBUTES ? "Yes" : "No");
    if (ATTRIBUTES) {
        [GPKGGeoPackageExample createAttributesWithGeoPackage:geoPackage];
        
        NSLog(@"Related Tables Simple Attributes Extension: %s", RELATED_TABLES_SIMPLE_ATTRIBUTES ? "Yes" : "No");
        if (RELATED_TABLES_SIMPLE_ATTRIBUTES) {
            [GPKGGeoPackageExample createRelatedTablesSimpleAttributesExtensionWithGeoPackage:geoPackage];
        }

    }else{
        NSLog(@"Related Tables Simple Attributes Extension: %s", ATTRIBUTES ? "Yes" : "No");
    }
    
    NSLog(@"Metadata: %s", METADATA ? "Yes" : "No");
    if (METADATA) {
        [GPKGGeoPackageExample createMetadataExtensionWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Coverage Data: %s", COVERAGE_DATA ? "Yes" : "No");
    if (COVERAGE_DATA) {
        [GPKGGeoPackageExample createCoverageDataExtensionWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Properties: %s", PROPERTIES ? "Yes" : "No");
    if (PROPERTIES) {
        [GPKGGeoPackageExample createPropertiesExtensionWithGeoPackage:geoPackage];
    }
    
    NSLog(@"Contents Id: %s", CONTENTS_ID ? "Yes" : "No");
    if (CONTENTS_ID) {
        [GPKGGeoPackageExample createContentsIdExtensionWithGeoPackage:geoPackage];
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
    
    [self createFeatures1WithGeoPackage:geoPackage andSrs:srs];
    [self createFeatures2WithGeoPackage:geoPackage andSrs:srs];
    
}

+(void) createFeatures1WithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs{
    
    NSMutableArray<SFGeometry *> *points = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *pointNames = [[NSMutableArray alloc] init];
    
    [points addObject:[[SFPoint alloc] initWithXValue:-104.801918 andYValue:39.720014]];
    [pointNames addObject:@"BIT Systems"];
    
    [points addObject:[[SFPoint alloc] initWithXValue:-104.802987 andYValue:39.717703]];
    [pointNames addObject:@"Community College of Aurora CentreTech Campus"];
    
    [points addObject:[[SFPoint alloc] initWithXValue:-104.807496 andYValue:39.714085]];
    [pointNames addObject:@"DeLaney Community Farm"];
    
    [points addObject:[[SFPoint alloc] initWithXValue:-104.799480 andYValue:39.714729]];
    [pointNames addObject:@"Centre Hills Disc Golf Course"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"point1" andType:SF_POINT andGeometries:points andNames:pointNames];
    
    NSMutableArray<SFGeometry *> *lines = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *lineNames = [[NSMutableArray alloc] init];
    
    SFLineString *line1 = [[SFLineString alloc] init];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-104.800614 andYValue:39.720721]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-104.802174 andYValue:39.720726]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-104.802584 andYValue:39.720660]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-104.803088 andYValue:39.720477]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-104.803474 andYValue:39.720209]];
    
    [lines addObject:line1];
    [lineNames addObject:@"East Lockheed Drive"];
    
    SFLineString *line2 = [[SFLineString alloc] init];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.809612 andYValue:39.718379]];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.806638 andYValue:39.718372]];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.806236 andYValue:39.718439]];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.805939 andYValue:39.718536]];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.805654 andYValue:39.718677]];
    [line2 addPoint:[[SFPoint alloc] initWithXValue:-104.803652 andYValue:39.720095]];
    
    [lines addObject:line2];
    [lineNames addObject:@"E 1st Ave"];
    
    SFLineString *line3 = [[SFLineString alloc] init];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.806344 andYValue:39.722425]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.805854 andYValue:39.722634]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.805656 andYValue:39.722647]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.803749 andYValue:39.722641]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.803769 andYValue:39.721849]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.803806 andYValue:39.721725]];
    [line3 addPoint:[[SFPoint alloc] initWithXValue:-104.804382 andYValue:39.720865]];
    
    [lines addObject:line3];
    [lineNames addObject:@"E Centretech Cir"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"line1" andType:SF_LINESTRING andGeometries:lines andNames:lineNames];

    NSMutableArray<SFGeometry *> *polygons = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *polygonNames = [[NSMutableArray alloc] init];
    
    SFPolygon *polygon1 = [[SFPolygon alloc] init];
    SFLineString *ring1 = [[SFLineString alloc] init];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802246 andYValue:39.720343]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802246 andYValue:39.719753]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802183 andYValue:39.719754]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802184 andYValue:39.719719]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802138 andYValue:39.719694]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802097 andYValue:39.719691]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802096 andYValue:39.719648]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801646 andYValue:39.719648]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801644 andYValue:39.719722]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801550 andYValue:39.719723]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801549 andYValue:39.720207]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801648 andYValue:39.720207]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.801648 andYValue:39.720341]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-104.802246 andYValue:39.720343]];
    [polygon1 addRing:ring1];
    
    [polygons addObject:polygon1];
    [polygonNames addObject:@"BIT Systems"];
    
    SFPolygon *polygon2 = [[SFPolygon alloc] init];
    
    SFLineString *ring2 = [[SFLineString alloc] init];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802259 andYValue:39.719604]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802260 andYValue:39.719550]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802281 andYValue:39.719416]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802332 andYValue:39.719372]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802081 andYValue:39.719240]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802044 andYValue:39.719290]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802027 andYValue:39.719278]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802044 andYValue:39.719229]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801785 andYValue:39.719129]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801639 andYValue:39.719413]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801649 andYValue:39.719472]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801694 andYValue:39.719524]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801753 andYValue:39.719550]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801750 andYValue:39.719606]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801940 andYValue:39.719606]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801939 andYValue:39.719555]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801977 andYValue:39.719556]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.801979 andYValue:39.719606]];
    [ring2 addPoint:[[SFPoint alloc] initWithXValue:-104.802259 andYValue:39.719604]];
    [polygon2 addRing:ring2];
    
    SFLineString *hole2 = [[SFLineString alloc] init];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802130 andYValue:39.719440]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802133 andYValue:39.719490]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802148 andYValue:39.719490]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802180 andYValue:39.719473]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802187 andYValue:39.719456]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802182 andYValue:39.719439]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802088 andYValue:39.719387]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802047 andYValue:39.719427]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801858 andYValue:39.719342]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801883 andYValue:39.719294]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801832 andYValue:39.719284]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801787 andYValue:39.719298]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801763 andYValue:39.719331]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801823 andYValue:39.719352]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801790 andYValue:39.719420]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801722 andYValue:39.719404]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801715 andYValue:39.719445]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801748 andYValue:39.719484]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801809 andYValue:39.719494]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.801816 andYValue:39.719439]];
    [hole2 addPoint:[[SFPoint alloc] initWithXValue:-104.802130 andYValue:39.719440]];
    [polygon2 addRing:hole2];
    
    [polygons addObject:polygon2];
    [polygonNames addObject:@"BIT Systems Visitor Parking"];
    
    SFPolygon *polygon3 = [[SFPolygon alloc] init];
    SFLineString *ring3 = [[SFLineString alloc] init];
    [ring3 addPoint:[[SFPoint alloc] initWithXValue:-104.802867 andYValue:39.718122]];
    [ring3 addPoint:[[SFPoint alloc] initWithXValue:-104.802369 andYValue:39.717845]];
    [ring3 addPoint:[[SFPoint alloc] initWithXValue:-104.802571 andYValue:39.717630]];
    [ring3 addPoint:[[SFPoint alloc] initWithXValue:-104.803066 andYValue:39.717909]];
    [ring3 addPoint:[[SFPoint alloc] initWithXValue:-104.802867 andYValue:39.718122]];
    [polygon3 addRing:ring3];
    
    [polygons addObject:polygon3];
    [polygonNames addObject:@"CCA Administration Building"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"polygon1" andType:SF_POLYGON andGeometries:polygons andNames:polygonNames];
    
    NSMutableArray<SFGeometry *> *geometries = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *geometryNames = [[NSMutableArray alloc] init];
    [geometries addObjectsFromArray:points];
    [geometryNames addObjectsFromArray:pointNames];
    [geometries addObjectsFromArray:lines];
    [geometryNames addObjectsFromArray:lineNames];
    [geometries addObjectsFromArray:polygons];
    [geometryNames addObjectsFromArray:polygonNames];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"geometry1" andType:SF_GEOMETRY andGeometries:geometries andNames:geometryNames];
    
}

+(void) createFeatures2WithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs{

    NSMutableArray<SFGeometry *> *points = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *pointNames = [[NSMutableArray alloc] init];
    
    [points addObject:[[SFPoint alloc] initWithXValue:-77.196736 andYValue:38.753370]];
    [pointNames addObject:@"NGA"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"point2" andType:SF_POINT andGeometries:points andNames:pointNames];
    
    NSMutableArray<SFGeometry *> *lines = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *lineNames = [[NSMutableArray alloc] init];
    
    SFLineString *line1 = [[SFLineString alloc] init];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.196650 andYValue:38.756501]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.196414 andYValue:38.755979]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.195518 andYValue:38.755208]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.195303 andYValue:38.755272]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.195351 andYValue:38.755459]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.195863 andYValue:38.755697]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.196328 andYValue:38.756069]];
    [line1 addPoint:[[SFPoint alloc] initWithXValue:-77.196568 andYValue:38.756526]];
    
    [lines addObject:line1];
    [lineNames addObject:@"NGA"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"line2" andType:SF_LINESTRING andGeometries:lines andNames:lineNames];
    
    NSMutableArray<SFGeometry *> *polygons = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *polygonNames = [[NSMutableArray alloc] init];
    
    SFPolygon *polygon1 = [[SFPolygon alloc] init];
    SFLineString *ring1 = [[SFLineString alloc] init];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195299 andYValue:38.755159]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195203 andYValue:38.755080]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195410 andYValue:38.754930]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195350 andYValue:38.754884]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195228 andYValue:38.754966]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195135 andYValue:38.754889]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195048 andYValue:38.754956]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.194986 andYValue:38.754906]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.194897 andYValue:38.754976]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.194953 andYValue:38.755025]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.194763 andYValue:38.755173]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.194827 andYValue:38.755224]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195012 andYValue:38.755082]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195041 andYValue:38.755104]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195028 andYValue:38.755116]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195090 andYValue:38.755167]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195106 andYValue:38.755154]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195205 andYValue:38.755233]];
    [ring1 addPoint:[[SFPoint alloc] initWithXValue:-77.195299 andYValue:38.755159]];
    [polygon1 addRing:ring1];
    
    [polygons addObject:polygon1];
    [polygonNames addObject:@"NGA Visitor Center"];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"polygon2" andType:SF_POLYGON andGeometries:polygons andNames:polygonNames];
    
    NSMutableArray<SFGeometry *> *geometries = [[NSMutableArray alloc] init];
    NSMutableArray<NSString *> *geometryNames = [[NSMutableArray alloc] init];
    [geometries addObjectsFromArray:points];
    [geometryNames addObjectsFromArray:pointNames];
    [geometries addObjectsFromArray:lines];
    [geometryNames addObjectsFromArray:lineNames];
    [geometries addObjectsFromArray:polygons];
    [geometryNames addObjectsFromArray:polygonNames];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:@"geometry2" andType:SF_GEOMETRY andGeometries:geometries andNames:geometryNames];
    
}

+(void) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs andTableName: (NSString *) tableName andType: (enum SFGeometryType) type andGeometry: (SFGeometry *) geometry andName: (NSString *) name{
    
    NSMutableArray<SFGeometry *> *geometries = [[NSMutableArray alloc] init];
    [geometries addObject:geometry];
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];
    [names addObject:name];
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:tableName andType:type andGeometries:geometries andNames:names];
}

+(void) createFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andSrs: (GPKGSpatialReferenceSystem *) srs andTableName: (NSString *) tableName andType: (enum SFGeometryType) type andGeometries: (NSArray<SFGeometry *> *) geometries andNames: (NSArray<NSString *> *) names{

    SFGeometryEnvelope *envelope = nil;
    for(SFGeometry *geometry in geometries){
        if(envelope == nil){
            envelope = [SFGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
        }else{
            [SFGeometryEnvelopeBuilder buildEnvelope:envelope andGeometry:geometry];
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
    
    [columns addObject:[GPKGFeatureColumn createPrimaryKeyColumnWithName:ID_COLUMN]];
    [columns addObject:[GPKGFeatureColumn createGeometryColumnWithName:GEOMETRY_COLUMN andGeometryType:type andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:TEXT_COLUMN andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:REAL_COLUMN andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BOOLEAN_COLUMN andDataType:GPKG_DT_BOOLEAN andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BLOB_COLUMN andDataType:GPKG_DT_BLOB andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:INTEGER_COLUMN andDataType:GPKG_DT_INTEGER andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:TEXT_LIMITED_COLUMN andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BLOB_LIMITED_COLUMN andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:DATE_COLUMN andDataType:GPKG_DT_DATE andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:DATETIME_COLUMN andDataType:GPKG_DT_DATETIME andNotNull:NO andDefaultValue:nil]];

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
        
        SFGeometry *geometry = [geometries objectAtIndex:i];
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
        [tileMatrix setPixelXSizeValue:pixelXSize];
        [tileMatrix setPixelYSizeValue:pixelYSize];
        [tileMatrixDao create:tileMatrix];
        
        tileGrid = [GPKGTileBoundingBoxUtils tileGrid:tileGrid zoomIncrease:1];
        
    }
    
}

+(void) createAttributesWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSMutableArray *columns = [[NSMutableArray alloc] init];
    
    [columns addObject:[GPKGFeatureColumn createColumnWithName:TEXT_COLUMN andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:@""]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:REAL_COLUMN andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BOOLEAN_COLUMN andDataType:GPKG_DT_BOOLEAN andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BLOB_COLUMN andDataType:GPKG_DT_BLOB andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:INTEGER_COLUMN andDataType:GPKG_DT_INTEGER andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:TEXT_LIMITED_COLUMN andDataType:GPKG_DT_TEXT andMax:[NSNumber numberWithUnsignedInteger:[[NSProcessInfo processInfo] globallyUniqueString].length] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:BLOB_LIMITED_COLUMN andDataType:GPKG_DT_BLOB andMax:[NSNumber numberWithUnsignedInteger:[[[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding] length]] andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:DATE_COLUMN andDataType:GPKG_DT_DATE andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:DATETIME_COLUMN andDataType:GPKG_DT_DATETIME andNotNull:NO andDefaultValue:nil]];
    
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
        [indexer close];
    }
    
}

+(void) createFeatureTileLinkExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSArray *featureTables = [geoPackage getFeatureTables];
    for(NSString *featureTable in featureTables){
        
        GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        GPKGBoundingBox *boundingBox = [featureDao getBoundingBox];
        SFPProjection *projection = featureDao.projection;
        
        SFPProjection *requestProjection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR];
        SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:requestProjection];
        GPKGBoundingBox *requestBoundingBox = [boundingBox transform:transform];
        
        int zoomLevel = [GPKGTileBoundingBoxUtils getZoomLevelWithWebMercatorBoundingBox:requestBoundingBox];
        zoomLevel = MAX(zoomLevel, 8);
        zoomLevel = MIN(zoomLevel, 19);
        
        int minZoom = zoomLevel - 8;
        int maxZoom = zoomLevel + 2;
        
        GPKGTileGenerator *tileGenerator = [[GPKGFeatureTileGenerator alloc] initWithGeoPackage:geoPackage andTableName:[NSString stringWithFormat:@"%@_tiles", featureTable] andFeatureTiles:featureTiles andMinZoom:minZoom andMaxZoom:maxZoom andBoundingBox:requestBoundingBox andProjection:requestProjection];
        
        [tileGenerator generateTiles];
        [featureTiles close];
    }
    
}

static int dataColumnConstraintIndex = 0;

+(void) createSchemaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    [geoPackage createDataColumnConstraintsTable];
    
    GPKGDataColumnConstraintsDao *dao = [geoPackage getDataColumnConstraintsDao];
    
    GPKGDataColumnConstraints * sampleRange = [[GPKGDataColumnConstraints alloc] init];
    [sampleRange setConstraintName:@"sampleRange"];
    [sampleRange setDataColumnConstraintType:GPKG_DCCT_RANGE];
    [sampleRange setMinValue:1.0];
    [sampleRange setMinIsInclusiveValue:true];
    [sampleRange setMaxValue:10.0];
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
    
    SFCircularString *circularString = [[SFCircularString alloc] init];
    [circularString addPoint:[[SFPoint alloc] initWithXValue:-122.358 andYValue:47.653]];
    [circularString addPoint:[[SFPoint alloc] initWithXValue:-122.348 andYValue:47.649]];
    [circularString addPoint:[[SFPoint alloc] initWithXValue:-122.348 andYValue:47.658]];
    [circularString addPoint:[[SFPoint alloc] initWithXValue:-122.358 andYValue:47.658]];
    [circularString addPoint:[[SFPoint alloc] initWithXValue:-122.358 andYValue:47.653]];
    
    for(int i = (int)SF_CIRCULARSTRING; i <= (int)SF_SURFACE; i++){
        
        enum SFGeometryType geometryType = i;
        [extensions getOrCreateWithTable:tableName andColumn:GEOMETRY_COLUMN andType:geometryType];
        
        SFGeometry *geometry = nil;
        NSString *name = [SFGeometryTypes name:geometryType];
        
        switch (geometryType) {
            case SF_CIRCULARSTRING:
                geometry = circularString;
                break;
            case SF_COMPOUNDCURVE:
                {
                    SFCompoundCurve *compoundCurve = [[SFCompoundCurve alloc] init];
                    [compoundCurve addLineString:circularString];
                    geometry = compoundCurve;
                }
                break;
            case SF_CURVEPOLYGON:
                {
                    SFCurvePolygon *curvePolygon = [[SFCurvePolygon alloc] init];
                    [curvePolygon addRing:circularString];
                    geometry = curvePolygon;
                }
                break;
            case SF_MULTICURVE:
                {
                    SFMultiLineString *multiCurve = [[SFMultiLineString alloc] init];
                    [multiCurve addLineString:circularString];
                    geometry = multiCurve;
                }
                break;
            case SF_MULTISURFACE:
                {
                    SFMultiPolygon *multiSurface = [[SFMultiPolygon alloc] init];
                    SFPolygon *polygon = [[SFPolygon alloc] init];
                    [polygon addRing:circularString];
                    [multiSurface addPolygon:polygon];
                    geometry = multiSurface;
                }
                break;
            case SF_CURVE:
                {
                    SFCompoundCurve *curve = [[SFCompoundCurve alloc] init];
                    [curve addLineString:circularString];
                    geometry = curve;
                }
                break;
            case SF_SURFACE:
                {
                    SFCurvePolygon *surface = [[SFCurvePolygon alloc] init];
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
    
    [self createFeaturesWithGeoPackage:geoPackage andSrs:srs andTableName:tableName andType:SF_GEOMETRY andGeometries:geometries andNames:geometryNames];
    
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
    
    int contentsEpsg = PROJ_EPSG_WEB_MERCATOR;
    int tileMatrixSetEpsg = PROJ_EPSG_WEB_MERCATOR;
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    
    GPKGSpatialReferenceSystem *contentsSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:contentsEpsg]];
    GPKGSpatialReferenceSystem *tileMatrixSetSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:tileMatrixSetEpsg]];
    
    SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:[tileMatrixSetSrs projection] andToProjection:[contentsSrs projection]];
    GPKGBoundingBox *contentsBoundingBox = nil;
    if(![transform isSameProjection]){
        contentsBoundingBox = [bbox transform:transform];
    }
    
    GPKGCoverageDataPng *coverageData = [GPKGCoverageDataPng createTileTableWithGeoPackage:geoPackage andTableName:@"coverage_png" andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrs.srsId andTileMatrixSetBoundingBox:bbox andTileMatrixSetSrsId:tileMatrixSetSrs.srsId];
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
    [tileMatrix setPixelXSizeValue:([bbox.maxLongitude doubleValue] - [bbox.minLongitude doubleValue]) / width / tileWidth];
    [tileMatrix setPixelYSizeValue:([bbox.maxLatitude doubleValue] - [bbox.minLatitude doubleValue]) / height / tileHeight];
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
    
    int contentsEpsg = PROJ_EPSG_WEB_MERCATOR;
    int tileMatrixSetEpsg = PROJ_EPSG_WEB_MERCATOR;
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage getSpatialReferenceSystemDao];
    [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D]];
    
    GPKGSpatialReferenceSystem *contentsSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:contentsEpsg]];
    GPKGSpatialReferenceSystem *tileMatrixSetSrs = [srsDao getOrCreateWithEpsg:[NSNumber numberWithInt:tileMatrixSetEpsg]];
    
    SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:[tileMatrixSetSrs projection] andToProjection:[contentsSrs projection]];
    GPKGBoundingBox *contentsBoundingBox = nil;
    if(![transform isSameProjection]){
        contentsBoundingBox = [bbox transform:transform];
    }
    
    GPKGCoverageDataTiff *coverageData = [GPKGCoverageDataTiff createTileTableWithGeoPackage:geoPackage andTableName:@"coverage_tiff" andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrs.srsId andTileMatrixSetBoundingBox:bbox andTileMatrixSetSrsId:tileMatrixSetSrs.srsId];
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
    [tileMatrix setPixelXSizeValue:([bbox.maxLongitude doubleValue] - [bbox.minLongitude doubleValue]) / width / tileWidth];
    [tileMatrix setPixelYSizeValue:([bbox.maxLatitude doubleValue] - [bbox.minLatitude doubleValue]) / height / tileHeight];
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

+(void) createRelatedTablesMediaExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray<GPKGUserCustomColumn *> *additionalMediaColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    GPKGMediaTable *mediaTable = [GPKGMediaTable createWithName:@"media" andAdditionalColumns:additionalMediaColumns];
    
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    
    NSString *tableName1 = @"geometry1";
    GPKGUserMappingTable *userMappingTable1 = [GPKGUserMappingTable createWithName:[NSString stringWithFormat:@"%@_%@", tableName1, mediaTable.tableName] andAdditionalColumns:additionalMappingColumns];
    GPKGExtendedRelation *relation1 = [relatedTables addMediaRelationshipWithBaseTable:tableName1 andMediaTable:mediaTable andUserMappingTable:userMappingTable1];
    
    [self insertRelatedTablesMediaExtensionRowsWithGeoPackage:geoPackage andRelation:relation1 andQuery:@"BIT Systems%" andName:@"BIT Systems" andFile:@"BITSystems_Logo.png" andContentType:@"image/png" andDescription:@"BIT Systems Logo" andSource:@"http://www.bit-sys.com"];
    
    NSString *tableName2 = @"geometry2";
    GPKGUserMappingTable *userMappingTable2 = [GPKGUserMappingTable createWithName:[NSString stringWithFormat:@"%@_%@", tableName2, mediaTable.tableName] andAdditionalColumns:additionalMappingColumns];
    GPKGExtendedRelation *relation2 = [relatedTables addMediaRelationshipWithBaseTable:tableName2 andMediaTable:mediaTable andUserMappingTable:userMappingTable2];
    
    [self insertRelatedTablesMediaExtensionRowsWithGeoPackage:geoPackage andRelation:relation2 andQuery:@"NGA%" andName:@"NGA" andFile:@"NGA_Logo.png" andContentType:@"image/png" andDescription:@"NGA Logo" andSource:@"http://www.nga.mil"];
    [self insertRelatedTablesMediaExtensionRowsWithGeoPackage:geoPackage andRelation:relation2 andQuery:@"NGA" andName:@"NGA" andFile:@"NGA.jpg" andContentType:@"image/jpeg" andDescription:@"Aerial View of NGA East" andSource:@"http://www.nga.mil"];
    
}

+(void) insertRelatedTablesMediaExtensionRowsWithGeoPackage: (GPKGGeoPackage *) geoPackage andRelation: (GPKGExtendedRelation *) relation andQuery: (NSString *) query andName: (NSString *) name andFile: (NSString *) file andContentType: (NSString *) contentType andDescription: (NSString *) description andSource: (NSString *) source{
    
    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:relation.baseTableName];
    GPKGMediaDao *mediaDao = [relatedTables mediaDaoForRelation:relation];
    GPKGUserMappingDao *userMappingDao = [relatedTables mappingDaoForRelation:relation];
    
    GPKGMediaRow *mediaRow = [mediaDao newRow];
    NSString *mediaPath  = [[[NSBundle bundleForClass:[GPKGGeoPackageExample class]] resourcePath] stringByAppendingPathComponent:file];
    NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:mediaPath];
    [mediaRow setData:mediaData];
    [mediaRow setContentType:contentType];
    [GPKGRelatedTablesUtils populateUserRowWithTable:[mediaDao table] andRow:mediaRow andSkipColumns:[GPKGMediaTable requiredColumns]];
    [GPKGDublinCoreMetadata setValue:name asColumn:GPKG_DCM_TITLE inRow:mediaRow];
    [GPKGDublinCoreMetadata setValue:description asColumn:GPKG_DCM_DESCRIPTION inRow:mediaRow];
    [GPKGDublinCoreMetadata setValue:source asColumn:GPKG_DCM_SOURCE inRow:mediaRow];
    int mediaRowId = (int)[mediaDao create:mediaRow];
    
    GPKGResultSet *featureResultSet = [featureDao queryForLikeWithField:TEXT_COLUMN andValue:query];
    while([featureResultSet moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao getFeatureRow:featureResultSet];
        GPKGUserMappingRow *userMappingRow = [userMappingDao newRow];
        [userMappingRow setBaseId:[featureRow idValue]];
        [userMappingRow setRelatedId:mediaRowId];
        [GPKGRelatedTablesUtils populateUserRowWithTable:[userMappingDao table] andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        NSString *featureName = (NSString *)[featureRow valueWithColumnName:TEXT_COLUMN];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", featureName, name] asColumn:GPKG_DCM_TITLE inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", featureName, description] asColumn:GPKG_DCM_DESCRIPTION inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:source asColumn:GPKG_DCM_SOURCE inRow:userMappingRow];
        [userMappingDao create:userMappingRow];
    }
    [featureResultSet close];
    
}

+(void) createRelatedTablesFeaturesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [self createRelatedTablesFeaturesExtensionWithGeoPackage:geoPackage andTableName1:@"point1" andTableName2:@"polygon1"];
    
    [self createRelatedTablesFeaturesExtensionWithGeoPackage:geoPackage andTableName1:@"point2" andTableName2:@"line2"];
    
}

+(void) createRelatedTablesFeaturesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName1: (NSString *) tableName1 andTableName2: (NSString *) tableName2{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:[NSString stringWithFormat:@"%@_%@", tableName1, tableName2] andAdditionalColumns:additionalMappingColumns];
    GPKGExtendedRelation *relation = [relatedTables addFeaturesRelationshipWithBaseTable:tableName1 andRelatedTable:tableName2 andUserMappingTable:userMappingTable];
    
    [self insertRelatedTablesFeaturesExtensionRowsWithGeoPackage:geoPackage andRelation:relation];

}

+(void) insertRelatedTablesFeaturesExtensionRowsWithGeoPackage: (GPKGGeoPackage *) geoPackage andRelation: (GPKGExtendedRelation *) relation{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    GPKGUserMappingDao *userMappingDao = [relatedTables mappingDaoForRelation:relation];
    
    GPKGFeatureDao *featureDao1 = [geoPackage getFeatureDaoWithTableName:relation.baseTableName];
    GPKGFeatureDao *featureDao2 = [geoPackage getFeatureDaoWithTableName:relation.relatedTableName];
    
    NSMutableArray<GPKGUserMappingRow *> *userMappingRows = [[NSMutableArray alloc] init];
    
    GPKGResultSet *featureResultSet1 = [featureDao1 queryForAll];
    while([featureResultSet1 moveToNext]){
        
        GPKGFeatureRow *featureRow1 = [featureDao1 getFeatureRow:featureResultSet1];
        NSString *featureName = (NSString *)[featureRow1 valueWithColumnName:TEXT_COLUMN];
        
        GPKGResultSet *featureResultSet2 = [featureDao2 queryForEqWithField:TEXT_COLUMN andValue:featureName];
        while([featureResultSet2 moveToNext]){
            
            GPKGFeatureRow *featureRow2 = [featureDao2 getFeatureRow:featureResultSet2];
            
            GPKGUserMappingRow *userMappingRow = [userMappingDao newRow];
            [userMappingRow setBaseId:[featureRow1 idValue]];
            [userMappingRow setRelatedId:[featureRow2 idValue]];
            [GPKGRelatedTablesUtils populateUserRowWithTable:[userMappingDao table] andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
            [GPKGDublinCoreMetadata setValue:featureName asColumn:GPKG_DCM_TITLE inRow:userMappingRow];
            [GPKGDublinCoreMetadata setValue:featureName asColumn:GPKG_DCM_DESCRIPTION inRow:userMappingRow];
            [GPKGDublinCoreMetadata setValue:featureName asColumn:GPKG_DCM_SOURCE inRow:userMappingRow];
            [userMappingRows addObject:userMappingRow];
        }
        [featureResultSet2 close];
        
    }
    [featureResultSet1 close];
    
    for(GPKGUserMappingRow *userMappingRow in userMappingRows){
        [userMappingDao create:userMappingRow];
    }
    
}

+(void) createRelatedTablesSimpleAttributesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];
    
    NSArray<GPKGUserCustomColumn *> *simpleUserColumns = [GPKGRelatedTablesUtils createSimpleUserColumns];
    GPKGSimpleAttributesTable *simpleTable = [GPKGSimpleAttributesTable createWithName:@"simple_attributes" andColumns:simpleUserColumns];
    
    NSString *tableName = @"attributes";
    
    NSArray<GPKGUserCustomColumn *> *additionalMappingColumns = [GPKGRelatedTablesUtils createAdditionalUserColumns];
    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:[NSString stringWithFormat:@"%@_%@", tableName, simpleTable.tableName] andAdditionalColumns:additionalMappingColumns];
    GPKGExtendedRelation *relation = [relatedTables addSimpleAttributesRelationshipWithBaseTable:tableName andSimpleAttributesTable:simpleTable andUserMappingTable:userMappingTable];
    
    GPKGSimpleAttributesDao *simpleAttributesDao = [relatedTables simpleAttributesDaoForTable:simpleTable];
    NSMutableArray<NSNumber *> *simpleAttributesIds = [[NSMutableArray alloc] init];
    for(int i = 1; i <=3; i++){
        
        GPKGSimpleAttributesRow *simpleAttributesRow = [simpleAttributesDao newRow];
        [GPKGRelatedTablesUtils populateUserRowWithTable:[simpleAttributesRow table] andRow:simpleAttributesRow andSkipColumns:[GPKGSimpleAttributesTable requiredColumns]];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@%d", [GPKGDublinCoreTypes name:GPKG_DCM_TITLE], i] asColumn:GPKG_DCM_TITLE inRow:simpleAttributesRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@%d", [GPKGDublinCoreTypes name:GPKG_DCM_DESCRIPTION], i] asColumn:GPKG_DCM_DESCRIPTION inRow:simpleAttributesRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@%d", [GPKGDublinCoreTypes name:GPKG_DCM_SOURCE], i] asColumn:GPKG_DCM_SOURCE inRow:simpleAttributesRow];
        [simpleAttributesIds addObject:[NSNumber numberWithLongLong:[simpleAttributesDao create:simpleAttributesRow]]];
    }
    
    GPKGUserMappingDao *userMappingDao = [relatedTables mappingDaoForRelation:relation];
    GPKGAttributesDao *attributesDao = [geoPackage getAttributesDaoWithTableName:tableName];
    
    GPKGResultSet *attributesResultSet = [attributesDao queryForAll];
    while([attributesResultSet moveToNext]){
        GPKGAttributesRow *attributesRow = [attributesDao getAttributesRow:attributesResultSet];
        NSNumber *randomSimpleRowId = [simpleAttributesIds objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)simpleAttributesIds.count]];
        GPKGSimpleAttributesRow *simpleAttributesRow = (GPKGSimpleAttributesRow *)[simpleAttributesDao queryForIdObject:randomSimpleRowId];
        
        GPKGUserMappingRow *userMappingRow = [userMappingDao newRow];
        [userMappingRow setBaseId:[attributesRow idValue]];
        [userMappingRow setRelatedId:[simpleAttributesRow idValue]];
        [GPKGRelatedTablesUtils populateUserRowWithTable:[userMappingDao table] andRow:userMappingRow andSkipColumns:[GPKGUserMappingTable requiredColumns]];
        NSString *attributesName = (NSString *)[attributesRow valueWithColumnName:TEXT_COLUMN];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", attributesName, [GPKGDublinCoreMetadata value:GPKG_DCM_TITLE fromRow:simpleAttributesRow]] asColumn:GPKG_DCM_TITLE inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", attributesName, [GPKGDublinCoreMetadata value:GPKG_DCM_DESCRIPTION fromRow:simpleAttributesRow]] asColumn:GPKG_DCM_DESCRIPTION inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", attributesName, [GPKGDublinCoreMetadata value:GPKG_DCM_SOURCE fromRow:simpleAttributesRow]] asColumn:GPKG_DCM_SOURCE inRow:userMappingRow];
        [userMappingDao create:userMappingRow];
    }
    [attributesResultSet close];
    
}

+(void) createTileScalingExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    for(NSString *tileTable in [geoPackage getTileTables]){
        
        GPKGTileTableScaling *tileTableScaling = [[GPKGTileTableScaling alloc] initWithGeoPackage:geoPackage andTableName:tileTable];
        GPKGTileScaling *tileScaling = [[GPKGTileScaling alloc] init];
        [tileScaling setZoomIn:[NSNumber numberWithInt:2]];
        GPKGFeatureTileTableLinker *linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:geoPackage];
        if([linker has] && [linker getFeatureTablesForTileTable:tileTable].count > 0){
            [tileScaling setTileScalingType:GPKG_TSC_IN];
        }else{
            [tileScaling setTileScalingType:GPKG_TSC_IN_OUT];
            [tileScaling setZoomOut:[NSNumber numberWithInt:2]];
        }
        [tileTableScaling create:tileScaling];
        
    }
    
}

+(void) createPropertiesExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGPropertiesExtension *properties = [[GPKGPropertiesExtension alloc] initWithGeoPackage:geoPackage];
    
    NSString *dateTime = [GPKGDateTimeUtils convertToDateTimeStringWithDate:[NSDate date]];
    
    [properties addValue:@"GeoPackage iOS Example" withProperty:GPKG_PE_TITLE];
    [properties addValue:@"3.2.0" withProperty:GPKG_PE_VERSION];
    [properties addValue:@"NGA" withProperty:GPKG_PE_CREATOR];
    [properties addValue:@"NGA" withProperty:GPKG_PE_PUBLISHER];
    [properties addValue:@"Brian Osborn" withProperty:GPKG_PE_CONTRIBUTOR];
    [properties addValue:@"Dan Barela" withProperty:GPKG_PE_CONTRIBUTOR];
    [properties addValue:dateTime withProperty:GPKG_PE_CREATED];
    [properties addValue:dateTime withProperty:GPKG_PE_DATE];
    [properties addValue:dateTime withProperty:GPKG_PE_MODIFIED];
    [properties addValue:@"GeoPackage example created by https://github.com/ngageoint/geopackage-ios/blob/master/geopackage-iosTests/GPKGGeoPackageTestCase.m" withProperty:GPKG_PE_DESCRIPTION];
    [properties addValue:@"geopackage-java" withProperty:GPKG_PE_IDENTIFIER];
    [properties addValue:@"MIT" withProperty:GPKG_PE_LICENSE];
    [properties addValue:@"http://github.com/ngageoint/GeoPackage/blob/master/docs/examples/ios/example.gpkg" withProperty:GPKG_PE_SOURCE];
    [properties addValue:@"Examples" withProperty:GPKG_PE_SUBJECT];
    [properties addValue:@"Examples" withProperty:GPKG_PE_TYPE];
    [properties addValue:@"http://github.com/ngageoint/geopackage-ios" withProperty:GPKG_PE_URI];
    [properties addValue:@"NGA" withProperty:GPKG_PE_TAG];
    [properties addValue:@"Example" withProperty:GPKG_PE_TAG];
    [properties addValue:@"BIT Systems" withProperty:GPKG_PE_TAG];
    
}

+(void) createContentsIdExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGContentsIdExtension *contentsId = [[GPKGContentsIdExtension alloc] initWithGeoPackage:geoPackage];
    [contentsId createIdsForType:GPKG_CDT_FEATURES];
    
}

+(void) createFeatureStyleExtensionWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    NSMutableArray<GPKGStyleRow *> *styles = [[NSMutableArray alloc] init];
    
    GPKGStyleRow *style1 = [[GPKGStyleRow alloc] init];
    [style1 setName:@"Green"];
    [style1 setDescription:@"Green Style"];
    [style1 setHexColor:GPKG_COLOR_GREEN];
    [style1 setWidthValue:2.0];
    [styles addObject:style1];
    
    GPKGStyleRow *style2 = [[GPKGStyleRow alloc] init];
    [style2 setName:@"Blue with Red Fill"];
    [style2 setDescription:@"Blue with Red Fill Style"];
    [style2 setColor:[[GPKGColor alloc] initWithHex:GPKG_COLOR_BLUE]];
    [style2 setFillColor:[[GPKGColor alloc] initWithRed:255 andGreen:0 andBlue:0 andOpacity:.4f]];
    [styles addObject:style2];
    
    GPKGStyleRow *style3 = [[GPKGStyleRow alloc] init];
    [style3 setName:@"Orange"];
    [style3 setDescription:@"Orange Style"];
    [style3 setColor:[[GPKGColor alloc] initWithColor:0xFFA500]];
    [style3 setWidthValue:6.5];
    [styles addObject:style3];
    
    GPKGStyleRow *style4 = [[GPKGStyleRow alloc] init];
    [style4 setName:@"Violet with Yellow Fill"];
    [style4 setDescription:@"Violet with Yellow Fill Style"];
    [style4 setColor:[[GPKGColor alloc] initWithRed:138 andGreen:43 andBlue:226]];
    [style4 setWidthValue:4.1];
    [style4 setFillColor:[[GPKGColor alloc] initWithHue:61 andSaturation:.89f andLightness:.72f andAlpha:.3f]];
    [styles addObject:style4];

    NSMutableArray<GPKGIconRow *> *icons = [[NSMutableArray alloc] init];
    
    NSString *buildingPath  = [[[NSBundle bundleForClass:[GPKGGeoPackageExample class]] resourcePath] stringByAppendingPathComponent:@"building.png"];
    GPKGIconRow *icon1 = [[GPKGIconRow alloc] init];
    [icon1 setName:@"Building"];
    [icon1 setDescription:@"Building Icon"];
    [icon1 setData:[[NSFileManager defaultManager] contentsAtPath:buildingPath]];
    [icon1 setContentType:@"image/png"];
    [icon1 setWidthValue:32.0];
    [icon1 setAnchorUValue:0.5];
    [icon1 setAnchorVValue:1.0];
    [icons addObject:icon1];
    
    NSString *collegePath  = [[[NSBundle bundleForClass:[GPKGGeoPackageExample class]] resourcePath] stringByAppendingPathComponent:@"college.png"];
    GPKGIconRow *icon2 = [[GPKGIconRow alloc] init];
    [icon2 setName:@"College"];
    [icon2 setDescription:@"College Icon"];
    [icon2 setData:[[NSFileManager defaultManager] contentsAtPath:collegePath]];
    [icon2 setContentType:@"image/png"];
    [icon2 setWidthValue:32.0];
    [icon2 setHeightValue:44.0];
    [icons addObject:icon2];

    NSString *tractorPath  = [[[NSBundle bundleForClass:[GPKGGeoPackageExample class]] resourcePath] stringByAppendingPathComponent:@"tractor.png"];
    GPKGIconRow *icon3 = [[GPKGIconRow alloc] init];
    [icon3 setName:@"Tractor"];
    [icon3 setDescription:@"Tractor Icon"];
    [icon3 setData:[[NSFileManager defaultManager] contentsAtPath:tractorPath]];
    [icon3 setContentType:@"image/png"];
    [icon3 setAnchorVValue:1.0];
    [icons addObject:icon3];
    
    [self createFeatureStylesGeometry1WithGeoPackage:geoPackage andStyles:styles andIcons:icons];
    [self createFeatureStylesGeometry2WithGeoPackage:geoPackage andStyles:styles andIcons:icons];
}

+(void) createFeatureStylesGeometry1WithGeoPackage: (GPKGGeoPackage *) geoPackage andStyles: (NSArray<GPKGStyleRow *> *) styles andIcons: (NSArray<GPKGIconRow *> *) icons{
    
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:@"geometry1"];
    GPKGFeatureTableStyles *geometry1Styles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:[featureDao getFeatureTable]];
    
    [geometry1Styles setTableStyleDefault:[styles objectAtIndex:0]];
    [geometry1Styles setTableStyle:[styles objectAtIndex:1] withGeometryType:SF_POLYGON];
    [geometry1Styles setTableStyle:[styles objectAtIndex:2] withGeometryType:SF_POINT];
    
    [geometry1Styles createStyleRelationship];
    [geometry1Styles createIconRelationship];
    
    int pointCount = 0;
    int lineCount = 0;
    int polygonCount = 0;
    
    GPKGResultSet *features = [featureDao queryForAll];
    while([features moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao getFeatureRow:features];
        switch ([featureRow getGeometryType]) {
            case SF_POINT:
                pointCount++;
                switch (pointCount) {
                    case 1:
                        [geometry1Styles setIcon:[icons objectAtIndex:0] withFeature:featureRow];
                        break;
                    case 2:
                        [geometry1Styles setIcon:[icons objectAtIndex:1] withFeature:featureRow];
                        break;
                    case 3:
                        [geometry1Styles setIcon:[icons objectAtIndex:2] withFeature:featureRow];
                        break;
                }
                break;
            case SF_LINESTRING:
                lineCount++;
                switch (lineCount) {
                    case 2:
                        [geometry1Styles setStyle:[styles objectAtIndex:1] withFeature:featureRow];
                        break;
                    case 3:
                        [geometry1Styles setStyle:[styles objectAtIndex:2] withFeature:featureRow];
                        break;
                }
                break;
            case SF_POLYGON:
                polygonCount++;
                switch (polygonCount) {
                    case 2:
                        [geometry1Styles setStyle:[styles objectAtIndex:3] withFeature:featureRow];
                        break;
                    case 3:
                        [geometry1Styles setStyle:[styles objectAtIndex:2] withFeature:featureRow];
                        break;
                }
                break;
            default:
                break;
        }
    }
    [features close];
    
}

+(void) createFeatureStylesGeometry2WithGeoPackage: (GPKGGeoPackage *) geoPackage andStyles: (NSArray<GPKGStyleRow *> *) styles andIcons: (NSArray<GPKGIconRow *> *) icons{
    
    GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:@"geometry2"];
    GPKGFeatureTableStyles *geometry2Styles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:[featureDao getFeatureTable]];
    
    [geometry2Styles setTableStyle:[styles objectAtIndex:0] withGeometryType:SF_POINT];
    [geometry2Styles setTableStyle:[styles objectAtIndex:1] withGeometryType:SF_LINESTRING];
    [geometry2Styles setTableStyle:[styles objectAtIndex:0] withGeometryType:SF_POLYGON];
    [geometry2Styles setTableStyle:[styles objectAtIndex:2] withGeometryType:SF_GEOMETRY];
    
    [geometry2Styles createStyleRelationship];
    [geometry2Styles createIconRelationship];
    
    GPKGResultSet *features = [featureDao queryForAll];
    while([features moveToNext]){
        GPKGFeatureRow *featureRow = [featureDao getFeatureRow:features];
        switch ([featureRow getGeometryType]) {
            case SF_POINT:
                [geometry2Styles setIcon:[icons objectAtIndex:0] withFeature:featureRow];
                break;
            case SF_LINESTRING:
                [geometry2Styles setStyle:[styles objectAtIndex:0] withFeature:featureRow];
                break;
            case SF_POLYGON:
                [geometry2Styles setStyle:[styles objectAtIndex:1] withFeature:featureRow];
                break;
            default:
                break;
        }
    }
    [features close];
    
}

@end
