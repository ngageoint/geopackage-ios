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
#import "GPKGFeatureTileContext.h"
#import "GPKGTileUtils.h"

@interface GPKGFeatureTiles ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong) SFPProjectionTransform *wgs84ToWebMercatorTransform;
@property (nonatomic) GPKGIconCache *iconCache;
@property (nonatomic, strong) NSCache<NSNumber *, GPKGBoundingBox *> *boundingBoxCache;
@property (nonatomic, strong) NSCache<NSString *, GPKGMapShape *> *mapShapeCache;

@end

@implementation GPKGFeatureTiles

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [self initWithGeoPackage:nil andFeatureDao:featureDao];
    return self;
}

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao andScale: (float) scale{
    self = [self initWithGeoPackage:nil andFeatureDao:featureDao andScale:scale];
    return self;
}

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao andWidth: (int) width andHeight: (int) height{
    self = [self initWithGeoPackage:nil andFeatureDao:featureDao andWidth:width andHeight:height];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    float tileLength = [GPKGTileUtils tileLength];
    self = [self initWithGeoPackage:geoPackage andFeatureDao:featureDao andWidth:tileLength andHeight:tileLength];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao andScale: (float) scale{
    float tileLength = [GPKGTileUtils tileLengthWithScale:scale];
    self = [self initWithGeoPackage:geoPackage andFeatureDao:featureDao andScale:scale andWidth:tileLength andHeight:tileLength];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao andWidth: (int) width andHeight: (int) height{
    self = [self initWithGeoPackage:geoPackage andFeatureDao:featureDao andScale:[UIScreen mainScreen].nativeScale andWidth:width andHeight:height];
    return self;
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao andScale: (float) scale andWidth: (int) width andHeight: (int) height{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        
        self.iconCache = [[GPKGIconCache alloc] init];
        self.cacheBoundingBoxes = YES;
        self.boundingBoxCache = [[NSCache alloc] init];
        [self.boundingBoxCache setCountLimit:DEFAULT_BOUNDING_BOX_CACHE_SIZE];
        self.cacheMapShapes = YES;
        self.mapShapeCache = [[NSCache alloc] init];
        [self.mapShapeCache setCountLimit:DEFAULT_MAP_SHAPE_CACHE_SIZE];
        self.scale = scale;
        self.simplifyGeometries = YES;
        
        self.tileWidth = width;
        self.tileHeight = height;
        
        self.compressFormat = [GPKGCompressFormats fromName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_TILES_COMPRESS_FORMAT]];
        
        self.pointRadius = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POINT_RADIUS] doubleValue];
        
        self.lineStrokeWidth = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_LINE_STROKE_WIDTH] doubleValue];
        
        self.polygonStrokeWidth = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POLYGON_STROKE_WIDTH] doubleValue];
        
        self.fillPolygon = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_FEATURE_TILES andProperty:GPKG_PROP_FEATURE_POLYGON_FILL];
        
        self.wgs84ToWebMercatorTransform = [[SFPProjectionTransform alloc] initWithFromEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        
        if (geoPackage != nil) {
            
            self.indexManager = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
            if(![self.indexManager isIndexed]){
                [self.indexManager close];
                self.indexManager = nil;
            }
            
            self.featureTableStyles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:[featureDao featureTable]];
            if (![self.featureTableStyles has]) {
                self.featureTableStyles = nil;
            }
            
        }
        
        [self calculateDrawOverlap];
    }
    return self;
}

