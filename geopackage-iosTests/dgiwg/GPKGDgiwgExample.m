//
//  GPKGDgiwgExample.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/2/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgExample.h"
#import "GPKGDgiwgExampleCreate.h"
#import "GPKGDgiwgGeoPackageFactory.h"
#import "GPKGTestUtils.h"
#import "GPKGTestConstants.h"
#import "GPKGIOUtils.h"
#import "GPKGDgiwgConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGMetadataExtension.h"
#import "GPKGSchemaExtension.h"
#import "GPKGCoverageDataTiff.h"
#import "GPKGUtils.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGDublinCoreMetadata.h"

@implementation GPKGDgiwgExample

static BOOL FEATURES = YES;
static BOOL TILES = YES;
static BOOL NATIONAL_METADATA = YES;
static BOOL FEATURES_METADATA = YES;
static BOOL TILES_METADATA = YES;
static BOOL SCHEMA = YES;
static BOOL COVERAGE_DATA = YES;
static BOOL RELATED_TABLES_MEDIA = YES;
static BOOL RELATED_TABLES_TILES = YES;

static NSString *PRODUCER = @"NGA";
static NSString *DATA_PRODUCT = @"DGIWG-Example";
static NSString *GEOGRAPHIC_COVERAGE_AREA = @"Ft-Belvoir";
static int MIN_ZOOM = 15;
static int MAX_ZOOM = 16;
static int MAJOR_VERSION = 1;
static int MINOR_VERSION = 0;

static NSString *FEATURE_TABLE = @"nga_features";
static NSString *FEATURE_IDENTIFIER = @"NGA Features";
static NSString *FEATURE_DESCRIPTION = @"DGIWG Features example";
static NSString *FEATURE_NAME_COLUMN = @"name";
static NSString *FEATURE_NUMBER_COLUMN = @"number";

static NSString *TILE_TABLE = @"nga_tiles";
static NSString *TILE_IDENTIFIER = @"NGA Tiles";
static NSString *TILE_DESCRIPTION = @"DGIWG Tiles example";

static NSString *COVERAGE_DATA_TABLE = @"nga_coverage_data";
static NSString *COVERAGE_DATA_IDENTIFIER = @"NGA Coverage Data";
static NSString *COVERAGE_DATA_DESCRIPTION = @"DGIWG Coverage Data example";

static NSString *MEDIA_TABLE = @"media";
static NSString *MEDIA_MAPPING_TABLE = @"nga_features_media";

static NSString *TILE_MAPPING_TABLE = @"nga_features_tiles";

/**
 * Test making the GeoPackage example with specified parts
 */
-(void) testExample{
    
    GPKGDgiwgExampleCreate *create = [GPKGDgiwgExampleCreate base];
    create.features = FEATURES;
    create.tiles = TILES;
    create.nationalMetadata = NATIONAL_METADATA;
    create.featuresMetadata = FEATURES_METADATA;
    create.tilesMetadata = TILES_METADATA;
    create.schema = SCHEMA;
    create.coverage = COVERAGE_DATA;
    create.relatedMedia = RELATED_TABLES_MEDIA;
    create.relatedTiles = RELATED_TABLES_TILES;
    
    [self testExample:create];
}

/**
 * Test making the base GeoPackage example
 */
-(void) testExampleBase{
    [self testExample:[GPKGDgiwgExampleCreate base]];
}

/**
 * Test making the GeoPackage example with all parts
 */
-(void) testExampleAll{
    [self testExample:[GPKGDgiwgExampleCreate all]];
}

/**
 * Test making the GeoPackage example with features and tiles
 */
-(void) testExampleFeaturesAndTiles{
    [self testExample:[GPKGDgiwgExampleCreate featuresAndTiles]];
}

/**
 * Test making the GeoPackage example with features
 */
-(void) testExampleFeatures{
    [self testExample:[GPKGDgiwgExampleCreate features]];
}

/**
 * Test making the GeoPackage example with tiles
 */
-(void) testExampleTiles{
    [self testExample:[GPKGDgiwgExampleCreate tiles]];
}

/**
 * Test making the GeoPackage example
 *
 * @param create create parts
 */
-(void) testExample: (GPKGDgiwgExampleCreate *) create{
    
    GPKGDgiwgFileName *fileName = [self fileName];
    
    GPKGDgiwgFile *file = [self createWithFileName:fileName andCreate:create];
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:file];
    [GPKGTestUtils assertNotNil:geoPackage];
    [geoPackage close];
    
    [GPKGTestUtils assertTrue:[manager deleteDGIWG:file]];
}

/**
 * Get the file name
 *
 * @return file name
 */
