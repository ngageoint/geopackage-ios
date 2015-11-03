//
//  GPKGTileGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"
#import "GPKGProjectionTransform.h"
#import "GPKGImageConverter.h"

@interface GPKGTileGenerator ()

@property (nonatomic, strong) GPKGProjectionTransform * wgs84ToWebMercatorTransform;
@property (nonatomic, strong) GPKGProjectionTransform * webMercatorToWgs84Transform;

@end

@implementation GPKGTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom{
    self = [super init];
    if(self != nil){
        [geoPackage verifyWritable];
        self.geoPackage = geoPackage;
        self.tableName = tableName;
        self.minZoom = minZoom;
        self.maxZoom = maxZoom;
        self.tileGrids = [[NSMutableDictionary alloc] init];
        self.boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180.0 andMaxLongitudeDouble:180.0 andMinLatitudeDouble:PROJ_WEB_MERCATOR_MIN_LAT_RANGE andMaxLatitudeDouble:PROJ_WEB_MERCATOR_MAX_LAT_RANGE];
        self.compressFormat = GPKG_CF_NONE;
        self.compressQuality = 1.0;
        self.compressScale = 1.0;
        self.standardWebMercatorFormat = false;
        self.matrixHeight = 0;
        self.matrixWidth = 0;
        self.wgs84ToWebMercatorTransform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        self.webMercatorToWgs84Transform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    }
    return self;
}

-(NSData *) createTileWithZ: (int) z andX: (int) x andY: (int) y{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) setTileBoundingBox: (GPKGBoundingBox *) boundingBox{
    self.boundingBox = [GPKGTileBoundingBoxUtils boundWgs84BoundingBoxWithWebMercatorLimits:boundingBox];
}

-(void) setCompressQualityAsIntPercentage: (int) percentage{
    CGFloat value = [self getPercentageValueFromInt:percentage];
    [self setCompressQuality:value];
}

-(void) setCompressScaleAsIntPercentage: (int) percentage{
    CGFloat value = [self getPercentageValueFromInt:percentage];
    [self setCompressScale:value];
}

-(CGFloat) getPercentageValueFromInt: (int) percentage{
    return percentage / 100.0;
}

-(int) getTileCount{
    if(self.tileCount == nil){
        int count = 0;
        GPKGBoundingBox * requestWebMercatorBoundingBox = [GPKGTileBoundingBoxUtils toWebMercatorWithBoundingBox:self.boundingBox];
        for(int zoom = self.minZoom; zoom <= self.maxZoom; zoom++){
            // Get the tile grid that includes the entire bounding box
            GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithWebMercatorBoundingBox:requestWebMercatorBoundingBox andZoom:zoom];
            count += [tileGrid count];
            [GPKGUtils setObject:tileGrid forKey:[NSNumber numberWithInt:zoom] inDictionary:self.tileGrids];
        }
        
        self.tileCount = [NSNumber numberWithInt:count];
    }
    return [self.tileCount intValue];
}

