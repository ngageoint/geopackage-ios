//
//  GPKGFeatureTiles.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTiles.h"
#import "GPKGImageConverter.h"
#import "GPKGTileBoundingBoxUtils.h"
@import MapKit;
#import "WKBPoint.h"
#import "GPKGProjectionTransform.h"
#import "GPKGMapPoint.h"

@interface GPKGFeatureTiles ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGFeatureTiles

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        
        self.tileWidth = 256; //TODO
        self.tileHeight = 256; //TODO
        
        self.compressFormat = GPKG_CF_PNG; //TODO
        
        // TODO
        
        self.pointRadius = 2.0; //TODO
        
        self.fillPolygon = false; //TODO
        
        [self calculateDrawOverlap];
    }
    return self;
}

-(void) calculateDrawOverlap{
    
    //TODO
    self.heightOverlap = self.pointRadius;
    self.widthOverlap = self.widthOverlap;
    
}

-(void) setDrawOverlapsWithPixels: (double) pixels{
    [self setWidthOverlap:pixels];
    [self setHeightOverlap:pixels];
}

-(NSData *) drawTileDataWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    UIImage * image = [self drawTileWithX:x andY:y andZoom:zoom];
    
    // Convert the image to bytes
    NSData * tileData = [GPKGImageConverter toData:image andFormat:self.compressFormat];
    
    return tileData;
}

-(UIImage *) drawTileWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    UIImage * image = nil;
    if(self.indexQuery){
        image = [self drawTileQueryIndexWithX:x andY:y andZoom:zoom];
    }else{
        image = [self drawTileQueryAllWithX:x andY:y andZoom:zoom];
    }
    return image;
}

-(UIImage *) drawTileQueryIndexWithX: (int) x andY: (int) y andZoom: (int) zoom{
    return nil; // TODO
}

-(UIImage *) drawTileQueryAllWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    // Query for all features
    GPKGResultSet * results = [self.featureDao queryForAll];
    
    // Draw the tile image
    UIImage * image = [self drawTileWithBoundingBox:boundingBox andResults:results];
    
    return image;
}

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andResults: (GPKGResultSet *) results{
    
    UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // TODO
   // CGContextFillEl
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andFeatureRows: (NSArray *) featureRows{
    return nil; // TODO
}

-(void) drawPointWithBoundingBox: (GPKGBoundingBox *) boundingBox andTransform: (GPKGProjectionTransform *) transform andContext: (CGContextRef) context andPoint: (GPKGMapPoint *) point{
    
    WKBPoint * wkbPoint = [self getPointWithTransform:transform andPoint:point];
    double x = [GPKGTileBoundingBoxUtils getXPixelWithWidth:self.tileWidth andBoundingBox:boundingBox andLongitude:[wkbPoint.x doubleValue]];
    double y = [GPKGTileBoundingBoxUtils getYPixelWithHeight:self.tileHeight andBoundingBox:boundingBox andLatitude:[wkbPoint.y doubleValue]];
    
    // TODO point icon ?
    
    if(x >= 0 - self.pointRadius && x <= self.tileWidth + self.pointRadius && y >= 0 - self.pointRadius && y <= self.tileHeight + self.pointRadius){
        // setup the circle size
        CGRect circleRect = CGRectMake( 0, 0, self.pointRadius, self.pointRadius );
        circleRect = CGRectInset(circleRect, x, y);
        
        // Draw the Circle
        CGContextFillEllipseInRect(context, circleRect);
        CGContextStrokeEllipseInRect(context, circleRect);
    }
}

-(WKBPoint *) getPointWithTransform: (GPKGProjectionTransform *) transform andPoint: (GPKGMapPoint *) point{
    NSArray * lonLat = [transform transformWithX:point.coordinate.longitude andY:point.coordinate.latitude];
    return [[WKBPoint alloc] initWithX:(NSDecimalNumber *)lonLat[0] andY:(NSDecimalNumber *)lonLat[1]];
}

// TODO

// TODO MKShape

@end
