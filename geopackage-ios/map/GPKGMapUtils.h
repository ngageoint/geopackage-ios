//
//  GPKGMapUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GPKGBoundingBox.h"

/**
 *  Map utility methods
 */
@interface GPKGMapUtils : NSObject

/**
 *  Get the current zoom level of the map view
 *
 *  @param mapView map view
 *
 *  @return current zoom level
 */
+(double) currentZoomWithMapView: (MKMapView *) mapView;

/**
 *  Get the WGS84 bounding box of the current map view screen
 *
 *  @param mapView map view
 *
 *  @return current bounding box
 */
+(GPKGBoundingBox *) boundingBoxOfMapView: (MKMapView *) mapView;

@end
