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
#import "SFPoint.h"
#import "SFPProjectionTransform.h"
#import "GPKGMapPoint.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "SFPProjectionConstants.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGMultiPolyline.h"
#import "GPKGMultiPolygon.h"
#import "SFPProjectionFactory.h"
#import "SFGeometryEnvelopeBuilder.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGFeatureTiles ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong) SFPProjectionTransform *wgs84ToWebMercatorTransform;

@end

@implementation GPKGFeatureTiles

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        
        self.tileWidth = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_WIDTH] intValue];
        self.tileHeight = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_HEIGHT] intValue];
        
        self.compressFormat = [GPKGCompressFormats fromName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_COMPRESS_FORMAT]];
        
        self.pointRadius = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POINT_RADIUS] doubleValue];
        
        self.lineStrokeWidth = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_LINE_STROKE_WIDTH] doubleValue];;
        
        self.polygonStrokeWidth = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POLYGON_STROKE_WIDTH] doubleValue];;
        
        self.fillPolygon = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POLYGON_FILL];
        
        self.wgs84ToWebMercatorTransform = [[SFPProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        
        [self calculateDrawOverlap];
    }
    return self;
}

-(GPKGFeatureDao *) getFeatureDao{
    return self.featureDao;
}

-(void) close{
    if(self.indexManager != nil){
        [self.indexManager close];
    }
}

-(void) calculateDrawOverlap{
    
    if(self.pointIcon != nil){
        self.heightOverlap = [self.pointIcon getHeight];
        self.widthOverlap = [self.pointIcon getWidth];
    }else{
        self.heightOverlap = self.pointRadius;
        self.widthOverlap = self.pointRadius;
    }
    
    double lineHalfStroke = self.lineStrokeWidth / 2.0;
    self.heightOverlap = MAX(self.heightOverlap, lineHalfStroke);
    self.widthOverlap = MAX(self.widthOverlap, lineHalfStroke);
    
    double polygonHalfStroke = self.polygonStrokeWidth / 2.0;
    self.heightOverlap = MAX(self.heightOverlap, polygonHalfStroke);
    self.widthOverlap = MAX(self.widthOverlap, polygonHalfStroke);
}

-(void) setDrawOverlapsWithPixels: (double) pixels{
    [self setWidthOverlap:pixels];
    [self setHeightOverlap:pixels];
}

-(BOOL) isIndexQuery{
    return self.indexManager != nil && [self.indexManager isIndexed];
}

-(NSData *) drawTileDataWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    UIImage * image = [self drawTileWithX:x andY:y andZoom:zoom];
    
    NSData * tileData = nil;
    
    // Convert the image to bytes
    if(image != nil){
        tileData = [GPKGImageConverter toData:image andFormat:self.compressFormat];
    }
    
    return tileData;
}

-(UIImage *) drawTileWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    UIImage * image = nil;
    @try {
        if([self isIndexQuery]){
            image = [self drawTileQueryIndexWithX:x andY:y andZoom:zoom];
        }else{
            image = [self drawTileQueryAllWithX:x andY:y andZoom:zoom];
        }
    }
    @catch (NSException *e) {
        NSLog(@"Failed to draw tile from feature table %@. x: %d, y: %d, z: %d. Error: %@", self.featureDao.tableName, x, y, zoom, [e description]);
    }
    return image;
}

-(UIImage *) drawTileQueryIndexWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    // Get the web mercator bounding box
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    UIImage *image = nil;
    
    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults * results = [self queryIndexedFeaturesWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    @try {
        
        int tileCount = results.count;
        
        // Draw if at least one geometry exists
        if(tileCount > 0){
            
            if(self.maxFeaturesPerTile == nil || tileCount <= [self.maxFeaturesPerTile intValue]){
                
                // Create image
                UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
                GPKGBoundingBox *expandedBoundingBox  = [self expandBoundingBox:webMercatorBoundingBox];
                
                // Set the simplify tolerance for simplifying geometries to similar curves with fewer points
                double simplifyTolerance = [GPKGTileBoundingBoxUtils toleranceDistanceWithZoom:zoom andPixelWidth:self.tileWidth andPixelHeight:self.tileHeight];
                [converter setSimplifyToleranceAsDouble:simplifyTolerance];
                
                BOOL drawn = NO;
                for(GPKGFeatureRow * featureRow in results){
                    if([self drawFeatureWithBoundingBox:webMercatorBoundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:featureRow andShapeConverter:converter]){
                        drawn = YES;
                    }
                }
                
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                if(!drawn){
                    image = nil;
                }
                
            } else if(self.maxFeaturesTileDraw != nil){
                
                // Draw the max features tile
                image = [self.maxFeaturesTileDraw drawTileWithTileWidth:self.tileWidth andTileHeight:self.tileHeight andTileFeatureCount:tileCount andFeatureIndexResults:results];
            }
        }
    }
    @catch (NSException *e) {
        NSLog(@"Failed to draw tile from feature table %@ querying indexed results. x: %d, y: %d, z: %d. Error: %@", self.featureDao.tableName, x, y, zoom, [e description]);
    }
    @finally {
        [results close];
    }

    return image;
}

-(int) queryIndexedFeaturesCountWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    // Get the web mercator bounding box
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults * results = [self queryIndexedFeaturesWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    int count = 0;
    
    @try {
        count = [results count];
    }
    @finally {
        [results close];
    }
    
    return count;
}

-(GPKGFeatureIndexResults *) queryIndexedFeaturesWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    
    // Create an expanded bounding box to handle features outside the tile that overlap
    GPKGBoundingBox *expandedQueryBoundingBox = [self expandBoundingBox:webMercatorBoundingBox];
    
    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults * results = [self.indexManager queryWithBoundingBox:expandedQueryBoundingBox inProjection:[SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
    
    return results;
}

-(GPKGBoundingBox *) expandBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    
    // Create an expanded bounding box to handle features outside the tile that overlap
    double minLongitude = [GPKGTileBoundingBoxUtils getLongitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andPixel:(0 - self.widthOverlap)];
    double maxLongitude = [GPKGTileBoundingBoxUtils getLongitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andPixel:(self.tileWidth + self.widthOverlap)];
    double maxLatitude = [GPKGTileBoundingBoxUtils getLatitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andPixel:(0 - self.heightOverlap)];
    double minLatitude = [GPKGTileBoundingBoxUtils getLatitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andPixel:(self.tileHeight + self.heightOverlap)];
    GPKGBoundingBox * expandedQueryBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    return expandedQueryBoundingBox;
}

-(UIImage *) drawTileQueryAllWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    UIImage * image = nil;
    
    // Query for all features
    GPKGResultSet * results = [self.featureDao queryForAll];
    
    @try {
        
        int totalCount = results.count;

        // Draw if at least one geometry exists
        if(totalCount > 0){
        
            if(self.maxFeaturesPerTile == nil || totalCount <= [self.maxFeaturesPerTile intValue]){
                
                // Draw the tile image
                image = [self drawTileWithBoundingBox:boundingBox andResults:results];
                
            } else if(self.maxFeaturesTileDraw != nil){
                
                // Draw the unindexed max features tile
                image = [self.maxFeaturesTileDraw drawUnindexedTileWithTileWidth:self.tileWidth andTileHeight:self.tileHeight andTotalFeatureCount:totalCount andFeatureDao:self.featureDao andResults:results];
            }
            
        }
    }
    @catch (NSException *e) {
        NSLog(@"Failed to draw tile from feature table %@ querying all results. x: %d, y: %d, z: %d. Error: %@", self.featureDao.tableName, x, y, zoom, [e description]);
    }
    @finally {
        [results close];
    }
    
    return image;
}

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andResults: (GPKGResultSet *) results{
    
    UIImage *image = nil;
    
    @try{
        UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
        GPKGBoundingBox *expandedBoundingBox  = [self expandBoundingBox:boundingBox];
        
        BOOL drawn = NO;
        while([results moveToNext]){
            GPKGFeatureRow * row = [self.featureDao getFeatureRow:results];
            if([self drawFeatureWithBoundingBox:boundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:row andShapeConverter:converter]){
                drawn = YES;
            }
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if(!drawn){
            image = nil;
        }
        
    }@finally{
        [results close];
    }
    
    return image;
}

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andFeatureRows: (NSArray *) featureRows{
    
    UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
    GPKGBoundingBox *expandedBoundingBox  = [self expandBoundingBox:boundingBox];
    
    BOOL drawn = NO;
    for(GPKGFeatureRow * row in featureRows){
        if([self drawFeatureWithBoundingBox:boundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:row andShapeConverter:converter]){
            drawn = YES;
        }
    }
        
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(!drawn){
        image = nil;
    }
    
    return image;
}

-(BOOL) drawFeatureWithBoundingBox: (GPKGBoundingBox *) boundingBox andExpandedBoundingBox: (GPKGBoundingBox *) expandedBoundingBox andContext: (CGContextRef) context andRow: (GPKGFeatureRow *) row andShapeConverter: (GPKGMapShapeConverter *) converter{
    
    BOOL drawn = NO;
    
    @try{
        GPKGGeometryData * geomData = [row getGeometry];
        if(geomData != nil){
            SFGeometry * geometry = geomData.geometry;
            if(geometry != nil){
                
                SFGeometryEnvelope *envelope = [geomData getOrBuildEnvelope];
                GPKGBoundingBox *geometryBoundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:envelope];
                GPKGBoundingBox *transformedBoundingBox = [converter boundingBoxToWebMercator:geometryBoundingBox];
                
                if([expandedBoundingBox intersects:transformedBoundingBox withAllowEmpty:YES]){
                
                    GPKGMapShape * shape = [converter toShapeWithGeometry:geometry];
                    [self drawShapeWithBoundingBox:boundingBox andContext:context andMapShape:shape];
                
                    drawn = YES;
                }
            }
        }
    }@catch (NSException *e) {
        NSLog(@"Failed to draw feature in tile. Table: %@", self.featureDao.tableName);
    }
    
    return drawn;
}

