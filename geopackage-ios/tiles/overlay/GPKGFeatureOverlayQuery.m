//
//  GPKGFeatureOverlayQuery.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureOverlayQuery.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "PROJProjectionFactory.h"
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
        
        GPKGFeatureDao *featureDao = [self.featureTiles featureDao];
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
    return [self onAtZoom:zoom andLocationCoordinate:locationCoordinate];
}

-(BOOL) onAtZoom: (double) zoom andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate{
    
    NSDecimalNumber *x = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.longitude];
    NSDecimalNumber *y = [[NSDecimalNumber alloc] initWithDouble:locationCoordinate.latitude];
    SFPoint *point = [[SFPoint alloc] initWithX:x andY:y];
    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridFromWGS84Point:point andZoom:zoom];
    
    return [self.boundedOverlay hasTileWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
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
    return [self tileFeatureCountWithLocationCoordinate:location andZoom:(int) zoom];
}

-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom{
    SFPoint *point = [[SFPoint alloc] initWithXValue:location.longitude andYValue:location.latitude];
    return [self tileFeatureCountWithPoint:point andZoom:zoom];
}

-(int) tileFeatureCountWithPoint: (SFPoint *) point andDoubleZoom: (double) zoom{
    return [self tileFeatureCountWithPoint:point andZoom:(int) zoom];
}

-(int) tileFeatureCountWithPoint: (SFPoint *) point andZoom: (int) zoom{
    GPKGTileGrid *tileGrid = [GPKGTileBoundingBoxUtils tileGridFromWGS84Point:point andZoom:zoom];
    return [self.featureTiles queryIndexedFeaturesCountWithX:tileGrid.minX andY:tileGrid.minY andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsWithMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom{
    return [self tileBoundsWithMapPoint:mapPoint andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom{
    return [self tileBoundsWithLocationCoordinate:mapPoint.coordinate andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsWithMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom{
    return [self tileBoundsWithMKMapPoint:mapPoint andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsWithMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileBoundsWithLocationCoordinate:coord andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsWithLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom{
    return [self tileBoundsWithLocationCoordinate:location andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom{
    SFPoint *point = [[SFPoint alloc] initWithXValue:location.longitude andYValue:location.latitude];
    return [self tileBoundsWithPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsWithPoint: (SFPoint *) point andDoubleZoom: (double) zoom{
    return [self tileBoundsWithPoint:point andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsWithPoint: (SFPoint *) point andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils tileBoundsForWGS84Point:point andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom{
    return [self tileBoundsInProjection:projection withMapPoint:mapPoint andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom{
    return [self tileBoundsInProjection:projection withLocationCoordinate:mapPoint.coordinate andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom{
    return [self tileBoundsInProjection:projection withMKMapPoint:mapPoint andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    return [self tileBoundsInProjection:projection withLocationCoordinate:coord andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom{
    return [self tileBoundsInProjection:projection withLocationCoordinate:location andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom{
    SFPoint *point = [[SFPoint alloc] initWithXValue:location.longitude andYValue:location.latitude];
    return [self tileBoundsInProjection:projection withPoint:point andZoom:zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withPoint: (SFPoint *) point andDoubleZoom: (double) zoom{
    return [self tileBoundsInProjection:projection withPoint:point andZoom:(int) zoom];
}

+(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withPoint: (SFPoint *) point andZoom: (int) zoom{
    return [GPKGTileBoundingBoxUtils tileBoundsInProjection:projection andPoint:point andZoom:zoom];
}

-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount{
    return self.featureTiles.maxFeaturesPerTile != nil && tileFeaturesCount > [self.featureTiles.maxFeaturesPerTile intValue];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithBoundingBox:boundingBox inProjection:nil];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithColumns:columns andBoundingBox:boundingBox inProjection:nil];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryFeaturesWithColumns:[[self.featureTiles featureDao] columnNames] andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    
    if(projection == nil){
        projection = [PROJProjectionFactory projectionWithEpsgInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    }
    
    // Query for features
    GPKGFeatureIndexManager *indexManager = self.featureTiles.indexManager;
    if(indexManager == nil){
        [NSException raise:@"Index Manager" format:@"Index Manager is not set on the Feature Tiles and is required to query indexed features"];
    }
    GPKGFeatureIndexResults *results = [indexManager queryWithColumns:columns andBoundingBox:boundingBox inProjection:projection];
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

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (PROJProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox *boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    // Get the map click distance tolerance
    GPKGMapTolerance *tolerance = [GPKGMapUtils toleranceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    NSString *message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance{
    return [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andTolerance:tolerance andProjection:nil];
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox *boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    NSString *message = [self buildMapClickMessageWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return message;
}

-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection{
    
    NSString *message = nil;
    
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
                    GPKGFeatureIndexResults *results = [self queryFeaturesWithBoundingBox:boundingBox inProjection:projection];
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

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (PROJProjection *) projection{
    
    // Get the zoom level
    double zoom = [GPKGMapUtils currentZoomWithMapView:mapView];
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox *boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    // Get the map click distance tolerance
    GPKGMapTolerance *tolerance = [GPKGMapUtils toleranceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData *tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance{
    return [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andMapBounds:mapBounds andTolerance:tolerance andProjection:nil];
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection{
    
    // Build a bounding box to represent the click location
    GPKGBoundingBox *boundingBox = [GPKGMapUtils buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapBounds:mapBounds andScreenPercentage:self.screenClickPercentage];
    
    GPKGFeatureTableData *tableData = [self buildMapClickTableDataWithLocationCoordinate:locationCoordinate andZoom:zoom andClickBoundingBox:boundingBox andTolerance:tolerance andProjection:projection];
    
    return tableData;
}

-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andClickBoundingBox: (GPKGBoundingBox *) boundingBox andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection{
    
    GPKGFeatureTableData *tableData = nil;
    
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
                    GPKGFeatureIndexResults *results = [self queryFeaturesWithBoundingBox:boundingBox inProjection:projection];
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
