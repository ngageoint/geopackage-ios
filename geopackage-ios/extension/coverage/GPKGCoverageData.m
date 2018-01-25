//
//  GPKGCoverageData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCoverageData.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"
#import "GPKGCoverageDataSourcePixel.h"
#import "GPKGCoverageDataTileMatrixResults.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"
#import "GPKGCoverageDataPng.h"
#import "GPKGCoverageDataTiff.h"

NSString * const GPKG_GRIDDED_COVERAGE_EXTENSION_NAME = @"2d_gridded_coverage";
NSString * const GPKG_PROP_GRIDDED_COVERAGE_EXTENSION_DEFINITION = @"geopackage.extensions.2d_gridded_coverage";

@interface GPKGCoverageDictionary: NSObject

@property (nonatomic, strong) NSMutableArray * keys;
@property (nonatomic, strong) NSMutableDictionary * dictionary;

@end

@implementation GPKGCoverageDictionary

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.keys = [[NSMutableArray alloc] init];
        self.dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(id)objectForKey:(id)aKey{
    return [self.dictionary objectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    [self.dictionary setObject:anObject forKey:aKey];
    [self.keys addObject:aKey];
}

@end

@interface GPKGCoverageData ()

@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;
@property (nonatomic, strong) GPKGGriddedCoverageDao *griddedCoverageDao;
@property (nonatomic, strong) GPKGGriddedTileDao *griddedTileDao;
@property (nonatomic, strong) GPKGGriddedCoverage *griddedCoverage;
@property (nonatomic, strong) GPKGProjection *requestProjection;
@property (nonatomic, strong) GPKGProjection *coverageProjection;
@property (nonatomic, strong) GPKGBoundingBox *coverageBoundingBox;
@property (nonatomic) BOOL sameProjection;

@end

@implementation GPKGCoverageData

+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection{
    
    GPKGTileMatrixSet *tileMatrixSet = tileDao.tileMatrixSet;
    GPKGGriddedCoverageDao *griddedCoverageDao = [geoPackage getGriddedCoverageDao];
    
    GPKGGriddedCoverage *griddedCoverage = nil;
    @try {
        if ([griddedCoverageDao tableExists]) {
            griddedCoverage = [griddedCoverageDao queryByTileMatrixSet:tileMatrixSet];
        }
    } @catch (NSException *e) {
        [NSException raise:@"Gridded Coverage" format:@"Failed to get Gridded Coverage for table name: %@, error: %@", tileMatrixSet.tableName, [e description]];
    }
    
    GPKGCoverageData *coverageData = nil;
    
    enum GPKGGriddedCoverageDataType dataType = [griddedCoverage getGriddedCoverageDataType];
    switch (dataType) {
        case GPKG_GCDT_INTEGER:
            coverageData = [[GPKGCoverageDataPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:width andHeight:height andProjection:requestProjection];
            break;
        case GPKG_GCDT_FLOAT:
            coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao andWidth:width andHeight:height andProjection:requestProjection];
            break;
        default:
            [NSException raise:@"Unsupported Data Type" format:@"Unsupported Gridded Coverage Data Type: %u", dataType];
    }
    
    return coverageData;
}

+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao{
    return [self coverageDataWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:tileDao.projection];
}

+(GPKGCoverageData *) coverageDataWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andProjection: (GPKGProjection *) requestProjection{
    return [self coverageDataWithGeoPackage:geoPackage andTileDao:tileDao andWidth:nil andHeight:nil andProjection:requestProjection];
}

+(GPKGCoverageData *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId andDataType: (enum GPKGGriddedCoverageDataType) dataType{
    
    GPKGTileMatrixSet *tileMatrixSet = [GPKGCoverageData createTileTableWithGeoPackage:geoPackage andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    GPKGTileDao *tileDao = [geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
    
    GPKGCoverageData *coverageData = nil;
    switch (dataType) {
        case GPKG_GCDT_INTEGER:
            coverageData = [[GPKGCoverageDataPng alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
            break;
        case GPKG_GCDT_FLOAT:
            coverageData = [[GPKGCoverageDataTiff alloc] initWithGeoPackage:geoPackage andTileDao:tileDao];
            break;
        default:
            [NSException raise:@"Unsupported Data Type" format:@"Unsupported Gridded Coverage Data Type: %u", dataType];
    }
    
    [coverageData getOrCreate];
    
    return coverageData;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_GRIDDED_COVERAGE_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_GRIDDED_COVERAGE_EXTENSION_DEFINITION];
        self.zoomIn = true;
        self.zoomOut = true;
        self.zoomInBeforeOut = true;
        self.algorithm = GPKG_CDA_NEAREST_NEIGHBOR;
        self.encoding = GPKG_GCET_CENTER;
        
        self.tileDao = tileDao;
        self.tileMatrixSet = tileDao.tileMatrixSet;
        self.griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        self.griddedTileDao = [geoPackage getGriddedTileDao];
        [self queryGriddedCoverage];
        
        self.width = width;
        self.height = height;
        self.requestProjection = requestProjection;
        self.coverageProjection = [GPKGProjectionFactory projectionWithSrs:[[geoPackage getTileMatrixSetDao] getSrs:tileDao.tileMatrixSet]];
        self.coverageBoundingBox = [tileDao.tileMatrixSet getBoundingBox];
        
        // Check if the projections have the same units
        if(requestProjection != nil){
            self.sameProjection = [requestProjection getUnit] == [self.coverageProjection getUnit];
        }else{
            self.sameProjection = true;
        }
    }
    return self;
}

-(GPKGTileMatrixSet *) tileMatrixSet{
    return _tileMatrixSet;
}

-(GPKGGriddedCoverageDao *) griddedCoverageDao{
    return _griddedCoverageDao;
}

-(GPKGGriddedTileDao *) griddedTileDao{
    return _griddedTileDao;
}

-(GPKGProjection *) requestProjection{
    return _requestProjection;
}

-(GPKGProjection *) coverageProjection{
    return _coverageProjection;
}

-(GPKGBoundingBox *) coverageBoundingBox{
    return _coverageBoundingBox;
}

-(BOOL) isSameProjection{
    return _sameProjection;
}

-(NSArray *) getOrCreate{
    
    // Create tables
    [self.geoPackage createGriddedCoverageTable];
    [self.geoPackage createGriddedTileTable];
    
    NSMutableArray * extensions = [[NSMutableArray alloc] init];
    
    GPKGExtensions * coverage = [self getOrCreateWithExtensionName:self.extensionName andTableName:GPKG_CDGC_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    GPKGExtensions * tile = [self getOrCreateWithExtensionName:self.extensionName andTableName:GPKG_CDGT_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    GPKGExtensions * table = [self getOrCreateWithExtensionName:self.extensionName andTableName:self.tileMatrixSet.tableName andColumnName:GPKG_TT_COLUMN_TILE_DATA andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    
    [extensions addObject:coverage];
    [extensions addObject:tile];
    [extensions addObject:table];
    
    return extensions;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:self.tileMatrixSet.tableName andColumnName:GPKG_TT_COLUMN_TILE_DATA];
    
    return exists;
}

-(GPKGGriddedCoverage *) griddedCoverage{
    return _griddedCoverage;
}

-(GPKGGriddedCoverage *) queryGriddedCoverage{
    if([self.griddedCoverageDao tableExists]){
        self.griddedCoverage = [self.griddedCoverageDao queryByTileMatrixSet:self.tileMatrixSet];
    }
    return self.griddedCoverage;
}

-(GPKGResultSet *) griddedTile{
    GPKGResultSet * griddedTile = nil;
    if([self.griddedTileDao tableExists]){
        griddedTile = [self.griddedTileDao queryByTableName:_tileMatrixSet.tableName];
    }
    return griddedTile;
}

-(GPKGGriddedTile *) griddedTileWithResultSet: (GPKGResultSet *) resultSet{
    return (GPKGGriddedTile *)[self.griddedTileDao getObject:resultSet];
}

-(GPKGGriddedTile *) griddedTileWithTileId: (int) tileId{
    GPKGGriddedTile * griddedTile = nil;
    if([self.griddedTileDao tableExists]){
        griddedTile = [self.griddedTileDao queryByTableName:_tileMatrixSet.tableName andTileId:tileId];
    }
    return griddedTile;
}

-(NSDecimalNumber *) dataNull{
    NSDecimalNumber * dataNull = nil;
    if(self.griddedCoverage != nil){
        dataNull = self.griddedCoverage.dataNull;
    }
    return dataNull;
}

-(BOOL) isDataNull: (double) value{
    NSDecimalNumber * dataNull = [self dataNull];
    BOOL isDataNull = dataNull != nil && [dataNull doubleValue] == value;
    return isDataNull;
}

+(NSArray *) tablesForGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [geoPackage getTablesByType:GPKG_CDT_GRIDDED_COVERAGE];
}

/**
 * Reproject the coverage data values to the requested projection
 *
 * @param values
 *            coverage data values
 * @param requestedWidth
 *            requested coverage data width
 * @param requestedHeight
 *            requested coverage data height
 * @param requestBoundingBox
 *            request bounding box in the request projection
 * @param transformRequestToCoverage
 *            transformation from request to coverage data
 * @param covergeBoundingBox
 *            coverage bounding box
 * @return projected coverage data values
 */
-(NSArray *) reprojectValues: (NSArray *) values withWidth: (int) requestedWidth andHeight: (int) requestedHeight andRequestBoundingBox: (GPKGBoundingBox *) requestBoundingBox andProjectionTransform: (GPKGProjectionTransform *) transformRequestToCoverage andCoverageBoundingBox: (GPKGBoundingBox *) coverageBoundingBox{
    
    double requestedWidthUnitsPerPixel = ([requestBoundingBox.maxLongitude doubleValue] - [requestBoundingBox.minLongitude doubleValue]) / requestedWidth;
    double requestedHeightUnitsPerPixel = ([requestBoundingBox.maxLatitude doubleValue] - [requestBoundingBox.minLatitude doubleValue]) / requestedHeight;
    
    double tilesDistanceWidth = [coverageBoundingBox.maxLongitude doubleValue] - [coverageBoundingBox.minLongitude doubleValue];
    double tilesDistanceHeight = [coverageBoundingBox.maxLatitude doubleValue] - [coverageBoundingBox.minLatitude doubleValue];
    
    int width = [self countInDoubleArray:values atIndex1:0];
    int height = (int) values.count;
    
    NSMutableArray * projectedValues = [[NSMutableArray alloc] initWithCapacity:requestedHeight];
    
    // Retrieve each coverage data value in the unprojected coverage data
    for (int y = 0; y < requestedHeight; y++) {
        NSMutableArray * coverageDataRow = [[NSMutableArray alloc] initWithCapacity:requestedWidth];
        [projectedValues addObject:coverageDataRow];
        for (int x = 0; x < requestedWidth; x++) {
            
            double longitude = [requestBoundingBox.minLongitude doubleValue]
            + (x * requestedWidthUnitsPerPixel);
            double latitude = [requestBoundingBox.maxLatitude doubleValue]
            - (y * requestedHeightUnitsPerPixel);
            CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(latitude, longitude);
            CLLocationCoordinate2D toCoord = [transformRequestToCoverage transform:fromCoord];
            double projectedLongitude = toCoord.longitude;
            double projectedLatitude = toCoord.latitude;
            
            int xPixel = (int) round(((projectedLongitude - [coverageBoundingBox.minLongitude doubleValue]) / tilesDistanceWidth)
                   * width);
            int yPixel = (int) round((([coverageBoundingBox.maxLatitude doubleValue] - projectedLatitude) / tilesDistanceHeight)
                   * height);
            
            xPixel = MAX(0, xPixel);
            xPixel = MIN(width - 1, xPixel);
            
            yPixel = MAX(0, yPixel);
            yPixel = MIN(height - 1, yPixel);
            
            NSDecimalNumber * value = (NSDecimalNumber *)[self objectInDoubleArray:values atIndex1:yPixel andIndex2:xPixel];
            [GPKGUtils addObject:value toArray:coverageDataRow];
        }
    }
    
    return projectedValues;
}

/**
 * Get the coverage data values from the rows dictionary
 *
 * @param row
 *            row number
 * @param column
 *            column number
 * @return coverage data values
 */
-(NSArray *) getValuesFromDictionary: (NSDictionary *) dictionary atRow: (int) row andColumn: (int) column{
    return (NSArray *)[((NSDictionary *)[dictionary objectForKey:[NSNumber numberWithInt:row]]) objectForKey:[NSNumber numberWithInt:column]];
}

/**
 * Get the coverage data values from the coverage data dictionary
 *
 * @param row
 *            row number
 * @param column
 *            column number
 * @return coverage data values
 */
-(NSArray *) getValuesFromCoverageDataDictionary: (GPKGCoverageDictionary *) coverageDataDictionary atRow: (int) row andColumn: (int) column{
    return (NSMutableArray *)[((GPKGCoverageDictionary *)[coverageDataDictionary objectForKey:[NSNumber numberWithInt:row]]) objectForKey:[NSNumber numberWithInt:column]];
}

/**
 * Format the unbounded results from coverage data into a single double
 * array of coverage data values
 *
 * @param tileMatrix
 *            tile matrix
 * @param coverageDictionary
 *            coverage data dictionary
 * @param tileCount
 *            tile count
 * @param minRow
 *            min row
 * @param maxRow
 *            max row
 * @param minColumn
 *            min column
 * @param maxColumn
 *            max column
 * @return coverage data values
 */
-(NSArray *) formatUnboundedResultsWithTileMatrix: (GPKGTileMatrix *) tileMatrix andCoverageDictionary: (GPKGCoverageDictionary *) coverageDictionary andTileCount: (int) tileCount andMinRow: (int) minRow andMaxRow: (int) maxRow andMinColumn: (int) minColumn andMaxColumn: (int) maxColumn{
    
    // Handle formatting the results
    NSMutableArray * values = nil;
    if(coverageDictionary.dictionary.count != 0){
        
        // If only one tile result, use the coverage data values as the result
        if (tileCount == 1) {
            values = (NSMutableArray *)[self getValuesFromCoverageDataDictionary:coverageDictionary atRow:minRow andColumn:minColumn];
        } else {
            
            // Else, combine all results into a single coverage data values result
            
            // Get the top left and bottom right coverage data values
            NSArray * topLeft = [self getValuesFromCoverageDataDictionary:coverageDictionary atRow:minRow andColumn:minColumn];
            NSArray * bottomRight = [self getValuesFromCoverageDataDictionary:coverageDictionary atRow:maxRow andColumn:maxColumn];
            
            // Determine the width and height of the top left coverage data results
            int firstWidth = [self countInDoubleArray:topLeft atIndex1:0];
            int firstHeight = (int) topLeft.count;
            
            // Determine the final result width and height
            int width = firstWidth;
            int height = firstHeight;
            if (minColumn < maxColumn) {
                width += [self countInDoubleArray:bottomRight atIndex1:0];
                int middleColumns = maxColumn - minColumn - 1;
                if (middleColumns > 0) {
                    width += (middleColumns * [tileMatrix.tileWidth intValue]);
                }
            }
            if (minRow < maxRow) {
                height += bottomRight.count;
                long middleRows = maxRow - minRow - 1;
                if (middleRows > 0) {
                    height += (middleRows * [tileMatrix.tileHeight intValue]);
                }
            }
            
            // Create the coverage data result array
            values = [self createNullFilledDoubleArrayWithSize1:height andSize2:width];
            
            // Copy the coverage data values from each tile results into the
            // final result arrays
            for(NSNumber * rowKey in coverageDictionary.keys){
                
                // Determine the starting base row for this tile
                int row = [rowKey intValue];
                int baseRow = 0;
                if (minRow < row) {
                    baseRow = firstHeight
                        + (int) ((row - minRow - 1) * [tileMatrix.tileHeight intValue]);
                }
                
                // Get the row's columns dictionary
                GPKGCoverageDictionary * columnsDictionary = [coverageDictionary objectForKey:rowKey];
                
                for(NSNumber * columnKey in columnsDictionary.keys){
                    
                    // Determine the starting base column for this tile
                    int column = [columnKey intValue];
                    int baseColumn = 0;
                    if (minColumn < column) {
                        baseColumn = firstWidth
                            + (int) ((column - minColumn - 1) * [tileMatrix.tileWidth intValue]);
                    }
                    
                    // Get the tiles coverage data values
                    NSArray * localValues = [columnsDictionary objectForKey:columnKey];
                    
                    // Copy the columns array at each local coverage data row to
                    // the global row and column result location
                    for (int localRow = 0; localRow < localValues.count; localRow++) {
                        
                        int globalRow = baseRow + localRow;
                        
                        NSArray * localRowArray = [localValues objectAtIndex:localRow];
                        NSMutableArray * coverageDataRowArray = [values objectAtIndex:globalRow];
                        
                        [coverageDataRowArray replaceObjectsInRange:NSMakeRange(baseColumn, localRowArray.count) withObjectsFromArray:localRowArray];
                    }
                }
            }

        }
    }
    
    return values;
}

/**
 * Determine the x source pixel location
 *
 * @param x
 *            x pixel
 * @param destLeft
 *            destination left most pixel
 * @param srcLeft
 *            source left most pixel
 * @param widthRatio
 *            source over destination width ratio
 * @return x source pixel
 */
-(float) xSourceWithX: (int) x andDestLeft: (float) destLeft andSrcLeft: (float) srcLeft andWidthRatio: (float) widthRatio{
    
    float dest = [self encodedLocationWithX:x andEncoding:self.encoding];
    float source = [self sourceWithDest:dest andDestMin:destLeft andSrcMin:srcLeft andRatio:widthRatio];
    
    return source;
}

/**
 * Determine the y source pixel location
 *
 * @param y
 *            y pixel
 * @param destTop
 *            destination top most pixel
 * @param srcTop
 *            source top most pixel
 * @param heightRatio
 *            source over destination height ratio
 * @return y source pixel
 */
-(float) ySourceWithY: (int) y andDestTop: (float) destTop andSrcTop: (float) srcTop andHeightRatio: (float) heightRatio{
    
    float dest = [self encodedLocationWithY:y andEncoding:self.encoding];
    float source = [self sourceWithDest:dest andDestMin:destTop andSrcMin:srcTop andRatio:heightRatio];
    
    return source;
}

/**
 * Determine the source pixel location
 *
 * @param dest
 *            destination pixel location
 * @param destMin
 *            destination minimum most pixel
 * @param srcMin
 *            source minimum most pixel
 * @param ratio
 *            source over destination length ratio
 * @return source pixel
 */
-(float) sourceWithDest: (float) dest andDestMin: (float) destMin andSrcMin: (float) srcMin andRatio: (float) ratio {
    
    float destDistance = dest - destMin;
    float srcDistance = destDistance * ratio;
    float ySource = srcMin + srcDistance;
    
    return ySource;
}

/**
 * Get the X encoded location from the base provided x
 *
 * @param x
 *            x location
 * @param encodingType
 *            pixel encoding type
 * @return encoded x location
 */
-(float) encodedLocationWithX: (float) x andEncoding: (enum GPKGGriddedCoverageEncodingType) encodingType{
    
    float xLocation = x;
    
    switch (encodingType) {
        case GPKG_GCET_CENTER:
        case GPKG_GCET_AREA:
            xLocation += 0.5f;
            break;
        case GPKG_GCET_CORNER:
            break;
        default:
            [NSException raise:@"Unsupported Encoding Type" format:@"Unsupported Encoding Type: %u", encodingType];
    }
    
    return xLocation;
}

/**
 * Get the Y encoded location from the base provided y
 *
 * @param y
 *            y location
 * @param encodingType
 *            pixel encoding type
 * @return encoded y location
 */
-(float) encodedLocationWithY: (float) y andEncoding: (enum GPKGGriddedCoverageEncodingType) encodingType{
    
    float yLocation = y;
    
    switch (encodingType) {
        case GPKG_GCET_CENTER:
        case GPKG_GCET_AREA:
            yLocation += 0.5f;
            break;
        case GPKG_GCET_CORNER:
            yLocation += 1.0f;
            break;
        default:
            [NSException raise:@"Unsupported Encoding Type" format:@"Unsupported Encoding Type: %u", encodingType];
    }
    
    return yLocation;
}

/**
 * Determine the nearest neighbors of the source pixel, sorted by closest to
 * farthest neighbor
 *
 * @param xSource
 *            x source pixel
 * @param ySource
 *            y source pixel
 * @return nearest neighbor pixels
 */
-(NSArray *) nearestNeighborsWithXSource: (float) xSource andYSource: (float) ySource {
    
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    // Get the coverage data source pixels for x and y
    GPKGCoverageDataSourcePixel * xPixel = [self minAndMaxOfXSource:xSource];
    GPKGCoverageDataSourcePixel * yPixel = [self minAndMaxOfYSource:ySource];
    
    // Determine which x pixel is the closest, the second closest, and the
    // distance to the second pixel
    int firstX;
    int secondX;
    float xDistance;
    if (xPixel.offset > .5) {
        firstX = xPixel.max;
        secondX = xPixel.min;
        xDistance = 1.0f - xPixel.offset;
    } else {
        firstX = xPixel.min;
        secondX = xPixel.max;
        xDistance = xPixel.offset;
    }
    
    // Determine which y pixel is the closest, the second closest, and the
    // distance to the second pixel
    int firstY;
    int secondY;
    float yDistance;
    if (yPixel.offset > .5) {
        firstY = yPixel.max;
        secondY = yPixel.min;
        yDistance = 1.0f - yPixel.offset;
    } else {
        firstY = yPixel.min;
        secondY = yPixel.max;
        yDistance = yPixel.offset;
    }
    
    // Add the closest neighbor
    [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:firstX], [NSNumber numberWithInt:firstY], nil]];
    
    // Add the second and third neighbor based upon the x and y distances to
    // second coordinates
    if (xDistance <= yDistance) {
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:secondX], [NSNumber numberWithInt:firstY], nil]];
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:firstX], [NSNumber numberWithInt:secondY], nil]];
    } else {
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:firstX], [NSNumber numberWithInt:secondY], nil]];
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:secondX], [NSNumber numberWithInt:firstY], nil]];
    }
    
    // Add the farthest neighbor
    [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:secondX], [NSNumber numberWithInt:secondY], nil]];
    
    // If right on the boundary between the forward and backwards pixel, add
    // the backwards pixel options
    if (xPixel.offset == 0) {
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:xPixel.min - 1], [NSNumber numberWithInt:yPixel.min], nil]];
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:xPixel.min - 1], [NSNumber numberWithInt:yPixel.max], nil]];
    }
    if (yPixel.offset == 0) {
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:xPixel.min], [NSNumber numberWithInt:yPixel.min - 1], nil]];
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:xPixel.max], [NSNumber numberWithInt:yPixel.min - 1], nil]];
    }
    if (xPixel.offset == 0 && yPixel.offset == 0) {
        [results addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:xPixel.min - 1], [NSNumber numberWithInt:yPixel.min - 1], nil]];
    }
    
    return results;
}

