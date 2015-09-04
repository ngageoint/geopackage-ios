//
//  GPKGSLocationCoordinate3D.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

/**
 *  3D Location Coordinate
 */
@interface GPKGSLocationCoordinate3D : NSObject

/**
 *  Location Coordinate
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  Z Altitude
 */
@property (nonatomic, strong) NSDecimalNumber *z;

/**
 *  Initialize as 2D coordinate
 *
 *  @param coordinate coordinate
 *
 *  @return new coordinate
 */
-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate;

/**
 *  Initialize as 2D or 3D coordinate
 *
 *  @param coordinate coorindate
 *  @param z          z coordinate
 *
 *  @return new coordinate
 */
-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate andZ: (NSDecimalNumber *) z;

/**
 *  Has z coordinate?
 *
 *  @return true if 3D, false if 2D
 */
-(BOOL) hasZ;

@end
