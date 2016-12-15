//
//  GPKGElevationTilesCore.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesCore.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGElevationTilesAlgorithms.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionTransform.h"
#import "GPKGElevationSourcePixel.h"
#import "GPKGElevationTileMatrixResults.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"

NSString * const GPKG_ELEVATION_TILES_EXTENSION_NAME = @"elevation_tiles";
NSString * const GPKG_PROP_ELEVATION_TILES_EXTENSION_DEFINITION = @"geopackage.extensions.elevation_tiles";

@interface GPKGElevationDictionary: NSObject

@property (nonatomic, strong) NSMutableArray * keys;
@property (nonatomic, strong) NSMutableDictionary * dictionary;

@end

@implementation GPKGElevationDictionary

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

@interface GPKGElevationTilesCore ()

@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;
@property (nonatomic, strong) GPKGGriddedCoverageDao *griddedCoverageDao;
@property (nonatomic, strong) GPKGGriddedTileDao *griddedTileDao;
@property (nonatomic, strong) GPKGGriddedCoverage *griddedCoverage;
@property (nonatomic, strong) GPKGProjection *requestProjection;
@property (nonatomic, strong) GPKGProjection *elevationProjection;
@property (nonatomic, strong) GPKGBoundingBox *elevationBoundingBox;
@property (nonatomic) BOOL sameProjection;

@end

