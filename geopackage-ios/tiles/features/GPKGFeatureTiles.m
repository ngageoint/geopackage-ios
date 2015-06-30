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
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGProjectionConstants.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGMetadataDb.h"

@interface GPKGFeatureTiles ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGFeatureTiles

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        
        self.tileWidth = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_WIDTH] intValue];
        self.tileHeight = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_HEIGHT] intValue];
        
        self.compressFormat = [GPKGCompressFormats fromName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_COMPRESS_FORMAT]];
        
        // TODO draw styles, color, anti alias, etc
        
        self.pointRadius = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POINT_RADIUS] doubleValue];
        
        self.fillPolygon = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POLYGON_FILL];
        
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
    
    // Get the web mercator bounding box
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils getWebMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    // Create an expanded bounding box to handle features outside the tile that overlap
    double minLongitude = [GPKGTileBoundingBoxUtils getLongitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andPixel:(0 - self.widthOverlap)];
    double maxLongitude = [GPKGTileBoundingBoxUtils getLongitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andPixel:(self.tileWidth + self.widthOverlap)];
    double maxLatitude = [GPKGTileBoundingBoxUtils getLatitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andPixel:(0 - self.heightOverlap)];
    double minLatitude = [GPKGTileBoundingBoxUtils getLatitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andPixel:(self.tileHeight + self.heightOverlap)];
    GPKGBoundingBox * expandedQueryBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    
    // Convert to the projection bounding box to query the index
    GPKGProjectionTransform * webMercatorToProjectionTransform = [[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WEB_MERCATOR andToProjection:self.featureDao.projection];
    GPKGBoundingBox * projectionBoundingBox = [webMercatorToProjectionTransform transformWithBoundingBox:expandedQueryBoundingBox];
    
    // Create image
    UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // WGS84 to web mercator projection and shape converter
    GPKGProjectionTransform * wgs84ToWebMercatorTransform =[[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
    
    GPKGMetadataDb * db = [[GPKGMetadataDb alloc] init];
    @try{
        // Query for geometries matching the bounds in the index
        GPKGGeometryMetadataDao * dao = [db getGeometryMetadataDao];
        GPKGResultSet * results = [dao queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:projectionBoundingBox];
        @try{
            while([results moveToNext]){
                GPKGGeometryMetadata * metadata = (GPKGGeometryMetadata *) [dao getObject:results];
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao queryForIdObject:metadata.id];
                [self drawFeatureWithBoundingBox:webMercatorBoundingBox andTransform:wgs84ToWebMercatorTransform andContext:context andRow:row andShapeConverter:converter];
            }
        }@finally{
            [results close];
        }
    }@finally{
        [db close];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
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
    
    UIImage *image = nil;
    
    @try{
        UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        GPKGProjectionTransform * wgs84ToWebMercatorTransform =[[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
        
        while([results moveToNext]){
            GPKGFeatureRow * row = [self.featureDao getFeatureRow:results];
            [self drawFeatureWithBoundingBox:boundingBox andTransform:wgs84ToWebMercatorTransform andContext:context andRow:row andShapeConverter:converter];
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext();
    }@finally{
        [results close];
    }
    
    return image;
}

-(UIImage *) drawTileWithBoundingBox: (GPKGBoundingBox *) boundingBox andFeatureRows: (NSArray *) featureRows{
    
    UIGraphicsBeginImageContext(CGSizeMake(self.tileWidth, self.tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
        
    GPKGProjectionTransform * wgs84ToWebMercatorTransform =[[GPKGProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    GPKGMapShapeConverter * converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
        
    for(GPKGFeatureRow * row in featureRows){
        [self drawFeatureWithBoundingBox:boundingBox andTransform:wgs84ToWebMercatorTransform andContext:context andRow:row andShapeConverter:converter];
    }
        
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    return image;
}

-(void) drawFeatureWithBoundingBox: (GPKGBoundingBox *) boundingBox andTransform: (GPKGProjectionTransform *) transform andContext: (CGContextRef) context andRow: (GPKGFeatureRow *) row andShapeConverter: (GPKGMapShapeConverter *) converter{
    GPKGGeometryData * geomData = [row getGeometry];
    if(geomData != nil){
        WKBGeometry * geometry = geomData.geometry;
        if(geometry != nil){
            GPKGMapShape * shape = [converter toShapeWithGeometry:geometry];
            [self drawShapeWithBoundingBox:boundingBox andTransform:transform andContext:context andMapShape:shape];
        }
    }
}

-(void) drawShapeWithBoundingBox: (GPKGBoundingBox *) boundingBox andTransform: (GPKGProjectionTransform *) transform andContext: (CGContextRef) context andMapShape: (GPKGMapShape *) shape{
    
    NSObject * shapeObject = shape.shape;
    
    switch(shape.shapeType){
            
        case GPKG_MST_POINT:
            {
                GPKGMapPoint * point = (GPKGMapPoint *) shapeObject;
                [self drawPointWithBoundingBox:boundingBox andTransform:transform andContext:context andPoint:point];
            }
            break;
        case GPKG_MST_POLYLINE:
            {
                MKPolyline * polyline = (MKPolyline *) shapeObject;
                //TODO
            }
            break;
        case GPKG_MST_POLYGON:
            {
                MKPolygon * polygon = (MKPolygon *) shapeObject;
                //TODO
            }
            break;
        case GPKG_MST_MULTI_POINT:
            {
                GPKGMultiPoint * multiPoint = (GPKGMultiPoint *) shapeObject;
                for(GPKGMapPoint * point in multiPoint.points){
                    [self drawPointWithBoundingBox:boundingBox andTransform:transform andContext:context andPoint:point];
                }
            }
            break;
        case GPKG_MST_MULTI_POLYLINE:
            //TODO
            break;
        case GPKG_MST_MULTI_POLYGON:
            //TODO
            break;
        case GPKG_MST_COLLECTION:
            //TODO
            break;
        default:
            [NSException raise:@"Shape Type" format:@"Unsupported shape type: %@", [GPKGMapShapeTypes name:shape.shapeType]];
            
    }
}

// TODO

//-(void) addRingWithBoundingBox: (GPKGBoundingBox *) boundingBox andTransform: (GPKGProjectionTransform *) transform

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

@end