-(GPKGDgiwgFileName *) fileName{
    
    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] init];
    
    [fileName setProducer:PRODUCER];
    [fileName setDataProduct:DATA_PRODUCT];
    [fileName setGeographicCoverageArea:GEOGRAPHIC_COVERAGE_AREA];
    [fileName setZoomLevelRangeWithMin:MIN_ZOOM andMax:MAX_ZOOM];
    [fileName setVersionWithMajor:MAJOR_VERSION andMinor:MINOR_VERSION];
    [fileName setCreationDate:[NSDate date]];
    
    return fileName;
}

/**
 * Create the GeoPackage example file
 *
 * @param fileName file name
 * @param create   create parts
 * @return GeoPackage file
 */
-(GPKGDgiwgFile *) createWithFileName: (GPKGDgiwgFileName *) fileName andCreate: (GPKGDgiwgExampleCreate *) create{
    
    NSLog(@"Creating: %@", [fileName name]);
    GPKGDgiwgGeoPackage *geoPackage = [GPKGDgiwgExample createWithFileName:fileName];
    
    NSLog(@"National Metadata Extension: %s", create.nationalMetadata ? "Yes" : "No");
    if(create.nationalMetadata){
        [GPKGDgiwgExample createNationalMetadataExtension:geoPackage];
    }
    
    NSLog(@"Features: %s", create.features ? "Yes" : "No");
    if(create.features){
        
        [GPKGDgiwgExample createFeatures:geoPackage];
        
        NSLog(@"Features Metadata Extension: %s", create.featuresMetadata ? "Yes" : "No");
        if(create.featuresMetadata){
            [GPKGDgiwgExample createFeaturesMetadataExtension:geoPackage];
        }
        
        NSLog(@"Schema Extension: %s", create.schema ? "Yes" : "No");
        if(create.schema){
            [GPKGDgiwgExample createSchemaExtension:geoPackage];
        }
        
        NSLog(@"Related Tables Media Extension: %s", create.relatedMedia ? "Yes" : "No");
        if(create.relatedMedia){
            [GPKGDgiwgExample createRelatedTablesMediaExtension:geoPackage];
        }
        
    }else{
        NSLog(@"Features Metadata Extension: %s", create.features ? "Yes" : "No");
        NSLog(@"Schema Extension: %s", create.features ? "Yes" : "No");
        NSLog(@"Related Tables Media Extension: %s", create.features ? "Yes" : "No");
    }
    
    NSLog(@"Tiles: %s", create.tiles ? "Yes" : "No");
    if(create.tiles){
        
        [GPKGDgiwgExample createTiles:geoPackage];
        
        NSLog(@"Tiles Metadata Extension: %s", create.tilesMetadata ? "Yes" : "No");
        if(create.tilesMetadata){
            [GPKGDgiwgExample createTilesMetadataExtension:geoPackage];
        }
        
        NSLog(@"Coverage Data: %s", create.coverage ? "Yes" : "No");
        if(create.coverage){
            [GPKGDgiwgExample createCoverageDataExtension:geoPackage];
        }
        
        BOOL relatedTablesTiles = create.relatedTiles && create.features;
        NSLog(@"Related Tables Tiles Extension: %s", relatedTablesTiles ? "Yes" : "No");
        if(relatedTablesTiles){
            [GPKGDgiwgExample createRelatedTablesTilesExtension:geoPackage];
        }
        
    }else{
        NSLog(@"Tiles Metadata Extension: %s", create.tiles ? "Yes" : "No");
        NSLog(@"Coverage Data: %s", create.tiles ? "Yes" : "No");
        NSLog(@"Related Tables Tiles Extension: %s", create.tiles ? "Yes" : "No");
    }
    
    GPKGDgiwgValidationErrors *errors = [geoPackage validate];
    if([errors hasErrors]){
        NSLog(@"%@", errors);
    }
    [GPKGTestUtils assertTrue:[geoPackage isValid]];
    
    [geoPackage close];
    [GPKGDgiwgExample exportWithFileName:fileName];
    
    return [geoPackage file];
}

