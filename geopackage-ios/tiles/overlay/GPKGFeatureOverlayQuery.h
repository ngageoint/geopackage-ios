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
#import "GPKGFeatureInfoBuilder.h"

/**
 * Used to query the features represented by tiles, either being drawn from or linked to the features
 */
@interface GPKGFeatureOverlayQuery : NSObject

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
 *  Initialize
 *
 *  @param featureOverlay feature overlay
 *
 *  @return new feature overlay query
 */
-(instancetype) initWithFeatureOverlay: (GPKGFeatureOverlay *) featureOverlay;

/**
 *  Initialize
 *
 *  @param boundedOverlay bounded overlay
 *  @param featureTiles feature tiles
 *
 *  @return new feature overlay query
 */
-(instancetype) initWithBoundedOverlay: (GPKGBoundedOverlay *) boundedOverlay andFeatureTiles: (GPKGFeatureTiles *) featureTiles;

/**
 *  Get the bounded overlay
 *
 *  @return bounded overlay
 */
-(GPKGBoundedOverlay *) boundedOverlay;

/**
 *  Get the feature tiles
 *
 *  @return feature tiles
 */
-(GPKGFeatureTiles *) featureTiles;

/**
 *  Get the feature info builder
 *
 *  @return feature info builder
 */
-(GPKGFeatureInfoBuilder *) featureInfoBuilder;

/**
 *  Determine if the the feature overlay is on for the current zoom level of the map view at the location coordinate
 *
 *  @param mapView map view
 *  @param locationCoordinate location coordinate
 *
 *  @return true if on
 */
-(BOOL) onAtCurrentZoomWithMapView: (MKMapView *) mapView andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate;

/**
 *  Determine if the the feature overlay is on for the provided zoom level at the location coordinate
 *
 *  @param zoom zoom level
 *  @param locationCoordinate location coordinate
 *
 *  @return true if on
 */
-(BOOL) onAtZoom: (double) zoom andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate;

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
 *  @param point    point
 *  @param zoom     double zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithPoint: (SFPoint *) point andDoubleZoom: (double) zoom;

/**
 *  Get the count of features in the tile at the point and zoom level
 *
 *  @param point    point
 *  @param zoom     zoom value
 *
 *  @return tile feature count
 */
-(int) tileFeatureCountWithPoint: (SFPoint *) point andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the map point and zoom level
 *
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the map point and zoom level
 *
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the mapkit map point and zoom level
 *
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the mapkit map point and zoom level
 *
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the location coordinate and zoom level
 *
 * @param location location coordinate
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the location coordinate and zoom level
 *
 * @param location location coordinate
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the point and zoom level
 *
 * @param point   point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithPoint: (SFPoint *) point andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the point and zoom level
 *
 * @param point   point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsWithPoint: (SFPoint *) point andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the map point and zoom level
 *
 * @param projection desired bounding box projection
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMapPoint: (GPKGMapPoint *) mapPoint andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the map point and zoom level
 *
 * @param projection desired bounding box projection
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMapPoint: (GPKGMapPoint *) mapPoint andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the mapkit map point and zoom level
 *
 * @param projection desired bounding box projection
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMKMapPoint: (MKMapPoint) mapPoint andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the mapkit map point and zoom level
 *
 * @param projection desired bounding box projection
 * @param mapPoint map point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withMKMapPoint: (MKMapPoint) mapPoint andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the location coordinate and zoom level
 *
 * @param projection desired bounding box projection
 * @param location location coordinate
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withLocationCoordinate: (CLLocationCoordinate2D) location andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the location coordinate and zoom level
 *
 * @param projection desired bounding box projection
 * @param projection desired bounding box projection
 * @param location location coordinate
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withLocationCoordinate: (CLLocationCoordinate2D) location andZoom: (int) zoom;

/**
 * Get the WGS84 bounds of the tile at the point and zoom level
 *
 * @param projection desired bounding box projection
 * @param point   point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withPoint: (SFPoint *) point andDoubleZoom: (double) zoom;

/**
 * Get the WGS84 bounds of the tile at the point and zoom level
 *
 * @param projection desired bounding box projection
 * @param point   point
 * @param zoom   zoom level
 * @return WGS84 bounding box
 */
