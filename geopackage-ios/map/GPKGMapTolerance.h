//
//  GPKGMapTolerance.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/6/17.
//  Copyright (c) 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Map tolerance values distance and screen distances
 */
@interface GPKGMapTolerance : NSObject

/**
 *  Distance tolerance in meters
 */
@property (nonatomic) double distance;

/**
 *  Screen tolerance in pixels
 */
@property (nonatomic) double screen;

/**
 *  Initialize
 *
 *  @return new map tolerance
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param distance distance tolerance in meters
 *  @param screen   screen tolerance in pixels
 *
 *  @return new map tolerance
 */
-(instancetype) initWithDistance: (double) distance andScreen: (double) screen;

@end