+(void) exportWithFileName: (GPKGDgiwgFileName *) fileName{
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    
    NSString *exportDirectory = [GPKGIOUtils documentsDirectory];
    
    NSString *geoPackageName = [fileName name];
    NSString *name = [NSString stringWithFormat:@"%@-%.0f", geoPackageName, [[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString *exportedFile = [manager exportGeoPackage:geoPackageName withName:name toDirectory:exportDirectory];
    
    NSLog(@"Created: %@", exportedFile);
}

/**
 * Create the GeoPackage
 *
 * @param fileName file name
 * @return GeoPackage
 */
+(GPKGDgiwgGeoPackage *) createWithFileName: (GPKGDgiwgFileName *) fileName{
    
    GPKGDgiwgGeoPackageManager *manager = [GPKGDgiwgGeoPackageFactory manager];
    
    NSString *geoPackageName = [fileName name];
    
    [manager delete:geoPackageName];
    
    GPKGDgiwgFile *file = [manager create:geoPackageName withMetadata:[self metadataWithName:GPKG_TEST_DGIWG_METADATA_1]];
    
    GPKGDgiwgGeoPackage *geoPackage = [manager openDGIWG:file];
    if(geoPackage == nil){
        [NSException raise:@"Open Failed" format:@"Failed to open database"];
    }
    
    return geoPackage;
}

/**
 * Get the example metadata
 *
 * @param name    metadata name
 * @return metadata
 */
+(NSString *) metadataWithName: (NSString *) name{
    NSString *metadataPath  = [[[NSBundle bundleForClass:[GPKGDgiwgExample class]] resourcePath] stringByAppendingPathComponent:name];
    NSData *metadataData = [[NSFileManager defaultManager] contentsAtPath:metadataPath];
    NSString *metadata = [[NSString alloc] initWithData:metadataData encoding:NSUTF8StringEncoding];
    return metadata;
}

/**
 * Create features
 *
 * @param geoPackage GeoPackage
 */
+(void) createFeatures: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_4326];
    
    NSMutableArray<GPKGFeatureColumn *> *columns = [NSMutableArray array];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:FEATURE_NAME_COLUMN andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGFeatureColumn createColumnWithName:FEATURE_NUMBER_COLUMN andDataType:GPKG_DT_INTEGER]];
    GPKGGeometryColumns *geometryColumns = [geoPackage createFeaturesWithTable:FEATURE_TABLE andIdentifier:FEATURE_IDENTIFIER andDescription:FEATURE_DESCRIPTION andGeometryType:SF_GEOMETRY andColumns:columns andCRS:crs];
    NSNumber *srsId = geometryColumns.srsId;
    
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    
    SFPoint *point = [SFPoint pointWithXValue:-77.196736 andYValue:38.753370];
    GPKGFeatureRow *pointRow = [featureDao newRow];
    [pointRow setGeometry:[GPKGGeometryData createWithSrsId:srsId andGeometry:point]];
    [pointRow setValueWithColumnName:FEATURE_NAME_COLUMN andValue:@"NGA"];
    [pointRow setValueWithColumnName:FEATURE_NUMBER_COLUMN andValue:[NSNumber numberWithInt:1]];
    [featureDao insert:pointRow];
    
    SFLineString *line = [SFLineString lineString];
    [line addPoint:[SFPoint pointWithXValue:-77.196650 andYValue:38.756501]];
    [line addPoint:[SFPoint pointWithXValue:-77.196414 andYValue:38.755979]];
    [line addPoint:[SFPoint pointWithXValue:-77.195518 andYValue:38.755208]];
    [line addPoint:[SFPoint pointWithXValue:-77.195303 andYValue:38.755272]];
    [line addPoint:[SFPoint pointWithXValue:-77.195351 andYValue:38.755459]];
    [line addPoint:[SFPoint pointWithXValue:-77.195863 andYValue:38.755697]];
    [line addPoint:[SFPoint pointWithXValue:-77.196328 andYValue:38.756069]];
    [line addPoint:[SFPoint pointWithXValue:-77.196568 andYValue:38.756526]];
    GPKGFeatureRow *lineRow = [featureDao newRow];
    [lineRow setGeometry:[GPKGGeometryData createWithSrsId:srsId andGeometry:line]];
    [lineRow setValueWithColumnName:FEATURE_NAME_COLUMN andValue:@"NGA Visitor Center Road"];
    [lineRow setValueWithColumnName:FEATURE_NUMBER_COLUMN andValue:[NSNumber numberWithInt:2]];
    [featureDao insert:lineRow];
    
    SFPolygon *polygon = [SFPolygon polygon];
    SFLineString *ring = [SFLineString lineString];
    [ring addPoint:[SFPoint pointWithXValue:-77.195299 andYValue:38.755159]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195203 andYValue:38.755080]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195410 andYValue:38.754930]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195350 andYValue:38.754884]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195228 andYValue:38.754966]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195135 andYValue:38.754889]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195048 andYValue:38.754956]];
    [ring addPoint:[SFPoint pointWithXValue:-77.194986 andYValue:38.754906]];
    [ring addPoint:[SFPoint pointWithXValue:-77.194897 andYValue:38.754976]];
    [ring addPoint:[SFPoint pointWithXValue:-77.194953 andYValue:38.755025]];
    [ring addPoint:[SFPoint pointWithXValue:-77.194763 andYValue:38.755173]];
    [ring addPoint:[SFPoint pointWithXValue:-77.194827 andYValue:38.755224]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195012 andYValue:38.755082]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195041 andYValue:38.755104]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195028 andYValue:38.755116]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195090 andYValue:38.755167]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195106 andYValue:38.755154]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195205 andYValue:38.755233]];
    [ring addPoint:[SFPoint pointWithXValue:-77.195299 andYValue:38.755159]];
    [polygon addRing:ring];
    GPKGFeatureRow *polygonRow = [featureDao newRow];
    [polygonRow setGeometry:[GPKGGeometryData createWithSrsId:srsId andGeometry:polygon]];
    [polygonRow setValueWithColumnName:FEATURE_NAME_COLUMN andValue:@"NGA Visitor Center"];
    [polygonRow setValueWithColumnName:FEATURE_NUMBER_COLUMN andValue:[NSNumber numberWithInt:3]];
    [featureDao insert:polygonRow];
    
}