-(GPKGBoundingBox *) tileBoundsInProjection: (PROJProjection *) projection withPoint: (SFPoint *) point andZoom: (int) zoom;

/**
 *  Determine if the provided count of features in the tile is more than the configured max features per tile
 *
 *  @param tileFeaturesCount tile feature count
 *
 *  @return true if more than the max features, false if less than or no configured max features
 */
-(BOOL) moreThanMaxFeatures: (int) tileFeaturesCount;

/**
 *  Query for features in the WGS84 projected bounding box
 *
 *  @param boundingBox query bounding box in WGS84 projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for features in the WGS84 projected bounding box
 *
 *  @param columns          columns
 *  @param boundingBox query bounding box in WGS84 projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Query for features in the bounding box
 *
 *  @param boundingBox query bounding box
 *  @param projection  bounding box projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 *  Query for features in the bounding box
 *
 *  @param columns          columns
 *  @param boundingBox query bounding box
 *  @param projection  bounding box projection
 *
 *  @return feature index results, must be closed
 */
-(GPKGFeatureIndexResults *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 *  Check if the features are indexed
 *
 *  @return true if indexed
 */
-(BOOL) isIndexed;

/**
 *  Get a max features information message
 *
 *  @param tileFeaturesCount tile features count
 *
 *  @return max features message
 */
-(NSString *) buildMaxFeaturesInfoMessageWithTileFeaturesCount: (int) tileFeaturesCount;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param point   cg point
 *  @param mapView map view
 *
 *  @return information message on what was clicked, or nil
 */
-(NSString *) buildMapClickMessageWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param locationCoordinate   location coordinate
 *  @param mapView              map view
 *
 *  @return information message on what was clicked, or nil
 */
-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param locationCoordinate location coordinate
 *  @param mapView            map view
 *  @param projection         desired geometry projection
 *
 *  @return information message on what was clicked, or nil
 */
-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (PROJProjection *) projection;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param locationCoordinate location coordinate
 *  @param zoom               current zoom level
 *  @param mapBounds          map view bounds
 *  @param tolerance          distance and screen tolerance
 *
 *  @return information message on what was clicked, or nil
 */
-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance;

/**
 *  Perform a query based upon the map click location and build a info message
 *
 *  @param locationCoordinate location coordinate
 *  @param zoom               current zoom level
 *  @param mapBounds          map view bounds
 *  @param tolerance          distance and screen tolerance
 *  @param projection         desired geometry projection
 *
 *  @return information message on what was clicked, or nil
 */
-(NSString *) buildMapClickMessageWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection;

/**
 *  Perform a query based upon the map click location and build feature table data
 *
 *  @param locationCoordinate location coordinate
 *  @param mapView            map view
 *
 *  @return table data on what was clicked, or nil
 */
-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView;

/**
 *  Perform a query based upon the map click location and build feature table data
 *
 *  @param locationCoordinate location coordinate
 *  @param mapView            map view
 *  @param projection         desired geometry projection
 *
 *  @return table data on what was clicked, or nil
 */
-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andMapView: (MKMapView *) mapView andProjection: (PROJProjection *) projection;

/**
 *  Perform a query based upon the map click location and build feature table data
 *
 *  @param locationCoordinate location coordinate
 *  @param zoom               current zoom level
 *  @param mapBounds          map view bounds
 *  @param tolerance          distance and screen tolerance
 *
 *  @return table data on what was clicked, or nil
 */
-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance;

/**
 *  Perform a query based upon the map click location and build feature table data
 *
 *  @param locationCoordinate location coordinate
 *  @param zoom               current zoom level
 *  @param mapBounds          map view bounds
 *  @param tolerance          distance and screen tolerance
 *  @param projection         desired geometry projection
 *
 *  @return table data on what was clicked, or nil
 */
-(GPKGFeatureTableData *) buildMapClickTableDataWithLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andZoom: (double) zoom andMapBounds: (GPKGBoundingBox *) mapBounds andTolerance: (GPKGMapTolerance *) tolerance andProjection: (PROJProjection *) projection;

@end