-(void) drawShapeWithBoundingBox: (GPKGBoundingBox *) boundingBox andContext: (CGContextRef) context andMapShape: (GPKGMapShape *) shape{
    
    NSObject * shapeObject = shape.shape;
    
    switch(shape.shapeType){
            
        case GPKG_MST_POINT:
            {
                GPKGMapPoint * point = (GPKGMapPoint *) shapeObject;
                [self drawPointWithBoundingBox:boundingBox andContext:context andPoint:point];
            }
            break;
        case GPKG_MST_POLYLINE:
            {
                MKPolyline * polyline = (MKPolyline *) shapeObject;
                CGMutablePathRef linePath = CGPathCreateMutable();
                [self addPolyline:polyline toPath:linePath withBoundingBox:boundingBox];
                [self drawLinePath:linePath andContext:context];
            }
            break;
        case GPKG_MST_POLYGON:
            {
                MKPolygon * polygon = (MKPolygon *) shapeObject;
                CGMutablePathRef polygonPath = CGPathCreateMutable();
                [self addPolygon:polygon toPath:polygonPath withBoundingBox:boundingBox];
                [self drawPolygonPath:polygonPath andContext:context];
            }
            break;
        case GPKG_MST_MULTI_POINT:
            {
                GPKGMultiPoint * multiPoint = (GPKGMultiPoint *) shapeObject;
                for(GPKGMapPoint * point in multiPoint.points){
                    [self drawPointWithBoundingBox:boundingBox andContext:context andPoint:point];
                }
            }
            break;
        case GPKG_MST_MULTI_POLYLINE:
            {
                GPKGMultiPolyline * multiPolyline = (GPKGMultiPolyline *) shapeObject;
                for(MKPolyline * polyline in multiPolyline.polylines){
                    CGMutablePathRef multiLinePath = CGPathCreateMutable();
                    [self addPolyline:polyline toPath:multiLinePath withBoundingBox:boundingBox];
                    [self drawLinePath:multiLinePath andContext:context];
                }
            }
            break;
        case GPKG_MST_MULTI_POLYGON:
            {
                GPKGMultiPolygon * multiPolygon = (GPKGMultiPolygon *) shapeObject;
                CGMutablePathRef multiPolygonPath = CGPathCreateMutable();
                for(MKPolygon * polygon in multiPolygon.polygons){
                    [self addPolygon:polygon toPath:multiPolygonPath withBoundingBox:boundingBox];
                }
                [self drawPolygonPath:multiPolygonPath andContext:context];
            }
            break;
        case GPKG_MST_COLLECTION:
            {
                NSArray * shapes = (NSArray *) shapeObject;
                for(GPKGMapShape * arrayShape in shapes){
                    [self drawShapeWithBoundingBox:boundingBox andContext:context andMapShape:arrayShape];
                }
            }
            break;
        default:
            [NSException raise:@"Shape Type" format:@"Unsupported shape type: %@", [GPKGMapShapeTypes name:shape.shapeType]];
            
    }
}