/**
 * Create tiles
 *
 * @param geoPackage GeoPackage
 */
+(void) createTiles: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:GPKG_DGIWG_CRS_EPSG_3857];
    
    GPKGBoundingBox *informativeBounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-8593967 andMinLatitudeDouble:4685285 andMaxLongitudeDouble:-8592745 andMaxLatitudeDouble:4687730];
    
    GPKGTileGrid *totalTileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:informativeBounds andZoom:MIN_ZOOM];
    GPKGBoundingBox *extentBounds = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:totalTileGrid andZoom:MIN_ZOOM];
    
    GPKGTileMatrixSet *tileMatrixSet = [geoPackage createTilesWithTable:TILE_TABLE andIdentifier:TILE_IDENTIFIER andDescription:TILE_DESCRIPTION andInformativeBounds:informativeBounds andCRS:crs andExtentBounds:extentBounds];
    
    int matrixWidth = totalTileGrid.width;
    int matrixHeight = totalTileGrid.height;
    
    [geoPackage createTileMatricesWithTileMatrixSet:tileMatrixSet andMinZoom:MIN_ZOOM andMaxZoom:MAX_ZOOM andWidth:matrixWidth andHeight:matrixHeight];
    
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
    
    NSString *resourcePath  = [[NSBundle bundleForClass:[GPKGDgiwgExample class]] resourcePath];
    
    GPKGTileGrid *tileGrid = totalTileGrid;
    
    for(int zoom = MIN_ZOOM; zoom <= MAX_ZOOM; zoom++){
        
        NSString *zoomPath = [NSString stringWithFormat:@"%@/%d_", resourcePath, zoom];
        
        for(int x = tileGrid.minX; x <= tileGrid.maxX; x++){
            
            NSString *xPath = [NSString stringWithFormat:@"%@%d_", zoomPath, x];
            
            for(int y = tileGrid.minY; y <= tileGrid.maxY; y++){
                
                NSString *yPath = [NSString stringWithFormat:@"%@%d.png", xPath, y];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:yPath]){
                    
                    NSData *tileData = [[NSFileManager defaultManager] contentsAtPath:yPath];
                    
                    GPKGTileRow *newRow = [tileDao newRow];
                    
                    [newRow setZoomLevel:zoom];
                    [newRow setTileColumn:x - tileGrid.minX];
                    [newRow setTileRow:y - tileGrid.minY];
                    [newRow setTileData:tileData];
                    
                    [tileDao create:newRow];
                    
                }
                
            }
        }
        
        tileGrid = [GPKGTileBoundingBoxUtils tileGrid:tileGrid zoomIncrease:1];
    }
    
}

/**
 * Create national metadata extension
 *
 * @param geoPackage GeoPackage
 */
+(void) createNationalMetadataExtension: (GPKGDgiwgGeoPackage *) geoPackage{
    
    [geoPackage createGeoPackageDatasetMetadata:[self metadataWithName:GPKG_TEST_NMIS_METADATA_1] withURI:GPKG_DGIWG_NMIS_DEFAULT_URI];
    
}

/**
 * Create features metadata extension
 *
 * @param geoPackage GeoPackage
 */
+(void) createFeaturesMetadataExtension: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    
    [metadataExtension createMetadataTable];
    GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
    
    [metadataExtension createMetadataReferenceTable];
    GPKGMetadataReferenceDao *metadataReferenceDao = [metadataExtension metadataReferenceDao];
    
    GPKGMetadata *metadata = [[GPKGMetadata alloc] init];
    [metadata setMetadataScopeType:GPKG_MST_FEATURE];
    [metadata setStandardUri:GPKG_DGIWG_DMF_DEFAULT_URI];
    [metadata setMimeType:GPKG_DGIWG_METADATA_MIME_TYPE];
    [metadata setMetadata:[self metadataWithName:GPKG_TEST_DGIWG_METADATA_2]];
    [metadataDao create:metadata];
    
    GPKGMetadataReference *reference = [[GPKGMetadataReference alloc] init];
    [reference setReferenceScopeType:GPKG_RST_ROW];
    [reference setTableName:FEATURE_TABLE];
    [reference setRowIdValue:[NSNumber numberWithInt:1]];
    [reference setMetadata:metadata];
    [metadataReferenceDao create:reference];
    
}