@implementation GPKGElevationTilesCore

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_ELEVATION_TILES_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_ELEVATION_TILES_EXTENSION_DEFINITION];
        self.zoomIn = true;
        self.zoomOut = true;
        self.zoomInBeforeOut = true;
        self.algorithm = GPKG_ETA_NEAREST_NEIGHBOR;
        
        self.tileDao = tileDao;
        self.tileMatrixSet = tileDao.tileMatrixSet;
        self.griddedCoverageDao = [geoPackage getGriddedCoverageDao];
        self.griddedTileDao = [geoPackage getGriddedTileDao];
        [self queryGriddedCoverage];
        
        self.width = width;
        self.height = height;
        self.requestProjection = requestProjection;
        self.elevationProjection = [GPKGProjectionFactory getProjectionWithSrs:[[geoPackage getTileMatrixSetDao] getSrs:tileDao.tileMatrixSet]];
        self.elevationBoundingBox = [tileDao.tileMatrixSet getBoundingBox];
        
        // Check if the projections have the same units
        if(requestProjection != nil){
            self.sameProjection = [requestProjection getUnit] == [self.elevationProjection getUnit];
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

-(GPKGProjection *) elevationProjection{
    return _elevationProjection;
}

-(GPKGBoundingBox *) elevationBoundingBox{
    return _elevationBoundingBox;
}

-(BOOL) isSameProjection{
    return _sameProjection;
}

-(NSArray *) getOrCreate{
    
    // Create tables
    [self.geoPackage createGriddedCoverageTable];
    [self.geoPackage createGriddedTileTable];
    
    NSMutableArray * extensions = [[NSMutableArray alloc] init];
    
    GPKGExtensions * coverage = [self getOrCreateWithExtensionName:self.extensionName andTableName:GPKG_EGC_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    GPKGExtensions * tile = [self getOrCreateWithExtensionName:self.extensionName andTableName:GPKG_EGT_TABLE_NAME andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
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
    return [geoPackage getTablesByType:GPKG_CDT_ELEVATION_TILES];
}

/**
 * Reproject the elevations to the requested projection
 *
 * @param elevations
 *            elevations
 * @param requestedElevationsWidth
 *            requested elevations width
 * @param requestedElevationsHeight
 *            requested elevations height
 * @param requestBoundingBox
 *            request bounding box in the request projection
 * @param transformRequestToElevation
 *            transformation from request to elevations
 * @param elevationBoundingBox
 *            elevations bounding box
 * @return projected elevations
 */
-(NSArray *) reprojectElevations: (NSArray *) elevations withWidth: (int) requestedElevationsWidth andHeight: (int) requestedElevationsHeight andRequestBoundingBox: (GPKGBoundingBox *) requestBoundingBox andProjectionTransform: (GPKGProjectionTransform *) transformRequestToElevation andElevationBoundingBox: (GPKGBoundingBox *) elevationBoundingBox{
    
    double requestedWidthUnitsPerPixel = ([requestBoundingBox.maxLongitude doubleValue] - [requestBoundingBox.minLongitude doubleValue]) / requestedElevationsWidth;
    double requestedHeightUnitsPerPixel = ([requestBoundingBox.maxLatitude doubleValue] - [requestBoundingBox.minLatitude doubleValue]) / requestedElevationsHeight;
    
    double tilesDistanceWidth = [elevationBoundingBox.maxLongitude doubleValue] - [elevationBoundingBox.minLongitude doubleValue];
    double tilesDistanceHeight = [elevationBoundingBox.maxLatitude doubleValue] - [elevationBoundingBox.minLatitude doubleValue];
    
    int width = [self countInDoubleArray:elevations atIndex1:0];
    int height = (int) elevations.count;
    
    NSMutableArray * projectedElevations = [[NSMutableArray alloc] initWithCapacity:requestedElevationsHeight];
    
    // Retrieve each elevation in the unprojected elevations
    for (int y = 0; y < requestedElevationsHeight; y++) {
        NSMutableArray * elevationsRow = [[NSMutableArray alloc] initWithCapacity:requestedElevationsWidth];
        [projectedElevations addObject:elevationsRow];
        for (int x = 0; x < requestedElevationsWidth; x++) {
            
            double longitude = [requestBoundingBox.minLongitude doubleValue]
            + (x * requestedWidthUnitsPerPixel);
            double latitude = [requestBoundingBox.maxLatitude doubleValue]
            - (y * requestedHeightUnitsPerPixel);
            CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(latitude, longitude);
            CLLocationCoordinate2D toCoord = [transformRequestToElevation transform:fromCoord];
            double projectedLongitude = toCoord.longitude;
            double projectedLatitude = toCoord.latitude;
            
            int xPixel = (int) round(((projectedLongitude - [elevationBoundingBox.minLongitude doubleValue]) / tilesDistanceWidth)
                   * width);
            int yPixel = (int) round((([elevationBoundingBox.maxLatitude doubleValue] - projectedLatitude) / tilesDistanceHeight)
                   * height);
            
            xPixel = MAX(0, xPixel);
            xPixel = MIN(width - 1, xPixel);
            
            yPixel = MAX(0, yPixel);
            yPixel = MIN(height - 1, yPixel);
            
            NSDecimalNumber * elevation = (NSDecimalNumber *)[self objectInDoubleArray:elevations atIndex1:yPixel andIndex2:xPixel];
            [elevationsRow addObject:elevation];
        }
    }
    
    return projectedElevations;
}

/**
 * Get the elevations from the rows dictionary
 *
 * @param row
 *            row number
 * @param column
 *            column number
 * @return elevations
 */
-(NSArray *) getElevationsFromDictionary: (NSDictionary *) dictionary atRow: (int) row andColumn: (int) column{
    return (NSArray *)[((NSDictionary *)[dictionary objectForKey:[NSNumber numberWithInt:row]]) objectForKey:[NSNumber numberWithInt:column]];
}

/**
 * Get the elevations from the elevation dictionary
 *
 * @param row
 *            row number
 * @param column
 *            column number
 * @return elevations
 */
-(NSArray *) getElevationsFromElevationDictionary: (GPKGElevationDictionary *) elevationDictionary atRow: (int) row andColumn: (int) column{
    return (NSMutableArray *)[((GPKGElevationDictionary *)[elevationDictionary objectForKey:[NSNumber numberWithInt:row]]) objectForKey:[NSNumber numberWithInt:column]];
}

/**
 * Format the unbounded results from elevation tiles into a single double
 * array of elevation
 *
 * @param tileMatrix
 *            tile matrix
 * @param elevationDictionary
 *            elevation dictionary
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
 * @return elevations
 */
-(NSArray *) formatUnboundedResultsWithTileMatrix: (GPKGTileMatrix *) tileMatrix andElevationDictionary: (GPKGElevationDictionary *) elevationDictionary andTileCount: (int) tileCount andMinRow: (int) minRow andMaxRow: (int) maxRow andMinColumn: (int) minColumn andMaxColumn: (int) maxColumn{
    
    // Handle formatting the results
    NSMutableArray * elevations = nil;
    if(elevationDictionary.dictionary.count != 0){
        
        // If only one tile result, use the elevations as the result
        if (tileCount == 1) {
            elevations = (NSMutableArray *)[self getElevationsFromElevationDictionary:elevationDictionary atRow:minRow andColumn:minColumn];
        } else {
            
            // Else, combine all results into a single elevations result
            
            // Get the top left and bottom right elevations
            NSArray * topLeft = [self getElevationsFromElevationDictionary:elevationDictionary atRow:minRow andColumn:minColumn];
            NSArray * bottomRight = [self getElevationsFromElevationDictionary:elevationDictionary atRow:maxRow andColumn:maxColumn];
            
            // Determine the width and height of the top left elevation results
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
            
            // Create the elevation result array
            elevations = [self createNullFilledDoubleArrayWithSize1:height andSize2:width];
            
            // Copy the elevation values from each tile results into the
            // final result arrays
            for(NSNumber * rowKey in elevationDictionary.keys){
                
                // Determine the starting base row for this tile
                int row = [rowKey intValue];
                int baseRow = 0;
                if (minRow < row) {
                    baseRow = firstHeight
                        + (int) ((row - minRow - 1) * [tileMatrix.tileHeight intValue]);
                }
                
                // Get the row's columns dictionary
                GPKGElevationDictionary * columnsDictionary = [elevationDictionary objectForKey:rowKey];
                
                for(NSNumber * columnKey in columnsDictionary.keys){
                    
                    // Determine the starting base column for this tile
                    int column = [columnKey intValue];
                    int baseColumn = 0;
                    if (minColumn < column) {
                        baseColumn = firstWidth
                            + (int) ((column - minColumn - 1) * [tileMatrix.tileWidth intValue]);
                    }
                    
                    // Get the tiles elevation values
                    NSArray * values = [columnsDictionary objectForKey:columnKey];
                    
                    // Copy the columns array at each local elevation row to
                    // the global row and column result location
                    for (int localRow = 0; localRow < values.count; localRow++) {
                        
                        int globalRow = baseRow + localRow;
                        
                        NSArray * localRowArray = [values objectAtIndex:localRow];
                        NSMutableArray * elevationsRowArray = [elevations objectAtIndex:globalRow];
                        
                        [elevationsRowArray replaceObjectsInRange:NSMakeRange(baseColumn, localRowArray.count) withObjectsFromArray:localRowArray];
                    }
                }
            }

        }
    }
    
    return elevations;
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
 *            source over destination width radio
 * @return x source pixel
 */
-(float) xSourceWithX: (int) x andDestLeft: (float) destLeft andSrcLeft: (float) srcLeft andWidthRatio: (float) widthRatio{
    float middleOfXDestPixel = (x - destLeft) + 0.5f;
    float xSourcePixel = middleOfXDestPixel * widthRatio;
    float xSource = srcLeft + xSourcePixel;
    return xSource;
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
 *            source over destination height radio
 * @return y source pixel
 */
-(float) ySourceWithY: (int) y andDestTop: (float) destTop andSrcTop: (float) srcTop andHeightRatio: (float) heightRatio{
    float middleOfYDestPixel = (y - destTop) + 0.5f;
    float ySourcePixel = middleOfYDestPixel * heightRatio;
    float ySource = srcTop + ySourcePixel;
    return ySource;
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
    
    // Get the elevation source pixels for x and y
    GPKGElevationSourcePixel * xPixel = [self minAndMaxOfSource:xSource];
    GPKGElevationSourcePixel * yPixel = [self minAndMaxOfSource:ySource];
    
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
 * Get the min, max, and offset of the source pixel
 *
 * @param source
 *            source pixel
 * @return source pixel information
 */
-(GPKGElevationSourcePixel *) minAndMaxOfSource: (float) source{
    
    int floor = (int) floorf(source);
    int min = floor;
    int max = floor;
    float offset = source - floor;
    if (offset < .5) {
        min--;
        offset += .5f;
    } else if (offset >= .5) {
        max++;
        offset -= .5f;
    }
    
    return [[GPKGElevationSourcePixel alloc] initWithPixel:source andMin:min andMax:max andOffset:offset];
}

/**
 * Get the Bilinear Interpolation elevation value
 *
 * @param sourcePixelX
 *            source pixel x
 * @param sourcePixelY
 *            source pixel y
 * @param values
 *            2 x 2 elevation values as [y][x]
 * @return elevation
 */
-(NSDecimalNumber *) bilinearInterpolationElevationWithSourcePixelX: (GPKGElevationSourcePixel *) sourcePixelX andSourcePixelY: (GPKGElevationSourcePixel *) sourcePixelY andValues: (NSArray *) values{
    return [self bilinearInterpolationElevationWithOffsetX:sourcePixelX.offset andOffsetY:sourcePixelY.offset andMinX:sourcePixelX.min andMaxX:sourcePixelX.max andMinY:sourcePixelY.min andMaxY:sourcePixelY.max andValues:values];
}

/**
 * Get the Bilinear Interpolation elevation value
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
 *            2 x 2 elevation values as [y][x]
 * @return elevation
 */
-(NSDecimalNumber *) bilinearInterpolationElevationWithOffsetX: (float) offsetX andOffsetY: (float) offsetY andMinX: (float) minX andMaxX: (float) maxX andMinY: (float) minY andMaxY: (float) maxY andValues: (NSArray *) values{
    
    NSDecimalNumber * elevation = nil;
    
    if (values != nil) {
        NSArray * top = [values objectAtIndex:0];
        NSArray * bottom = [values objectAtIndex:1];
        NSDecimalNumber * topLeft = (NSDecimalNumber *)[GPKGUtils objectAtIndex:0 inArray:top];
        NSDecimalNumber * topRight = (NSDecimalNumber *)[GPKGUtils objectAtIndex:1 inArray:top];
        NSDecimalNumber * bottomLeft = (NSDecimalNumber *)[GPKGUtils objectAtIndex:0 inArray:bottom];
        NSDecimalNumber * bottomRight = (NSDecimalNumber *)[GPKGUtils objectAtIndex:1 inArray:bottom];
        elevation = [self bilinearInterpolationElevationWithOffsetX:offsetX andOffsetY:offsetY andMinX:minX andMaxX:maxX andMinY:minY andMaxY:maxY andTopLeft:topLeft andTopRight:topRight andBottomLeft:bottomLeft andBottomRight:bottomRight];
    }
    
    return elevation;
}

/**
 * Get the Bilinear Interpolation elevation value
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
 *            top left elevation
 * @param topRight
 *            top right elevation
 * @param bottomLeft
 *            bottom left elevation
 * @param bottomRight
 *            bottom right elevation
 * @return elevation
 */
-(NSDecimalNumber *) bilinearInterpolationElevationWithOffsetX: (float) offsetX andOffsetY: (float) offsetY andMinX: (float) minX andMaxX: (float) maxX andMinY: (float) minY andMaxY: (float) maxY andTopLeft: (NSDecimalNumber *) topLeft andTopRight: (NSDecimalNumber *) topRight andBottomLeft: (NSDecimalNumber *) bottomLeft andBottomRight: (NSDecimalNumber *) bottomRight{
    
    NSDecimalNumber * elevation = nil;
    
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
        
        elevation = [[NSDecimalNumber alloc] initWithDouble:result];
    }
    
    return elevation;
}

/**
 * Get the bicubic interpolation elevation from the 4 x 4 elevation values
 *
 * @param values
 *            elevation values
 * @param sourcePixelX
 *            source pixel x
 * @param sourcePixelY
 *            source pixel y
 * @return bicubic elevation
 */
-(NSDecimalNumber *) bicubicInterpolationElevationWithValues: (NSArray *) values andSourcePixelX: (GPKGElevationSourcePixel *) sourcePixelX andSourcePixelY: (GPKGElevationSourcePixel *) sourcePixelY{
    return [self bicubicInterpolationElevationWithValues:values andOffsetX:sourcePixelX.offset andOffsetY:sourcePixelY.offset];
}

/**
 * Get the bicubic interpolation elevation from the 4 x 4 elevation values
 *
 * @param values
 *            elevation values
 * @param offsetX
 *            x source pixel offset
 * @param offsetY
 *            y source pixel offset
 * @return bicubic elevation
 */
-(NSDecimalNumber *) bicubicInterpolationElevationWithValues: (NSArray *) values andOffsetX: (float) offsetX andOffsetY: (float) offsetY{

    NSDecimalNumber * elevation = nil;
    
    NSMutableArray * rowValues = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (int y = 0; y < 4; y++) {
        NSArray * yValues = [values objectAtIndex:y];
        NSDecimalNumber * value0 = [GPKGUtils objectAtIndex:0 inArray:yValues];
        NSDecimalNumber * value1 = [GPKGUtils objectAtIndex:1 inArray:yValues];
        NSDecimalNumber * value2 = [GPKGUtils objectAtIndex:2 inArray:yValues];
        NSDecimalNumber * value3 = [GPKGUtils objectAtIndex:3 inArray:yValues];
        NSDecimalNumber * rowElevation = [self cubicInterpolationElevationWithValue0:value0 andValue1:value1 andValue2:value2 andValue3:value3 andOffset:offsetX];
        if (rowElevation == nil) {
            rowValues = nil;
            break;
        }
        [rowValues addObject:rowElevation];
    }
    
    if (rowValues != nil) {
        elevation = [self cubicInterpolationElevationWithValues:rowValues andOffset:offsetY];
    }
    
    return elevation;
}

/**
 * Interpolate 4 values using the offset between value1 and value2
 *
 * @param values
 *            elevation values
 * @param offset
 *            offset between the middle two pixels
 * @return value elevation value
 */
-(NSDecimalNumber *) cubicInterpolationElevationWithValues: (NSArray *) values andOffset: (double) offset{
    
    NSDecimalNumber * elevation = nil;
    if (values != nil) {
        NSDecimalNumber * value0 = [GPKGUtils objectAtIndex:0 inArray:values];
        NSDecimalNumber * value1 = [GPKGUtils objectAtIndex:1 inArray:values];
        NSDecimalNumber * value2 = [GPKGUtils objectAtIndex:2 inArray:values];
        NSDecimalNumber * value3 = [GPKGUtils objectAtIndex:3 inArray:values];
        elevation = [self cubicInterpolationElevationWithValue0:value0 andValue1:value1 andValue2:value2 andValue3:value3 andOffset:offset];
    }
    return elevation;
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
 * @return value elevation value
 */
-(NSDecimalNumber *) cubicInterpolationElevationWithValue0: (NSDecimalNumber *) value0 andValue1: (NSDecimalNumber *) value1 andValue2: (NSDecimalNumber *) value2 andValue3: (NSDecimalNumber *) value3 andOffset: (double) offset{
    
    NSDecimalNumber * elevation = nil;
    
    if (value0 != nil && value1 != nil && value2 != nil && value3 != nil) {
        
        double coefficient0 = 2 * [value1 doubleValue];
        double coefficient1 = [value2 doubleValue] - [value0 doubleValue];
        double coefficient2 = 2 * [value0 doubleValue] - 5 * [value1 doubleValue] + 4 * [value2 doubleValue] - [value3 doubleValue];
        double coefficient3 = -[value0 doubleValue] + 3 * [value1 doubleValue] - 3 * [value2 doubleValue] + [value3 doubleValue];
        double elevationDouble = (coefficient3 * offset * offset * offset + coefficient2
                     * offset * offset + coefficient1 * offset + coefficient0) / 2;
        elevation = [[NSDecimalNumber alloc] initWithDouble:elevationDouble];
    }
    
    return elevation;
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
                                                                        andMaxLongitudeDouble:[boundingBox.maxLongitude doubleValue] + lonPixelPadding
                                                                         andMinLatitudeDouble:[boundingBox.minLatitude doubleValue] - latPixelPadding
                                                                         andMaxLatitudeDouble:[boundingBox.maxLatitude doubleValue] + latPixelPadding];
    return paddedBoundingBox;
}

-(unsigned short) pixelValueWithValues:(NSArray *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return [((NSNumber *)[pixelValues objectAtIndex:(y * width) + x]) unsignedShortValue];
}

-(unsigned short) pixelValueWithUnsignedShortValues:(unsigned short *) pixelValues andWidth: (int) width andX: (int) x andY: (int) y{
    return pixelValues[(y * width) + x];
}

-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (unsigned short) pixelValue{
    
    NSDecimalNumber * elevation = nil;
    if (![self isDataNull:pixelValue]) {
        elevation = [self pixelValueToElevationWithGriddedTile:griddedTile andPixelValue:[[NSDecimalNumber alloc] initWithUnsignedShort:pixelValue]];
    }
    
    return elevation;
}

-(NSDecimalNumber *) pixelValueToElevationWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValue: (NSDecimalNumber *) pixelValue{

    NSDecimalNumber * elevation = nil;
    
    if (self.griddedCoverage != nil
        && [self.griddedCoverage getGriddedCoverageDataType] == GPKG_GCDT_INTEGER) {
        
        double elevationValue = [pixelValue doubleValue];
        
        if (griddedTile != nil) {
            if (griddedTile.scale != nil) {
                elevationValue *= [griddedTile.scale doubleValue];
            }
            if (griddedTile.offset != nil) {
                elevationValue += [griddedTile.offset doubleValue];
            }
        }
        if (self.griddedCoverage.scale != nil) {
            elevationValue *= [self.griddedCoverage.scale doubleValue];
        }
        if (self.griddedCoverage.offset != nil) {
            elevationValue += [self.griddedCoverage.offset doubleValue];
        }
     
        elevation = [[NSDecimalNumber alloc] initWithDouble:elevationValue];
    }
    
    return elevation;
}

-(NSArray *) elevationValuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (NSArray *) pixelValues{
    NSMutableArray * elevations = [[NSMutableArray alloc] initWithCapacity:pixelValues.count];
    for(int i = 0; i < pixelValues.count; i++){
        [elevations addObject:[self elevationValueWithGriddedTile:griddedTile andPixelValue:[((NSNumber *)[pixelValues objectAtIndex:i]) unsignedShortValue]]];
    }
    return elevations;
}

-(NSArray *) elevationValuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelValues: (unsigned short *) pixelValues andCount: (int) count{
    NSMutableArray * elevations = [[NSMutableArray alloc] initWithCapacity:count];
    for(int i = 0; i < count; i++){
        [elevations addObject:[self elevationValueWithGriddedTile:griddedTile andPixelValue:pixelValues[i]]];
    }
    return elevations;
}

+(GPKGTileMatrixSet *) createTileTableWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId{
    
    GPKGTileMatrixSet * tileMatrixSet = [geoPackage createTileTableWithType:GPKG_CDT_ELEVATION_TILES andTableName:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileMatrixSetBoundingBox:tileMatrixSetBoundingBox andTileMatrixSetSrsId:tileMatrixSetSrsId];
    return tileMatrixSet;
}

-(unsigned short) pixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevation: (NSDecimalNumber *) elevation{
    
    unsigned short pixelValue = 0;
    
    if(elevation == nil){
        if(self.griddedCoverage != nil){
            pixelValue = [self.griddedCoverage.dataNull unsignedShortValue];
        }
    }else{
        double value = [self elevationToPixelValueWithGriddedTile:griddedTile andElevation: [elevation doubleValue]];
        pixelValue = (unsigned short) round(value);
    }
    
    return pixelValue;
}

/**
 * Convert integer coverage typed elevation value to a pixel value through
 * offsets and scales
 *
 * @param griddedTile
 *            gridded tile
 * @param elevation
 *            elevation value
 * @return pixel value
 */
-(double) elevationToPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevation: (double) elevation{
    
    double pixelValue = elevation;
    
    if (self.griddedCoverage != nil
        && [self.griddedCoverage getGriddedCoverageDataType] == GPKG_GCDT_INTEGER) {
        
        if (self.griddedCoverage.offset != nil) {
            pixelValue -= [self.griddedCoverage.offset doubleValue];
        }
        if (self.griddedCoverage.scale != nil) {
            pixelValue /= [self.griddedCoverage.scale doubleValue];
        }
        if (griddedTile != nil) {
            if (griddedTile.offset != nil) {
                pixelValue -= [griddedTile.offset doubleValue];
            }
            if (griddedTile.scale != nil) {
                pixelValue /= [griddedTile.scale doubleValue];
            }
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

-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValue: (float) pixelValue{
    
    NSDecimalNumber * elevation = nil;
    if(![self isDataNull:pixelValue]){
        elevation = [self pixelValueToElevationWithGriddedTile:griddedTile andPixelValue:[[NSDecimalNumber alloc] initWithFloat:pixelValue]];
    }
    
    return elevation;
}

-(NSArray *) elevationValuesWithGriddedTile: (GPKGGriddedTile *) griddedTile andPixelFloatValues: (NSArray *) pixelValues{
    NSMutableArray * elevations = [[NSMutableArray alloc] initWithCapacity:pixelValues.count];
    for (int i = 0; i < pixelValues.count; i++) {
        [elevations addObject:[self elevationValueWithGriddedTile:griddedTile andPixelFloatValue:[((NSDecimalNumber *)[pixelValues objectAtIndex:i]) floatValue]]];
    }
    return elevations;
}

-(float) floatPixelValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevation: (NSDecimalNumber *) elevation{
    
    double value = 0;
    if (elevation == nil) {
        if (self.griddedCoverage != nil) {
            value = [self.griddedCoverage.dataNull doubleValue];
        }
    } else {
        value = [self elevationToPixelValueWithGriddedTile:griddedTile andElevation:[elevation doubleValue]];
    }
    
    float pixelValue = (float) value;
    
    return pixelValue;
}

-(NSDecimalNumber *) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andX: (int) x andY: (int) y{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending elevation tiles type"];
    return nil;
}

-(double) elevationValueWithGriddedTile: (GPKGGriddedTile *) griddedTile andTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    [NSException raise:@"No Core Implementation" format:@"Implementation must be provided by an extending elevation tiles type"];
    return 0;
}

-(GPKGTileDao *) tileDao{
    return _tileDao;
}

-(NSDecimalNumber *) elevationWithLatitude: (double) latitude andLongitude: (double) longitude{
    GPKGElevationRequest * request = [[GPKGElevationRequest alloc] initWithLatitude:latitude andLongitude:longitude];
    GPKGElevationTileResults * elevations = [self elevationsWithElevationRequest:request andWidth:[NSNumber numberWithInt:1] andHeight:[NSNumber numberWithInt:1]];
    NSDecimalNumber * elevation = nil;
    if(elevations != nil){
        elevation = [elevations elevationAtRow:0 andColumn:0];
    }
    return elevation;
}


-(GPKGElevationTileResults *) elevationsWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    GPKGElevationRequest * request = [[GPKGElevationRequest alloc] initWithBoundingBox:requestBoundingBox];
    GPKGElevationTileResults * elevations = [self elevationsWithElevationRequest:request];
    return elevations;
}

-(GPKGElevationTileResults *) elevationsWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    GPKGElevationRequest * request = [[GPKGElevationRequest alloc] initWithBoundingBox:requestBoundingBox];
    GPKGElevationTileResults * elevations = [self elevationsWithElevationRequest:request andWidth:width andHeight:height];
    return elevations;
}

-(GPKGElevationTileResults *) elevationsWithElevationRequest: (GPKGElevationRequest *) request{
    GPKGElevationTileResults * elevations = [self elevationsWithElevationRequest:request andWidth:self.width andHeight:self.height];
    return elevations;
}

-(GPKGElevationTileResults *) elevationsWithElevationRequest: (GPKGElevationRequest *) request andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    
    GPKGElevationTileResults * elevationResults = nil;
    
    // Transform to the projection of the elevation tiles
    GPKGProjectionTransform * transformRequestToElevation = nil;
    GPKGBoundingBox * requestProjectedBoundingBox = request.boundingBox;
    if (!self.sameProjection) {
        transformRequestToElevation = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.elevationProjection];
        requestProjectedBoundingBox = [transformRequestToElevation transformWithBoundingBox:requestProjectedBoundingBox];
    }
    [request setProjectedBoundingBox:requestProjectedBoundingBox];
    
    // Determine how many overlapping pixels to store based upon the
    // algorithm
    int overlappingPixels;
    switch (self.algorithm) {
        case GPKG_ETA_BICUBIC:
            overlappingPixels = 3;
            break;
        default:
            overlappingPixels = 1;
    }
    
    // Find the tile matrix and results
    GPKGElevationTileMatrixResults * results = [self resultsWithElevationRequest: request andBoundingBox: requestProjectedBoundingBox andOverlappingPixels: overlappingPixels];
    
    if(results != nil){
        
        GPKGTileMatrix * tileMatrix = [results tileMatrix];
        GPKGResultSet * tileResults = [results tileResults];
        
        @try {
            
            // Determine the requested elevation dimensions, or use the
            // dimensions of a single tile matrix elevation tile
            int requestedElevationsWidth = width != nil ? [width intValue] : [tileMatrix.tileWidth intValue];
            int requestedElevationsHeight = height != nil ? [height intValue] : [tileMatrix.tileHeight intValue];
            
            // Determine the size of the non projected elevation results
            int tileWidth = requestedElevationsWidth;
            int tileHeight = requestedElevationsHeight;
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
            
            // Retrieve the elevations from the results
            NSArray * elevations = [self elevationsWithTileMatrix: tileMatrix andTileResults: tileResults andRequest: request andTileWidth: tileWidth andTileHeight: tileHeight andOverlappingPixels: overlappingPixels];
            
            // Project the elevations if needed
            if (elevations != nil && !self.sameProjection && !request.isPoint) {
                elevations = [self reprojectElevations:elevations withWidth:requestedElevationsWidth andHeight:requestedElevationsHeight andRequestBoundingBox:request.boundingBox andProjectionTransform:transformRequestToElevation andElevationBoundingBox:requestProjectedBoundingBox];
            }
            
            // Create the results
            if (elevations != nil) {
                elevationResults = [[GPKGElevationTileResults alloc] initWithElevations:elevations andTileMatrix:tileMatrix];
            }
        } @finally {
            [tileResults close];
        }
    }
    
    return elevationResults;
}

-(GPKGElevationTileResults *) elevationsUnboundedWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    GPKGElevationRequest * request = [[GPKGElevationRequest alloc] initWithBoundingBox:requestBoundingBox];
    return [self elevationsUnboundedWithElevationRequest: request];
}

-(GPKGElevationTileResults *) elevationsUnboundedWithElevationRequest: (GPKGElevationRequest *) request{
    
    GPKGElevationTileResults * elevationResults = nil;
    
    // Transform to the projection of the elevation tiles
    GPKGProjectionTransform * transformRequestToElevation = nil;
    GPKGBoundingBox * requestProjectedBoundingBox = request.boundingBox;
    if (!self.sameProjection) {
        transformRequestToElevation = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.elevationProjection];
        requestProjectedBoundingBox = [transformRequestToElevation transformWithBoundingBox:requestProjectedBoundingBox];
    }
    [request setProjectedBoundingBox:requestProjectedBoundingBox];
    
    // Find the tile matrix and results
    GPKGElevationTileMatrixResults * results = [self resultsWithElevationRequest: request andBoundingBox: requestProjectedBoundingBox];
    
    if(results != nil){
        
        GPKGTileMatrix * tileMatrix = [results tileMatrix];
        GPKGResultSet * tileResults = [results tileResults];
        
        @try {
            
            // Retrieve the elevations from the results
            NSArray * elevations = [self elevationsUnboundedWithTileMatrix: tileMatrix andTileResults: tileResults andRequest: request];
            
            // Project the elevations if needed
            if (elevations != nil && !self.sameProjection && !request.isPoint) {
                elevations = [self reprojectElevations:elevations withWidth:[self countInDoubleArray:elevations atIndex1:0] andHeight:(int)elevations.count andRequestBoundingBox:request.boundingBox andProjectionTransform:transformRequestToElevation andElevationBoundingBox:requestProjectedBoundingBox];
            }
            
            // Create the results
            if (elevations != nil) {
                elevationResults = [[GPKGElevationTileResults alloc] initWithElevations:elevations andTileMatrix:tileMatrix];
            }
            
        } @finally {
            [tileResults close];
        }
    }
    
    return elevationResults;
}

/**
 * Get the elevation tile results by finding the tile matrix with values
 *
 * @param request
 *            elevation request
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @return tile matrix results
 */
-(GPKGElevationTileMatrixResults *) resultsWithElevationRequest: (GPKGElevationRequest *) request andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox{
    return [self resultsWithElevationRequest:request andBoundingBox:requestProjectedBoundingBox andOverlappingPixels:0];
}

/**
 * Get the elevation tile results by finding the tile matrix with values
 *
 * @param request
 *            elevation request
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param overlappingPixels
 *            overlapping request pixels
 * @return tile matrix results
 */
-(GPKGElevationTileMatrixResults *) resultsWithElevationRequest: (GPKGElevationRequest *) request andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andOverlappingPixels: (int) overlappingPixels{
    // Try to get the elevation from the current zoom level
    GPKGTileMatrix * tileMatrix = [self tileMatrixWithRequest: request];
    GPKGElevationTileMatrixResults * results = nil;
    if (tileMatrix != nil) {
        results = [self resultsWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
        
        // Try to zoom in or out to find a matching elevation
        if (results == nil) {
            results = [self resultsZoomWithBoundingBox: requestProjectedBoundingBox andTileMatrix: tileMatrix andOverlappingPixels: overlappingPixels];
        }
    }
    return results;
}

/**
 * Get the elevation tile results for a specified tile matrix
 *
 * @param requestProjectedBoundingBox
 *            request projected bounding box
 * @param tileMatrix
 *            tile matrix
 * @param overlappingPixels
 *            number of overlapping pixels used by the algorithm
 * @return tile matrix results
 */
-(GPKGElevationTileMatrixResults *) resultsWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    GPKGElevationTileMatrixResults * results = nil;
    GPKGBoundingBox * paddedBoundingBox = [self padBoundingBoxWithTileMatrix:tileMatrix andBoundingBox:requestProjectedBoundingBox andOverlap:overlappingPixels];
    GPKGResultSet * tileResults = [self retrieveSortedTileResultsWithBoundingBox: paddedBoundingBox andTileMatrix: tileMatrix];
    if(tileResults != nil){
        if(tileResults.count > 0){
            results = [[GPKGElevationTileMatrixResults alloc] initWithTileMatrix:tileMatrix andTileResults:tileResults];
        }else{
            [tileResults close];
        }
    }
    return results;
}

/**
 * Get the elevation tile results by zooming in or out as needed from the
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
-(GPKGElevationTileMatrixResults *) resultsZoomWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGElevationTileMatrixResults * results = nil;
    
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
 * Get the elevation tile results by zooming in from the provided tile
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
-(GPKGElevationTileMatrixResults *) resultsZoomInWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGElevationTileMatrixResults * results = nil;
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
 * Get the elevation tile results by zooming out from the provided tile
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
-(GPKGElevationTileMatrixResults *) resultsZoomOutWithBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix andOverlappingPixels: (int) overlappingPixels{
    
    GPKGElevationTileMatrixResults * results = nil;
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
 * Get the elevation values from the tile results scaled to the provided
 * dimensions
 *
 * @param tileMatrix
 *            tile matrix
 * @param tileResults
 *            tile results
 * @param request
 *            elevation request
 * @param tileWidth
 *            tile width
 * @param tileHeight
 *            tile height
 * @param overlappingPixels
 *            overlapping request pixels
 * @return elevation values
 */
-(NSArray *) elevationsWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults andRequest: (GPKGElevationRequest *) request andTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andOverlappingPixels: (int) overlappingPixels{

    NSMutableArray * elevations = nil;
    
    // Tiles are ordered by rows and then columns. Track the last column
    // elevations of the tile to the left and the last rows of the tiles in
    // the row above
    NSMutableArray * leftLastColumns = nil;
    NSMutableDictionary * lastRowsByColumn = nil;
    NSMutableDictionary * previousLastRowsByColumn = nil;
    
    int previousRow = -1;
    int previousColumn = INT_MAX;
    
    // Process each elevation tile
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileMatrix.tableName];
    while ([tileResults moveToNext]) {
        
        // Get the next elevation tile
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
        
        // Get the bounding box of the elevation
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.elevationBoundingBox andTileMatrix:tileMatrix andTileColumn:currentColumn andTileRow:currentRow];
        
        // Get the bounding box where the request and elevation tile overlap
        GPKGBoundingBox * overlap = [request overlapWithBoundingBox:tileBoundingBox];
        
        // Get the gridded tile value for the tile
        GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
        
        // Get the elevation tile image
        GPKGElevationImage * image = [[GPKGElevationImage alloc] initWithTileRow:tileRow];
        
        // If the tile overlaps with the requested box
        if (overlap != nil) {
            
            // Get the rectangle of the tile elevation with matching values
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
                
                // Create the elevations array first time through
                if (elevations == nil) {
                    elevations = [self createNullFilledDoubleArrayWithSize1:tileHeight andSize2:tileWidth];
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
                
                // Read and set the elevation values
                for (int y = minDestY; y <= maxDestY; y++) {
                    for (int x = minDestX; x <= maxDestX; x++) {
                        
                        // Determine the elevation based upon the
                        // selected algorithm
                        NSDecimalNumber * elevation = nil;
                        switch (self.algorithm) {
                            case GPKG_ETA_NEAREST_NEIGHBOR:
                                elevation = [self nearestNeighborElevation:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            case GPKG_ETA_BILINEAR:
                                elevation = [self bilinearInterpolationElevationWithGriddedTile:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            case GPKG_ETA_BICUBIC:
                                elevation = [self bicubicInterpolationElevation:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andY:y andX:x andWidthRatio:widthRatio andHeightRatio:heightRatio andDestTop:dest.origin.y andDestLeft:dest.origin.x andSrcTop:src.origin.y andSrcLeft:src.origin.x];
                                break;
                            default:
                                [NSException raise:@"Unsupported Algorithm" format:@"Algorithm is not supported: %u", self.algorithm];
                        }
                        
                        if (elevation != nil) {
                            [self replaceObjectInDoubleArray:elevations atIndex1:y andIndex2:x withValue:elevation];
                        }
                        
                    }
                }
                
            }
        }
        
        // Determine and store the elevations of the last columns and rows
        leftLastColumns = [[NSMutableArray alloc] initWithCapacity:overlappingPixels];
        NSMutableArray * lastRows = [[NSMutableArray alloc] initWithCapacity:overlappingPixels];
        [lastRowsByColumn setObject:lastRows forKey:[NSNumber numberWithInt:currentColumn]];
        
        // For each overlapping pixel
        for (int lastIndex = 0; lastIndex < overlappingPixels; lastIndex++) {
            
            // Store the last column row elevation values
            NSMutableArray * leftLastColumnsRow = [[NSMutableArray alloc] initWithCapacity:[tileMatrix.tileHeight intValue]];
            [leftLastColumns addObject:leftLastColumnsRow];
            int lastColumnIndex = [tileMatrix.tileWidth intValue] - lastIndex - 1;
            for (int row = 0; row < [tileMatrix.tileHeight intValue]; row++) {
                NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andElevationImage:image andX:lastColumnIndex andY:row];
                [leftLastColumnsRow addObject:elevation];
            }
            
            // Store the last row column elevation values
            NSMutableArray * lastRowsColumn = [[NSMutableArray alloc] initWithCapacity:[tileMatrix.tileWidth intValue]];
            [lastRows addObject:lastRowsColumn];
            int lastRowIndex = [tileMatrix.tileHeight intValue] - lastIndex - 1;
            for (int column = 0; column < [tileMatrix.tileWidth intValue]; column++) {
                NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andElevationImage:image andX:column andY:lastRowIndex];
                [lastRowsColumn addObject:elevation];
            }
            
        }
        
        // Update the previous row and column
        previousRow = currentRow;
        previousColumn = currentColumn;
    }
    
    return elevations;
}

