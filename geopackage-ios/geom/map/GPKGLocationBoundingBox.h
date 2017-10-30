//
//  GPKGLocationBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/30/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/**
 * Location Bounding Box, contains left, up, right, and down coordinates
 */
@interface GPKGLocationBoundingBox : NSObject

/**
 * Left coordinate
 */
@property (nonatomic) CLLocationCoordinate2D leftCoordinate;

/**
 * Up coordinate
 */
@property (nonatomic) CLLocationCoordinate2D upCoordinate;

/**
 * Right coordinate
 */
@property (nonatomic) CLLocationCoordinate2D rightCoordinate;

/**
 * Down coordinate
 */
@property (nonatomic) CLLocationCoordinate2D downCoordinate;

/**
 *  Initialize
 *
 *  @return new location boundingbox
 */
-(instancetype) initWithLeft: (CLLocationCoordinate2D) left andUp: (CLLocationCoordinate2D) up andRight: (CLLocationCoordinate2D) right andDown: (CLLocationCoordinate2D) down;

@end
