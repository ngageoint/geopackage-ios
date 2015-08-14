//
//  GPKGMapPoint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/22/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "WKBPoint.h"
#import "GPKGMapPointOptions.h"

@interface GPKGMapPoint : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title, *subtitle;
@property (nonatomic) NSUInteger id;
@property (nonatomic, strong) GPKGMapPointOptions * options;
@property (nonatomic, strong) NSObject * data;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

- (id)initWithLatitude: (double) latitude andLongitude: (double) longitude;

- (id)initWithPoint: (WKBPoint *) point;

- (id)initWithMKMapPoint: (MKMapPoint) point;

-(NSNumber *) getIdAsNumber;

@end
