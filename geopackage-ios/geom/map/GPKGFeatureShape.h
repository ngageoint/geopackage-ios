//
//  GPKGFeatureShape.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/15/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGMapShape.h"

@interface GPKGFeatureShape : NSObject

/**
 *  Initializer
 *
 *  @param featureId feature id
 *
 *  @return new feature shape
 */
-(instancetype) initWithId: (int) featureId;

/**
 * Get feature id
 *
 * @return feature id
 */
-(int) featureId;

/**
 * Get the map shapes
 *
 * @return map shapes
 */
-(NSMutableArray<GPKGMapShape *> *) shapes;

/**
 * Get the map metadata shapes
 *
 * @return map metadata shapes
 */
-(NSMutableArray<GPKGMapShape *> *) metadataShapes;

/**
 * Add a map shape
 *
 * @param shape map shape
 */
-(void) addShape: (GPKGMapShape *) shape;

/**
 * Add a metadata map shape
 *
 * @param shape metadata map shape
 */
-(void) addMetadataShape: (GPKGMapShape *) shape;

/**
 * Get the count of map shapes
 *
 * @return map shapes count
 */
-(int) count;

/**
 * Determine if there are map shapes
 *
 * @return true if has map shapes
 */
-(BOOL) hasShapes;

/**
 * Get the count of map metadata shapes
 *
 * @return map metadata shapes count
 */
-(int) countMetadataShapes;

/**
 * Determine if there are map metadata shapes
 *
 * @return true if has map metadata shapes
 */
-(BOOL) hasMetadataShapes;

/**
 * Remove all map shapes and metadata map shapes from the map and feature shape
 *
 * @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 * Remove the map shapes from the map and feature shape
 *
 * @param mapView map view
 */
-(void) removeShapesFromMapView: (MKMapView *) mapView;

/**
 * Remove the map metadata shapes from the map and feature shape
 *
 * @param mapView map view
 */
-(void) removeMetadataShapesFromMapView: (MKMapView *) mapView;

@end