/**
 * Get the bilinear interpolation elevation
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
 * @return bilinear elevation
 */
-(NSDecimalNumber *) bilinearInterpolationElevationWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    GPKGElevationSourcePixel * sourcePixelX = [self minAndMaxOfSource:xSource];
    GPKGElevationSourcePixel * sourcePixelY = [self minAndMaxOfSource:ySource];
    
    NSMutableArray * values = [self createNullFilledDoubleArrayWithSize1:2 andSize2:2];
    [self populateElevationValues:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andPixelX:sourcePixelX andPixelY:sourcePixelY andValues:values];
    
    NSDecimalNumber * elevation = nil;
    
    if (values != nil) {
        elevation = [self bilinearInterpolationElevationWithSourcePixelX:sourcePixelX andSourcePixelY:sourcePixelY andValues:values];
    }
    
    return elevation;
}

/**
 * Get the bicubic interpolation elevation
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
 * @return bicubic elevation
 */
-(NSDecimalNumber *) bicubicInterpolationElevation: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    GPKGElevationSourcePixel * sourcePixelX = [self minAndMaxOfSource:xSource];
    [sourcePixelX setMin:sourcePixelX.min - 1];
    [sourcePixelX setMax:sourcePixelX.max + 1];
    
    GPKGElevationSourcePixel * sourcePixelY = [self minAndMaxOfSource:ySource];
    [sourcePixelY setMin:sourcePixelY.min - 1];
    [sourcePixelY setMax:sourcePixelY.max + 1];
    
    NSMutableArray * values = [self createNullFilledDoubleArrayWithSize1:4 andSize2:4];
    [self populateElevationValues:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andPixelX:sourcePixelX andPixelY:sourcePixelY andValues:values];
    
    NSDecimalNumber * elevation = nil;
    
    if (values != nil) {
        elevation = [self bicubicInterpolationElevationWithValues:values andSourcePixelX:sourcePixelX andSourcePixelY:sourcePixelY];
    }
    
    return elevation;
}

