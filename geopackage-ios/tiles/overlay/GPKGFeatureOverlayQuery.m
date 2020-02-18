//
//  GPKGFeatureOverlayQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQuery.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "SFPProjectionFactory.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGMapUtils.h"

@interface GPKGFeatureOverlayQuery ()

@property (nonatomic, strong) GPKGBoundedOverlay *boundedOverlay;
@property (nonatomic, strong) GPKGFeatureTiles *featureTiles;
@property (nonatomic, strong) GPKGFeatureInfoBuilder *featureInfoBuilder;

@end

@implementation GPKGFeatureOverlayQuery

-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay{
    return [self initWithBoundedOverlay:featureOverlay andFeatureTiles:featureOverlay.featureTiles];
}

-(instancetype) initWithBoundedOverlay: (GPKGBoundedOverlay *) boundedOverlay andFeatureTiles: (GPKGFeatureTiles *) featureTiles{
    self = [super init];
    if(self != nil){
        self.boundedOverlay = boundedOverlay;
        self.featureTiles = featureTiles;
        
        // Get the screen percentage to determine when a feature is clicked
        self.screenClickPercentage = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_SCREEN_CLICK_PERCENTAGE] floatValue];
        
        self.maxFeaturesInfo = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_MAX_FEATURES_INFO];
        self.featuresInfo = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_FEATURE_OVERLAY_QUERY andProperty:GPKG_PROP_FEATURE_QUERY_FEATURES_INFO];
        
        GPKGFeatureDao * featureDao = [self.featureTiles featureDao];
        self.featureInfoBuilder = [[GPKGFeatureInfoBuilder alloc] initWithFeatureDao:featureDao];
    }
    return self;
}

-(GPKGBoundedOverlay *) boundedOverlay{
    return _boundedOverlay;
}

-(GPKGFeatureTiles *) featureTiles{
    return _featureTiles;
}

-(GPKGFeatureInfoBuilder *) featureInfoBuilder{
    return _featureInfoBuilder;
}

-(void) setScreenClickPercentage:(float)screenClickPercentage{
    if(screenClickPercentage < 0.0 || screenClickPercentage > 1.0){
        [NSException raise:@"Screen Click Percentage" format:@"Screen click percentage must be a float between 0.0 and 1.0, not %f", screenClickPercentage];
    }
    _screenClickPercentage = screenClickPercentage;
}

-(BOOL) onAtCurrentZoomWithMapView: (MKMapView *) mapView andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    BOOL on = [self onAtZoom:zoom andLocationCoordinate:locationCoordinate];
    return on;
}

-(BOOL) onAtZoom: (double) zoom andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.latitude];
    SFPoint * point = [[SFPoint alloc] initWithX:x andY:y];
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils tileGridFromWGS84Point:point andZoom:zoom];
    
    BOOL on = [self.boundedOverlay hasTileWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
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
    SFPoint * point = [[SFPoint alloc] initWithX:x andY:y];
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoom];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (SFPoint *) point andDoubleZoom: (double) zoom{
    int zoomValue = (int) zoom;
    int tileFeaturesCount = [self tileFeatureCountWithPoint:point andZoom:zoomValue];
    return tileFeaturesCount;
}