/**
 * Get the min, max, and offset of the source X pixel
 *
 * @param source
 *            source x pixel
 * @return source x pixel information
 */
-(GPKGCoverageDataSourcePixel *) minAndMaxOfXSource: (float) source{
    
    int floor = (int) floorf(source);
    float valueLocation = [self encodedLocationWithX:floor andEncoding:[self.griddedCoverage getGridCellEncodingType]];
    
    GPKGCoverageDataSourcePixel *pixel = [self minAndMaxOfSource:source withFloor:floor andValueLocation:valueLocation];
    return pixel;
}

/**
 * Get the min, max, and offset of the source Y pixel
 *
 * @param source
 *            source y pixel
 * @return source y pixel information
 */
-(GPKGCoverageDataSourcePixel *) minAndMaxOfYSource: (float) source{
    
    int floor = (int) floorf(source);
    float valueLocation = [self encodedLocationWithY:floor andEncoding:[self.griddedCoverage getGridCellEncodingType]];
    
    GPKGCoverageDataSourcePixel *pixel = [self minAndMaxOfSource:source withFloor:floor andValueLocation:valueLocation];
    return pixel;
}

/**
 * Get the min, max, and offset of the source pixel
 *
 * @param source
 *            source pixel
 * @param sourceFloor
 *            source floor value
 * @param valueLocation
 *            value location
 * @return source pixel information
 */
