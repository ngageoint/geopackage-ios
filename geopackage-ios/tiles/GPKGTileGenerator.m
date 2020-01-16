//
//  GPKGTileGenerator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileGenerator.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGUtils.h"
#import "SFPProjectionTransform.h"
#import "GPKGImageConverter.h"
#import "GPKGTileTableScaling.h"

@implementation GPKGTileGenerator

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName andMinZoom: (int) minZoom andMaxZoom: (int) maxZoom andBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (SFPProjection *) projection{
    self = [super init];
    if(self != nil){
        [geoPackage verifyWritable];
        self.geoPackage = geoPackage;
        self.tableName = tableName;
        self.minZoom = minZoom;
        self.maxZoom = maxZoom;
        self.boundingBox = boundingBox;
        self.projection = projection;
        self.tileGrids = [[NSMutableDictionary alloc] init];
        self.tileBounds = [[NSMutableDictionary alloc] init];
        self.compressFormat = GPKG_CF_NONE;
        self.compressQuality = 1.0;
        self.compressScale = 1.0;
        self.xyzTiles = false;
        self.matrixHeight = 0;
        self.matrixWidth = 0;
    }
    return self;
}

-(void) preTileGeneration{
    [self doesNotRecognizeSelector:_cmd];
}

-(NSData *) createTileWithZ: (int) z andX: (int) x andY: (int) y{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxAtZoom: (int) zoom{
    return _boundingBox;
}

-(void) setCompressQualityAsIntPercentage: (int) percentage{
    CGFloat value = [self percentageValueFromInt:percentage];
    [self setCompressQuality:value];
}

-(void) setCompressScaleAsIntPercentage: (int) percentage{
    CGFloat value = [self percentageValueFromInt:percentage];
    [self setCompressScale:value];
}

-(CGFloat) percentageValueFromInt: (int) percentage{
    return percentage / 100.0;
}

-(int) tileCount{
    if(self.totalCount == nil){
        int count = 0;
        
        BOOL degrees = [self.projection isUnit:SFP_UNIT_DEGREES];
        SFPProjectionTransform *transformToWebMercator = nil;
        if(!degrees){
            transformToWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        }
        
        for(int zoom = self.minZoom; zoom <= self.maxZoom; zoom++){
            
            GPKGBoundingBox *expandedBoundingBox = [self boundingBoxAtZoom:zoom];
            
            // Get the tile grid that includes the entire bounding box
            GPKGTileGrid * tileGrid = nil;
            if(degrees){
                tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:expandedBoundingBox andZoom:zoom];
            }else{
                tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:[expandedBoundingBox transform:transformToWebMercator] andZoom:zoom];
            }

            count += [tileGrid count];
            NSNumber *zoomKey = [NSNumber numberWithInt:zoom];
            [GPKGUtils setObject:tileGrid forKey:zoomKey inDictionary:self.tileGrids];
            [GPKGUtils setObject:expandedBoundingBox forKey:zoomKey inDictionary:self.tileBounds];
        }
        
        self.totalCount = [NSNumber numberWithInt:count];
    }
    return [self.totalCount intValue];
}