/**
 * Create tiles metadata extension
 *
 * @param geoPackage GeoPackage
 */
+(void) createTilesMetadataExtension: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGMetadataExtension *metadataExtension = [[GPKGMetadataExtension alloc] initWithGeoPackage:geoPackage];
    
    [metadataExtension createMetadataTable];
    GPKGMetadataDao *metadataDao = [metadataExtension metadataDao];
    
    [metadataExtension createMetadataReferenceTable];
    GPKGMetadataReferenceDao *metadataReferenceDao = [metadataExtension metadataReferenceDao];
    
    GPKGMetadata *metadata = [[GPKGMetadata alloc] init];
    [metadata setMetadataScopeType:GPKG_MST_MODEL];
    [metadata setStandardUri:GPKG_DGIWG_DMF_DEFAULT_URI];
    [metadata setMimeType:GPKG_DGIWG_METADATA_MIME_TYPE];
    [metadata setMetadata:[self metadataWithName:GPKG_TEST_DGIWG_METADATA_2]];
    [metadataDao create:metadata];
    
    GPKGMetadataReference *reference = [[GPKGMetadataReference alloc] init];
    [reference setReferenceScopeType:GPKG_RST_TABLE];
    [reference setTableName:TILE_TABLE];
    [reference setMetadata:metadata];
    [metadataReferenceDao create:reference];
    
}

/**
 * Create schema extension
 *
 * @param geoPackage GeoPackage
 */
+(void) createSchemaExtension: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    
    [schemaExtension createDataColumnConstraintsTable];
    
    GPKGDataColumnConstraintsDao *dao = [schemaExtension dataColumnConstraintsDao];
    
    GPKGDataColumnConstraints *sampleRange = [[GPKGDataColumnConstraints alloc] init];
    [sampleRange setConstraintName:@"sampleRange"];
    [sampleRange setDataColumnConstraintType:GPKG_DCCT_RANGE];
    [sampleRange setMinValue:1.0];
    [sampleRange setMinIsInclusiveValue:YES];
    [sampleRange setMaxValue:10.0];
    [sampleRange setMaxIsInclusiveValue:YES];
    [sampleRange setTheDescription:@"sampleRange description"];
    [dao create:sampleRange];
    
    [schemaExtension createDataColumnsTable];
    
    GPKGDataColumnsDao *dataColumnsDao = [schemaExtension dataColumnsDao];
    
    GPKGDataColumns *dataColumns = [[GPKGDataColumns alloc] init];
    [dataColumns setContents:[geoPackage contentsOfTable:FEATURE_TABLE]];
    [dataColumns setColumnName:FEATURE_NAME_COLUMN];
    [dataColumns setName:FEATURE_TABLE];
    [dataColumns setTitle:@"Test Title"];
    [dataColumns setTheDescription:@"Test Description"];
    [dataColumns setMimeType:@"Test MIME Type"];
    [dataColumns setConstraintName:sampleRange.constraintName];
    
    [dataColumnsDao create:dataColumns];
    
}

/**
 * Create coverage data extension
 *
 * @param geoPackage GeoPackage
 */
