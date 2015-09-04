//
//  GPKGMultiPolygon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

/**
 *  Multi polygon shape
 */
@interface GPKGMultiPolygon : NSObject

/**
 *  Polygons
 */
@property (nonatomic, strong) NSMutableArray *polygons;

/**
 *  Initialize
 *
 *  @return new multi polygon
 */
-(instancetype) init;

/**
 *  Add a polygon
 *
 *  @param polygon polygon
 */
-(void) addPolygon: (MKPolygon *) polygon;

/**
 *  Remove the multi polygon shape from the map view
 *
 *  @param mapView map view
 */
-(void) removeFromMapView: (MKMapView *) mapView;

@end