-(GPKGCoverageDataSourcePixel *) minAndMaxOfSource: (float) source withFloor: (int) sourceFloor andValueLocation: (float) valueLocation{
    
    int min = sourceFloor;
    int max = sourceFloor;
    float offset;
    if (source < valueLocation) {
        min--;
        offset = 1.0f - (valueLocation - source);
    } else {
        max++;
        offset = source - valueLocation;
    }
    
    return [[GPKGCoverageDataSourcePixel alloc] initWithPixel:source andMin:min andMax:max andOffset:offset];
}

/**
 * Get the Bilinear Interpolation coverage data value
 *
 * @param sourcePixelX
 *            source pixel x
 * @param sourcePixelY
 *            source pixel y
 * @param values
 *            2 x 2 coverage data values as [y][x]
 * @return coverage data value
 */
-(NSDecimalNumber *) bilinearInterpolationValueWithSourcePixelX: (GPKGCoverageDataSourcePixel *) sourcePixelX andSourcePixelY: (GPKGCoverageDataSourcePixel *) sourcePixelY andValues: (NSArray *) values{
    return [self bilinearInterpolationValueWithOffsetX:sourcePixelX.offset andOffsetY:sourcePixelY.offset andMinX:sourcePixelX.min andMaxX:sourcePixelX.max andMinY:sourcePixelY.min andMaxY:sourcePixelY.max andValues:values];
}

/**
 * Get the Bilinear Interpolation coverage data value
 *
 * @param offsetX
 *            x source pixel offset
 * @param offsetY
 *            y source pixel offset
 * @param minX
 *            min x value
 * @param maxX
 *            max x value
 * @param minY
 *            min y value
 * @param maxY
 *            max y value
 * @param values
 *            2 x 2 coverage data values as [y][x]
 * @return coverage data value
 */
-(NSDecimalNumber *) bilinearInterpolationValueWithOffsetX: (float) offsetX andOffsetY: (float) offsetY andMinX: (float) minX andMaxX: (float) maxX andMinY: (float) minY andMaxY: (float) maxY andValues: (NSArray *) values{
    
    NSDecimalNumber * value = nil;
    
    if (values != nil) {
        NSArray * top = [values objectAtIndex:0];
        NSArray * bottom = [values objectAtIndex:1];
        NSDecimalNumber * topLeft = (NSDecimalNumber *)[GPKGUtils objectAtIndex:0 inArray:top];
        NSDecimalNumber * topRight = (NSDecimalNumber *)[GPKGUtils objectAtIndex:1 inArray:top];
        NSDecimalNumber * bottomLeft = (NSDecimalNumber *)[GPKGUtils objectAtIndex:0 inArray:bottom];
        NSDecimalNumber * bottomRight = (NSDecimalNumber *)[GPKGUtils objectAtIndex:1 inArray:bottom];
        value = [self bilinearInterpolationValueWithOffsetX:offsetX andOffsetY:offsetY andMinX:minX andMaxX:maxX andMinY:minY andMaxY:maxY andTopLeft:topLeft andTopRight:topRight andBottomLeft:bottomLeft andBottomRight:bottomRight];
    }
    
    return value;
}

/**
 * Get the Bilinear Interpolation coverage data value
 *
 * @param offsetX
 *            x source pixel offset
 * @param offsetY
 *            y source pixel offset
 * @param minX
 *            min x value
 * @param maxX
 *            max x value
 * @param minY
 *            min y value
 * @param maxY
 *            max y value
 * @param topLeft
 *            top left coverage data value
 * @param topRight
 *            top right coverage data value
 * @param bottomLeft
 *            bottom left coverage data value
 * @param bottomRight
 *            bottom right coverage data value
 * @return coverage data value
 */
-(NSDecimalNumber *) bilinearInterpolationValueWithOffsetX: (float) offsetX andOffsetY: (float) offsetY andMinX: (float) minX andMaxX: (float) maxX andMinY: (float) minY andMaxY: (float) maxY andTopLeft: (NSDecimalNumber *) topLeft andTopRight: (NSDecimalNumber *) topRight andBottomLeft: (NSDecimalNumber *) bottomLeft andBottomRight: (NSDecimalNumber *) bottomRight{
    
    NSDecimalNumber * value = nil;
    
    if (topLeft != nil && (topRight != nil || minX == maxX)
        && (bottomLeft != nil || minY == maxY)
        && (bottomRight != nil || (minX == maxX && minY == maxY))) {
        
        float diffX = maxX - minX;
        
        double topRow;
        double bottomRow;
        if (diffX == 0) {
            topRow = [topLeft doubleValue];
            bottomRow = [bottomLeft doubleValue];
        } else {
            float diffLeft = offsetX;
            float diffRight = diffX - offsetX;
            topRow = ((diffRight / diffX) * [topLeft doubleValue])
                + ((diffLeft / diffX) * [topRight doubleValue]);
            bottomRow = ((diffRight / diffX) * [bottomLeft doubleValue])
                + ((diffLeft / diffX) * [bottomRight doubleValue]);
        }
        
        float diffY = maxY - minY;
        
        double result;
        if (diffY == 0) {
            result = topRow;
        } else {
            float diffTop = offsetY;
            float diffBottom = diffY - offsetY;
            result = ((diffBottom / diffY) * topRow)
                + ((diffTop / diffY) * bottomRow);
        }
        
        value = [[NSDecimalNumber alloc] initWithDouble:result];
    }
    
    return value;
}