-(int) generateTiles{
    
    int totalCount = [self tileCount];
    
    // Set the max progress count
    if(self.progress != nil){
        [self.progress setMax:totalCount];
    }
    
    int count = 0;
    BOOL update = false;
    
    // Adjust the tile matrix set and  bounds
    GPKGBoundingBox *minZoomBoundingBox = [GPKGUtils objectForKey:[NSNumber numberWithInt:self.minZoom] inDictionary:self.tileBounds];
    [self adjustBoundsWithBoundingBox:minZoomBoundingBox andZoom:self.minZoom];
    
    // Create a new tile matrix or update an existing
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self.geoPackage tileMatrixSetDao];
    GPKGTileMatrixSet * tileMatrixSet = nil;
    if(![tileMatrixSetDao tableExists] || ![tileMatrixSetDao idExists:self.tableName]){
        // Create the srs if needed
        GPKGSpatialReferenceSystemDao * srsDao = [self.geoPackage spatialReferenceSystemDao];
        NSNumber *coordsysId = [NSNumber numberWithInteger:[[self.projection code] integerValue]];
        GPKGSpatialReferenceSystem * srs = [srsDao srsWithOrganization:[self.projection authority] andCoordsysId:coordsysId];
        // Create the tile table
        tileMatrixSet = [self.geoPackage createTileTableWithTableName:self.tableName andContentsBoundingBox:self.boundingBox andContentsSrsId:srs.srsId andTileMatrixSetBoundingBox:self.tileGridBoundingBox andTileMatrixSetSrsId:srs.srsId];
        
    }else{
        update = true;
        //Query to get the Tile Matrix Set
        tileMatrixSet = (GPKGTileMatrixSet *)[tileMatrixSetDao queryForIdObject:self.tableName];
        
        // Update the tile bounds between the existing and this request
        [self updateTileBoundsWithTileMatrixSet:tileMatrixSet];
    }
    
    [self preTileGeneration];
    
    // If tile scaling is set, create the tile scaling extension entry
    if (self.scaling != nil) {
        GPKGTileTableScaling  *tileTableScaling = [[GPKGTileTableScaling alloc] initWithGeoPackage:self.geoPackage andTileMatrixSet:tileMatrixSet];
        [tileTableScaling createOrUpdate:self.scaling];
    }
    
    // Create the tiles
    @try {
        GPKGContents * contents = [tileMatrixSetDao contents:tileMatrixSet];
        GPKGTileMatrixDao * tileMatrixDao = [self.geoPackage tileMatrixDao];
        GPKGTileDao * tileDao = [self.geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
        
        // Create the new matrix tiles
        for(int zoom = self.minZoom; zoom <= self.maxZoom && (self.progress == nil || [self.progress isActive]); zoom++){
            
            GPKGTileGrid * localTileGrid = nil;
            
            // Determine the matrix width and height for standard web mercator format
            if(self.xyzTiles){
                self.matrixWidth = [GPKGTileBoundingBoxUtils tilesPerSideWithZoom:zoom];
                self.matrixHeight = self.matrixWidth;
            }
            // Get the local tile grid for GeoPackage format of where the tiles belong
            else{
                GPKGBoundingBox *zoomBoundingBox = [GPKGUtils objectForKey:[NSNumber numberWithInt:zoom] inDictionary:self.tileBounds];
                localTileGrid = [GPKGTileBoundingBoxUtils tileGridWithTotalBoundingBox:self.tileGridBoundingBox andMatrixWidth:self.matrixWidth andMatrixHeight:self.matrixHeight andBoundingBox:zoomBoundingBox];
            }
            
            // Generate the tiles for the zoom level
            GPKGTileGrid * tileGrid = [GPKGUtils objectForKey:[NSNumber numberWithInt:zoom] inDictionary:self.tileGrids];
            count += [self generateTilesWithTileMatrixDao:tileMatrixDao andTileDao:tileDao andContents:contents andZoomLevel:zoom andTileGrid:tileGrid andLocalTileGrid:localTileGrid andMatrixWidth:self.matrixWidth andMatrixHeight:self.matrixHeight andUpdate:update];
            
            if(!self.xyzTiles){
                // Double the matrix width and height for the next level
                self.matrixWidth *= 2;
                self.matrixHeight *= 2;
            }
        }
        
        // Delete the table if canceled
        if(self.progress != nil && ![self.progress isActive] && [self.progress cleanupOnCancel]){
            [self.geoPackage deleteTableQuietly:self.tableName];
            count = 0;
        } else{
            // Update the contents last modified date
            [contents setLastChange:[NSDate date]];
            GPKGContentsDao * contentsDao = [self.geoPackage contentsDao];
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
        [self.geoPackage deleteTableQuietly:self.tableName];
        [self.progress failureWithError:[e description]];
    }
    
    return count;
}

-(void) adjustBoundsWithBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    
    if(self.xyzTiles){
        [self adjustXYZBounds];
    } else if([self.projection isUnit:SFP_UNIT_DEGREES]){
        [self adjustGeoPackageBoundsWithWgs84BoundingBox:boundingBox andZoom:zoom];
    } else{
        [self adjustGeoPackageBoundsWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
    }
}

-(void) adjustXYZBounds{
    // Set the tile matrix set bounding box to be the world
    GPKGBoundingBox * standardWgs84Box = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-PROJ_WGS84_HALF_WORLD_LON_WIDTH andMinLatitudeDouble:PROJ_WEB_MERCATOR_MIN_LAT_RANGE andMaxLongitudeDouble:PROJ_WGS84_HALF_WORLD_LON_WIDTH andMaxLatitudeDouble:PROJ_WEB_MERCATOR_MAX_LAT_RANGE];
    SFPProjectionTransform * wgs84ToWebMercatorTransform = [[SFPProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    self.tileGridBoundingBox = [standardWgs84Box transform:wgs84ToWebMercatorTransform];
}

-(void) adjustGeoPackageBoundsWithWgs84BoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    // Get the fitting tile grid and determine the bounding box that fits it
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWgs84BoundingBox:boundingBox andZoom:zoom];
    self.tileGridBoundingBox = [GPKGTileBoundingBoxUtils wgs84BoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    self.matrixWidth = tileGrid.maxX + 1 - tileGrid.minX;
    self.matrixHeight = tileGrid.maxY + 1 - tileGrid.minY;
}

-(void) adjustGeoPackageBoundsWithWebMercatorBoundingBox: (GPKGBoundingBox *) boundingBox andZoom: (int) zoom{
    // Get the fitting tile grid and determine the bounding box that fits it
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils tileGridWithWebMercatorBoundingBox:boundingBox andZoom:zoom];
    self.tileGridBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithTileGrid:tileGrid andZoom:zoom];
    self.matrixWidth = tileGrid.maxX + 1 - tileGrid.minX;
    self.matrixHeight = tileGrid.maxY + 1 - tileGrid.minY;
}