-(int) generateTiles{
    
    int totalCount = [self getTileCount];
    
    // Set the max progress count
    if(self.progress != nil){
        [self.progress setMax:totalCount];
    }
    
    int count = 0;
    BOOL update = false;
    
    // Get the web mercator projection of the requested bounding box
    GPKGBoundingBox * requestWebMercatorBoundingBox = [GPKGTileBoundingBoxUtils toWebMercatorWithBoundingBox:self.boundingBox];
    
    // Adjust the tile matrix set and web mercator bounds
    [self adjustBoundsWithWebMercatorBoundingBox:requestWebMercatorBoundingBox andZoom:self.minZoom];
    
    // Create a new tile matrix or update an existing
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self.geoPackage getTileMatrixSetDao];
    GPKGTileMatrixSet * tileMatrixSet = nil;
    if(![tileMatrixSetDao tableExists] || ![tileMatrixSetDao idExists:self.tableName]){
        // Create the web mercator srs if needed
        GPKGSpatialReferenceSystemDao * srsDao = [self.geoPackage getSpatialReferenceSystemDao];
        [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
        // Create the tile table
        tileMatrixSet = [self.geoPackage createTileTableWithTableName:self.tableName andContentsBoundingBox:self.boundingBox andContentsSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM] andTileMatrixSetBoundingBox:self.webMercatorBoundingBox andTileMatrixSetSrsId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
        
    }else{
        update = true;
        //Query to get the Tile Matrix Set
        tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:self.tableName];
        
        // Update the tile bounds between the existing and this request
        [self updateTileBoundsWithTileMatrixSet:tileMatrixSet];
    }
    
    // Create the tiles
    @try {
        GPKGContents * contents = [tileMatrixSetDao getContents:tileMatrixSet];
        GPKGTileMatrixDao * tileMatrixDao = [self.geoPackage getTileMatrixDao];
        GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
        
        // Create the new matrix tiles
        for(int zoom = self.minZoom; zoom <= self.maxZoom && (self.progress == nil || [self.progress isActive]); zoom++){
            
            GPKGTileGrid * localTileGrid = nil;
            
            // Determine the matrix width and height for standard web mercator format
            if(self.standardWebMercatorFormat){
                self.matrixWidth = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:zoom];
                self.matrixHeight = self.matrixWidth;
            }
            // Get the local tile grid for GeoPackage format of where the tiles belong
            else{
                localTileGrid = [GPKGTileBoundingBoxUtils getTileGridWithWebMercatorTotalBoundingBox:self.webMercatorBoundingBox andMatrixWidth:self.matrixWidth andMatrixHeight:self.matrixHeight andWebMercatorBoundingBox:requestWebMercatorBoundingBox];
            }
            
            // Generate the tiles for the zoom level
            GPKGTileGrid * tileGrid = [GPKGUtils objectForKey:[NSNumber numberWithInt:zoom] inDictionary:self.tileGrids];
            count += [self generateTilesWithTileMatrixDao:tileMatrixDao andTileDao:tileDao andContents:contents andZoomLevel:zoom andTileGrid:tileGrid andLocalTileGrid:localTileGrid andMatrixWidth:self.matrixWidth andMatrixHeight:self.matrixHeight andUpdate:update];
            
            if(!self.standardWebMercatorFormat){
                // Double the matrix width and height for the next level
                self.matrixWidth *= 2;
                self.matrixHeight *= 2;
            }
        }
        
        // Delete the table if canceled
        if(self.progress != nil && ![self.progress isActive] && [self.progress cleanupOnCancel]){
            [self.geoPackage deleteUserTableQuietly:self.tableName];
            count = 0;
        } else{
            // Update the contents last modified date
            [contents setLastChange:[NSDate date]];
            GPKGContentsDao * contentsDao = [self.geoPackage getContentsDao];
            [contentsDao update:contents];
        }
        
        if(self.progress == nil || [self.progress isActive]){
            [self.progress completed];
        }else{
            [self.progress failureWithError:@"Operation was canceled"];
        }
    }
    @catch (NSException *e) {
        NSLog(@"Tile Generator Error: %@", [e description]);
        [self.geoPackage deleteUserTableQuietly:self.tableName];
        [self.progress failureWithError:[e description]];
    }
    
    return count;
}

-(void) adjustBoundsWithWebMercatorBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    
    if(self.standardWebMercatorFormat){
        [self adjustStandardWebMercatorFormatBounds];
    }
    // GeoPackage Tile Format
    else{
        [self adjustGeoPackageBoundsWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
    }
}

-(void) adjustStandardWebMercatorFormatBounds{
    // Set the tile matrix set bounding box to be the world
    self.tileMatrixSetBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-180.0 andMaxLongitudeDouble:180.0 andMinLatitudeDouble:PROJ_WEB_MERCATOR_MIN_LAT_RANGE andMaxLatitudeDouble:PROJ_WEB_MERCATOR_MAX_LAT_RANGE];
    self.webMercatorBoundingBox = [self.wgs84ToWebMercatorTransform transformWithBoundingBox:self.tileMatrixSetBoundingBox];
}
 
-(void) adjustGeoPackageBoundsWithWebMercatorBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    // Get the fitting tile grid and determine the bounding box that fits it
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
    self.webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    self.tileMatrixSetBoundingBox = [self.webMercatorToWgs84Transform transformWithBoundingBox:self.webMercatorBoundingBox];
    self.matrixWidth = tileGrid.maxX + 1 - tileGrid.minX;
    self.matrixHeight = tileGrid.maxY + 1 - tileGrid.minY;
}

