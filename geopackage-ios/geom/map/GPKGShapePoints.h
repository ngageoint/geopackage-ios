//
//  GPKGShapePoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGShapePoints_h
#define geopackage_ios_GPKGShapePoints_h

@import MapKit;
#import "GPKGMapPoint.h"

@protocol GPKGShapePoints <NSObject>

-(NSArray *) getPoints;

-(void) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView * ) mapView;

-(void) addNewPoint: (GPKGMapPoint *) point;

@end

#endif