-(void) setScale:(float)scale{
    _scale = scale;
    self.iconCache.scale = scale;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(void) close{
    if(self.indexManager != nil){
        [self.indexManager close];
    }
}

-(void) calculateDrawOverlap{
    
    if(self.pointIcon != nil){
        self.heightOverlap = self.scale * [self.pointIcon height];
        self.widthOverlap = self.scale * [self.pointIcon width];
    }else{
        self.heightOverlap = self.scale * self.pointRadius;
        self.widthOverlap = self.scale * self.pointRadius;
    }
    
    double lineHalfStroke = self.scale * self.lineStrokeWidth / 2.0;
    self.heightOverlap = MAX(self.heightOverlap, lineHalfStroke);
    self.widthOverlap = MAX(self.widthOverlap, lineHalfStroke);
    
    double polygonHalfStroke = self.scale * self.polygonStrokeWidth / 2.0;
    self.heightOverlap = MAX(self.heightOverlap, polygonHalfStroke);
    self.widthOverlap = MAX(self.widthOverlap, polygonHalfStroke);
    
    if(self.featureTableStyles != nil && [self.featureTableStyles has]){
        
        // Style Rows
        NSMutableSet<NSNumber *> *styleRowIds = [[NSMutableSet alloc] init];
        NSArray<NSNumber *> *tableStyleIds = [self.featureTableStyles allTableStyleIds];
        if(tableStyleIds != nil){
            [styleRowIds addObjectsFromArray:tableStyleIds];
        }
        NSArray<NSNumber *> *styleIds = [self.featureTableStyles allStyleIds];
        if(styleIds != nil){
            [styleRowIds addObjectsFromArray:styleIds];
        }
        
        GPKGStyleDao *styleDao = [self.featureTableStyles styleDao];
        for(NSNumber *styleRowId in styleRowIds){
            GPKGStyleRow *styleRow = (GPKGStyleRow *)[styleDao queryForIdObject:styleRowId];
            double styleHalfWidth = self.scale * [styleRow widthOrDefault] / 2.0;
            self.widthOverlap = MAX(self.widthOverlap, styleHalfWidth);
            self.heightOverlap = MAX(self.heightOverlap, styleHalfWidth);
        }
        
        // Icon Rows
        NSMutableSet<NSNumber *> *iconRowIds = [[NSMutableSet alloc] init];
        NSArray<NSNumber *> *tableIconIds = [self.featureTableStyles allTableIconIds];
        if(tableIconIds != nil){
            [iconRowIds addObjectsFromArray:tableIconIds];
        }
        NSArray<NSNumber *> *iconIds = [self.featureTableStyles allIconIds];
        if(iconIds != nil){
            [iconRowIds addObjectsFromArray:iconIds];
        }
        
        GPKGIconDao *iconDao = [self.featureTableStyles iconDao];
        for(NSNumber *iconRowId in iconRowIds){
            GPKGIconRow *iconRow = (GPKGIconRow *)[iconDao queryForIdObject:iconRowId];
            double *iconDimensions = [iconRow derivedDimensions];
            double iconWidth = self.scale * ceil(iconDimensions[0]);
            double iconHeight = self.scale * ceil(iconDimensions[1]);
            free(iconDimensions);
            self.widthOverlap = MAX(self.widthOverlap, iconWidth);
            self.heightOverlap = MAX(self.heightOverlap, iconHeight);
        }
        
    }
    
}

-(void) setDrawOverlapsWithPixels: (double) pixels{
    [self setWidthOverlap:pixels];
    [self setHeightOverlap:pixels];
}

-(BOOL) isIndexQuery{
    return self.indexManager != nil && [self.indexManager isIndexed];
}

-(void) ignoreFeatureTableStyles{
    [self setFeatureTableStyles:nil];
    [self calculateDrawOverlap];
}

-(void) clearCache{
    [self clearIconCache];
    [self clearBoundingBoxCache];
    [self clearMapShapeCache];
}

-(void) clearIconCache{
    [self.iconCache clear];
}

-(void) setIconCacheSize: (int) size{
    [self.iconCache resizeWithSize:size];
}

-(void) clearBoundingBoxCache{
    [self.boundingBoxCache removeAllObjects];
}

-(void) setBoundingBoxCacheSize: (int) size{
    [self.boundingBoxCache setCountLimit:size];
}

-(void) clearMapShapeCache{
    [self.mapShapeCache removeAllObjects];
}

-(void) setMapShapeCacheSize: (int) size{
    [self.mapShapeCache setCountLimit:size];
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
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    UIImage *image = nil;
    
    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults * results = [self queryIndexedFeaturesWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    @try {
        
        int tileCount = results.count;
        
        // Draw if at least one geometry exists
        if(tileCount > 0){
            
            if(self.maxFeaturesPerTile == nil || tileCount <= [self.maxFeaturesPerTile intValue]){
                
                // Draw the tile image
                image = [self drawTileWithZoom:zoom andBoundingBox:webMercatorBoundingBox andIndexResults:results];
                
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
    GPKGBoundingBox * webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    // Query for the count of geometries matching the bounds in the index
    int count = [self queryIndexedFeaturesCountWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    return count;
}

-(int) queryIndexedFeaturesCountWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{

    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults *results = [self queryIndexedFeaturesWithWebMercatorBoundingBox:webMercatorBoundingBox];
    
    int count = 0;
    
    @try {
        count = results.count;
    } @finally {
        [results close];
    }
    
    return count;
}

-(GPKGFeatureIndexResults *) queryIndexedFeaturesWithX: (int) x andY: (int) y andZoom: (int) zoom{

    // Get the web mercator bounding box
    GPKGBoundingBox *webMercatorBoundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    // Query for the geometries matching the bounds in the index
    return [self queryIndexedFeaturesWithWebMercatorBoundingBox:webMercatorBoundingBox];
}

-(GPKGFeatureIndexResults *) queryIndexedFeaturesWithWebMercatorBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    
    // Create an expanded bounding box to handle features outside the tile that overlap
    GPKGBoundingBox *expandedQueryBoundingBox = [self expandBoundingBox:webMercatorBoundingBox];
    
    // Query for geometries matching the bounds in the index
    GPKGFeatureIndexResults * results = [self.indexManager queryWithBoundingBox:expandedQueryBoundingBox inProjection:[SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WEB_MERCATOR]];
    
    return results;
}

-(GPKGBoundingBox *) expandBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *expandedBoundingBox = boundingBox;
    
    SFPProjectionTransform * toWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
    if(![toWebMercator isSameProjection]){
        expandedBoundingBox = [expandedBoundingBox transform:toWebMercator];
    }
    
    expandedBoundingBox = [self expandBoundingBox:expandedBoundingBox];
    
    if(![toWebMercator isSameProjection]){
        SFPProjectionTransform *fromWebMercator = [toWebMercator inverseTransformation];
        expandedBoundingBox = [expandedBoundingBox transform:fromWebMercator];
    }
    
    return expandedBoundingBox;
}

-(GPKGBoundingBox *) expandBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox{
    return [self expandBoundingBox:webMercatorBoundingBox withTileBoundingBox:webMercatorBoundingBox];
}

-(GPKGBoundingBox *) expandBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox withTileBoundingBox: (GPKGBoundingBox *) tileWebMercatorBoundingBox{
    
    // Create an expanded bounding box to handle features outside the tile that overlap
    double minLongitude = [GPKGTileBoundingBoxUtils longitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andTileBoundingBox:tileWebMercatorBoundingBox andPixel:(0 - self.widthOverlap)];
    double maxLongitude = [GPKGTileBoundingBoxUtils longitudeFromPixelWithWidth:self.tileWidth andBoundingBox:webMercatorBoundingBox andTileBoundingBox:tileWebMercatorBoundingBox andPixel:(self.tileWidth + self.widthOverlap)];
    double maxLatitude = [GPKGTileBoundingBoxUtils latitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andTileBoundingBox:tileWebMercatorBoundingBox andPixel:(0 - self.heightOverlap)];
    double minLatitude = [GPKGTileBoundingBoxUtils latitudeFromPixelWithHeight:self.tileHeight andBoundingBox:webMercatorBoundingBox andTileBoundingBox:tileWebMercatorBoundingBox andPixel:(self.tileHeight + self.heightOverlap)];
    
    // Choose the most expanded longitudes and latitudes
    minLongitude = MIN(minLongitude, [webMercatorBoundingBox.minLongitude doubleValue]);
    maxLongitude = MAX(maxLongitude, [webMercatorBoundingBox.maxLongitude doubleValue]);
    minLatitude = MIN(minLatitude, [webMercatorBoundingBox.minLatitude doubleValue]);
    maxLatitude = MAX(maxLatitude, [webMercatorBoundingBox.maxLatitude doubleValue]);
    
    // Bound with the web mercator limits
    minLongitude = MAX(minLongitude, -1 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH);
    maxLongitude = MIN(maxLongitude, PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH);
    minLatitude = MAX(minLatitude, -1 * PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH);
    maxLatitude = MIN(maxLatitude, PROJ_WEB_MERCATOR_HALF_WORLD_WIDTH);
    
    GPKGBoundingBox * expandedBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    return expandedBoundingBox;
}

-(UIImage *) drawTileQueryAllWithX: (int) x andY: (int) y andZoom: (int) zoom{
    
    GPKGBoundingBox * boundingBox = [GPKGTileBoundingBoxUtils webMercatorBoundingBoxWithX:x andY:y andZoom:zoom];
    
    UIImage * image = nil;
    
    // Query for all features
    GPKGResultSet * results = [self.featureDao queryForAll];
    
    @try {
        
        int totalCount = results.count;

        // Draw if at least one geometry exists
        if(totalCount > 0){
        
            if(self.maxFeaturesPerTile == nil || totalCount <= [self.maxFeaturesPerTile intValue]){
                
                // Draw the tile image
                image = [self drawTileWithZoom:zoom andBoundingBox:boundingBox andResults:results];
                
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

-(UIImage *) drawTileWithZoom: (int) zoom andBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andIndexResults: (GPKGFeatureIndexResults *) results{
    
    UIImage *image = nil;
    
    @try{
    
        GPKGFeatureTileContext *context = [[GPKGFeatureTileContext alloc] initWithWidth:self.tileWidth andHeight:self.tileHeight];
        
        GPKGMapShapeConverter *converter = [self createMapShapeConverterWithZoom:zoom];
        GPKGBoundingBox *expandedBoundingBox = [self expandBoundingBox:webMercatorBoundingBox];
        
        BOOL drawn = NO;
        for(GPKGFeatureRow *featureRow in results){
            if([self drawFeatureWithZoom:zoom andBoundingBox:webMercatorBoundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:featureRow andShapeConverter:converter]){
                drawn = YES;
            }
        }
        
        if(drawn){
            image = [context createImage];
        }else{
            [context recycle];
        }
    
    }@finally{
        [results close];
    }
    
    return image;
}

-(UIImage *) drawTileWithZoom: (int) zoom andBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andResults: (GPKGResultSet *) results{
    
    UIImage *image = nil;
    
    @try{
        
        GPKGFeatureTileContext *context = [[GPKGFeatureTileContext alloc] initWithWidth:self.tileWidth andHeight:self.tileHeight];
        
        GPKGMapShapeConverter *converter = [self createMapShapeConverterWithZoom:zoom];
        GPKGBoundingBox *expandedBoundingBox = [self expandBoundingBox:webMercatorBoundingBox];
        
        BOOL drawn = NO;
        while([results moveToNext]){
            GPKGFeatureRow *row = [self.featureDao featureRow:results];
            if([self drawFeatureWithZoom:zoom andBoundingBox:webMercatorBoundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:row andShapeConverter:converter]){
                drawn = YES;
            }
        }
        
        if(drawn){
            image = [context createImage];
        }else{
            [context recycle];
        }
        
    }@finally{
        [results close];
    }
    
    return image;
}

-(UIImage *) drawTileWithZoom: (int) zoom andBoundingBox: (GPKGBoundingBox *) webMercatorBoundingBox andFeatureRows: (NSArray *) featureRows{
    
    UIImage *image = nil;
    
    GPKGFeatureTileContext *context = [[GPKGFeatureTileContext alloc] initWithWidth:self.tileWidth andHeight:self.tileHeight];
    
    GPKGMapShapeConverter *converter = [self createMapShapeConverterWithZoom:zoom];
    GPKGBoundingBox *expandedBoundingBox = [self expandBoundingBox:webMercatorBoundingBox];
    
    BOOL drawn = NO;
    for(GPKGFeatureRow *row in featureRows){
        if([self drawFeatureWithZoom:zoom andBoundingBox:webMercatorBoundingBox andExpandedBoundingBox:expandedBoundingBox andContext:context andRow:row andShapeConverter:converter]){
            drawn = YES;
        }
    }
        
    if(drawn){
        image = [context createImage];
    }else{
        [context recycle];
    }
    
    return image;
}

-(BOOL) drawFeatureWithZoom: (int) zoom andBoundingBox: (GPKGBoundingBox *) boundingBox andExpandedBoundingBox: (GPKGBoundingBox *) expandedBoundingBox andContext: (GPKGFeatureTileContext *) context andRow: (GPKGFeatureRow *) row andShapeConverter: (GPKGMapShapeConverter *) converter{
    
    BOOL drawn = NO;
    
    @try{
        
        GPKGMapShape *shape = [self mapShapeFromFeature:row withZoom:zoom andExpandedBoundingBox:expandedBoundingBox andShapeConverter:converter];
        if(shape != nil){
            drawn = [self drawShapeWithBoundingBox:boundingBox andContext:context andFeature:row andMapShape:shape];
        }

    }@catch (NSException *e) {
        NSLog(@"Failed to draw feature in tile. Table: %@", self.featureDao.tableName);
    }
    
    return drawn;
}

-(GPKGMapShape *) mapShapeFromFeature: (GPKGFeatureRow *) row withZoom: (int) zoom andExpandedBoundingBox: (GPKGBoundingBox *) expandedBoundingBox andShapeConverter: (GPKGMapShapeConverter *) converter{
    
    GPKGMapShape *shape = nil;
    
    GPKGBoundingBox *boundingBox = nil;
    GPKGGeometryData * geomData = nil;
    
    NSNumber *rowId = nil;
    
    // Check the cache for the transformed geometry bounding box
    if(self.cacheBoundingBoxes){
        rowId = [row id];
        boundingBox = [self.boundingBoxCache objectForKey:rowId];
    }
    
    if(boundingBox == nil){
        
        // Build the transformed feature bounding box
        geomData = [row geometry];
        boundingBox = [self boundingBoxOfFeature:row withGeometryData:geomData andShapeConverter:converter];
        
        // Cache the transformed feature bounding box
        if(self.cacheBoundingBoxes && boundingBox != nil){
            [self.boundingBoxCache setObject:boundingBox forKey:rowId];
        }
    }
    
    if(boundingBox != nil){
        
        // Does the expanded draw bounding box intersect the geometry bounding box
        if([expandedBoundingBox intersects:boundingBox withAllowEmpty:YES]){
            
            NSString *rowZoomId = nil;
            
            // Check the cache for the map shape
            if(self.cacheMapShapes){
                if(rowId == nil){
                    rowId = [row id];
                }
                rowZoomId = [NSString stringWithFormat:@"%@_%d", rowId, zoom];
                shape = [self.mapShapeCache objectForKey:rowZoomId];
            }
            
            if(shape == nil){
                
                // Build the zoom level simplified map shape from the feature
                shape = [self mapShapeFromFeature:row withGeometryData:geomData andShapeConverter:converter];
                
                // Cache the map shape
                if(self.cacheMapShapes && shape != nil){
                    [self.mapShapeCache setObject:shape forKey:rowZoomId];
                }
            }
            
        }
        
    }
    
    return shape;
}

-(GPKGBoundingBox *) boundingBoxOfFeature: (GPKGFeatureRow *) row withGeometryData: (GPKGGeometryData *) geomData andShapeConverter: (GPKGMapShapeConverter *) converter{
    
    GPKGBoundingBox *boundingBox = nil;
    
    if(geomData != nil){
        
        SFGeometry * geometry = geomData.geometry;
        if(geometry != nil){
            
            SFGeometryEnvelope *envelope = [geomData buildEnvelope];
            GPKGBoundingBox *geometryBoundingBox = [[GPKGBoundingBox alloc] initWithGeometryEnvelope:envelope];
            boundingBox = [converter boundingBoxToWebMercator:geometryBoundingBox];
            
        }
    }
    
    return boundingBox;
}

-(GPKGMapShape *) mapShapeFromFeature: (GPKGFeatureRow *) row withGeometryData: (GPKGGeometryData *) geomData andShapeConverter: (GPKGMapShapeConverter *) converter{
    
    GPKGMapShape *shape = nil;
    
    if(geomData == nil){
        geomData = [row geometry];
    }
    
    SFGeometry * geometry = geomData.geometry;
    if(geometry != nil){
        shape = [converter toShapeWithGeometry:geometry];
    }
    
    return shape;
}

-(BOOL) drawShapeWithBoundingBox: (GPKGBoundingBox *) boundingBox andContext: (GPKGFeatureTileContext *) context andFeature: (GPKGFeatureRow *) featureRow andMapShape: (GPKGMapShape *) shape{
    
    BOOL drawn = NO;
    
    enum GPKGMapShapeType shapeType = shape.shapeType;
    enum SFGeometryType geometryType = shape.geometryType;
    GPKGFeatureStyle *featureStyle = [self featureStyleForFeature:featureRow andGeometryType:geometryType];
    
    NSObject *shapeObject = shape.shape;
    
    switch(shapeType){
            
        case GPKG_MST_POINT:
            {
                GPKGMapPoint * point = (GPKGMapPoint *) shapeObject;
                drawn = [self drawPointWithBoundingBox:boundingBox andContext:context andPoint:point andStyle:featureStyle];
            }
            break;
        case GPKG_MST_POLYLINE:
            {
                MKPolyline * polyline = (MKPolyline *) shapeObject;
                CGMutablePathRef linePath = CGPathCreateMutable();
                [self addPolyline:polyline toPath:linePath withBoundingBox:boundingBox];
                drawn = [self drawLinePath:linePath andContext:context andStyle:featureStyle];
            }
            break;
        case GPKG_MST_POLYGON:
            {
                MKPolygon * polygon = (MKPolygon *) shapeObject;
                CGMutablePathRef polygonPath = CGPathCreateMutable();
                [self addPolygon:polygon toPath:polygonPath withBoundingBox:boundingBox];
                drawn = [self drawPolygonPath:polygonPath andContext:context andStyle:featureStyle];
            }
            break;
        case GPKG_MST_MULTI_POINT:
            {
                GPKGMultiPoint * multiPoint = (GPKGMultiPoint *) shapeObject;
                for(GPKGMapPoint * point in multiPoint.points){
                    drawn = [self drawPointWithBoundingBox:boundingBox andContext:context andPoint:point andStyle:featureStyle] || drawn;
                }
            }
            break;
        case GPKG_MST_MULTI_POLYLINE:
            {
                GPKGMultiPolyline * multiPolyline = (GPKGMultiPolyline *) shapeObject;
                for(MKPolyline * polyline in multiPolyline.polylines){
                    CGMutablePathRef multiLinePath = CGPathCreateMutable();
                    [self addPolyline:polyline toPath:multiLinePath withBoundingBox:boundingBox];
                    drawn = [self drawLinePath:multiLinePath andContext:context andStyle:featureStyle] || drawn;
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
                drawn = [self drawPolygonPath:multiPolygonPath andContext:context andStyle:featureStyle];
            }
            break;
        case GPKG_MST_COLLECTION:
            {
                NSArray * shapes = (NSArray *) shapeObject;
                for(GPKGMapShape * arrayShape in shapes){
                    drawn = [self drawShapeWithBoundingBox:boundingBox andContext:context andFeature:featureRow andMapShape:arrayShape] || drawn;
                }
            }
            break;
        default:
            [NSException raise:@"Shape Type" format:@"Unsupported shape type: %@", [GPKGMapShapeTypes name:shape.shapeType]];
            
    }
    
    return drawn;
}

-(BOOL) drawLinePath: (CGMutablePathRef) path andContext: (GPKGFeatureTileContext *) context andStyle: (GPKGFeatureStyle *) featureStyle{
    
    CGContextRef lineContext = [context lineContext];
    
    double strokeWidth = self.scale * self.lineStrokeWidth;
    UIColor *color = self.lineColor;
    
    if(featureStyle != nil){
        GPKGStyleRow *style = featureStyle.style;
        if(style != nil && [style hasColor]){
            color = [[style colorOrDefault] uiColor];
            strokeWidth = self.scale * [style widthOrDefault];
        }
    }
    
    CGContextSetLineWidth(lineContext, strokeWidth);
    CGContextSetStrokeColorWithColor(lineContext, color.CGColor);
    CGContextAddPath(lineContext, path);
    CGContextDrawPath(lineContext, kCGPathStroke);
    CGPathRelease(path);
    
    return YES;
}

-(BOOL) drawPolygonPath: (CGMutablePathRef) path andContext: (GPKGFeatureTileContext *) context andStyle: (GPKGFeatureStyle *) featureStyle{
    
    CGContextRef polygonContext = [context polygonContext];
    
    double strokeWidth = self.scale * self.polygonStrokeWidth;
    UIColor *color = self.polygonColor;
    UIColor *fillColor = self.polygonFillColor;
    BOOL fill = self.fillPolygon;
    
    if(featureStyle != nil){
        GPKGStyleRow *style = featureStyle.style;
        if(style != nil){
            if([style hasColor]){
                color = [[style colorOrDefault] uiColor];
                strokeWidth = self.scale * [style widthOrDefault];
                fill = NO;
            }
            if([style hasFillColor]){
                fillColor = [[style fillColor] uiColor];
                fill = YES;
            }
        }
    }
    
    CGContextSetLineWidth(polygonContext, strokeWidth);
    CGContextSetStrokeColorWithColor(polygonContext, color.CGColor);
    CGPathDrawingMode mode;
    if(fill){
        mode = kCGPathEOFillStroke;
        CGContextSetFillColorWithColor(polygonContext, fillColor.CGColor);
    }else{
        mode = kCGPathStroke;
    }
    CGContextAddPath(polygonContext, path);
    CGContextDrawPath(polygonContext, mode);
    CGPathRelease(path);
    
    return YES;
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
        double x = [GPKGTileBoundingBoxUtils xPixelWithWidth:self.tileWidth andBoundingBox:boundingBox andLongitude:[sfPoint.x doubleValue]];
        double y = [GPKGTileBoundingBoxUtils yPixelWithHeight:self.tileHeight andBoundingBox:boundingBox andLatitude:[sfPoint.y doubleValue]];
        if(i == 0){
            CGPathMoveToPoint(path, NULL, x, y);
        }else{
            CGPathAddLineToPoint(path, NULL, x, y);
        }
    }
}

-(BOOL) drawPointWithBoundingBox: (GPKGBoundingBox *) boundingBox andContext: (GPKGFeatureTileContext *) context andPoint: (GPKGMapPoint *) point andStyle: (GPKGFeatureStyle *) featureStyle{
    
    BOOL drawn = NO;
    
    SFPoint * sfPoint = [self transformPointWithMapPoint:point];
    double x = [GPKGTileBoundingBoxUtils xPixelWithWidth:self.tileWidth andBoundingBox:boundingBox andLongitude:[sfPoint.x doubleValue]];
    double y = [GPKGTileBoundingBoxUtils yPixelWithHeight:self.tileHeight andBoundingBox:boundingBox andLatitude:[sfPoint.y doubleValue]];
    
    if(featureStyle != nil && [featureStyle hasIcon]){
    
        GPKGIconRow *iconRow = featureStyle.icon;
        UIImage *icon = [self iconImageForIcon:iconRow];
        
        float width = icon.size.width;
        float height = icon.size.height;
        
        if(x >= 0 - width && x <= self.tileWidth + width && y >= 0 - height && y <= self.tileHeight + height){
            
            double anchorU = [iconRow anchorUOrDefault];
            double anchorV = [iconRow anchorVOrDefault];
            
            CGRect rect = CGRectMake(x - (anchorU * width), y - (anchorV * height), width, height);
            CGContextRef iconContext = [context iconContext];
            [self drawImage:icon inRect:rect onContext:iconContext];
            drawn = YES;
            
        }
        
    }else if(self.pointIcon != nil){
        
        int width = roundf(self.scale * [self.pointIcon width]);
        int height = roundf(self.scale * [self.pointIcon height]);
        if(x >= 0 - width && x <= self.tileWidth + width && y >= 0 - height && y <= self.tileHeight + height){
            CGRect rect = CGRectMake(x - self.scale * self.pointIcon.xOffset, y - self.scale * self.pointIcon.yOffset, width, height);
            CGContextRef iconContext = [context iconContext];
            [self drawImage:[self.pointIcon icon] inRect:rect onContext:iconContext];
            drawn = YES;
        }
    
    }else{
        
        double radius = self.scale * self.pointRadius;
        
        GPKGStyleRow *style = nil;
        if(featureStyle != nil){
            style = featureStyle.style;
            if(style != nil){
                radius = self.scale * [style widthOrDefault] / 2.0;
            }
        }
        
        if(x >= 0 - radius && x <= self.tileWidth + radius && y >= 0 - radius && y <= self.tileHeight + radius){
            
            UIColor *color = self.pointColor;
            
            if(style != nil && [style hasColor]){
                color = [[style colorOrDefault] uiColor];
            }
            
            double diameter = radius * 2;
            CGRect circleRect = CGRectMake(x - radius, y - radius, diameter, diameter);
        
            // Draw the Circle
            CGContextRef pointContext = [context pointContext];
            CGContextSetFillColorWithColor(pointContext, color.CGColor);
            CGContextFillEllipseInRect(pointContext, circleRect);
            drawn = YES;
        }
        
    }
    
    return drawn;
}

-(void) drawImage: (UIImage *) image inRect: (CGRect) rect onContext: (CGContextRef) context{
    
    // Flip the coordinates
    float ty = rect.origin.y + rect.size.height;
    CGContextTranslateCTM(context, 0, ty);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw
    CGRect drawRect = CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height);
    CGContextDrawImage(context, drawRect, image.CGImage);
    
    // Flip back
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -ty);
    
}

-(SFPoint *) transformPointWithMapPoint: (GPKGMapPoint *) point{
    NSArray * lonLat = [self.wgs84ToWebMercatorTransform transformWithX:point.coordinate.longitude andY:point.coordinate.latitude];
    return [[SFPoint alloc] initWithX:(NSDecimalNumber *)lonLat[0] andY:(NSDecimalNumber *)lonLat[1]];
}

/**
 * Create a map shape converter
 *
 * @param zoom    zoom
 */
-(GPKGMapShapeConverter *) createMapShapeConverterWithZoom: (int) zoom{
    
    GPKGMapShapeConverter *converter = [[GPKGMapShapeConverter alloc] initWithProjection:self.featureDao.projection];
    
    // Set the simplify tolerance for simplifying geometries to similar curves with fewer points
    if(self.simplifyGeometries){
        double simplifyTolerance = [GPKGTileBoundingBoxUtils toleranceDistanceWithZoom:zoom andPixelWidth:self.tileWidth andPixelHeight:self.tileHeight];
        [converter setSimplifyToleranceAsDouble:simplifyTolerance];
    }
    
    return converter;
}

/**
 * Get the feature style for the feature row and geometry type
 *
 * @param featureRow feature row
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleForFeature: (GPKGFeatureRow *) featureRow{
    GPKGFeatureStyle *featureStyle = nil;
    if (self.featureTableStyles != nil) {
        featureStyle = [self.featureTableStyles featureStyleWithFeature:featureRow];
    }
    return featureStyle;
}

/**
 * Get the feature style for the feature row and geometry type
 *
 * @param featureRow   feature row
 * @param geometryType geometry type
 * @return feature style
 */
-(GPKGFeatureStyle *) featureStyleForFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    GPKGFeatureStyle *featureStyle = nil;
    if (self.featureTableStyles != nil) {
        featureStyle = [self.featureTableStyles featureStyleWithFeature:featureRow andGeometryType:geometryType];
    }
    return featureStyle;
}

/**
 * Get the icon bitmap from the icon row
 *
 * @param iconRow icon row
 * @return icon bitmap
 */
-(UIImage *) iconImageForIcon: (GPKGIconRow *) iconRow{
    return [self.iconCache createIconForRow:iconRow];
}

@end
