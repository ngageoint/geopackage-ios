//
//  GPKGMultiPoint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGShapePoints.h"
#import "GPKGMapPoint.h"

/**
 *  Multi point shape
 */
@interface GPKGMultiPoint : NSObject <GPKGShapePoints>

/**
 *  Points
 */
@property (nonatomic, strong) NSMutableArray *points;

/**
 *  Initialize
 *
 *  @return new multi point
 */
-(instancetype) init;

/**
 *  Add a point
 *
 *  @param point point
 */
-(void) addPoint: (GPKGMapPoint *) point;

/**
 *  Remove the multi point from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

@end