/**
 * Populate the elevation values
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
-(void) populateElevationValues: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andPixelX: (GPKGElevationSourcePixel *) pixelX andPixelY: (GPKGElevationSourcePixel *) pixelY andValues: (NSMutableArray *) values{
    
    [self populateElevationValues:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andMinX:pixelX.min andMaxX:pixelX.max andMinY:pixelY.min andMaxY:pixelY.max andValues:values];
}

/**
 * Populate the elevation values
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
-(void) populateElevationValues: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andMinX: (int) minX andMaxX: (int) maxX andMinY: (int) minY andMaxY: (int) maxY andValues: (NSMutableArray *) values{
    
    for (int yLocation = maxY; values != nil && yLocation >= minY; yLocation--) {
        for (int xLocation = maxX; xLocation >= minX; xLocation--) {
            NSDecimalNumber * value = [self elevationValueOverBordersWithGriddedTile:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andX:xLocation andY:yLocation];

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
 * Get the nearest neighbor elevation
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
 * @return nearest neighbor elevation
 */
-(NSDecimalNumber *) nearestNeighborElevation: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andY: (int) y andX: (int) x andWidthRatio: (float) widthRatio andHeightRatio: (float) heightRatio andDestTop: (float) destTop andDestLeft: (float) destLeft andSrcTop: (float) srcTop andSrcLeft: (float) srcLeft{

    // Determine which source pixel to use
    float xSource =[self xSourceWithX:x andDestLeft:destLeft andSrcLeft:srcLeft andWidthRatio:widthRatio];
    float ySource =[self ySourceWithY:y andDestTop:destTop andSrcTop:srcTop andHeightRatio:heightRatio];
    
    // Get the closest nearest neighbors
    NSArray * nearestNeighbors = [self nearestNeighborsWithXSource:xSource andYSource:ySource];
    
    // Get the elevation value from the source pixel nearest neighbors until
    // one is found
    NSDecimalNumber * elevation = nil;
    for (NSArray * nearestNeighbor in nearestNeighbors) {
        elevation = [self elevationValueOverBordersWithGriddedTile:griddedTile andElevationImage:image andLeftLastColumns:leftLastColumns andTopLeftRows:topLeftRows andTopRows:topRows andX:[((NSNumber *)[nearestNeighbor objectAtIndex:0]) intValue] andY:[((NSNumber *)[nearestNeighbor objectAtIndex:1]) intValue]];
        if (elevation != nil) {
            break;
        }
    }
    
    return elevation;
}