/**
 * Get the bicubic interpolation coverage data value from the 4 x 4 coverage data values
 *
 * @param values
 *            coverage data values
 * @param sourcePixelX
 *            source pixel x
 * @param sourcePixelY
 *            source pixel y
 * @return bicubic coverage data value
 */
-(NSDecimalNumber *) bicubicInterpolationValueWithValues: (NSArray *) values andSourcePixelX: (GPKGCoverageDataSourcePixel *) sourcePixelX andSourcePixelY: (GPKGCoverageDataSourcePixel *) sourcePixelY{
    return [self bicubicInterpolationValueWithValues:values andOffsetX:sourcePixelX.offset andOffsetY:sourcePixelY.offset];
}

/**
 * Get the bicubic interpolation coverage data value from the 4 x 4 coverage data values
 *
 * @param values
 *            coverage data values
 * @param offsetX
 *            x source pixel offset
 * @param offsetY
 *            y source pixel offset
 * @return bicubic coverage data value
 */
-(NSDecimalNumber *) bicubicInterpolationValueWithValues: (NSArray *) values andOffsetX: (float) offsetX andOffsetY: (float) offsetY{

    NSDecimalNumber * value = nil;
    
    NSMutableArray * rowValues = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (int y = 0; y < 4; y++) {
        NSArray * yValues = [values objectAtIndex:y];
        NSDecimalNumber * value0 = [GPKGUtils objectAtIndex:0 inArray:yValues];
        NSDecimalNumber * value1 = [GPKGUtils objectAtIndex:1 inArray:yValues];
        NSDecimalNumber * value2 = [GPKGUtils objectAtIndex:2 inArray:yValues];
        NSDecimalNumber * value3 = [GPKGUtils objectAtIndex:3 inArray:yValues];
        NSDecimalNumber * rowValue = [self cubicInterpolationValueWithValue0:value0 andValue1:value1 andValue2:value2 andValue3:value3 andOffset:offsetX];
        if (rowValue == nil) {
            rowValues = nil;
            break;
        }
        [rowValues addObject:rowValue];
    }
    
    if (rowValues != nil) {
        value = [self cubicInterpolationValueWithValues:rowValues andOffset:offsetY];
    }
    
    return value;
}

/**
 * Interpolate 4 values using the offset between value1 and value2
 *
 * @param values
 *            coverage data values
 * @param offset
 *            offset between the middle two pixels
 * @return coverage data value
 */
-(NSDecimalNumber *) cubicInterpolationValueWithValues: (NSArray *) values andOffset: (double) offset{
    
    NSDecimalNumber * value = nil;
    if (values != nil) {
        NSDecimalNumber * value0 = [GPKGUtils objectAtIndex:0 inArray:values];
        NSDecimalNumber * value1 = [GPKGUtils objectAtIndex:1 inArray:values];
        NSDecimalNumber * value2 = [GPKGUtils objectAtIndex:2 inArray:values];
        NSDecimalNumber * value3 = [GPKGUtils objectAtIndex:3 inArray:values];
        value = [self cubicInterpolationValueWithValue0:value0 andValue1:value1 andValue2:value2 andValue3:value3 andOffset:offset];
    }
    return value;
}

/**
 * Interpolate 4 values using the offset between value1 and value2
 *
 * @param value0
 *            index 0 value
 * @param value1
 *            index 1 value
 * @param value2
 *            index 2 value
 * @param value3
 *            index 3 value
 * @param offset
 *            offset between the middle two pixels
 * @return coverage data value
 */
-(NSDecimalNumber *) cubicInterpolationValueWithValue0: (NSDecimalNumber *) value0 andValue1: (NSDecimalNumber *) value1 andValue2: (NSDecimalNumber *) value2 andValue3: (NSDecimalNumber *) value3 andOffset: (double) offset{
    
    NSDecimalNumber * value = nil;
    
    if (value0 != nil && value1 != nil && value2 != nil && value3 != nil) {
        
        double coefficient0 = 2 * [value1 doubleValue];
        double coefficient1 = [value2 doubleValue] - [value0 doubleValue];
        double coefficient2 = 2 * [value0 doubleValue] - 5 * [value1 doubleValue] + 4 * [value2 doubleValue] - [value3 doubleValue];
        double coefficient3 = -[value0 doubleValue] + 3 * [value1 doubleValue] - 3 * [value2 doubleValue] + [value3 doubleValue];
        double valueDouble = (coefficient3 * offset * offset * offset + coefficient2
                     * offset * offset + coefficient1 * offset + coefficient0) / 2;
        value = [[NSDecimalNumber alloc] initWithDouble:valueDouble];
    }
    
    return value;
}

/**
 * Pad the bounding box with extra space for the overlapping pixels
 *
 * @param tileMatrix
 *            tile matrix
 * @param boundingBox
 *            bounding box
 * @param overlap
 *            overlapping pixels
 * @return padded bounding box
 */
-(GPKGBoundingBox *) padBoundingBoxWithTileMatrix: (GPKGTileMatrix *) tileMatrix andBoundingBox: (GPKGBoundingBox *) boundingBox andOverlap: (int) overlap{

    double lonPixelPadding = [tileMatrix.pixelXSize doubleValue] * overlap;
    double latPixelPadding = [tileMatrix.pixelYSize doubleValue] * overlap;
    GPKGBoundingBox * paddedBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:[boundingBox.minLongitude doubleValue] - lonPixelPadding
                                                                         andMinLatitudeDouble:[boundingBox.minLatitude doubleValue] - latPixelPadding
                                                                        andMaxLongitudeDouble:[boundingBox.maxLongitude doubleValue] + lonPixelPadding
                                                                         andMaxLatitudeDouble:[boundingBox.maxLatitude doubleValue] + latPixelPadding];
    return paddedBoundingBox;
}

-(unsigned short) pixelValueWithValues:(NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return [((NSNumber *)[pixelValues objectAtIndex:(y * width) + x]) unsignedShortValue];
}