-(void) updateTileBoundsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    
    GPKGTileDao * tileDao = [self.geoPackage getTileDaoWithTileMatrixSet:tileMatrixSet];
    
    if([tileDao isStandardWebMercatorFormat]){
        if(!self.standardWebMercatorFormat){
            // If adding GeoPackage tiles to a Standard Tile format, add them as standard web mercator format tiles
            self.standardWebMercatorFormat = true;
            [self adjustStandardWebMercatorFormatBounds];
        }
    } else if(self.standardWebMercatorFormat){
        // Can't add Standard formatted tiles to GeoPackage tiles
        [NSException raise:@"Not Supported" format:@"Can not add Standard Web Mercator Formatted tiles to %@ which already contains GeoPackage formatted tiles", self.tableName];
    }
    
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self.geoPackage getTileMatrixSetDao];
    GPKGContents * contents = [tileMatrixSetDao getContents:tileMatrixSet];
    
    GPKGContentsDao * contentsDao = [self.geoPackage getContentsDao];
    GPKGProjectionTransform * transformContentsToWgs84 = [[GPKGProjectionTransform alloc] initWithFromProjection:[contentsDao getProjection:contents] andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    // Combine the existing content and request bounding boxes
    GPKGBoundingBox * contentsBoundingBox = [transformContentsToWgs84 transformWithBoundingBox:[contents getBoundingBox]];
    self.boundingBox = [GPKGTileBoundingBoxUtils unionWithBoundingBox:contentsBoundingBox andBoundingBox:self.boundingBox];
    
    // Update the contents if modified
    if(![contentsBoundingBox equals:self.boundingBox]){
        GPKGProjectionTransform * transformContentsToProjection = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToProjection:[contentsDao getProjection:contents]];
        [contents setBoundingBox:[transformContentsToProjection transformWithBoundingBox:self.boundingBox]];
        [contentsDao update:contents];
    }
    
    // If updating GeoPackage format tiles, all existing metadata and tile
    // rows needs to be adjusted
    if(!self.standardWebMercatorFormat){
        
        GPKGProjectionTransform * transformTileMatrixSetToWgs84 = [[GPKGProjectionTransform alloc] initWithFromProjection:[tileMatrixSetDao getProjection:tileMatrixSet] andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
        GPKGBoundingBox * previousTileMatrixSetBoundingBox = [transformTileMatrixSetToWgs84 transformWithBoundingBox:[tileMatrixSet getBoundingBox]];
        
        // Adjust the bounds to include the request and existing bounds
        GPKGBoundingBox * totalBoundingBox = [GPKGTileBoundingBoxUtils toWebMercatorWithBoundingBox:self.boundingBox];
        int minNewOrUpdateZoom = MIN(self.minZoom, tileDao.minZoom);
        [self adjustGeoPackageBoundsWithWebMercatorBoundingBox:totalBoundingBox andZoom:minNewOrUpdateZoom];
        
        // Update the tile matrix set if modified
        if(![previousTileMatrixSetBoundingBox equals:self.tileMatrixSetBoundingBox]){
            GPKGProjectionTransform * transformTileMatrixSetToProjection = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToProjection:[tileMatrixSetDao getProjection:tileMatrixSet]];
            [tileMatrixSet setBoundingBox:[transformTileMatrixSetToProjection transformWithBoundingBox:self.tileMatrixSetBoundingBox]];
            [tileMatrixSetDao update:tileMatrixSet];
        }
        
        // Get the previous bounding box and new bounding box in web
        // mercator
        GPKGProjectionTransform * transformWgs84ToWebMercator = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        GPKGBoundingBox * previousTileMatrixSetWebMercatorBoundingBox = [transformWgs84ToWebMercator transformWithBoundingBox:previousTileMatrixSetBoundingBox];
        GPKGBoundingBox * tileMatrixSetWebMercatorBoundingBox = [transformWgs84ToWebMercator transformWithBoundingBox:self.tileMatrixSetBoundingBox];
        
        GPKGTileMatrixDao * tileMatrixDao = [self.geoPackage getTileMatrixDao];
        
        // Adjust the tile matrix metadata and tile rows at each existing
        // zoom level
        for (int zoom = tileDao.minZoom; zoom <= tileDao.maxZoom; zoom++) {
            GPKGTileMatrix * tileMatrix = [tileDao getTileMatrixWithZoomLevel:zoom];
            if(tileMatrix != nil){
                
                // Determine the new width and height at this level
                int adjustment = pow(2, zoom - minNewOrUpdateZoom);
                int zoomMatrixWidth = self.matrixWidth * adjustment;
                int zoomMatrixHeight = self.matrixHeight * adjustment;
                
                // Get the zoom level tile rows, starting with highest rows
                // and columns so when updating we avoid constraint
                // violations
                GPKGResultSet * tileResults = [tileDao queryForTileDescending:zoom];
                @try {
                    // Update each tile row at this zoom level
                    while([tileResults moveToNext]){
                        GPKGTileRow * tileRow = [tileDao getTileRow:tileResults];
                        
                        // Get the bounding box of the existing tile
                        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithWebMercatorTotalBoundingBox:previousTileMatrixSetWebMercatorBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
                        
                        // Get the mid lat and lon to find the new tile row
                        // and column
                        double midLatitude = [tileBoundingBox.minLatitude doubleValue]
                            + (([tileBoundingBox.maxLatitude doubleValue] - [tileBoundingBox.minLatitude doubleValue]) / 2.0);
                        double midLongitude = [tileBoundingBox.minLongitude doubleValue]
                            + (([tileBoundingBox.maxLongitude doubleValue] - [tileBoundingBox.minLongitude doubleValue]) / 2.0);
                        
                        // Get the new tile row and column with regards to
                        // the new bounding box
                        int newTileRow = [GPKGTileBoundingBoxUtils getTileRowWithWebMercatorTotalBoundingBox:tileMatrixSetWebMercatorBoundingBox andMatrixHeight:zoomMatrixHeight andLatitude:midLatitude];
                        int newTileColumn = [GPKGTileBoundingBoxUtils getTileColumnWithWebMercatorTotalBoundingBox:tileMatrixSetWebMercatorBoundingBox andMatrixWidth:zoomMatrixWidth andLongitude:midLongitude];
                        
                        // Update the tile row
                        [tileRow setTileRow:newTileRow];
                        [tileRow setTileColumn:newTileColumn];
                        [tileDao update:tileRow];
                    }
                }
                @finally {
                    [tileResults close];
                }
                
                // Calculate the pixel size
                double pixelXSize = ([self.webMercatorBoundingBox.maxLongitude doubleValue] - [self.webMercatorBoundingBox.minLongitude doubleValue])
                    / zoomMatrixWidth / [tileMatrix.tileWidth intValue];
                double pixelYSize = ([self.webMercatorBoundingBox.maxLatitude doubleValue] - [self.webMercatorBoundingBox.minLatitude doubleValue])
                    / zoomMatrixHeight / [tileMatrix.tileHeight intValue];
                
                // Update the tile matrix
                [tileMatrix setMatrixWidth:[NSNumber numberWithInt:zoomMatrixWidth]];
                [tileMatrix setMatrixHeight:[NSNumber numberWithInt:zoomMatrixHeight]];
                [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:pixelXSize]];
                [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:pixelYSize]];
                
                [tileMatrixDao update:tileMatrix];
            }
        }
        
        // Adjust the width and height to the min zoom level of the
        // request
        if(minNewOrUpdateZoom < self.minZoom){
            int adjustment = pow(2, self.minZoom - minNewOrUpdateZoom);
            self.matrixWidth *= adjustment;
            self.matrixHeight *= adjustment;
        }
    }
}