/**
 * Get the elevation value from the coordinate location. If the coordinate
 * crosses the left, top, or top left tile, attempts to get the elevation
 * from previously processed border elevations.
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
 * @return elevation value
 */
-(NSDecimalNumber *) elevationValueOverBordersWithGriddedTile: (GPKGGriddedTile *) griddedTile andElevationImage: (GPKGElevationImage *) image andLeftLastColumns: (NSArray *) leftLastColumns andTopLeftRows: (NSArray *) topLeftRows andTopRows: (NSArray *) topRows andX: (int) x andY: (int) y{

    NSDecimalNumber * elevation = nil;
    
    // Only handle locations in the current tile, to the left, top left, or
    // top tiles. Tiles are processed sorted by rows and columns, so values
    // to the top right, right, or any below tiles will be handled later if
    // those tiles exist
    if (x < [image width] && y < [image height]) {
        
        if (x >= 0 && y >= 0) {
            elevation = [self elevationValueWithGriddedTile:griddedTile andElevationImage:image andX:x andY:y];
        } else if (x < 0 && y < 0) {
            // Try to get the elevation from the top left tile values
            if (topLeftRows != nil) {
                int row = (-1 * y) - 1;
                if (row < topLeftRows.count) {
                    int column = x + [self countInDoubleArray:topLeftRows atIndex1:row];
                    if (column >= 0) {
                        elevation = (NSDecimalNumber *)[self objectInDoubleArray:topLeftRows atIndex1:row andIndex2:column];
                    }
                }
            }
        } else if (x < 0) {
            // Try to get the elevation from the left tile values
            if (leftLastColumns != nil) {
                int column = (-1 * x) - 1;
                if (column < leftLastColumns.count) {
                    int row = y;
                    if (row < [self countInDoubleArray:leftLastColumns atIndex1:column]) {
                        elevation = (NSDecimalNumber *)[self objectInDoubleArray:leftLastColumns atIndex1:column andIndex2:row];
                    }
                }
            }
        } else {
            // Try to get the elevation from the top tile values
            if (topRows != nil) {
                int row = (-1 * y) - 1;
                if (row < topRows.count) {
                    int column = x;
                    if (column < [self countInDoubleArray:topRows atIndex1:row]) {
                        elevation = (NSDecimalNumber *)[self objectInDoubleArray:topRows atIndex1:row andIndex2:column];
                    }
                }
            }
        }
        
    }
    
    return elevation;
}