+(void) createCoverageDataExtension: (GPKGDgiwgGeoPackage *) geoPackage{
    
    GPKGTileDao *tileTableDao = [geoPackage tileDaoWithTableName:TILE_TABLE];
    
    GPKGBoundingBox *bbox = [tileTableDao boundingBox];
    
    GPKGTileTableMetadata *metadata = [GPKGTileTableMetadata createWithTable:COVERAGE_DATA_TABLE andContentsBoundingBox:[[tileTableDao contents] boundingBox] andTileBoundingBox:bbox andTileSrsId:[tileTableDao srsId]];
    [metadata setIdentifier:COVERAGE_DATA_IDENTIFIER];
    [metadata setTheDescription:COVERAGE_DATA_DESCRIPTION];
    GPKGCoverageDataTiff *coverageData = [GPKGCoverageDataTiff createTileTableWithGeoPackage:geoPackage andMetadata:metadata];
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
    int height = 2;
    int tileWidth = 4;
    int tileHeight = 4;
    
    GPKGTileMatrixSetDao *tileMatrixSetDao = [geoPackage tileMatrixSetDao];
    GPKGTileMatrixDao *tileMatrixDao = [geoPackage tileMatrixDao];
    
    GPKGTileMatrix *tileMatrix = [[GPKGTileMatrix alloc] init];
    [tileMatrix setContents:[tileMatrixSetDao contents:tileMatrixSet]];
    [tileMatrix setMatrixHeight:[NSNumber numberWithInt:height]];
    [tileMatrix setMatrixWidth:[NSNumber numberWithInt:width]];
    [tileMatrix setTileHeight:[NSNumber numberWithInt:tileHeight]];
    [tileMatrix setTileWidth:[NSNumber numberWithInt:tileWidth]];
    [tileMatrix setPixelXSizeValue:[bbox longitudeRangeValue] / width / tileWidth];
    [tileMatrix setPixelYSizeValue:[bbox latitudeRangeValue] / height / tileHeight];
    [tileMatrix setZoomLevel:[NSNumber numberWithInt:tileTableDao.minZoom]];
    [tileMatrixDao create:tileMatrix];
    
    NSMutableArray *tilePixels = [NSMutableArray arrayWithCapacity:tileHeight];
    
    NSMutableArray *row0 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row0 addObject:[NSNumber numberWithFloat:76.0]];
    [row0 addObject:[NSNumber numberWithFloat:74.0]];
    [row0 addObject:[NSNumber numberWithFloat:70.0]];
    [row0 addObject:[NSNumber numberWithFloat:70.0]];
    [tilePixels addObject:row0];
    
    NSMutableArray *row1 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row1 addObject:[NSNumber numberWithFloat:63.0]];
    [row1 addObject:[NSNumber numberWithFloat:71.0]];
    [row1 addObject:[NSNumber numberWithFloat:65.0]];
    [row1 addObject:[NSNumber numberWithFloat:69.0]];
    [tilePixels addObject:row1];
    
    NSMutableArray *row2 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row2 addObject:[NSNumber numberWithFloat:56.0]];
    [row2 addObject:[NSNumber numberWithFloat:59.0]];
    [row2 addObject:[NSNumber numberWithFloat:65.0]];
    [row2 addObject:[NSNumber numberWithFloat:70.0]];
    [tilePixels addObject:row2];
    
    NSMutableArray *row3 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row3 addObject:[NSNumber numberWithFloat:70.0]];
    [row3 addObject:[NSNumber numberWithFloat:71.0]];
    [row3 addObject:[NSNumber numberWithFloat:70.0]];
    [row3 addObject:[NSNumber numberWithFloat:71.0]];
    [tilePixels addObject:row3];
    
    NSData *imageData = [coverageData drawTileDataWithDoubleArrayPixelValues:tilePixels];
    
    GPKGTileRow *tileRow = [tileDao newRow];
    [tileRow setTileColumn:0];
    [tileRow setTileRow:0];
    [tileRow setZoomLevel:[tileMatrix.zoomLevel intValue]];
    [tileRow setTileData:imageData];
    
    long long tileId = [tileDao create:tileRow];
    
    GPKGGriddedTile *griddedTile = [[GPKGGriddedTile alloc] init];
    [griddedTile setContents:[tileMatrixSetDao contents:tileMatrixSet]];
    [griddedTile setTableId:[NSNumber numberWithLongLong:tileId]];
    
    [griddedTileDao create:griddedTile];
    
    tilePixels = [NSMutableArray arrayWithCapacity:tileHeight];
    
    row0 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row0 addObject:[NSNumber numberWithFloat:51.0]];
    [row0 addObject:[NSNumber numberWithFloat:71.0]];
    [row0 addObject:[NSNumber numberWithFloat:66.0]];
    [row0 addObject:[NSNumber numberWithFloat:70.0]];
    [tilePixels addObject:row0];
    
    row1 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row1 addObject:[NSNumber numberWithFloat:50.0]];
    [row1 addObject:[NSNumber numberWithFloat:62.0]];
    [row1 addObject:[NSNumber numberWithFloat:58.0]];
    [row1 addObject:[NSNumber numberWithFloat:67.0]];
    [tilePixels addObject:row1];
    
    row2 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row2 addObject:[NSNumber numberWithFloat:44.0]];
    [row2 addObject:[NSNumber numberWithFloat:64.0]];
    [row2 addObject:[NSNumber numberWithFloat:61.0]];
    [row2 addObject:[NSNumber numberWithFloat:53.0]];
    [tilePixels addObject:row2];
    
    row3 = [NSMutableArray arrayWithCapacity:tileWidth];
    [row3 addObject:[NSNumber numberWithFloat:55.0]];
    [row3 addObject:[NSNumber numberWithFloat:43.0]];
    [row3 addObject:[NSNumber numberWithFloat:59.0]];
    [row3 addObject:[NSNumber numberWithFloat:46.0]];
    [tilePixels addObject:row3];
    
    imageData = [coverageData drawTileDataWithDoubleArrayPixelValues:tilePixels];
    
    tileRow = [tileDao newRow];
    [tileRow setTileColumn:0];
    [tileRow setTileRow:1];
    [tileRow setZoomLevel:[tileMatrix.zoomLevel intValue]];
    [tileRow setTileData:imageData];
    
    tileId = [tileDao create:tileRow];
    
    griddedTile = [[GPKGGriddedTile alloc] init];
    [griddedTile setContents:[tileMatrixSetDao contents:tileMatrixSet]];
    [griddedTile setTableId:[NSNumber numberWithLongLong:tileId]];
    
    [griddedTileDao create:griddedTile];
    
}

