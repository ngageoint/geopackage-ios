//
//  GPKGSLocationCoordinate3D.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface GPKGSLocationCoordinate3D : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSDecimalNumber *z;

-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate;

-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate andZ: (NSDecimalNumber *) z;

-(BOOL) hasZ;

@end
