//
//  GPKGLocationBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/30/17.
//  Copyright © 2017 NGA. All rights reserved.
//

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
 *  @param coordinate coordinate
 *  @return new location boundingbox
 */
-(instancetype) initWithCoordinate: (CLLocationCoordinate2D) coordinate;

/**
 *  Initialize
 *
 *  @param left   left coordinate
 *  @param up       up coordinate
 *  @param right right coordinate
 *  @param down   down coordinate
 *  @return new location boundingbox
 */
-(instancetype) initWithLeft: (CLLocationCoordinate2D) left andUp: (CLLocationCoordinate2D) up andRight: (CLLocationCoordinate2D) right andDown: (CLLocationCoordinate2D) down;

/**
 * Get the west coordinate
 *
 * @return west coordinate
 */
-(CLLocationCoordinate2D) westCoordinate;

/**
 * Get the northwest coordinate
 *
 * @return northwest coordinate
 */
-(CLLocationCoordinate2D) northwestCoordinate;

/**
 * Get the north coordinate
 *
 * @return north coordinate
 */
-(CLLocationCoordinate2D) northCoordinate;

/**
 * Get the northeast coordinate
 *
 * @return northeast coordinate
 */
-(CLLocationCoordinate2D) northeastCoordinate;

/**
 * Get the east coordinate
 *
 * @return east coordinate
 */
-(CLLocationCoordinate2D) eastCoordinate;

/**
 * Get the southeast coordinate
 *
 * @return southeast coordinate
 */
-(CLLocationCoordinate2D) southeastCoordinate;

/**
 * Get the south coordinate
 *
 * @return south coordinate
 */
-(CLLocationCoordinate2D) southCoordinate;

/**
 * Get the southwest coordinate
 *
 * @return southwest coordinate
 */
-(CLLocationCoordinate2D) southwestCoordinate;

@end
