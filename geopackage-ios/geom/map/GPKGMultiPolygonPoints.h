//
//  GPKGMultiPolygonPoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPolygonPoints.h"

@class GPKGPolygonPoints;

/**
 *  Multiple Polygon Points shape
 */
@interface GPKGMultiPolygonPoints : NSObject

/**
 *  Polygon points
 */
@property (nonatomic, strong) NSMutableArray *polygonPoints;

/**
 *  Initialize
 *
 *  @return new multiple polygon points
 */
-(instancetype) init;

/**
 *  Add a polygon points shape
 *
 *  @param polygonPoints polygon points
 */
-(void) addPolygonPoints: (GPKGPolygonPoints *) polygonPoints;

/**
 *  Update the multiple polygon points with the map view
 *
 *  @param mapView map view
 */
-(void) updateWithMapView: (MKMapView *) mapView;

/**
 *  Remove the multiple polygon points from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

/**
 *  Determine if the multiple polygon points is valid
 *
 *  @return true if valid
 */
-(BOOL) isValid;

/**
 *  Determine if the multiple polygon points has been deleted
 *
 *  @return true if deleted
 */
-(BOOL) isDeleted;

@end
