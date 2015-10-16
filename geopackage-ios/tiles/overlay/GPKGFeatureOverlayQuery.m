//
//  GPKGFeatureOverlayQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQuery.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGProjectionFactory.h"

@interface GPKGFeatureOverlayQuery ()

@property (nonatomic, strong) GPKGFeatureOverlay *featureOverlay;
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;
@property (nonatomic) enum WKBGeometryType geometryType;

@end

@implementation GPKGFeatureOverlayQuery

-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay{
    self = [super init];
    if(self != nil){
        self.featureOverlay = featureOverlay;
        self.featureTiles = featureOverlay.featureTiles;
        
        GPKGFeatureDao * featureDao = [self.featureTiles getFeatureDao];
        self.geometryType = [featureDao getGeometryType];
        self.name = [NSString stringWithFormat:@"%@ - %@", featureDao.databaseName, featureDao.tableName];
        
        // Get the screen percentage to determine when a feature is clicked
        self.screenClickPercentage = .03; // TODO configure
        
        self.maxFeaturesInfo = true; // TODO configure
        self.featuresInfo = true; // TODO configure
        
        self.maxPointDetailedInfo = 10; // TODO configure
        self.maxFeatureDetailedInfo = 10; // TODO configure
        
        self.detailedInfoPrintPoints = true; // TODO configure
        self.detailedInfoPrintFeatures = false; // TODO configure
    }
    return self;
}

-(GPKGFeatureOverlay *) getFeatureOverlay{
    return self.featureOverlay;
}

-(GPKGFeatureTiles *) getFeatureTiles{
    return self.featureTiles;
}

-(enum WKBGeometryType) getGeometryType{
    return self.geometryType;
}

-(void) setScreenClickPercentage:(float)screenClickPercentage{
    if(screenClickPercentage < 0.0 || screenClickPercentage > 1.0){
        [NSException raise:@"Screen Click Percentage" format:@"Screen click percentage must be a float between 0.0 and 1.0, not %f", screenClickPercentage];
    }
    _screenClickPercentage = screenClickPercentage;
}

-(double) currentZoomWithMapView: (MKMapView *) mapView{
    double maxZoom = log2(MKMapSizeWorld.width / 256.0);
    CLLocationDegrees longitudeDelta = mapView.region.span.longitudeDelta;
    CGFloat width = mapView.bounds.size.width;
    double scale = longitudeDelta * PROJ_MERCATOR_RADIUS * M_PI / (180.0 * width);
    double zoom = maxZoom - log2(scale);
    if (maxZoom < 0){
        zoom = 0;
    }
    
    return zoom;
}

-(BOOL) onAtCurrentZoomWithMapView: (MKMapView *) mapView{
    double zoom = [self currentZoomWithMapView:mapView];
    BOOL on = [self onAtZoom:zoom];
    return on;
}

-(BOOL) onAtZoom: (double) zoom{
    BOOL on = (self.featureOverlay.minZoom == nil || zoom >= [self.featureOverlay.minZoom doubleValue])
    && (self.featureOverlay.maxZoom == nil || zoom <= [self.featureOverlay.maxZoom doubleValue]);
    return on;
}

-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom{
    return [self tileFeatureCountWithLocationCoordinate:mapPoint.coordinate andDoubleZoom:zoom];
}

-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom{
    return [self tileFeatureCountWithLocationCoordinate:mapPoint.coordinate andZoom:zoom];
}

-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileFeatureCountWithLocationCoordinate:coord andDoubleZoom:zoom];
}

-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileFeatureCountWithLocationCoordinate:coord andZoom:zoom];
}

-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom{
    int zoomValue = (int) zoom;
    int tileFeaturesCount = [self tileFeatureCountWithLocationCoordinate:location andZoom:zoomValue];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom{
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:location.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:location.latitude];
    WKBPoint * point = [[WKBPoint alloc] initWithX:x andY:y];
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoom];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (WKBPoint *) point andDoubleZoom: (double) zoom{
    int zoomValue = (int) zoom;
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoomValue];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (WKBPoint *) point andZoom: (int) zoom{
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils getTileGridFromWGS84Point:point andZoom:zoom];
    return [self.featureTiles queryIndexedFeaturesCountWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
}

-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount{
    return self.featureTiles.maxFeaturesPerTile != nil && tileFeaturesCount > [self.featureTiles.maxFeaturesPerTile intValue];
}

-(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andMapView: (MKMapView *) mapView{
    return [self buildClickBoundingBoxWithLocationCoordinate:mapPoint.coordinate andMapView:mapView];
}

-(GPKGBoundingBox *) buildClickBoundingBoxWithMKMapPoint: (MKMapPoint) mapPoint andMapView: (MKMapView *) mapView{
    CLLocationCoordinate2D locationCoordinate = MKCoordinateForMapPoint(mapPoint);
    return [self buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView];
}

-(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView{
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    return [self buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView];
}

-(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView{
    CGPoint point = [mapView convertCoordinate:location toPointToView:mapView];
    return [self buildClickBoundingBoxWithCGPoint:point andMapView:mapView];
}

-(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView{
    
    // Get the screen width and height a click occurs from a feature
    int width = (int)roundf(mapView.frame.size.width * self.screenClickPercentage);
    int height = (int)roundf(mapView.frame.size.height * self.screenClickPercentage);
    
    // Get the screen click locations in each width or height direction
    CGPoint left = CGPointMake(point.x - width, point.y);
    CGPoint up = CGPointMake(point.x, point.y - height);
    CGPoint right = CGPointMake(point.x + width, point.y);
    CGPoint down = CGPointMake(point.x, point.y + height);
    
    // Get the coordinates of the bounding box points
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:left toCoordinateFromView:mapView];
    CLLocationCoordinate2D upCoordinate = [mapView convertPoint:up toCoordinateFromView:mapView];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:right toCoordinateFromView:mapView];
    CLLocationCoordinate2D downCoordinate = [mapView convertPoint:down toCoordinateFromView:mapView];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:leftCoordinate.longitude
                                                                  andMaxLongitudeDouble:rightCoordinate.longitude
                                                                   andMinLatitudeDouble:downCoordinate.latitude
                                                                   andMaxLatitudeDouble:upCoordinate.latitude];
    
    return boundingBox;
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:projection];
    return results;
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection{
    // Query for features
    GPKGFeatureIndexManager * indexManager = self.featureTiles.indexManager;
    if(indexManager == nil){
        [NSException raise:@"Index Manager" format:@"Index Manager is not set on the Feature Tiles and is required to query indexed features"];
    }
    GPKGFeatureIndexResults * results = [indexManager queryWithBoundingBox:boundingBox andProjection:projection];
    return results;
}

// TODO

@end