-(unsigned short) pixelValueWithUnsignedShortValues:(unsigned short *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return pixelValues[(y * width) + x];
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (unsigned short) pixelValue{
    
    NSDecimalNumber * value = nil;
    if (![self isDataNull:pixelValue]) {
        value = [self pixelValueToValueWithGriddedTile:griddedTile andPixelValue:[[NSDecimalNumber alloc] initWithUnsignedShort:pixelValue]];
    }
    
    return value;
}

-(NSDecimalNumber *) pixelValueToValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (NSDecimalNumber *) pixelValue{

    NSDecimalNumber * valueNumber = pixelValue;
    
    if (self.griddedCoverage != nil
        && [self.griddedCoverage getGriddedCoverageDataType] == GPKG_GCDT_INTEGER) {
        
        double value = [pixelValue doubleValue];
        
        if (griddedTile != nil) {
            value *= [griddedTile scaleOrDefault];
            value += [griddedTile offsetOrDefault];
        }
        value *= [self.griddedCoverage scaleOrDefault];
        value += [self.griddedCoverage offsetOrDefault];
     
        valueNumber = [[NSDecimalNumber alloc] initWithDouble:value];
    }
    
    return valueNumber;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (NSArray *) pixelValues{
    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:pixelValues.count];
    for(int i = 0; i < pixelValues.count; i++){
        [GPKGUtils addObject:[self valueWithGriddedTile:griddedTile andPixelValue:[((NSNumber *)[pixelValues objectAtIndex:i]) unsignedShortValue]] toArray:values];
    }
    return values;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (unsigned short *) pixelValues andCount: (int) count{
    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i = 0; i < count; i++){
        [GPKGUtils addObject:[self valueWithGriddedTile:griddedTile andPixelValue:pixelValues[i]] toArray:values];
    }
    return values;
}

+(GPKGTileMatrixSet *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = [geoPackage createTileTableWithType:GPKG_CDT_GRIDDED_COVERAGE andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    return tileMatrixSet;
}

-(unsigned short) pixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andValue: (NSDecimalNumber *) value{
    
    unsigned short pixelValue = 0;
    
    if(value == nil){
        if(self.griddedCoverage != nil){
            pixelValue = [self.griddedCoverage.dataNull unsignedShortValue];
        }
    }else{
        double pixelValueDouble = [self valueToPixelValueWithGriddedTile:griddedTile andValue: [value doubleValue]];
        pixelValue = (unsigned short) round(pixelValueDouble);
    }
    
    return pixelValue;
}

/**
 * Convert integer coverage data value to a pixel value through
 * offsets and scales
 *
 * @param griddedTile
 *            gridded tile
 * @param value
 *            coverage data value
 * @return pixel value
 */
-(double) valueToPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andValue: (double) value{
    
    double pixelValue = value;
    
    if (self.griddedCoverage != nil
        && [self.griddedCoverage getGriddedCoverageDataType] == GPKG_GCDT_INTEGER) {
        
        pixelValue -= [self.griddedCoverage offsetOrDefault];
        pixelValue /= [self.griddedCoverage scaleOrDefault];
        if (griddedTile != nil) {
            pixelValue -= [griddedTile offsetOrDefault];
            pixelValue /= [griddedTile scaleOrDefault];
        }
        
    }
    
    return pixelValue;
}

-(float) pixelValueWithFloatValues: (NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return [((NSDecimalNumber *)[pixelValues objectAtIndex:(y * width) + x]) floatValue];
}

-(float) pixelValueWithRawFloatValues: (float *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return pixelValues[(y * width) + x];
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValue: (float) pixelValue{
    
    NSDecimalNumber * value = nil;
    if(![self isDataNull:pixelValue]){
        value = [self pixelValueToValueWithGriddedTile:griddedTile andPixelValue:[[NSDecimalNumber alloc] initWithFloat:pixelValue]];
    }
    
    return value;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (NSArray *) pixelValues{
    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:pixelValues.count];
    for (int i = 0; i < pixelValues.count; i++) {
        [GPKGUtils addObject:[self valueWithGriddedTile:griddedTile andPixelFloatValue:[((NSDecimalNumber *)[pixelValues objectAtIndex:i]) floatValue]] toArray:values];
    }
    return values;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (float *) pixelValues andCount: (int) count{
    NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i = 0; i < count; i++){
        [GPKGUtils addObject:[self valueWithGriddedTile:griddedTile andPixelFloatValue:pixelValues[i]] toArray:values];
    }
    return values;
}

-(float) floatPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andValue: (NSDecimalNumber *) value{
    
    double pixelValueDouble = 0;
    if (value == nil) {
        if (self.griddedCoverage != nil) {
            pixelValueDouble = [self.griddedCoverage.dataNull doubleValue];
        }
    } else {
        pixelValueDouble = [self valueToPixelValueWithGriddedTile:griddedTile andValue:[value doubleValue]];
    }
    
    float pixelValue = (float) pixelValueDouble;
    
    return pixelValue;
}

-(NSObject<GPKGCoverageDataImage> *) createImageWithTileRow: (GPKGTileRow *) tileRow{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return nil;
}

-(double) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return 0;
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData andX: (int) x andY: (int) y{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return 0;
}

-(NSArray *) valuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andData: (NSData *) imageData{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return 0;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andValues: (NSArray *) values andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return 0;
}

-(NSData *) drawTileDataWithGriddedTile: (GPKGGriddedTile *) griddedTile andDoubleArrayValues: (NSArray *) values{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return 0;
}

-(NSDecimalNumber *) valueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andX: (int) x andY: (int) y{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending coverage data type"];
    return nil;
}

-(GPKGTileDao *) tileDao{
    return _tileDao;
}

-(NSDecimalNumber *) valueWithLatitude: (double) latitude andLongitude: (double) longitude{
    GPKGCoverageDataRequest * request = [[GPKGCoverageDataRequest alloc] initWithLatitude:latitude andLongitude:longitude];
    GPKGCoverageDataResults * values = [self valuesWithCoverageDataRequest:request andWidth:[NSNumber numberWithInt:1] andHeight:[NSNumber numberWithInt:1]];
    NSDecimalNumber * value = nil;
    if(values != nil){
        value = [values valueAtRow:0 andColumn:0];
    }
    return value;
}

-(GPKGCoverageDataResults *) valuesWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    GPKGCoverageDataRequest * request = [[GPKGCoverageDataRequest alloc] initWithBoundingBox:requestBoundingBox];
    GPKGCoverageDataResults * values = [self valuesWithCoverageDataRequest:request];
    return values;
}

-(GPKGCoverageDataResults *) valuesWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    GPKGCoverageDataRequest * request = [[GPKGCoverageDataRequest alloc] initWithBoundingBox:requestBoundingBox];
    GPKGCoverageDataResults * values = [self valuesWithCoverageDataRequest:request andWidth:width andHeight:height];
    return values;
}

-(GPKGCoverageDataResults *) valuesWithCoverageDataRequest: (GPKGCoverageDataRequest *) request{
    GPKGCoverageDataResults * values = [self valuesWithCoverageDataRequest:request andWidth:self.width andHeight:self.height];
    return values;
}

-(GPKGCoverageDataResults *) valuesWithCoverageDataRequest: (GPKGCoverageDataRequest *) request andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    
    GPKGCoverageDataResults * coverageResults = nil;
    
    // Transform to the projection of the coverage data
    GPKGProjectionTransform * transformRequestToCoverage = nil;
    GPKGBoundingBox * requestProjectedBoundingBox = request.boundingBox;
    if (!self.sameProjection) {
        transformRequestToCoverage = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.coverageProjection];
        requestProjectedBoundingBox = [transformRequestToCoverage transformWithBoundingBox:requestProjectedBoundingBox];
    }
    [request setProjectedBoundingBox:requestProjectedBoundingBox];
    
    // Determine how many overlapping pixels to store based upon the
    // algorithm
    int overlappingPixels;
    switch (self.algorithm) {
        case GPKG_CDA_BICUBIC:
            overlappingPixels = 3;
            break;
        default:
            overlappingPixels = 1;
    }
    
    // Find the tile matrix and results
    GPKGCoverageDataTileMatrixResults * results = [self resultsWithCoverageDataRequest: request andBoundingBox: requestProjectedBoundingBox andOverlappingPixels: overlappingPixels];
    
    if(results != nil){
        
        GPKGTileMatrix * tileMatrix = [results tileMatrix];
        GPKGResultSet * tileResults = [results tileResults];
        
        @try {
            
            // Determine the requested coverage data dimensions, or use the
            // dimensions of a single tile matrix coverage data tile
            int requestedWidth = width != nil ? [width intValue] : [tileMatrix.tileWidth intValue];
            int requestedHeight = height != nil ? [height intValue] : [tileMatrix.tileHeight intValue];
            
            // Determine the size of the non projected coverage data results
            int tileWidth = requestedWidth;
            int tileHeight = requestedHeight;
            if (!self.sameProjection) {
                int projectedWidth = (int) round(([requestProjectedBoundingBox.maxLongitude doubleValue] - [requestProjectedBoundingBox.minLongitude doubleValue]) / [tileMatrix.pixelXSize doubleValue]);
                if (projectedWidth > 0) {
                    tileWidth = projectedWidth;
                }
                int projectedHeight = (int) round(([requestProjectedBoundingBox.maxLatitude doubleValue] - [requestProjectedBoundingBox.minLatitude doubleValue]) / [tileMatrix.pixelYSize doubleValue]);
                if (projectedHeight > 0) {
                    tileHeight = projectedHeight;
                }
            }
            
            // Retrieve the coverage data values from the results
            NSArray * values = [self valuesWithTileMatrix: tileMatrix andTileResults: tileResults andRequest: request andTileWidth: tileWidth andTileHeight: tileHeight andOverlappingPixels: overlappingPixels];
            
            // Project the coverage data values if needed
            if (values != nil && !self.sameProjection && !request.isPoint) {
                values = [self reprojectValues:values withWidth:requestedWidth andHeight:requestedHeight andRequestBoundingBox:request.boundingBox andProjectionTransform:transformRequestToCoverage andCoverageBoundingBox:requestProjectedBoundingBox];
            }
            
            // Create the results
            if (values != nil) {
                coverageResults = [[GPKGCoverageDataResults alloc] initWithValues:values andTileMatrix:tileMatrix];
            }
        } @finally {
            [tileResults close];
        }
    }
    
    return coverageResults;
}

-(GPKGCoverageDataResults *) valuesUnboundedWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    GPKGCoverageDataRequest * request = [[GPKGCoverageDataRequest alloc] initWithBoundingBox:requestBoundingBox];
    return [self valuesUnboundedWithCoverageDataRequest: request];
}

-(GPKGCoverageDataResults *) valuesUnboundedWithCoverageDataRequest: (GPKGCoverageDataRequest *) request{
    
    GPKGCoverageDataResults * coverageResults = nil;
    
    // Transform to the projection of the coverage data tiles
    GPKGProjectionTransform * transformRequestToCoverage = nil;
    GPKGBoundingBox * requestProjectedBoundingBox = request.boundingBox;
    if (!self.sameProjection) {
        transformRequestToCoverage = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.coverageProjection];
        requestProjectedBoundingBox = [transformRequestToCoverage transformWithBoundingBox:requestProjectedBoundingBox];
    }
    [request setProjectedBoundingBox:requestProjectedBoundingBox];
    
    // Find the tile matrix and results
    GPKGCoverageDataTileMatrixResults * results = [self resultsWithCoverageDataRequest: request andBoundingBox: requestProjectedBoundingBox];
    
    if(results != nil){
        
        GPKGTileMatrix * tileMatrix = [results tileMatrix];
        GPKGResultSet * tileResults = [results tileResults];
        
        @try {
            
            // Retrieve the coverage data values from the results
            NSArray * values = [self valuesUnboundedWithTileMatrix: tileMatrix andTileResults: tileResults andRequest: request];
            
            // Project the coverage data values if needed
            if (values != nil && !self.sameProjection && !request.isPoint) {
                values = [self reprojectValues:values withWidth:[self countInDoubleArray:values atIndex1:0] andHeight:(int)values.count andRequestBoundingBox:request.boundingBox andProjectionTransform:transformRequestToCoverage andCoverageBoundingBox:requestProjectedBoundingBox];
            }
            
            // Create the results
            if (values != nil) {
                coverageResults = [[GPKGCoverageDataResults alloc] initWithValues:values andTileMatrix:tileMatrix];
            }
            
        } @finally {
            [tileResults close];
        }
    }
    
    return coverageResults;
}

