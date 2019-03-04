//
//  GPKGTileCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreator.h"
#import "SFPProjectionFactory.h"
#import "GPKGTileMatrixSetDao.h"
#import "SFPProjectionTransform.h"
#import "GPKGImageConverter.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGTileCreator ()

@property (nonatomic, strong) GPKGTileDao *tileDao;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;
@property (nonatomic, strong) SFPProjection *requestProjection;
@property (nonatomic, strong) SFPProjection *tilesProjection;
@property (nonatomic, strong) GPKGBoundingBox *tileSetBoundingBox;
@property (nonatomic) BOOL sameProjection;

@end

/**
 *  Tile Creator, creates a tile from a tile matrix to the desired projection
 */
@implementation GPKGTileCreator

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (SFPProjection *) requestProjection{
    self = [super init];
    if(self != nil){
        self.tileDao = tileDao;
        self.width = width;
        self.height = height;
        self.requestProjection = requestProjection;
        
        self.tileMatrixSet = tileDao.tileMatrixSet;
        GPKGTileMatrixSetDao * tileMatrixSetDao = [[GPKGTileMatrixSetDao alloc] initWithDatabase: tileDao.database];
        self.tilesProjection = [tileMatrixSetDao getProjection:tileDao.tileMatrixSet];
        self.tileSetBoundingBox = [tileDao.tileMatrixSet getBoundingBox];
        
        // Check if the projections have the same units
        self.sameProjection = [self.requestProjection getUnit] == [self.tilesProjection getUnit];
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    return [self initWithTileDao:tileDao andWidth:nil andHeight:nil andProjection:tileDao.projection];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height{
    return [self initWithTileDao:tileDao andWidth:width andHeight:height andProjection:tileDao.projection];
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andProjection: (SFPProjection *) requestProjection{
    return [self initWithTileDao:tileDao andWidth:nil andHeight:nil andProjection:requestProjection];
}

-(GPKGTileDao *) tileDao{
    return _tileDao;
}

-(NSNumber *) width{
    return _width;
}

-(NSNumber *) height{
    return _height;
}

-(GPKGTileMatrixSet *) tileMatrixSet{
    return _tileMatrixSet;
}

-(SFPProjection *) requestProjection{
    return _requestProjection;
}

-(SFPProjection *) tilesProjection{
    return _tilesProjection;
}

-(GPKGBoundingBox *) tileSetBoundingBox{
    return _tileSetBoundingBox;
}

-(BOOL) sameProjection{
    return _sameProjection;
}

-(BOOL) hasTileWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    
    BOOL hasTile = false;
    
    // Transform to the projection of the tiles
    SFPProjectionTransform * transformRequestToTiles = [[SFPProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.tilesProjection];
    GPKGBoundingBox * tilesBoundingBox = [requestBoundingBox transform:transformRequestToTiles];
    
    NSArray<GPKGTileMatrix *> *tileMatrices = [self getTileMatrices:tilesBoundingBox];

    for(int i = 0; !hasTile && i < tileMatrices.count; i++){
    
        GPKGTileMatrix *tileMatrix = [tileMatrices objectAtIndex:i];
        
        GPKGResultSet * tileResults = [self retrieveTileResultsWithBoundingBox:tilesBoundingBox andTileMatrix:tileMatrix];
        if(tileResults != nil){
            
            @try{
                hasTile = tileResults.count > 0;
            } @finally{
                [tileResults close];
            }
        }
    }
    
    return hasTile;
}

-(GPKGGeoPackageTile *) getTileWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    
    GPKGGeoPackageTile * tile = nil;
    
    // Transform to the projection of the tiles
    SFPProjectionTransform * transformRequestToTiles = [[SFPProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.tilesProjection];
    GPKGBoundingBox * tilesBoundingBox = [requestBoundingBox transform:transformRequestToTiles];
    
    NSArray<GPKGTileMatrix *> *tileMatrices = [self getTileMatrices:tilesBoundingBox];
    
    for(int i = 0; tile == nil && i < tileMatrices.count; i++){
    
        GPKGTileMatrix *tileMatrix = [tileMatrices objectAtIndex:i];
        
        GPKGResultSet * tileResults = [self retrieveTileResultsWithBoundingBox:tilesBoundingBox andTileMatrix:tileMatrix];
        if(tileResults != nil){
            
            @try{
                
                if(tileResults.count > 0){
                    
                    GPKGBoundingBox * requestProjectedBoundingBox = [requestBoundingBox transform:transformRequestToTiles];
                    
                    // Determine the requested tile dimensions, or use the dimensions of a single tile matrix tile
                    int requestedTileWidth = self.width != nil ? [self.width intValue] : [tileMatrix.tileWidth intValue];
                    int requestedTileHeight = self.height != nil ? [self.height intValue] : [tileMatrix.tileHeight intValue];
                    
                    // Determine the size of the tile to initially draw
                    int tileWidth = requestedTileWidth;
                    int tileHeight = requestedTileHeight;
                    if (!self.sameProjection) {
                        tileWidth = round(([requestProjectedBoundingBox.maxLongitude doubleValue] - [requestProjectedBoundingBox.minLongitude doubleValue]) / [tileMatrix.pixelXSize doubleValue]);
                        tileHeight = round(([requestProjectedBoundingBox.maxLatitude doubleValue] - [requestProjectedBoundingBox.minLatitude doubleValue]) / [tileMatrix.pixelYSize doubleValue]);
                    }
                    
                    // Draw the resulting bitmap with the matching tiles
                    UIImage * tileImage = [self drawTileWithTileMatrix:tileMatrix andResults:tileResults andBoundingBox:requestProjectedBoundingBox andWidth:tileWidth andHeight:tileHeight];
                    
                    // Create the tile
                    if(tileImage != nil){
                        
                        // Project the tile if needed
                        if(!self.sameProjection){
                            UIImage * reprojectTile = [self reprojectTileWithImage:tileImage andWidth:requestedTileWidth andHeight:requestedTileHeight andBoundingBox:requestBoundingBox andTransform:transformRequestToTiles andBoundingBox:tilesBoundingBox];
                            tileImage = reprojectTile;
                        }
                        
                        NSData * tileData = [GPKGImageConverter toData:tileImage andFormat:GPKG_CF_PNG];
                        tile = [[GPKGGeoPackageTile alloc] initWithWidth:requestedTileWidth andHeight:requestedTileHeight andData:tileData];
                    }
                    
                }
                
            }@finally{
                [tileResults close];
            }
            
        }
    }
    
    return tile;
}

-(UIImage *) drawTileWithTileMatrix: (GPKGTileMatrix *) tileMatrix andResults: (GPKGResultSet *) tileResults andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andWidth: (int) width andHeight: (int) height{
    
    // Get the GeoPackage tile dimensions
    int tileWidth = [tileMatrix.tileWidth intValue];
    int tileHeight = [tileMatrix.tileHeight intValue];
    
    // Draw the resulting image with the matching tiles
    UIGraphicsBeginImageContext(CGSizeMake(tileWidth, tileHeight));
    UIGraphicsGetCurrentContext();
    
    while([tileResults moveToNext]){
        
        // Get the next tile
        GPKGTileRow * tileRow = [self.tileDao getTileRow:tileResults];
        UIImage * tileDataImage = [tileRow getTileDataImage];
        
        // Get the bounding box of the tile
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.tileSetBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
        
        // Get the bounding box where the requested image and tile overlap
        GPKGBoundingBox * overlap = [requestProjectedBoundingBox overlap:tileBoundingBox];
        
        // If the tile overlaps with the requested box
        if(overlap != nil){
            
            // Get the rectangle of the tile image to draw
            CGRect src = [GPKGTileBoundingBoxUtils getRoundedRectangleWithWidth:tileWidth andHeight:tileHeight andBoundingBox:tileBoundingBox andSection:overlap];
            
            if(src.size.width > 0 && src.size.height > 0){
            
                // Get the portion of the image to draw
                CGImageRef srcImageRef = CGImageCreateWithImageInRect([tileDataImage CGImage], src);
                UIImage *srcImage = [UIImage imageWithCGImage:srcImageRef];
                CGImageRelease(srcImageRef);
            
                // Get the rectangle of where to draw the tile in
                // the resulting image
                CGRect dest = [GPKGTileBoundingBoxUtils getRoundedRectangleWithWidth:tileWidth andHeight:tileHeight andBoundingBox:requestProjectedBoundingBox andSection:overlap];

                // Draw to the image
                [srcImage drawInRect:dest];
            }
        }
    }
    
    // Create the tile
    UIImage *tileImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Scale the image if needed
    if(width != tileWidth || height != tileHeight){
        CGSize scaledSize = CGSizeMake(width, height);
        UIGraphicsBeginImageContext(scaledSize);
        [tileImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
        tileImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return tileImage;
}

-(UIImage *) reprojectTileWithImage: (UIImage *) tile andWidth: (int) requestedTileWidth andHeight: (int) requestedTileHeight andBoundingBox: (GPKGBoundingBox *) requestBoundingBox andTransform: (SFPProjectionTransform *) transformRequestToTiles andBoundingBox: (GPKGBoundingBox *) tilesBoundingBox{
    
    double requestedWidthUnitsPerPixel = ([requestBoundingBox.maxLongitude doubleValue] - [requestBoundingBox.minLongitude doubleValue]) / requestedTileWidth;
    double requestedHeightUnitsPerPixel = ([requestBoundingBox.maxLatitude doubleValue] - [requestBoundingBox.minLatitude doubleValue]) / requestedTileHeight;
    
    double tilesDistanceWidth = [tilesBoundingBox.maxLongitude doubleValue] - [tilesBoundingBox.minLongitude doubleValue];
    double tilesDistanceHeight = [tilesBoundingBox.maxLatitude doubleValue] - [tilesBoundingBox.minLatitude doubleValue];
    
    int width = tile.size.width;
    int height = tile.size.height;
    
    // Tile pixels of the tile matrix tiles
    CGImageRef tileImageRef = [tile CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *pixels = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    CGContextRef context = CGBitmapContextCreate(pixels, width, height,
                                                 8, 4 * width, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), tileImageRef);
    CGContextRelease(context);
    
    // Projected tile pixels to draw the reprojected tile
    //uint8_t projectedPixels[requestedTileWidth * requestedTileHeight * 4];
    uint8_t * projectedPixels = calloc(requestedTileWidth * requestedTileHeight * 4, sizeof(unsigned char));
    
    // Retrieve each pixel in the new tile from the unprojected tile
    for (int y = 0; y < requestedTileHeight; y++) {
        for (int x = 0; x < requestedTileWidth; x++) {
            
            double longitude = [requestBoundingBox.minLongitude doubleValue] + (x * requestedWidthUnitsPerPixel);
            double latitude = [requestBoundingBox.maxLatitude doubleValue] - (y * requestedHeightUnitsPerPixel);
            CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(latitude, longitude);
            CLLocationCoordinate2D toCoord = [transformRequestToTiles transform:fromCoord];
            double projectedLongitude = toCoord.longitude;
            double projectedLatitude = toCoord.latitude;
            
            int xPixel = (int)round(((projectedLongitude - [tilesBoundingBox.minLongitude doubleValue]) / tilesDistanceWidth) * width);
            int yPixel = (int)round((([tilesBoundingBox.maxLatitude doubleValue] - projectedLatitude) / tilesDistanceHeight) * height);
            
            xPixel = MAX(0, xPixel);
            xPixel = MIN(width - 1, xPixel);
            
            yPixel = MAX(0, yPixel);
            yPixel = MIN(height - 1, yPixel);
            
            projectedPixels[((y * requestedTileWidth) + x) * 4] = pixels[((yPixel * width) + xPixel) * 4];
            projectedPixels[(((y * requestedTileWidth) + x) * 4) + 1] = pixels[(((yPixel * width) + xPixel) * 4) + 1];
            projectedPixels[(((y * requestedTileWidth) + x) * 4) + 2] = pixels[(((yPixel * width) + xPixel) * 4) + 2];
            projectedPixels[(((y * requestedTileWidth) + x) * 4) + 3] = pixels[(((yPixel * width) + xPixel) * 4) + 3];
        }
    }
    free(pixels);
    
    // Draw the new tile image
    CGColorSpaceRef projectedTileColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef projectedContext = CGBitmapContextCreate(&projectedPixels[0], requestedTileWidth, requestedTileHeight, 8, 4 * requestedTileWidth, projectedTileColorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef projectedImageRef = CGBitmapContextCreateImage(projectedContext);
    UIImage * projectedTileImage = [[UIImage alloc] initWithCGImage:projectedImageRef];
    CGColorSpaceRelease(projectedTileColorSpace);
    CGContextRelease(projectedContext);
    
    free(projectedPixels);
    
    return projectedTileImage;
}

-(NSArray<GPKGTileMatrix *> *) getTileMatrices: (GPKGBoundingBox *) projectedRequestBoundingBox{

    NSMutableArray<GPKGTileMatrix *> *tileMatrices = [[NSMutableArray alloc] init];
    
    // Check if the request overlaps the tile matrix set
    if(self.tileDao.tileMatrices.count > 0 && [projectedRequestBoundingBox intersects:self.tileSetBoundingBox]){
        
        // Get the tile distance
        double distanceWidth = [projectedRequestBoundingBox.maxLongitude doubleValue]
            - [projectedRequestBoundingBox.minLongitude doubleValue];
        double distanceHeight = [projectedRequestBoundingBox.maxLatitude doubleValue]
            - [projectedRequestBoundingBox.minLatitude doubleValue];
        
        // Get the zoom level to request based upon the tile size
        NSNumber * requestZoomLevel = nil;
        if(self.scaling != nil){
            // When options are provided, get the approximate zoom level regardless of whether a tile level exists
            requestZoomLevel = [self.tileDao approximateZoomLevelWithWidth:distanceWidth andHeight:distanceHeight];
        }else{
            // Get the closest existing zoom level
            requestZoomLevel = [self.tileDao zoomLevelWithWidth: distanceWidth andHeight: distanceHeight];
        }
        
        // If there is a matching zoom level
        if (requestZoomLevel != nil) {
        
            NSMutableArray<NSNumber *> *zoomLevels = nil;
            
            // If options are configured, build the possible zoom levels in order to request
            if (self.scaling != nil && self.scaling.scalingType != nil) {
                
                // Find zoom in levels
                NSMutableArray<NSNumber *> *zoomInLevels = [[NSMutableArray alloc] init];
                if ([self.scaling isZoomIn]) {
                    int zoomIn = self.scaling.zoomIn != nil ? [requestZoomLevel intValue] + [self.scaling.zoomIn intValue] : self.tileDao.maxZoom;
                    for (int zoomLevel = [requestZoomLevel intValue] + 1; zoomLevel <= zoomIn; zoomLevel++) {
                        [zoomInLevels addObject:[NSNumber numberWithInt:zoomLevel]];
                    }
                }
                
                // Find zoom out levels
                NSMutableArray<NSNumber *> *zoomOutLevels = [[NSMutableArray alloc] init];
                if ([self.scaling isZoomOut]) {
                    int zoomOut = self.scaling.zoomOut != nil ? [requestZoomLevel intValue] - [self.scaling.zoomOut intValue] : self.tileDao.minZoom;
                    for (int zoomLevel = [requestZoomLevel intValue] - 1; zoomLevel >= zoomOut; zoomLevel--) {
                        [zoomOutLevels addObject:[NSNumber numberWithInt:zoomLevel]];
                    }
                }
                
                if (zoomInLevels.count == 0) {
                    // Only zooming out
                    zoomLevels = zoomOutLevels;
                } else if (zoomOutLevels.count == 0) {
                    // Only zooming in
                    zoomLevels = zoomInLevels;
                } else {
                    // Determine how to order the zoom in and zoom out levels
                    enum GPKGTileScalingType type = [self.scaling getTileScalingType];
                    switch (type) {
                        case GPKG_TSC_IN:
                        case GPKG_TSC_IN_OUT:
                            // Order zoom in levels before zoom out levels
                            zoomLevels = zoomInLevels;
                            [zoomLevels addObjectsFromArray:zoomOutLevels];
                            break;
                        case GPKG_TSC_OUT:
                        case GPKG_TSC_OUT_IN:
                            // Order zoom out levels before zoom in levels
                            zoomLevels = zoomOutLevels;
                            [zoomLevels addObjectsFromArray:zoomInLevels];
                            break;
                        case GPKG_TSC_CLOSEST_IN_OUT:
                        case GPKG_TSC_CLOSEST_OUT_IN:
                            // Alternate the zoom in and out levels
                            {
                                NSMutableArray<NSNumber *> *firstLevels;
                                NSMutableArray<NSNumber *> *secondLevels;
                                if (type == GPKG_TSC_CLOSEST_IN_OUT) {
                                    // Alternate starting with zoom in
                                    firstLevels = zoomInLevels;
                                    secondLevels = zoomOutLevels;
                                } else {
                                    // Alternate starting with zoom out
                                    firstLevels = zoomOutLevels;
                                    secondLevels = zoomInLevels;
                                }
                                
                                zoomLevels = [[NSMutableArray alloc] init];
                                int maxLevels = (int)MAX(firstLevels.count, secondLevels.count);
                                for (int i = 0; i < maxLevels; i++) {
                                    if (i < firstLevels.count) {
                                        [zoomLevels addObject:[firstLevels objectAtIndex:i]];
                                    }
                                    if (i < secondLevels.count) {
                                        [zoomLevels addObject:[secondLevels objectAtIndex:i]];
                                    }
                                }
                            }
                            break;
                        default:
                            [NSException raise:@"Unsupported Tile Scaling Type" format:@"Unsupported Tile Scaling Type: %u", type];
                    }
                }
                
            }else{
                zoomLevels = [[NSMutableArray alloc] init];
            }
            
            // Always check the request zoom level first
            [zoomLevels insertObject:requestZoomLevel atIndex:0];
            
            // Build a list of tile matrices that exist for the zoom levels
            for (NSNumber *zoomLevel in zoomLevels) {
                GPKGTileMatrix *tileMatrix = [self.tileDao getTileMatrixWithZoomLevel:[zoomLevel intValue]];
                if (tileMatrix != nil) {
                    [tileMatrices addObject:tileMatrix];
                }
            }
            
        }
    }
    
    return tileMatrices;
}

-(GPKGResultSet *) retrieveTileResultsWithBoundingBox: (GPKGBoundingBox *) projectedRequestBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    
    GPKGResultSet * tileResults = nil;
    
    if (tileMatrix != nil) {
        
        // Get the tile grid
        GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithTotalBoundingBox:self.tileSetBoundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:projectedRequestBoundingBox];
        
        // Query for matching tiles in the tile grid
        tileResults = [self.tileDao queryByTileGrid:tileGrid andZoomLevel:[tileMatrix.zoomLevel intValue]];
    }
    
    return tileResults;
}

@end