-(int) tileFeatureCountWithPoint: (SFPoint *) point andZoom: (int) zoom{
    GPKGTileGrid * tileGrid = [GPKGTileBoundingBoxUtils tileGridFromWGS84Point:point andZoom:zoom];
    return [self.featureTiles queryIndexedFeaturesCountWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
}

-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount{
    return self.featureTiles.maxFeaturesPerTile != nil && tileFeaturesCount > [self.featureTiles.maxFeaturesPerTile intValue];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithBoundingBox:boundingBox withProjection:nil];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithColumns:columns andBoundingBox:boundingBox withProjection:nil];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (SFPProjection *) projection{
    return [self queryFeaturesWithColumns:[[self.featureTiles featureDao] columnNames] andBoundingBox:boundingBox withProjection:projection];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (SFPProjection *) projection{
    
    if(projection == nil){
        projection = [SFPProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    }
    
    // Query for features
    GPKGFeatureIndexManager * indexManager = self.featureTiles.indexManager;
    if(indexManager == nil){
        [NSException raise:@"Index Manager" format:@"Index Manager is not set on the Feature Tiles and is required to query indexed features"];
    }
    GPKGFeatureIndexResults * results = [indexManager queryWithColumns:columns andBoundingBox:boundingBox inProjection:projection];
    return results;
}

-(BOOL) isIndexed{
    return [self.featureTiles isIndexQuery];
}

-(NSString *) buildMaxFeaturesInfoMessageWithTileFeaturesCount: (int) tileFeaturesCount{
    return [NSString stringWithFormat:@"%@\n\t%d features", self.featureInfoBuilder.name, tileFeaturesCount];
}

-(NSString *) buildMapClickMessageWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView{
    CLLocationCoordinate2D locationCoordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andMapView:mapView];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView{
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andMapView:mapView andProjection:nil];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (SFPProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    // Get the map click distance tolerance
    GPKGMapTolerance *tolerance = [GPKGMapUtils toleranceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    NSString * message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance{
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andTolerance:tolerance andProjection:nil];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (SFPProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    NSString * message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andTolerance: (GPKGMapTolerance *) tolerance andProjection: (SFPProjection *) projection{
    
    NSString * message = nil;
    
    // Verify the features are indexed and we are getting information
    if([self isIndexed] && (self.maxFeaturesInfo || self.featuresInfo)){
        
        @try {
            
            if([self onAtZoom:zoom andLocationCoordinate:locationCoordinate]){
                
                // Get the number of features in the tile location
                int tileFeatureCount = [self tileFeatureCountWithLocationCoordinate:locationCoordinate andDoubleZoom:zoom];
                
                // If more than a configured max features to draw
                if([self moreThanMaxFeatures:tileFeatureCount]){
                    
                    // Build the max features message
                    if(self.maxFeaturesInfo){
                        message = [self buildMaxFeaturesInfoMessageWithTileFeaturesCount:tileFeatureCount];
                    }
                    
                }
                // Else, query for the features near the click
                else if(self.featuresInfo){
                    
                    // Query for results and build the message
                    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:projection];
                    message = [self.featureInfoBuilder buildResultsInfoMessageAndCloseWithFeatureIndexResults:results andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:projection];
                }
            }
            
        }
        @catch (NSException *e) {
            NSLog(@"Build Map Click Message Error: %@", [e description]);
        }
    }
    
    return message;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView{
    return [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andMapView:mapView andProjection:nil];
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (SFPProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    // Get the map click distance tolerance
    GPKGMapTolerance *tolerance = [GPKGMapUtils toleranceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData * tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance{
    return [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andTolerance:tolerance andProjection:nil];
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (SFPProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox * boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData * tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andTolerance: (GPKGMapTolerance *) tolerance andProjection: (SFPProjection *) projection{
    
    GPKGFeatureTableData * tableData = nil;
    
    // Verify the features are indexed and we are getting information
    if([self isIndexed] && (self.maxFeaturesInfo || self.featuresInfo)){
        
        @try {
            
            if([self onAtZoom:zoom andLocationCoordinate:locationCoordinate]){
                
                // Get the number of features in the tile location
                int tileFeatureCount = [self tileFeatureCountWithLocationCoordinate:locationCoordinate andDoubleZoom:zoom];
                
                // If more than a configured max features to drawere 
                if([self moreThanMaxFeatures:tileFeatureCount]){
                    
                    // Build the max features message
                    if(self.maxFeaturesInfo){
                        tableData = [[GPKGFeatureTableData alloc] initWithName:[self.featureTiles featureDao].tableName andCount:tileFeatureCount];
                    }
                    
                }
                // Else, query for the features near the click
                else if(self.featuresInfo){
                    
                    // Query for results and build the message
                    GPKGFeatureIndexResults * results = [self queryFeaturesWithBoundingBox:boundingBox withProjection:projection];
                    tableData = [self.featureInfoBuilder buildTableDataAndCloseWithFeatureIndexResults:results andTolerance:tolerance andLocationCoordinate:locationCoordinate andProjection:projection];
                }
            }
            
        }
        @catch (NSException *e) {
            NSLog(@"Build Map Click Message Error: %@", [e description]);
        }
    }
    
    return tableData;
}

@end
