//
//  GPKGFeatureOverlayQuery.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureOverlay.h"
#import "GPKGMapPoint.h"

/**
 * Used to query the features represented by the tiles drawn in a FeatureOverlay
 */
@interface GPKGFeatureOverlayQuery : NSObject

/**
 *  Table name used when building text
 */
@property (nonatomic, strong) NSString * name;

/**
 * Screen click percentage between 0.0 and 1.0 for how close a feature on the screen must be
 * to be included in a click query
 */
@property (nonatomic) float screenClickPercentage;

/**
 * Flag indicating if building info messages for tiles with features over the max is enabled
 */
@property (nonatomic) BOOL maxFeaturesInfo;

/**
 * Flag indicating if building info messages for clicked features is enabled
 */
@property (nonatomic) BOOL featuresInfo;

/**
 * Max number of points clicked to return detailed information about
 */
@property (nonatomic) int maxPointDetailedInfo;

/**
 * Max number of features clicked to return detailed information about
 */
@property (nonatomic) int maxFeatureDetailedInfo;

/**
 * Print Point geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintPoints;

/**
 * Print Feature geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintFeatures;

/**
 *  Initialize
 *
 *  @param featureOverlay feature overlay
 *
 *  @return new feature overlay query
 */
-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay;

/**
 *  Get the feature overlay
 *
 *  @return feature overlay
 */
-(GPKGFeatureOverlay *) getFeatureOverlay;

/**
 *  Get the feature tiles
 *
 *  @return feature tiles
 */
-(GPKGFeatureTiles *) getFeatureTiles;

/**
 *  Get the geometry type
 *
 *  @return geometry type
 */
-(enum WKBGeometryType) getGeometryType;

/**
 *  Get the current zoom level of the map view
 *
 *  @param mapView map view
 *
 *  @return current zoom level
 */
-(double) currentZoomWithMapView: (MKMapView *) mapView;

/**
 *  Determine if the the feature overlay is on for the current zoom level of the map view
 *
 *  @param mapView map view
 *
 *  @return true if on
 */
-(BOOL) onAtCurrentZoomWithMapView: (MKMapView *) mapView;

/**
 *  Determine if the feature overlay is on for the provided zoom level
 *
 *  @param zoom zoom level
 *
 *  @return true if one
 */
-(BOOL) onAtZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the map point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     double zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the map point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom;

/**
 *  Get the count of features in the tile at the mapkit map point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     double zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the mapkit map point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom;

/**
 *  Get the count of features in the tile at the location coordinate and zoom level
 *
 *  @param location location coordinate
 *  @param zoom     double zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the location coordinate and zoom level
 *
 *  @param location location coordinate
 *  @param zoom     zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom;

/**
 *  Get the count of features in the tile at the point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     double zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithPoint: (WKBPoint *) point andDoubleZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the point and zoom level
 *
 *  @param mapPoint map point
 *  @param zoom     zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithPoint: (WKBPoint *) point andZoom: (int) zoom;

/**
 *  Determine if the provided count of features in the tile is more than the configured max features per tile
 *
 *  @param tileFeaturesCount tile feature count
 *
 *  @return true if more than the max features, false if less than or no configured max features
 */
-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount;

/**
 *  Build a bounding box using the map point click location and map view that can be used to query for features
 *
 *  @param mapPoint map point
 *  @param mapView  map view
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andMapView: (MKMapView *) mapView;

/**
 *  Build a bounding box using the mapkit map point click location and map view that can be used to query for features
 *
 *  @param mapPoint mapkit map point
 *  @param mapView  map view
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) buildClickBoundingBoxWithMKMapPoint: (MKMapPoint) mapPoint andMapView: (MKMapView *) mapView;

/**
 *  Build a bounding box using the point click location and map view that can be used to query for features
 *
 *  @param point   point
 *  @param mapView map view
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView;

/**
 *  Build a bounding box using the location coordinate click location and map view that can be used to query for features
 *
 *  @param location location coordinate
 *  @param mapView  map view
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView;

/**
 *  Build a bounding box using the cg point click location and map view that can be used to query for features
 *
 *  @param point   cg point
 *  @param mapView map view
 *
 *  @return bounding box
 */
-(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView;

/**
 *  Query for features in the WGS84 projected bounding box
 *
 *  @param boundingBox query bounding box in WGS84 projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for features in the bounding box
 *
 *  @param boundingBox query bounding box
 *  @param projection  bounding box projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox withProjection: (GPKGProjection *) projection;

/**
 *  Get a max features information message
 *
 *  @param tileFeaturesCount tile features count
 *
 *  @return max features message
 */
-(NSString *) buildMaxFeaturesInfoMessageWithTileFeaturesCount: (int) tileFeaturesCount;

/**
 *  Build a feature results information message and close the results
 *
 *  @param results feature index results
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results;

/**
 *  Build a feature results information message
 *
 *  @param results            feature index results
 *  @param locationCoordinate location coordinate
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate;

/**
 *  Build a feature results information message
 *
 *  @param results feature index results
 *  @param point   point
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andPoint: (WKBPoint *) point;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param point   cg point
 *  @param mapView map view
 *
 *  @return information message on what was clicked, or null
 */
-(NSString *) buildMapClickMessageWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param locationCoordinate   location coordinate
 *  @param mapView              map view
 *
 *  @return information message on what was clicked, or null
 */
-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView;

@end
