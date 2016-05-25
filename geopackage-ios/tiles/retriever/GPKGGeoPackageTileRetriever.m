//
//  GPKGGeoPackageTileRetriever.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeoPackageTileRetriever.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGGeoPackageTile.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGImageConverter.h"

@interface GPKGGeoPackageTileRetriever ()

@property (nonatomic, strong) GPKGTileDao *tileDao;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) GPKGBoundingBox * setWebMercatorBoundingBox;

@end

@implementation GPKGGeoPackageTileRetriever

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao{
    self = [super init];
    if(self != nil){
        self.tileDao = tileDao;
        [tileDao adjustTileMatrixLengths];
        
        GPKGTileMatrixSetDao * tileMatrixSetDao = [[GPKGTileMatrixSetDao alloc] initWithDatabase: self.tileDao.database];
        GPKGProjection * projection = [tileMatrixSetDao getProjection:tileDao.tileMatrixSet];
        
        GPKGProjectionTransform * projectionToWebMercator = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        
        GPKGTileMatrixSet * tileMatrixSet = tileDao.tileMatrixSet;
        GPKGBoundingBox * setProjectionBoundingBox = [tileMatrixSet getBoundingBox];
        self.setWebMercatorBoundingBox = [projectionToWebMercator transformWithBoundingBox:setProjectionBoundingBox];
    }
    return self;
}

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height{
    self = [self initWithTileDao:tileDao];
    if(self != nil){
        self.width = [NSNumber numberWithInt:width];
        self.height = [NSNumber numberWithInt:height];
    }
    return self;
}

-(GPKGBoundingBox *) getWebMercatorBoundingBox{
    return self.setWebMercatorBoundingBox;
}

-(BOOL) hasTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    BOOL hasTile = false;
    
    // Get the bounding box of the requested tile
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    GPKGTileMatrix * tileMatrix = [self getTileMatrixWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    GPKGResultSet * tileResults = [self retrieveTileResultsWithWebMercatorBoundingBox:webMercatorBoundingBox andTileMatrix:tileMatrix];
    if(tileResults != nil){
        
        @try{
            hasTile = [tileResults count] > 0;
        }@finally{
            [tileResults close];
        }
        
    }
    
    return hasTile;
}