/**
 * Get the coverage data results by finding the tile matrix with values
 *
 * @param request
 *            coverage data request
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsWithCoverageDataRequest: (GPKGCoverageDataRequest *) request andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox{
    return [self resultsWithCoverageDataRequest:request andBoundingBox:requestProjectedBoundingBox andOverlappingPixels:0];
}

/**
 * Get the coverage data results by finding the tile matrix with values
 *
 * @param request
 *            coverage data request
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param overlappingPixels
 *            overlapping request pixels
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsWithCoverageDataRequest: (GPKGCoverageDataRequest *) request andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andOverlappingPixels: (int) overlappingPixels{
    // Try to get the coverage data from the current zoom level
    GPKGTileMatrix * tileMatrix = [self tileMatrixWithRequest: request];
    GPKGCoverageDataTileMatrixResults * results = nil;
    if (tileMatrix != nil) {
        results = [self resultsWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
        
        // Try to zoom in or out to find matching coverage data
        if (results == nil) {
            results = [self resultsZoomWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
        }
    }
    return results;
}

/**
 * Get the coverage data results for a specified tile matrix
 *
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param tileMatrix
 *            tile matrix
 * @param overlappingPixels
 *            number of overlapping pixels used by the algorithm
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    GPKGCoverageDataTileMatrixResults * results = nil;
    GPKGBoundingBox * paddedBoundingBox = [self padBoundingBoxWithTileMatrix:tileMatrix andBoundingBox:requestProjectedBoundingBox andOverlap:overlappingPixels];
    GPKGResultSet * tileResults = [self retrieveSortedTileResultsWithBoundingBox: paddedBoundingBox andTileMatrix: tileMatrix];
    if(tileResults != nil){
        if(tileResults.count > 0){
            results = [[GPKGCoverageDataTileMatrixResults alloc] initWithTileMatrix:tileMatrix andTileResults:tileResults];
        }else{
            [tileResults close];
        }
    }
    return results;
}

/**
 * Get the coverage data results by zooming in or out as needed from the
 * provided tile matrix to find values
 *
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param tileMatrix
 *            tile matrix
 * @param overlappingPixels
 *            overlapping request pixels
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsZoomWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGCoverageDataTileMatrixResults * results = nil;
    
    if (self.zoomIn && self.zoomInBeforeOut) {
        results = [self resultsZoomInWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
    }
    if (results == nil && self.zoomOut) {
        results = [self resultsZoomOutWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
    }
    if (results == nil && self.zoomIn && !self.zoomInBeforeOut) {
        results = [self resultsZoomInWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
    }
    
    return results;
}

/**
 * Get the coverage data results by zooming in from the provided tile
 * matrix
 *
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param tileMatrix
 *            tile matrix
 * @param overlappingPixels
 *            overlapping request pixels
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsZoomInWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGCoverageDataTileMatrixResults * results = nil;
    for (int zoomLevel = [tileMatrix.zoomLevel intValue] + 1; zoomLevel <= self.tileDao
         .maxZoom; zoomLevel++) {
        GPKGTileMatrix * zoomTileMatrix = [self.tileDao getTileMatrixWithZoomLevel:zoomLevel];
        if (zoomTileMatrix != nil) {
            results = [self resultsWithBoundingBox:requestProjectedBoundingBox andTileMatrix:zoomTileMatrix andOverlappingPixels:overlappingPixels];
            if (results != nil) {
                break;
            }
        }
    }
    return results;
}

/**
 * Get the coverage data results by zooming out from the provided tile
 * matrix
 *
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param tileMatrix
 *            tile matrix
 * @param overlappingPixels
 *            overlapping request pixels
 * @return tile matrix results
 */
-(GPKGCoverageDataTileMatrixResults *) resultsZoomOutWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGCoverageDataTileMatrixResults * results = nil;
    for (int zoomLevel = [tileMatrix.zoomLevel intValue] - 1; zoomLevel >= self.tileDao
         .minZoom; zoomLevel--) {
        GPKGTileMatrix * zoomTileMatrix = [self.tileDao getTileMatrixWithZoomLevel:zoomLevel];
        if (zoomTileMatrix != nil) {
            results = [self resultsWithBoundingBox:requestProjectedBoundingBox andTileMatrix:zoomTileMatrix andOverlappingPixels:overlappingPixels];
            if (results != nil) {
                break;
            }
        }
    }
    return results;
}

/**
 * Get the coverage data values from the tile results scaled to the provided
 * dimensions
 *
 * @param tileMatrix
 *            tile matrix
 * @param tileResults
 *            tile results
 * @param request
 *            coverage data request
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @param overlappingPixels
 *            overlapping request pixels
 * @return coverage data values
 */
-(NSArray *) valuesWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults andRequest: (GPKGCoverageDataRequest *) request andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andOverlappingPixels: (int) overlappingPixels{

    NSMutableArray * values = nil;
    
    // Tiles are ordered by rows and then columns. Track the last column
    // coverage data values of the tile to the left and the last rows of the tiles in
    // the row above
    NSMutableArray * leftLastColumns = nil;
    NSMutableDictionary * lastRowsByColumn = nil;
    NSMutableDictionary * previousLastRowsByColumn = nil;
    
    int previousRow = -1;
    int previousColumn = INT_MAX;
    
    // Process each coverage data tile
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileMatrix.tableName];
    while ([tileResults moveToNext]) {
        
        // Get the next coverage data tile
        GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
        
        int currentRow = [tileRow getTileRow];
        int currentColumn = [tileRow getTileColumn];
        
        // If the row has changed, save off the previous last rows and begin
        // tracking this row. Clear the left last columns.
        if (currentRow > previousRow) {
            previousLastRowsByColumn = lastRowsByColumn;
            lastRowsByColumn = [[NSMutableDictionary alloc] init];
            leftLastColumns = nil;
        }
        
        // If there was a previous row, retrieve the top left and top
        // overlapping rows
        NSMutableArray * topLeftRows = nil;
        NSMutableArray * topRows = nil;
        if (previousLastRowsByColumn != nil) {
            topLeftRows = [previousLastRowsByColumn objectForKey:[NSNumber numberWithInt:currentColumn - 1]];
            topRows = [previousLastRowsByColumn objectForKey:[NSNumber numberWithInt:currentColumn]];
        }
        
        // If the current column is not the column after the previous clear
        // the left values
        if (currentColumn < previousColumn
            || currentColumn != previousColumn + 1) {
            leftLastColumns = nil;
        }
        
        // Get the bounding box of the coverage data
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.coverageBoundingBox andTileMatrix:tileMatrix andTileColumn:currentColumn andTileRow:currentRow];
        
        // Get the bounding box where the request and coverage data tile overlap
        GPKGBoundingBox * overlap = [request overlapWithBoundingBox:tileBoundingBox];
        
        // Get the gridded tile value for the tile
        GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
        
        // Get the coverage data tile image
        NSObject<GPKGCoverageDataImage> * image = [self createImageWithTileRow:tileRow];
        
        // If the tile overlaps with the requested box
        if (overlap != nil) {
            
            // Get the rectangle of the tile coverage data with matching values
            CGRect src = [GPKGTileBoundingBoxUtils getRectangleWithWidth:[tileMatrix.tileWidth intValue] andHeight:[tileMatrix.tileHeight intValue] andBoundingBox:tileBoundingBox andSection:overlap];
            
            // Get the rectangle of where to store the results
            CGRect dest;
            if ([request.projectedBoundingBox equals:overlap]) {
                if ([request isPoint]) {
                    // For single points request only a single destination
                    // pixel
                    dest = CGRectMake(0, 0, 0, 0);
                } else {
                    // The overlap is equal to the request, set as the full
                    // destination size
                    dest = CGRectMake(0, 0, tileWidth, tileHeight);
                }
            } else {
                dest = [GPKGTileBoundingBoxUtils getRectangleWithWidth:tileWidth andHeight:tileHeight andBoundingBox:request.projectedBoundingBox andSection:overlap];
            }
            
            if (src.size.width >= 0 && src.size.height >= 0
                && dest.size.width >= 0 && dest.size.height >= 0) {
                
                // Create the coverage data array first time through
                if (values == nil) {
                    values = [self createNullFilledDoubleArrayWithSize1:tileHeight andSize2:tileWidth];
                }
                
                // Get the destination widths
                float destWidth = dest.size.width;
                float destHeight = dest.size.height;
                
                // Get the destination heights
                float srcWidth = src.size.width;
                float srcHeight = src.size.height;
                
                // Determine the source to destination ratio and how many
                // destination pixels equal half a source pixel
                float widthRatio;
                float halfDestWidthPixel;
                if (destWidth == 0) {
                    widthRatio = 0.0f;
                    halfDestWidthPixel = 0.0f;
                } else {
                    widthRatio = srcWidth / destWidth;
                    halfDestWidthPixel = 0.5f / widthRatio;
                }
                float heightRatio;
                float halfDestHeightPixel;
                if (destHeight == 0) {
                    heightRatio = 0.0f;
                    halfDestHeightPixel = 0.0f;
                } else {
                    heightRatio = srcHeight / destHeight;
                    halfDestHeightPixel = 0.5f / heightRatio;
                }
                
                float algorithmDestWidthPixelOverlap = halfDestWidthPixel
                    * overlappingPixels;
                float algorithmDestHeightPixelOverlap = halfDestHeightPixel
                    * overlappingPixels;
                
                // Determine the range of destination values to set
                int minDestY = (int) floor(dest.origin.y
                                                - algorithmDestHeightPixelOverlap);
                int maxDestY = (int) ceil(dest.origin.y + dest.size.height
                                               + algorithmDestHeightPixelOverlap);
                int minDestX = (int) floor(dest.origin.x
                                                - algorithmDestWidthPixelOverlap);
                int maxDestX = (int) ceil(dest.origin.x + dest.size.width
                                               + algorithmDestWidthPixelOverlap);
                minDestY = MAX(minDestY, 0);
                minDestX = MAX(minDestX, 0);
                maxDestY = MIN(maxDestY, tileHeight - 1);
                maxDestX = MIN(maxDestX, tileWidth - 1);
                
                // Read and set the coverage data values
                for (int y = minDestY; y <= maxDestY; y++) {
                    for (int x = minDestX; x <= maxDestX; x++) {
                        
                        // Determine the coverage data value based upon the
                        // selected algorithm
                        NSDecimalNumber * value = nil;
                        switch (self.algorithm) {
                            case GPKG_CDA_NEAREST_NEIGHBOR:
                                value = [self nearestNeighborValueWithGriddedTile:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            case GPKG_CDA_BILINEAR:
                                value = [self bilinearInterpolationValueWithGriddedTile:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            case GPKG_CDA_BICUBIC:
                                value = [self bicubicInterpolationValueWithGriddedTile:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            default:
                                [NSException raise:@"Unsupported Algorithm" format:@"Algorithm is not supported: %u", self.algorithm];
                        }
                        
                        if (value != nil) {
                            [self replaceObjectInDoubleArray:values atIndex1:y andIndex2:x withValue:value];
                        }
                        
                    }
                }
                
            }
        }
        
        // Determine and store the coverage data values of the last columns and rows
        leftLastColumns = [[NSMutableArray alloc] initWithCapacity:overlappingPixels];
        NSMutableArray * lastRows = [[NSMutableArray alloc] initWithCapacity:overlappingPixels];
        [lastRowsByColumn setObject:lastRows forKey:[NSNumber numberWithInt:currentColumn]];
        
        // For each overlapping pixel
        for (int lastIndex = 0; lastIndex < overlappingPixels; lastIndex++) {
            
            // Store the last column row coverage data values
            NSMutableArray * leftLastColumnsRow = [[NSMutableArray alloc] initWithCapacity:[tileMatrix.tileHeight intValue]];
            [leftLastColumns addObject:leftLastColumnsRow];
            int lastColumnIndex = [tileMatrix.tileWidth intValue] - lastIndex - 1;
            for (int row = 0; row < [tileMatrix.tileHeight intValue]; row++) {
                NSDecimalNumber * value = [self valueWithGriddedTile:griddedTile andCoverageDataImage:image andX:lastColumnIndex andY:row];
                [GPKGUtils addObject:value toArray:leftLastColumnsRow];
            }
            
            // Store the last row column coverage data values
            NSMutableArray * lastRowsColumn = [[NSMutableArray alloc] initWithCapacity:[tileMatrix.tileWidth intValue]];
            [lastRows addObject:lastRowsColumn];
            int lastRowIndex = [tileMatrix.tileHeight intValue] - lastIndex - 1;
            for (int column = 0; column < [tileMatrix.tileWidth intValue]; column++) {
                NSDecimalNumber * value = [self valueWithGriddedTile:griddedTile andCoverageDataImage:image andX:column andY:lastRowIndex];
                [GPKGUtils addObject:value toArray:lastRowsColumn];
            }
            
        }
        
        // Update the previous row and column
        previousRow = currentRow;
        previousColumn = currentColumn;
    }
    
    return values;
}

/**
 * Get the bilinear interpolation coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param y
 *            y coordinate
 * @param x
 *            x coordinate
 * @param widthRatio
 *            width source over destination ratio
 * @param heightRatio
 *            height source over destination ratio
 * @param destTop
 *            destination top most pixel
 * @param destLeft
 *            destination left most pixel
 * @param srcTop
 *            source top most pixel
 * @param srcLeft
 *            source left most pixel
 * @return bilinear coverage data value
 */
-(NSDecimalNumber *) bilinearInterpolationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    GPKGCoverageDataSourcePixel * sourcePixelX = [self minAndMaxOfXSource:xSource];
    GPKGCoverageDataSourcePixel * sourcePixelY = [self minAndMaxOfYSource:ySource];
    
    NSMutableArray * values = [self createNullFilledDoubleArrayWithSize1:2 andSize2:2];
    [self populateValues:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andPixelX:sourcePixelX andPixelY:sourcePixelY andValues:values];
    
    NSDecimalNumber * value = nil;
    
    if (values != nil) {
        value = [self bilinearInterpolationValueWithSourcePixelX:sourcePixelX andSourcePixelY:sourcePixelY andValues:values];
    }
    
    return value;
}

