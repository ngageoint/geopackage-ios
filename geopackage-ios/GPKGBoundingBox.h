//
//  GPKGBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGBoundingBox : NSObject

@property (nonatomic, strong) NSDecimalNumber *minLongitude;
@property (nonatomic, strong) NSDecimalNumber *maxLongitude;
@property (nonatomic, strong) NSDecimalNumber *minLatitude;
@property (nonatomic, strong) NSDecimalNumber *maxLatitude;

-(instancetype) init;

-(instancetype) initWithMinLongitude: (NSDecimalNumber *) minLongitude
                      andMaxLongitude: (NSDecimalNumber *) maxLongitude
                      andMinLatitude: (NSDecimalNumber *) minLatitude
                      andMaxLatitude: (NSDecimalNumber *) maxLatitude;

-(instancetype) initWithMinLongitudeDouble: (double) minLongitude
                     andMaxLongitudeDouble: (double) maxLongitude
                      andMinLatitudeDouble: (double) minLatitude
                      andMaxLatitudeDouble: (double) maxLatitude;

-(BOOL) equals: (GPKGBoundingBox *) boundingBox;

-(MKMapRect) getMapRect;

-(MKCoordinateRegion) getCoordinateRegion;

-(MKCoordinateSpan) getSpan;

-(CLLocationCoordinate2D) getCenter;

@end