-(void) updateTileBoundsWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    
    GPKGTileDao * tileDao = [self.geoPackage tileDaoWithTileMatrixSet:tileMatrixSet];
    
    if([tileDao isXYZTiles]){
        if(!self.xyzTiles){
            // If adding GeoPackage tiles to a Standard Tile format, add them as standard web mercator format tiles
            self.xyzTiles = true;
            [self adjustXYZBounds];
        }
    } else if(self.xyzTiles){
        // Can't add Standard formatted tiles to GeoPackage tiles
        [NSException raise:@"Not Supported" format:@"Can not add Standard Web Mercator Formatted tiles to %@ which already contains GeoPackage formatted tiles", self.tableName];
    }
    
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self.geoPackage tileMatrixSetDao];
    SFPProjection * tileMatrixProjection = [tileMatrixSetDao projection:tileMatrixSet];
    if(![tileMatrixProjection isEqual:self.projection]){
        [NSException raise:@"Projection Mismatch" format:@"Can not update tiles projected at %@:%@ with tiles projected at %@:%@", [tileMatrixProjection authority], [tileMatrixProjection code], [self.projection authority], [self.projection code]];
    }
    
    GPKGContents * contents = [tileMatrixSetDao contents:tileMatrixSet];
    
    GPKGContentsDao * contentsDao = [self.geoPackage contentsDao];
    
    GPKGBoundingBox * previousContentsBoundingBox = [contents boundingBox];
    if(previousContentsBoundingBox != nil){
        SFPProjectionTransform * transformProjectionToContents = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToProjection:[contentsDao projection:contents]];
        GPKGBoundingBox * contentsBoundingBox = self.boundingBox;
        if(![transformProjectionToContents isSameProjection]){
            contentsBoundingBox = [contentsBoundingBox transform:transformProjectionToContents];
        }
        contentsBoundingBox = [contentsBoundingBox union:previousContentsBoundingBox];
        
        // Update the contents if modified
        if(![contentsBoundingBox equals:previousContentsBoundingBox]){
            [contents setBoundingBox:contentsBoundingBox];
            [contentsDao update:contents];
        }
    }
    
    // If updating GeoPackage format tiles, all existing metadata and tile
    // rows needs to be adjusted
    if(!self.xyzTiles){
        
        GPKGBoundingBox * previousTileMatrixSetBoundingBox = [tileMatrixSet boundingBox];
        
        // Adjust the bounds to include the request and existing bounds
        SFPProjectionTransform * transformProjectionToTileMatrixSet = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToProjection:tileMatrixProjection];
        BOOL sameProjection = [transformProjectionToTileMatrixSet isSameProjection];
        GPKGBoundingBox * updateBoundingBox = [GPKGUtils objectForKey:[NSNumber numberWithInt:self.minZoom] inDictionary:self.tileBounds];
        if(!sameProjection){
            updateBoundingBox = [updateBoundingBox transform:transformProjectionToTileMatrixSet];
        }
        int minNewOrUpdateZoom = MIN(self.minZoom, tileDao.minZoom);
        [self adjustBoundsWithBoundingBox:updateBoundingBox andZoom:minNewOrUpdateZoom];
        
        // Update the tile matrix set if modified
        GPKGBoundingBox * updateTileGridBoundingBox = self.tileGridBoundingBox;
        if(!sameProjection){
            updateTileGridBoundingBox = [updateTileGridBoundingBox transform:transformProjectionToTileMatrixSet];
        }
        if(![previousTileMatrixSetBoundingBox equals:updateTileGridBoundingBox]){
            updateTileGridBoundingBox = [updateTileGridBoundingBox union:previousTileMatrixSetBoundingBox];
            [self adjustBoundsWithBoundingBox:updateTileGridBoundingBox andZoom:minNewOrUpdateZoom];
            updateTileGridBoundingBox = self.tileGridBoundingBox;
            if(!sameProjection){
                updateTileGridBoundingBox = [updateTileGridBoundingBox transform:transformProjectionToTileMatrixSet];
            }
            [tileMatrixSet setBoundingBox:updateTileGridBoundingBox];
            [tileMatrixSetDao update:tileMatrixSet];
        }
        
        GPKGTileMatrixDao * tileMatrixDao = [self.geoPackage tileMatrixDao];
        
        // Adjust the tile matrix metadata and tile rows at each existing
        // zoom level
        for (int zoom = tileDao.minZoom; zoom <= tileDao.maxZoom; zoom++) {
            GPKGTileMatrix * tileMatrix = [tileDao tileMatrixWithZoomLevel:zoom];
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
                        GPKGTileRow * tileRow = [tileDao tileRow:tileResults];
                        
                        // Get the bounding box of the existing tile
                        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils boundingBoxWithTotalBoundingBox:previousTileMatrixSetBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow tileColumn] andTileRow:[tileRow tileRow]];
                        
                        // Get the mid lat and lon to find the new tile row
                        // and column
                        double midLatitude = [tileBoundingBox.minLatitude doubleValue]
                            + (([tileBoundingBox.maxLatitude doubleValue] - [tileBoundingBox.minLatitude doubleValue]) / 2.0);
                        double midLongitude = [tileBoundingBox.minLongitude doubleValue]
                            + (([tileBoundingBox.maxLongitude doubleValue] - [tileBoundingBox.minLongitude doubleValue]) / 2.0);
                        
                        // Get the new tile row and column with regards to
                        // the new bounding box
                        int newTileRow = [GPKGTileBoundingBoxUtils tileRowWithTotalBoundingBox:self.tileGridBoundingBox andMatrixHeight:zoomMatrixHeight andLatitude:midLatitude];
                        int newTileColumn = [GPKGTileBoundingBoxUtils tileColumnWithTotalBoundingBox:self.tileGridBoundingBox andMatrixWidth:zoomMatrixWidth andLongitude:midLongitude];
                        
                        // Update the tile row
                        if([tileRow tileRow] != newTileRow || [tileRow tileColumn] != newTileColumn){
                            [tileRow setTileRow:newTileRow];
                            [tileRow setTileColumn:newTileColumn];
                            [tileDao update:tileRow];
                        }
                    }
                }
                @finally {
                    [tileResults close];
                }
                
                // Calculate the pixel size
                double pixelXSize = ([self.tileGridBoundingBox.maxLongitude doubleValue] - [self.tileGridBoundingBox.minLongitude doubleValue])
                    / zoomMatrixWidth / [tileMatrix.tileWidth intValue];
                double pixelYSize = ([self.tileGridBoundingBox.maxLatitude doubleValue] - [self.tileGridBoundingBox.minLatitude doubleValue])
                    / zoomMatrixHeight / [tileMatrix.tileHeight intValue];
                
                // Update the tile matrix
                [tileMatrix setMatrixWidth:[NSNumber numberWithInt:zoomMatrixWidth]];
                [tileMatrix setMatrixHeight:[NSNumber numberWithInt:zoomMatrixHeight]];
                [tileMatrix setPixelXSizeValue:pixelXSize];
                [tileMatrix setPixelYSizeValue:pixelYSize];
                
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
                         
                         // If an update, delete an existing row
                         if(update){
                             [tileDao deleteTileWithColumn:tileColumn andRow:tileRow andZoomLevel:zoomLevel];
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
        
        
        [where appendString:[tileDao buildWhereWithField:GPKG_TC_COLUMN_ZOOM_LEVEL andValue:zoomLevelArg]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TC_COLUMN_TILE_COLUMN andValue:minXArg andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TC_COLUMN_TILE_COLUMN andValue:maxXArg andOperation:@"<="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TC_COLUMN_TILE_ROW andValue:minYArg andOperation:@">="]];
        
        [where appendString:@" and "];
        [where appendString:[tileDao buildWhereWithField:GPKG_TC_COLUMN_TILE_ROW andValue:maxYArg andOperation:@"<="]];
        

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
            double pixelXSize = ([self.tileGridBoundingBox.maxLongitude doubleValue] - [self.tileGridBoundingBox.minLongitude doubleValue]) / matrixWidth / [tileWidth intValue];
            double pixelYSize = ([self.tileGridBoundingBox.maxLatitude doubleValue] - [self.tileGridBoundingBox.minLatitude doubleValue]) / matrixHeight / [tileHeight intValue];
            
            // Create the tile matrix for this zoom level
            GPKGTileMatrix * tileMatrix = [[GPKGTileMatrix alloc] init];
            [tileMatrix setContents:contents];
            [tileMatrix setZoomLevel:zoomLevelArg];
            [tileMatrix setMatrixWidth:[NSNumber numberWithInt:matrixWidth]];
            [tileMatrix setMatrixHeight:[NSNumber numberWithInt:matrixHeight]];
            [tileMatrix setTileWidth:tileWidth];
            [tileMatrix setTileHeight:tileHeight];
            [tileMatrix setPixelXSizeValue:pixelXSize];
            [tileMatrix setPixelYSizeValue:pixelYSize];
            [tileMatrixDao create:tileMatrix];
        }
    }
    
    return count;
}

@end