/**
 * Get the bicubic interpolation coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param y
 *            y coordinate
 * @param x
 *            x coordinate
 * @param widthRatio
 *            width source over destination ratio
 * @param heightRatio
 *            height source over destination ratio
 * @param destTop
 *            destination top most pixel
 * @param destLeft
 *            destination left most pixel
 * @param srcTop
 *            source top most pixel
 * @param srcLeft
 *            source left most pixel
 * @return bicubic coverage data value
 */
-(NSDecimalNumber *) bicubicInterpolationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    GPKGCoverageDataSourcePixel * sourcePixelX = [self minAndMaxOfXSource:xSource];
    [sourcePixelX setMin:sourcePixelX.min - 1];
    [sourcePixelX setMax:sourcePixelX.max + 1];
    
    GPKGCoverageDataSourcePixel * sourcePixelY = [self minAndMaxOfYSource:ySource];
    [sourcePixelY setMin:sourcePixelY.min - 1];
    [sourcePixelY setMax:sourcePixelY.max + 1];
    
    NSMutableArray * values = [self createNullFilledDoubleArrayWithSize1:4 andSize2:4];
    [self populateValues:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andPixelX:sourcePixelX andPixelY:sourcePixelY andValues:values];
    
    NSDecimalNumber * value = nil;
    
    if (values != nil) {
        value = [self bicubicInterpolationValueWithValues:values andSourcePixelX:sourcePixelX andSourcePixelY:sourcePixelY];
    }
    
    return value;
}

/**
 * Populate the coverage data values
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param pixelX
 *            source x pixel
 * @param pixelY
 *            source y pixel
 * @param values
 *            values to populate
 */
-(void) populateValues: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andPixelX: (GPKGCoverageDataSourcePixel *) pixelX andPixelY: (GPKGCoverageDataSourcePixel *) pixelY andValues: (NSMutableArray *) values{
    
    [self populateValues:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andMinX:pixelX.min andMaxX:pixelX.max andMinY:pixelY.min andMaxY:pixelY.max andValues:values];
}

/**
 * Populate the coverage data values
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param minX
 *            min x coordinate
 * @param maxX
 *            max x coordinate
 * @param minY
 *            min y coordinate
 * @param maxY
 *            max y coordinate
 * @param values
 *            values to populate
 */
-(void) populateValues: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andMinX: (int) minX andMaxX: (int) maxX andMinY: (int) minY andMaxY: (int) maxY andValues: (NSMutableArray *) values{
    
    for (int yLocation = maxY; values != nil && yLocation >= minY; yLocation--) {
        for (int xLocation = maxX; xLocation >= minX; xLocation--) {
            NSDecimalNumber * value = [self valueOverBordersWithGriddedTile:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andX:xLocation andY:yLocation];

            if (value == nil) {
                values = nil;
                break;
            } else {
                [self replaceObjectInDoubleArray:values atIndex1:yLocation - minY andIndex2:xLocation - minX withValue:value];
            }
        }
    }
}

/**
 * Get the nearest neighbor coverage data value
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param y
 *            y coordinate
 * @param x
 *            x coordinate
 * @param widthRatio
 *            width source over destination ratio
 * @param heightRatio
 *            height source over destination ratio
 * @param destTop
 *            destination top most pixel
 * @param destLeft
 *            destination left most pixel
 * @param srcTop
 *            source top most pixel
 * @param srcLeft
 *            source left most pixel
 * @return nearest neighbor coverage data value
 */
-(NSDecimalNumber *) nearestNeighborValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    // Get the closest nearest neighbors
    NSArray * nearestNeighbors = [self nearestNeighborsWithXSource:xSource andYSource:ySource];
    
    // Get the coverage data value from the source pixel nearest neighbors until
    // one is found
    NSDecimalNumber * value = nil;
    for (NSArray * nearestNeighbor in nearestNeighbors) {
        value = [self valueOverBordersWithGriddedTile:griddedTile andCoverageDataImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andX:[((NSNumber *)[nearestNeighbor objectAtIndex:0]) intValue] andY:[((NSNumber *)[nearestNeighbor objectAtIndex:1]) intValue]];
        if (value != nil) {
            break;
        }
    }
    
    return value;
}

/**
 * Get the coverage data value from the coordinate location. If the coordinate
 * crosses the left, top, or top left tile, attempts to get the coverage data value
 * from previously processed border coverage data values.
 *
 * @param griddedTile
 *            gridded tile
 * @param image
 *            image
 * @param leftLastColumns
 *            last columns in the tile to the left
 * @param topLeftRows
 *            last rows of the tile to the top left
 * @param topRows
 *            last rows of the tile to the top
 * @param x
 *            x coordinate
 * @param y
 *            y coordinate
 * @return coverage data value
 */