-(void) drawLinePath: (CGMutablePathRef) path andContext: (CGContextRef) context{
    CGContextSetLineWidth(context, self.lineStrokeWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextAddPath(context, path);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
}

-(void) drawPolygonPath: (CGMutablePathRef) path andContext: (CGContextRef) context{
    CGContextSetLineWidth(context, self.polygonStrokeWidth);
    CGContextSetStrokeColorWithColor(context, self.polygonColor.CGColor);
    CGContextSetFillColorWithColor(context, self.polygonFillColor.CGColor);
    CGContextAddPath(context, path);
    CGPathDrawingMode mode;
    if(self.fillPolygon){
        mode = kCGPathEOFillStroke;
    }else{
        mode = kCGPathStroke;
    }
    CGContextDrawPath(context, mode);
    CGPathRelease(path);
}

-(void) addPolyline: (MKPolyline *) polyline toPath: (CGMutablePathRef) path withBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    if(polyline.pointCount >= 2){
        [self addMultiPoint:polyline toPath:path withBoundingBox:boundingBox];
    }
}

-(void) addPolygon: (MKPolygon *) polygon toPath: (CGMutablePathRef) path withBoundingBox: (GPKGBoundingBox *) boundingBox{

    
        if(polygon.pointCount >= 2){
            [self addRing:polygon toPath:path withBoundingBox:boundingBox];
            
            for(MKPolygon * hole in polygon.interiorPolygons){
                if(hole.pointCount >= 2){
                    [self addRing:hole toPath:path withBoundingBox:boundingBox];
                }
            }
        }
}

-(void) addRing: (MKPolygon *) ring toPath: (CGMutablePathRef) path withBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    [self addMultiPoint:ring toPath:path withBoundingBox:boundingBox];
    CGPathCloseSubpath(path);
}

-(void) addMultiPoint: (MKMultiPoint *) multiPoint toPath: (CGMutablePathRef) path withBoundingBox: (GPKGBoundingBox *) boundingBox{

    for(int i = 0; i < multiPoint.pointCount; i++){
        MKMapPoint mkMapPoint = multiPoint.points[i];
        GPKGMapPoint * mapPoint = [[GPKGMapPoint alloc] initWithMKMapPoint:mkMapPoint];
        SFPoint *sfPoint = [self transformPointWithMapPoint:mapPoint];
        double x = [GPKGTileBoundingBoxUtils getXPixelWithWidth:self.tileWidth andBoundingBox:boundingBox andLongitude:[sfPoint.x doubleValue]];
        double y = [GPKGTileBoundingBoxUtils getYPixelWithHeight:self.tileHeight andBoundingBox:boundingBox andLatitude:[sfPoint.y doubleValue]];
        if(i == 0){
            CGPathMoveToPoint(path, NULL, x, y);
        }else{
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
}

-(void) drawPointWithBoundingBox: (GPKGBoundingBox *) boundingBox andContext: (CGContextRef) context andPoint: (GPKGMapPoint *) point{
    
    SFPoint * sfPoint = [self transformPointWithMapPoint:point];
    double x = [GPKGTileBoundingBoxUtils getXPixelWithWidth:self.tileWidth andBoundingBox:boundingBox andLongitude:[sfPoint.x doubleValue]];
    double y = [GPKGTileBoundingBoxUtils getYPixelWithHeight:self.tileHeight andBoundingBox:boundingBox andLatitude:[sfPoint.y doubleValue]];
    
    if(self.pointIcon != nil){
        
        int width = [self.pointIcon getWidth];
        int height = [self.pointIcon getHeight];
        if(x >= 0 - width && x <= self.tileWidth + width && y >= 0 - height && y <= self.tileHeight + height){
            CGRect rect = CGRectMake(x - self.pointIcon.xOffset, y - self.pointIcon.yOffset, width, height);
            [self.pointIcon.getIcon drawInRect:rect];
        }
    
    }else{
        if(x >= 0 - self.pointRadius && x <= self.tileWidth + self.pointRadius && y >= 0 - self.pointRadius && y <= self.tileHeight + self.pointRadius){
            
            double pointDiameter = self.pointRadius * 2;
            CGRect circleRect = CGRectMake(x - self.pointRadius, y - self.pointRadius, pointDiameter, pointDiameter);
        
            // Draw the Circle
            CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
            CGContextFillEllipseInRect(context, circleRect);
        }
    }
}

-(SFPoint *) transformPointWithMapPoint: (GPKGMapPoint *) point{
    NSArray * lonLat = [self.wgs84ToWebMercatorTransform transformWithX:point.coordinate.longitude andY:point.coordinate.latitude];
    return [[SFPoint alloc] initWithX:(NSDecimalNumber *)lonLat[0] andY:(NSDecimalNumber *)lonLat[1]];
}

@end