-(GPKGGeoPackageTile *) getTileWithX: (NSInteger) x andY: (NSInteger) y andZoom: (NSInteger) zoom{
    
    GPKGGeoPackageTile * tile = nil;
    
    // Get the bounding box of the requested tile
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:(int)x andY:(int)y andZoom:(int)zoom];
    
    GPKGTileMatrix * tileMatrix = [self getTileMatrixWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    GPKGResultSet * tileResults = [self retrieveTileResultsWithWebMercatorBoundingBox:webMercatorBoundingBox andTileMatrix:tileMatrix];
    if(tileResults != nil){
        
        @try{
            
            if([tileResults count] > 0){
                
                // Get the requested tile dimensions
                int tileWidth = [tileMatrix.tileWidth intValue];
                int tileHeight = [tileMatrix.tileHeight intValue];
                
                // Draw the resulting image with the matching tiles
                UIGraphicsBeginImageContext(CGSizeMake(tileWidth, tileHeight));
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                // Draw from the top left
                CGContextTranslateCTM(context, 0, tileHeight);
                CGContextScaleCTM(context, 1.0, -1.0);
                
                while([tileResults moveToNext]){
                    
                    // Get the next tile
                    GPKGTileRow * tileRow = [self.tileDao getTileRow:tileResults];
                    UIImage * tileDataImage = [tileRow getTileDataImage];
                    
                    // Get the bounding box of the tile
                    GPKGBoundingBox * tileWebMercatorBoundingBox = [GPKGTileBoundingBoxUtils getBoundingBoxWithTotalBoundingBox:self.setWebMercatorBoundingBox andTileMatrix:tileMatrix andTileColumn:[tileRow getTileColumn] andTileRow:[tileRow getTileRow]];
                    
                    // Get the bounding box where the requested image and tile overlap
                    GPKGBoundingBox * overlap = [GPKGTileBoundingBoxUtils overlapWithBoundingBox:webMercatorBoundingBox andBoundingBox:tileWebMercatorBoundingBox];
                    
                    // If the tile overlaps with the requested box
                    if(overlap != nil){
                        
                        // Find the offset of where to draw the tile
                        double xOffset = [GPKGTileBoundingBoxUtils getXPixelWithWidth:tileWidth andBoundingBox:webMercatorBoundingBox andLongitude:[tileWebMercatorBoundingBox.minLongitude doubleValue]];
                        double yOffset = [GPKGTileBoundingBoxUtils getYPixelWithHeight:tileHeight andBoundingBox:webMercatorBoundingBox andLatitude:[tileWebMercatorBoundingBox.maxLatitude doubleValue]];
                        
                        // Draw the image
                        CGRect imageRect = CGRectMake(xOffset, yOffset, tileDataImage.size.width, tileDataImage.size.height);
                        CGContextDrawImage(context, imageRect, tileDataImage.CGImage);
                    }
                }
                
                // Create the tile
                UIImage *tileImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                if(tileImage != nil){
                    
                    // Scale the image if needed
                    if((self.width != nil && [self.width intValue] != tileWidth) || (self.height != nil && [self.height intValue] != tileHeight)){
                        int scaledTileWidth = self.width != nil ? [self.width intValue] : [tileMatrix.tileWidth intValue];
                        int scaledTileHeight = self.height != nil ? [self.height intValue] : [tileMatrix.tileHeight intValue];
                        CGSize scaledSize = CGSizeMake(scaledTileWidth, scaledTileHeight);
                        UIGraphicsBeginImageContext(scaledSize);
                        [tileImage drawInRect:CGRectMake(0,0,scaledSize.width,scaledSize.height)];
                        tileImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                    }
                    
                    NSData * tileData = [GPKGImageConverter toData:tileImage andFormat:GPKG_CF_PNG];
                    tile = [[GPKGGeoPackageTile alloc] initWithWidth:(self.width != nil ? [self.width intValue] : tileWidth) andHeight:(self.height != nil ? [self.height intValue] : tileHeight) andData:tileData];
                }
            }
            
        }@finally{
            [tileResults close];
        }
        
    }
    
    return tile;
}

-(GPKGTileMatrix *) getTileMatrixWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    
    GPKGTileMatrix * tileMatrix = nil;
    
    // Check if the request overlaps the tile matrix set
    if([GPKGTileBoundingBoxUtils overlapWithBoundingBox:webMercatorBoundingBox andBoundingBox:self.setWebMercatorBoundingBox] != nil){
        
        // Get the tile distance
        double distance = [webMercatorBoundingBox.maxLongitude doubleValue] - [webMercatorBoundingBox.minLongitude doubleValue];
        
        // Get the zoom level to request based upon the tile size
        NSNumber * zoomLevel = [self.tileDao getZoomLevelWithLength:distance];
        
        // If there is a matching zoom level
        if(zoomLevel != nil){
            tileMatrix = [self.tileDao getTileMatrixWithZoomLevel:[zoomLevel intValue]];
        }
    }
    
    return tileMatrix;
}

-(GPKGResultSet *) retrieveTileResultsWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andTileMatrix: (GPKGTileMatrix *) tileMatrix{
    
    GPKGResultSet * tileResults = nil;
    
    if(tileMatrix != nil){
        
        // Get the grid
        GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridWithTotalBoundingBox:self.setWebMercatorBoundingBox andMatrixWidth:[tileMatrix.matrixWidth intValue] andMatrixHeight:[tileMatrix.matrixHeight intValue] andBoundingBox:webMercatorBoundingBox];
        
        // Query for matching tiles in the tile grid
        tileResults = [self.tileDao queryByTileGrid:tileGrid andZoomLevel:[tileMatrix.zoomLevel intValue]];
        
    }
    
    return tileResults;
}

@end
