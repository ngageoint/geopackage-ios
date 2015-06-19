//
//  GPKGMapShapeConverter.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGMapShapeConverter : NSObject

-(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points;

//TODO

@end