-(void) close{
    if(self.geoPackage != nil){
        [self.geoPackage close];
    }
}

-(int) generateTilesWithTileMatrixDao: (GPKGTileMatrixDao *) tileMatrixDao andTileDao: (GPKGTileDao *) tileDao andContents: (GPKGContents *) contents andZoomLevel: (int) zoomLevel andTileGrid: (GPKGTileGrid *) tileGrid andLocalTileGrid: (GPKGTileGrid *) localTileGrid andMatrixWidth: (int) matrixWidth andMatrixHeight: (int) matrixHeight andUpdate: (BOOL) update{
    
    int count = 0;
    
    NSNumber * tileWidth = nil;
    NSNumber * tileHeight = nil;
    
    // Create the tile and each coordinate
    for (int x = tileGrid.minX; x <= tileGrid.maxX; x++) {
        
        // Check if the progress has been cancelled
        if (self.progress != nil && ![self.progress isActive]) {
            break;
        }
        
         for (int y = tileGrid.minY; y <= tileGrid.maxY; y++) {
             
             // Check if the progress has been cancelled
             if (self.progress != nil && ![self.progress isActive]) {
                 break;
             }
             
             // Autorelease to reduce memory footprint
             @autoreleasepool {
             
                 @try {
                     
                     // If an update, delete an existing row
                     if(update){
                         [tileDao deleteTileWithColumn:x andRow:y andZoomLevel:zoomLevel];
                     }
                     
                     // Create the tile
                     NSData * tileData = [self createTileWithZ:zoomLevel andX:x andY:y];
                     
                     if(tileData != nil){
                     
                         UIImage * image = nil;
                         
                         // Compress the image
                         if(self.compressFormat != GPKG_CF_NONE){
                             image = [GPKGImageConverter toImage:tileData withScale:self.compressScale];
                             if(image != nil){
                                 tileData = [GPKGImageConverter toData:image andFormat:self.compressFormat andQuality:self.compressQuality];
                             }
                         }
                         
                         // Create a new tile row
                         GPKGTileRow * newRow = [tileDao newRow];
                         [newRow setZoomLevel:zoomLevel];
                         
                         int tileColumn = x;
                         int tileRow = y;
                         
                         // Update the column and row to the local tile grid location
                         if (localTileGrid != nil) {
                             tileColumn = (x - tileGrid.minX) + localTileGrid.minX;
                             tileRow = (y - tileGrid.minY) + localTileGrid.minY;
                         }
                         
                         [newRow setTileColumn:tileColumn];
                         [newRow setTileRow:tileRow];
                         [newRow setTileData:tileData];
                         [tileDao create:newRow];
                         
                         count++;
                         
                         // Determine the tile width and height
                         if (tileWidth == nil) {
                             if (image == nil) {
                                 image = [GPKGImageConverter toImage:tileData withScale:self.compressScale];
                             }
                             if (image != nil) {
                                 tileWidth = [NSNumber numberWithInt:image.size.width];
                                 tileHeight = [NSNumber numberWithInt:image.size.height];
                             }
                         }
                     }
                 }
                 @catch (NSException *exception) {
                     // Skip this tile, don't increase count
                 }
                 
             }
             
             // Update the progress count, even on failures
             if (self.progress != nil) {
                 [self.progress addProgress:1];
             }
         }
    }
    
    NSNumber * zoomLevelArg  = [NSNumber numberWithInt:zoomLevel];
    
    // If none of the tiles were translated into a bitmap with dimensions,
    // delete them
    if(tileWidth == nil || tileHeight == nil){
        count = 0;
        
        NSNumber * minXArg  = [NSNumber numberWithInt:tileGrid.minX];
        NSNumber * maxXArg  = [NSNumber numberWithInt:tileGrid.maxX];
        NSNumber * minYArg  = [NSNumber numberWithInt:tileGrid.minY];
        NSNumber * maxYArg  = [NSNumber numberWithInt:tileGrid.maxY];
        
        NSMutableString * where = [[NSMutableString alloc] init];
        
        
        [where appendString:[tileDao buildWhereWithField:GPKG_TT_COLUMN_ZOOM_LEVEL andValue:zoomLevelArg]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TT_COLUMN_TILE_COLUMN andValue:minXArg andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TT_COLUMN_TILE_COLUMN andValue:maxXArg andOperation:@"<="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TT_COLUMN_TILE_ROW andValue:minYArg andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TT_COLUMN_TILE_ROW andValue:maxYArg andOperation:@"<="]];
        

        NSArray * whereArgs =[tileDao buildWhereArgsWithValueArray:[[NSArray alloc] initWithObjects:zoomLevelArg, minXArg, maxXArg, minYArg, maxYArg, nil]];
        
        [tileDao deleteWhere:where andWhereArgs:whereArgs];
    }else{
        
        // Check if the tile matrix already exists
        BOOL create = true;
        if (update) {
            create = ![tileMatrixDao multiIdExists:[[NSArray alloc] initWithObjects:self.tableName, zoomLevelArg, nil]];
        }
        
        // Create the tile matrix
        if (create) {
            
            // Calculate meters per pixel
            double pixelXSize = ([self.webMercatorBoundingBox.maxLongitude doubleValue] - [self.webMercatorBoundingBox.minLongitude doubleValue]) / matrixWidth / [tileWidth intValue];
            double pixelYSize = ([self.webMercatorBoundingBox.maxLatitude doubleValue] - [self.webMercatorBoundingBox.minLatitude doubleValue]) / matrixHeight / [tileHeight intValue];
            
            // Create the tile matrix for this zoom level
            GPKGTileMatrix * tileMatrix = [[GPKGTileMatrix alloc] init];
            [tileMatrix setContents:contents];
            [tileMatrix setZoomLevel:zoomLevelArg];
            [tileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
            [tileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
            [tileMatrix setTileWidth:tileWidth];
            [tileMatrix setTileHeight:tileHeight];
            [tileMatrix setPixelXSize:[[NSDecimalNumber alloc] initWithDouble:pixelXSize]];
            [tileMatrix setPixelYSize:[[NSDecimalNumber alloc] initWithDouble:pixelYSize]];
            [tileMatrixDao create:tileMatrix];
        }
    }
    
    return count;
}

@end