/**
 * Create related tables extension to media
 *
 * @param geoPackage  GeoPackage
 */
+(void) createRelatedTablesMediaExtension: (GPKGDgiwgGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];

    GPKGMediaTable *mediaTable = [GPKGMediaTable createWithMetadata:[GPKGMediaTableMetadata createWithTable:MEDIA_TABLE andAdditionalColumns:[self additionalColumns]]];

    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:MEDIA_MAPPING_TABLE andAdditionalColumns:[self additionalColumns]];
    GPKGExtendedRelation *relation = [relatedTables addMediaRelationshipWithBaseTable:FEATURE_TABLE andMediaTable:mediaTable andUserMappingTable:userMappingTable];

    [self insertRelatedTablesMediaExtensionRows:geoPackage withRelation:relation andQuery:@"NGA%" andName:@"NGA" andFile:@"NGA_Logo.png" andContentType:@"image/png" andDescription:@"NGA Logo" andSource:@"http://www.nga.mil"];
    [self insertRelatedTablesMediaExtensionRows:geoPackage withRelation:relation andQuery:@"NGA" andName:@"NGA" andFile:@"NGA.jpg" andContentType:@"image/jpeg" andDescription:@"Aerial View of NGA East" andSource:@"http://www.nga.mil"];

}

/**
 * Insert related tables media extension rows
 *
 * @param geoPackage  GeoPackage
 * @param relation    extended relation
 * @param query       feature name column query
 * @param name        relation name
 * @param file        media file name
 * @param contentType media content type
 * @param description relation description
 * @param source      relation source
 */
+(void) insertRelatedTablesMediaExtensionRows: (GPKGDgiwgGeoPackage *) geoPackage withRelation: (GPKGExtendedRelation *) relation andQuery: (NSString *) query andName: (NSString *) name andFile: (NSString *) file andContentType: (NSString *) contentType andDescription: (NSString *) description andSource: (NSString *) source{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];

    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:relation.baseTableName];
    GPKGMediaDao *mediaDao = [relatedTables mediaDaoForRelation:relation];
    GPKGUserMappingDao *userMappingDao = [relatedTables mappingDaoForRelation:relation];

    GPKGMediaRow *mediaRow = [mediaDao newRow];

    NSString *mediaPath  = [[[NSBundle bundleForClass:[GPKGDgiwgExample class]] resourcePath] stringByAppendingPathComponent:file];
    NSData *mediaData = [[NSFileManager defaultManager] contentsAtPath:mediaPath];

    [mediaRow setData:mediaData];
    [mediaRow setContentType:contentType];
    [GPKGDublinCoreMetadata setValue:[NSDate date] asColumn:GPKG_DCM_DATE inRow:mediaRow];
    [GPKGDublinCoreMetadata setValue:description asColumn:GPKG_DCM_DESCRIPTION inRow:mediaRow];
    [GPKGDublinCoreMetadata setValue:source asColumn:GPKG_DCM_SOURCE inRow:mediaRow];
    [GPKGDublinCoreMetadata setValue:name asColumn:GPKG_DCM_TITLE inRow:mediaRow];
    int mediaRowId = (int)[mediaDao create:mediaRow];

    GPKGRowResultSet *featureResultSet = [featureDao results:[featureDao queryForLikeWithField:FEATURE_NAME_COLUMN andValue:query]];
    for(GPKGFeatureRow *featureRow in featureResultSet){
        GPKGUserMappingRow *userMappingRow = [userMappingDao newRow];
        [userMappingRow setBaseId:[featureRow idValue]];
        [userMappingRow setRelatedId:mediaRowId];
        NSString *featureName = (NSString *)[featureRow valueWithColumnName:FEATURE_NAME_COLUMN];
        [GPKGDublinCoreMetadata setValue:[NSDate date] asColumn:GPKG_DCM_DATE inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", featureName, description] asColumn:GPKG_DCM_DESCRIPTION inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:source asColumn:GPKG_DCM_SOURCE inRow:userMappingRow];
        [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"%@ - %@", featureName, name] asColumn:GPKG_DCM_TITLE inRow:userMappingRow];
        [userMappingDao create:userMappingRow];
    }
    [featureResultSet close];
}