/**
 * Get the elevation values from the tile results unbounded in result size
 *
 * @param tileMatrix
 *            tile matrix
 * @param tileResults
 *            tile results
 * @param request
 *            elevation request
 * @return elevation values
 */
-(NSArray *) elevationsUnboundedWithTileMatrix: (GPKGTileMatrix *) tileMatrix andTileResults: (GPKGResultSet *) tileResults andRequest: (GPKGElevationRequest *) request{

    // Build a map of rows to maps of columns and values
    GPKGElevationDictionary * rowsMap = [[GPKGElevationDictionary alloc] init];
    
    // Track the min and max row and column
    NSNumber * minRow = nil;
    NSNumber * maxRow = nil;
    NSNumber * minColumn = nil;
    NSNumber * maxColumn = nil;
    
    // Track count of tiles involved in the results
    int tileCount = 0;
    
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTableName:tileMatrix.tableName];
    
    // Process each elevation tile row
    while([tileResults moveToNext]){
        
        // Get the next elevation tile
        GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
        
        // Get the bounding box of the elevation
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.elevationBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
        
        // Get the bounding box where the request and elevation tile overlap
        GPKGBoundingBox * overlap = [request overlapWithBoundingBox:tileBoundingBox];
        
        // If the elevation tile overlaps with the requested box
        if (overlap != nil) {
            
            // Get the rectangle of the tile elevation with matching values
            CGRect src = [GPKGTileBoundingBoxUtils getRectangleWithWidth:[tileMatrix.tileWidth intValue] andHeight:[tileMatrix.tileHeight intValue] andBoundingBox:tileBoundingBox andSection:overlap];
            
            if (src.size.width >= 0 && src.size.height >= 0) {
                
                // Get the source dimensions
                int srcTop = MIN(src.origin.y, [tileMatrix.tileHeight intValue] - 1);
                int srcBottom = MIN(src.origin.y + src.size.height, [tileMatrix.tileHeight intValue] - 1);
                int srcLeft = MIN(src.origin.x, [tileMatrix.tileWidth intValue] - 1);
                int srcRight = MIN(src.origin.x + src.size.width, [tileMatrix.tileWidth intValue] - 1);
                
                // Get the gridded tile value for the tile
                GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
                
                // Get the elevation tile image
                GPKGElevationImage * image = [[GPKGElevationImage alloc] initWithTileRow:tileRow];
                
                // Create the elevation results for this tile
                NSMutableArray * elevations = [[NSMutableArray alloc] initWithCapacity:srcBottom - srcTop + 1];
                
                // Get or add the columns map to the rows map
                GPKGElevationDictionary * columnsMap = [rowsMap.dictionary objectForKey:[NSNumber numberWithInt:[tileRow getTileRow]]];
                if (columnsMap == nil) {
                    columnsMap = [[GPKGElevationDictionary alloc] init];
                    [rowsMap setObject:columnsMap forKey:[NSNumber numberWithInt:[tileRow getTileRow]]];
                }
                
                // Read and set the elevation values
                for (int y = srcTop; y <= srcBottom; y++) {
                    
                    NSMutableArray * innerElevations = [[NSMutableArray alloc] initWithCapacity:srcRight - srcLeft + 1];
                    [elevations addObject:innerElevations];
                    
                    for (int x = srcLeft; x <= srcRight; x++) {
                        
                        // Get the elevation value from the source pixel
                        NSDecimalNumber * elevation = [self elevationValueWithGriddedTile:griddedTile andElevationImage:image andX:x andY:y];
                        
                        [innerElevations addObject:elevation];
                    }
                }
                
                // Set the elevations in the results map
                [columnsMap setObject:elevations forKey:[NSNumber numberWithInt:[tileRow getTileColumn]]];
                
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
    NSArray * elevations = [self formatUnboundedResultsWithTileMatrix:tileMatrix andElevationDictionary:rowsMap andTileCount:tileCount andMinRow:[minRow intValue] andMaxRow:[maxRow intValue] andMinColumn:[minColumn intValue] andMaxColumn:[maxColumn intValue]];
    
    return elevations;
}

/**
 * Get the tile matrix for the zoom level as defined by the area of the
 * request
 *
 * @param request
 *            elevation request
 * @return tile matrix or null
 */
-(GPKGTileMatrix *) tileMatrixWithRequest: (GPKGElevationRequest *) request{

    GPKGTileMatrix * tileMatrix = nil;
    
    // Check if the request overlaps elevation bounding box
    if([request overlapWithBoundingBox:self.elevationBoundingBox] != nil){
        
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
 * Get the tile row results of elevation tiles needed to create the
 * requested bounding box elevations, sorted by row and then column
 *
 * @param projectedRequestBoundingBox
 *            bounding box projected to the elevations
 * @param tileMatrix
 *            tile matrix
 * @return tile results or null
 */
-(GPKGResultSet *) retrieveSortedTileResultsWithBoundingBox: (GPKGBoundingBox *) projectedRequestBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix{

    GPKGResultSet * tileResults = nil;
    
    if (tileMatrix != nil) {
        
        // Get the tile grid
        GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithTotalBoundingBox:self.elevationBoundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:projectedRequestBoundingBox];
        
        // Query for matching tiles in the tile grid
        tileResults = [self.tileDao queryByTileGrid:tileGrid andZoomLevel:[tileMatrix.zoomLevel intValue] andOrderBy:[NSString stringWithFormat:@"%@,%@", GPKG_TT_COLUMN_TILE_ROW, GPKG_TT_COLUMN_TILE_COLUMN]];

    }
    
    return tileResults;
}

/**
 * Create a new array using the provided sizes filled with NSNull values
 *
 * @param size
 *            array size
 * @param subSize
 *            sub array size
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
     [((NSMutableArray *)[array objectAtIndex:index1]) replaceObjectAtIndex:index2 withObject:value];
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
    return [((NSArray *)[array objectAtIndex:index1]) objectAtIndex:index2];
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

-(double) elevationValueWithTileRow: (GPKGTileRow *) tileRow andX: (int) x andY: (int) y{
    GPKGGriddedTile * griddedTile = [self griddedTileWithTileId:[[tileRow getId] intValue]];
    double elevation = [self elevationValueWithGriddedTile:griddedTile andTileRow:tileRow andX:x andY:y];
    return elevation;
}


@end
