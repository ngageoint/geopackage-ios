//
//  GPKGMapShapeConverter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapeConverter.h"

@implementation GPKGMapShapeConverter

-(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points{
    CLLocationCoordinate2D *coordinates = calloc([points count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(MKPointAnnotation * point in points){
        coordinates[index++] = point.coordinate;
    }
    return coordinates;
}

//TODO

@end