/**
 * Create related tables extension to tiles
 *
 * @param geoPackage GeoPackage
 */
+(void) createRelatedTablesTilesExtension: (GPKGDgiwgGeoPackage *) geoPackage{

    GPKGRelatedTablesExtension *relatedTables = [[GPKGRelatedTablesExtension alloc] initWithGeoPackage:geoPackage];

    GPKGUserMappingTable *userMappingTable = [GPKGUserMappingTable createWithName:TILE_MAPPING_TABLE andAdditionalColumns:[self additionalColumns]];
    GPKGExtendedRelation *relation = [relatedTables addTilesRelationshipWithBaseTable:FEATURE_TABLE andRelatedTable:TILE_TABLE andUserMappingTable:userMappingTable];

    GPKGUserMappingDao *userMappingDao = [relatedTables mappingDaoForRelation:relation];

    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithTableName:relation.baseTableName];
    GPKGTileDao *tileDao = [geoPackage tileDaoWithTableName:relation.relatedTableName];

    GPKGBoundingBox *boundingBox = [tileDao boundingBox];

    SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:featureDao.projection andToProjection:tileDao.projection];
    
    NSMutableArray<NSNumber *> *featureIds = [NSMutableArray array];
    GPKGRowResultSet *featureResultSet = [featureDao results:[featureDao queryForAll]];
    for(GPKGFeatureRow *featureRow in featureResultSet){
        [featureIds addObject:[featureRow id]];
    }
    [featureResultSet close];
        
    for(NSNumber *featureId in featureIds){
        
        GPKGFeatureRow *featureRow = (GPKGFeatureRow *) [featureDao queryForIdObject:featureId];
        
        NSString *featureName = (NSString *)[featureRow valueWithColumnName:FEATURE_NAME_COLUMN];
        
        GPKGBoundingBox *geometryBoundingBox = [[featureRow geometry] getOrBuildBoundingBox];
        GPKGBoundingBox *geometryTransform = [geometryBoundingBox transform:transform];
        
        for(int zoom = tileDao.minZoom; zoom <= tileDao.maxZoom; zoom++){
            
            GPKGTileMatrix *tileMatrix = [tileDao tileMatrixWithZoomLevel:zoom];
            int width = [tileMatrix.matrixWidth intValue];
            int height = [tileMatrix.matrixHeight intValue];
            
            GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:boundingBox andMatrixWidth:width andMatrixHeight:height andBoundingBox:geometryTransform];
            
            GPKGResultSet *tileResultSet = [tileDao queryByTileGrid:tileGrid andZoomLevel:zoom];
            
            while ([tileResultSet moveToNext]) {
                GPKGTileRow *tileRow = [tileDao row:tileResultSet];
                
                GPKGUserMappingRow *userMappingRow = [userMappingDao newRow];
                [userMappingRow setBaseId:[featureRow idValue]];
                [userMappingRow setRelatedId:[tileRow idValue]];
                [GPKGDublinCoreMetadata setValue:[NSDate date] asColumn:GPKG_DCM_DATE inRow:userMappingRow];
                [GPKGDublinCoreMetadata setValue:[NSString stringWithFormat:@"Zoom level %d tile", zoom] asColumn:GPKG_DCM_DESCRIPTION inRow:userMappingRow];
                [GPKGDublinCoreMetadata setValue:@"http://www.nga.mil" asColumn:GPKG_DCM_SOURCE inRow:userMappingRow];
                [GPKGDublinCoreMetadata setValue:featureName asColumn:GPKG_DCM_TITLE inRow:userMappingRow];
                [userMappingDao create:userMappingRow];
            }
            [tileResultSet close];
            
        }
    }
    
    [transform destroy];

}

/**
 * Get additional related tables columns
 *
 * @return additional columns
 */
+(NSArray<GPKGUserCustomColumn *> *) additionalColumns{

    NSMutableArray<GPKGUserCustomColumn *> *additionalColumns = [NSMutableArray array];

    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_DATE] andDataType:GPKG_DT_DATETIME] toArray:additionalColumns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_DESCRIPTION] andDataType:GPKG_DT_TEXT] toArray:additionalColumns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_SOURCE] andDataType:GPKG_DT_TEXT] toArray:additionalColumns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_TITLE] andDataType:GPKG_DT_TEXT] toArray:additionalColumns];

    return additionalColumns;
}

@end
