//
//  GPKGTileCreator.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGTileCreator.h"
#import "GPKGProjectionFactory.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGProjectionTransform.h"
#import "GPKGImageConverter.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGTileCreator ()

@property (nonatomic, strong) GPKGTileDao *tileDao;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;
@property (nonatomic, strong) GPKGProjection *requestProjection;
@property (nonatomic, strong) GPKGProjection *tilesProjection;
@property (nonatomic, strong) GPKGBoundingBox *tileSetBoundingBox;
@property (nonatomic) BOOL sameProjection;

@end

/**
 *  Tile Creator, creates a tile from a tile matrix to the desired projection
 */
@implementation GPKGTileCreator

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (NSNumber *) width andHeight: (NSNumber *) height andProjection: (GPKGProjection *) requestProjection{
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

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andProjection: (GPKGProjection *) requestProjection{
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

-(GPKGProjection *) requestProjection{
    return _requestProjection;
}

-(GPKGProjection *) tilesProjection{
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
    GPKGProjectionTransform * transformRequestToTiles = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.tilesProjection];
    GPKGBoundingBox * tilesBoundingBox = [transformRequestToTiles transformWithBoundingBox:requestBoundingBox];
    
    GPKGTileMatrix * tileMatrix = [self getTileMatrix:tilesBoundingBox];
    
    GPKGResultSet * tileResults = [self retrieveTileResultsWithBoundingBox:tilesBoundingBox andTileMatrix:tileMatrix];
    if(tileResults != nil){
        
        @try{
            hasTile = tileResults.count > 0;
        } @finally{
            [tileResults close];
        }
    }
    
    return hasTile;
}

-(GPKGGeoPackageTile *) getTileWithBoundingBox: (GPKGBoundingBox *) requestBoundingBox{
    
    GPKGGeoPackageTile * tile = nil;
    
    // Transform to the projection of the tiles
    GPKGProjectionTransform * transformRequestToTiles = [[GPKGProjectionTransform alloc] initWithFromProjection:self.requestProjection andToProjection:self.tilesProjection];
    GPKGBoundingBox * tilesBoundingBox = [transformRequestToTiles transformWithBoundingBox:requestBoundingBox];
    
    GPKGTileMatrix * tileMatrix = [self getTileMatrix:tilesBoundingBox];
    
    GPKGResultSet * tileResults = [self retrieveTileResultsWithBoundingBox:tilesBoundingBox andTileMatrix:tileMatrix];
    if(tileResults != nil){
        
        @try{
            
            if(tileResults.count > 0){
                
                GPKGBoundingBox * requestProjectedBoundingBox = [transformRequestToTiles transformWithBoundingBox:requestBoundingBox];
                
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
    
    return tile;
}

-(UIImage *) drawTileWithTileMatrix: (GPKGTileMatrix *) tileMatrix andResults: (GPKGResultSet *) tileResults andBoundingBox: (GPKGBoundingBox *) requestProjectedBoundingBox andWidth: (int) width andHeight: (int) height{
    
    // Get the GeoPackage tile dimensions
    int tileWidth = [tileMatrix.tileWidth intValue];
    int tileHeight = [tileMatrix.tileHeight intValue];
    
    // Draw the resulting image with the matching tiles
    UIGraphicsBeginImageContext(CGSizeMake(tileWidth, tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    while([tileResults moveToNext]){
        
        // Get the next tile
        GPKGTileRow * tileRow = [self.tileDao getTileRow:tileResults];
        UIImage * tileDataImage = [tileRow getTileDataImage];
        
        // Get the bounding box of the tile
        GPKGBoundingBox * tileBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.tileSetBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
        
        // Get the bounding box where the requested image and tile overlap
        GPKGBoundingBox * overlap = [GPKGTileBoundingBoxUtils overlapWithBoundingBox:requestProjectedBoundingBox andBoundingBox:tileBoundingBox];
        
        // If the tile overlaps with the requested box
        if(overlap != nil){
            
            // Get the rectangle of the tile image to draw
            CGRect src = [GPKGTileBoundingBoxUtils getRoundedRectangleWithWidth:tileWidth andHeight:tileHeight andBoundingBox:tileBoundingBox andSection:overlap];
            
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

-(UIImage *) reprojectTileWithImage: (UIImage *) tile andWidth: (int) requestedTileWidth andHeight: (int) requestedTileHeight andBoundingBox: (GPKGBoundingBox *) requestBoundingBox andTransform: (GPKGProjectionTransform *) transformRequestToTiles andBoundingBox: (GPKGBoundingBox *) tilesBoundingBox{
    
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
    
    // Draw the new tile image
    CGColorSpaceRef projectedTileColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef projectedContext = CGBitmapContextCreate(&projectedPixels[0], requestedTileWidth, requestedTileHeight, 8, 4 * requestedTileWidth, projectedTileColorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef projectedImageRef = CGBitmapContextCreateImage(projectedContext);
    UIImage * projectedTileImage = [[UIImage alloc] initWithCGImage:projectedImageRef];
    CGColorSpaceRelease(projectedTileColorSpace);
    CGContextRelease(projectedContext);
    
    return projectedTileImage;
}

-(GPKGTileMatrix *) getTileMatrix: (GPKGBoundingBox *) projectedRequestBoundingBox{

    GPKGTileMatrix * tileMatrix = nil;
    
    // Check if the request overlaps the tile matrix set
    if([GPKGTileBoundingBoxUtils overlapWithBoundingBox:projectedRequestBoundingBox andBoundingBox:self.tileSetBoundingBox] != nil){
        
        // Get the tile distance
        double distance = [projectedRequestBoundingBox.maxLongitude doubleValue]
            - [projectedRequestBoundingBox.minLongitude doubleValue];
        
        // Get the zoom level to request based upon the tile size
        NSNumber * zoomLevel = [self.tileDao getZoomLevelWithLength:distance];
        
        // If there is a matching zoom level
        if (zoomLevel != nil) {
            tileMatrix = [self.tileDao getTileMatrixWithZoomLevel:[zoomLevel intValue]];
        }
    }
    
    return tileMatrix;
    
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
