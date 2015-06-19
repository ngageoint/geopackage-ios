//
//  GPKGMapShapePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGMapShapePoints : NSObject

+(void) addPointAsPolygon: (MKPointAnnotation *) point toPoints: (NSArray *) points;

+(void) addPointAsPolyline: (MKPointAnnotation *) point toPoints: (NSArray *) points;

@end