-(NSDecimalNumber *) valueOverBordersWithGriddedTile: (GPKGGriddedTile *) griddedTile andCoverageDataImage: (NSObject<GPKGCoverageDataImage> *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andX: (int) x andY: (int) y{

    NSDecimalNumber * value = nil;
    
    // Only handle locations in the current tile, to the left, top left, or
    // top tiles. Tiles are processed sorted by rows and columns, so values
    // to the top right, right, or any below tiles will be handled later if
    // those tiles exist
    if (x < [image width] && y < [image height]) {
        
        if (x >= 0 && y >= 0) {
            value = [self valueWithGriddedTile:griddedTile andCoverageDataImage:image andX:x andY:y];
        } else if (x < 0 && y < 0) {
            // Try to get the coverage data value from the top left tile values
            if (topLeftRows != nil) {
                int row = (-1 * y) - 1;
                if (row < topLeftRows.count) {
                    int column = x + [self countInDoubleArray:topLeftRows atIndex1:row];
                    if (column >= 0) {
                        value = (NSDecimalNumber *)[self objectInDoubleArray:topLeftRows atIndex1:row andIndex2:column];
                    }
                }
            }
        } else if (x < 0) {
            // Try to get the coverage data value from the left tile values
            if (leftLastColumns != nil) {
                int column = (-1 * x) - 1;
                if (column < leftLastColumns.count) {
                    int row = y;
                    if (row < [self countInDoubleArray:leftLastColumns atIndex1:column]) {
                        value = (NSDecimalNumber *)[self objectInDoubleArray:leftLastColumns atIndex1:column andIndex2:row];
                    }
                }
            }
        } else {
            // Try to get the coverage data value from the top tile values
            if (topRows != nil) {
                int row = (-1 * y) - 1;
                if (row < topRows.count) {
                    int column = x;
                    if (column < [self countInDoubleArray:topRows atIndex1:row]) {
                        value = (NSDecimalNumber *)[self objectInDoubleArray:topRows atIndex1:row andIndex2:column];
                    }
                }
            }
        }
        
    }
    
    return value;
}

/**
 * Get the coverage data values from the tile results unbounded in result size
 *
 * @param tileMatrix
 *            tile matrix
 * @param tileResults
 *            tile results
 * @param request
 *            coverage data request
 * @return coverage data values
 */
-(NSArray *) valuesUnboundedWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults andRequest: (GPKGCoverageDataRequest *) request{

    // Build a map of rows to maps of columns and values
    GPKGCoverageDictionary * rowsMap = [[GPKGCoverageDictionary alloc] init];
    
    // Track the min and max row and column
    NSNumber * minRow = nil;
    NSNumber * maxRow = nil;
    NSNumber * minColumn = nil;
    NSNumber * maxColumn = nil;
    
    // Track count of tiles involved in the results
    int tileCount = 0;
    
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileMatrix.tableName];
    
    // Process each coverage data tile row
    while([tileResults moveToNext]){
        
        // Get the next coverage data tile
        GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
        
        // Get the bounding box of the coverage data
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.coverageBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
        
        // Get the bounding box where the request and coverage data tile overlap
        GPKGBoundingBox * overlap = [request overlapWithBoundingBox:tileBoundingBox];
        
        // If the coverage data tile overlaps with the requested box
        if (overlap != nil) {
            
            // Get the rectangle of the tile coverage data with matching values
            CGRect src = [GPKGTileBoundingBoxUtils getRectangleWithWidth:[tileMatrix.tileWidth intValue] andHeight:[tileMatrix.tileHeight intValue] andBoundingBox:tileBoundingBox andSection:overlap];
            
            if (src.size.width >= 0 && src.size.height >= 0) {
                
                // Get the source dimensions
                int srcTop = MIN(src.origin.y, [tileMatrix.tileHeight intValue] - 1);
                int srcBottom = MIN(src.origin.y + src.size.height, [tileMatrix.tileHeight intValue] - 1);
                int srcLeft = MIN(src.origin.x, [tileMatrix.tileWidth intValue] - 1);
                int srcRight = MIN(src.origin.x + src.size.width, [tileMatrix.tileWidth intValue] - 1);
                
                // Get the gridded tile value for the tile
                GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
                
                // Get the coverage data tile image
                NSObject<GPKGCoverageDataImage> * image = [self createImageWithTileRow:tileRow];
                
                // Create the coverage data results for this tile
                NSMutableArray * values = [[NSMutableArray alloc] initWithCapacity:srcBottom - srcTop + 1];
                
                // Get or add the columns map to the rows map
                GPKGCoverageDictionary * columnsMap = [rowsMap.dictionary objectForKey:[NSNumber numberWithInt:[tileRow getTileRow]]];
                if (columnsMap == nil) {
                    columnsMap = [[GPKGCoverageDictionary alloc] init];
                    [rowsMap setObject:columnsMap forKey:[NSNumber numberWithInt:[tileRow getTileRow]]];
                }
                
                // Read and set the coverage data values
                for (int y = srcTop; y <= srcBottom; y++) {
                    
                    NSMutableArray * innerValues = [[NSMutableArray alloc] initWithCapacity:srcRight - srcLeft + 1];
                    [values addObject:innerValues];
                    
                    for (int x = srcLeft; x <= srcRight; x++) {
                        
                        // Get the coverage data value from the source pixel
                        NSDecimalNumber * value = [self valueWithGriddedTile:griddedTile andCoverageDataImage:image andX:x andY:y];
                        
                        [GPKGUtils addObject:value toArray:innerValues];
                    }
                }
                
                // Set the coverage data values in the results map
                [columnsMap setObject:values forKey:[NSNumber numberWithInt:[tileRow getTileColumn]]];
                
                // Increase the contributing tiles count
                tileCount++;
                
                // Track the min and max row and column
                minRow = [NSNumber numberWithInt:(minRow == nil ? [tileRow getTileRow] : MIN([minRow intValue], [tileRow getTileRow]))];
                maxRow = [NSNumber numberWithInt:(maxRow == nil ? [tileRow getTileRow] : MAX([maxRow intValue], [tileRow getTileRow]))];
                minColumn = [NSNumber numberWithInt:(minColumn == nil ? [tileRow getTileColumn] : MIN([minColumn intValue], [tileRow getTileColumn]))];
                maxColumn = [NSNumber numberWithInt:(maxColumn == nil ? [tileRow getTileColumn] : MAX([maxColumn intValue], [tileRow getTileColumn]))];
            }
        }
    }
    
    // Handle formatting the results
    NSArray * values = [self formatUnboundedResultsWithTileMatrix:tileMatrix andCoverageDictionary:rowsMap andTileCount:tileCount andMinRow:[minRow intValue] andMaxRow:[maxRow intValue] andMinColumn:[minColumn intValue] andMaxColumn:[maxColumn intValue]];
    
    return values;
}

/**
 * Get the tile matrix for the zoom level as defined by the area of the
 * request
 *
 * @param request
 *            coverage data request
 * @return tile matrix or null
 */
-(GPKGTileMatrix *) tileMatrixWithRequest: (GPKGCoverageDataRequest *) request{

    GPKGTileMatrix * tileMatrix = nil;
    
    // Check if the request overlaps coverage data bounding box
    if([request overlapWithBoundingBox:self.coverageBoundingBox] != nil){
        
        // Get the tile distance
        GPKGBoundingBox * projectedBoundingBox = request.projectedBoundingBox;
        double distanceWidth = [projectedBoundingBox.maxLongitude doubleValue] - [projectedBoundingBox.minLongitude doubleValue];
        double distanceHeight = [projectedBoundingBox.maxLatitude doubleValue] - [projectedBoundingBox.minLatitude doubleValue];
        
        // Get the zoom level to request based upon the tile size
        NSNumber * zoomLevel = [self.tileDao closestZoomLevelWithWidth:distanceWidth andHeight:distanceHeight];
        
        // If there is a matching zoom level
        if (zoomLevel != nil) {
            tileMatrix = [self.tileDao getTileMatrixWithZoomLevel:[zoomLevel intValue]];
        }
    }
    
    return tileMatrix;
}

/**
 * Get the tile row results of coverage data needed to create the
 * requested bounding box coverage data, sorted by row and then column
 *
 * @param projectedRequestBoundingBox
 *            bounding box projected to the coverage data
 * @param tileMatrix
 *            tile matrix
 * @return tile results or null
 */
-(GPKGResultSet *) retrieveSortedTileResultsWithBoundingBox: (GPKGBoundingBox *) projectedRequestBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix{

    GPKGResultSet * tileResults = nil;
    
    if (tileMatrix != nil) {
        
        // Get the tile grid
        GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithTotalBoundingBox:self.coverageBoundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:projectedRequestBoundingBox];
        
        // Query for matching tiles in the tile grid
        tileResults = [self.tileDao queryByTileGrid:tileGrid andZoomLevel:[tileMatrix.zoomLevel intValue] andOrderBy:[NSString stringWithFormat:@"%@,%@", GPKG_TT_COLUMN_TILE_ROW, GPKG_TT_COLUMN_TILE_COLUMN]];

    }
    
    return tileResults;
}

/**
 * Create a new array using the provided sizes filled with NSNull values
 *
 * @param size1
 *            array size 1
 * @param size2
 *            array size 2
 * @return NSNull filled double array
 */
-(NSMutableArray *) createNullFilledDoubleArrayWithSize1: (int) size1 andSize2: (int) size2{
    NSMutableArray * array = [[NSMutableArray alloc] initWithCapacity:size1];
    for(int i = 0; i < size1; i++){
        NSMutableArray * subArray = [[NSMutableArray alloc] initWithCapacity:size2];
        for(int j = 0; j < size2; j++){
            [subArray addObject:[NSNull null]];
        }
        [array addObject:subArray];
    }
    return array;
}

/**
 * Replace an object in the double array at index 1 & 2 with the provided value
 *
 * @param array
 *            double array
 * @param index1
 *            index 1
 * @param index2
 *            index 2
 * @param value
 *            object value
 */
-(void) replaceObjectInDoubleArray: (NSMutableArray *) array atIndex1: (int) index1 andIndex2: (int) index2 withValue: (NSObject *) value{
    [GPKGUtils replaceObjectAtIndex:index2 withObject:value inArray:(NSMutableArray *)[array objectAtIndex:index1]];
}

/**
 * Get an object value in the double array at index 1 & 2
 *
 * @param array
 *            double array
 * @param index1
 *            index 1
 * @param index2
 *            index 2
 * @return object value
 */
-(NSObject *) objectInDoubleArray: (NSArray *) array atIndex1: (int) index1 andIndex2: (int) index2{
    return [GPKGUtils objectAtIndex:index2 inArray:(NSArray *)[array objectAtIndex:index1]];
}

/**
 * Get the count in the double array at the index
 *
 * @param array
 *            double array
 * @param index1
 *            index 1
 * @return count
 */
-(int) countInDoubleArray: (NSArray *) array atIndex1: (int) index1{
    return (int)((NSArray *)[array objectAtIndex:index1]).count;
}

-(double) valueWithTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
    double value = [self valueWithGriddedTile:griddedTile andTileRow:tileRow andX:x andY:y];
    return value;
}


@end
