//
//  GPKGBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "WKBGeometryEnvelope.h"

/**
 *  Bounding box width and height struct
 */
struct GPKGBoundingBoxSize{
    double width;
    double height;
};

/**
 *  Bounding box with longitude and latitude range
 */
@interface GPKGBoundingBox : NSObject

/**
 *  Longitude range
 */
@property (nonatomic, strong) NSDecimalNumber *minLongitude;
@property (nonatomic, strong) NSDecimalNumber *maxLongitude;

/**
 *  Latitude range
 */
@property (nonatomic, strong) NSDecimalNumber *minLatitude;
@property (nonatomic, strong) NSDecimalNumber *maxLatitude;

/**
 *  Initialize with degrees representing the entire world
 *
 *  @return new bounding box
 */
-(instancetype) init;

/**
 *  Initialize with number range
 *
 *  @param minLongitude minimum longitude
 *  @param maxLongitude maximum longitude
 *  @param minLatitude  minimum latitude
 *  @param maxLatitude  maximum latitude
 *
 *  @return new bounding box
 */
-(instancetype) initWithMinLongitude: (NSDecimalNumber *) minLongitude
                      andMaxLongitude: (NSDecimalNumber *) maxLongitude
                      andMinLatitude: (NSDecimalNumber *) minLatitude
                      andMaxLatitude: (NSDecimalNumber *) maxLatitude;

/**
 *  Initialize with double range
 *
 *  @param minLongitude minimum longitude
 *  @param maxLongitude maximum longitude
 *  @param minLatitude  minimum latitude
 *  @param maxLatitude  maximum latitude
 *
 *  @return new bounding box
 */
-(instancetype) initWithMinLongitudeDouble: (double) minLongitude
                     andMaxLongitudeDouble: (double) maxLongitude
                      andMinLatitudeDouble: (double) minLatitude
                      andMaxLatitudeDouble: (double) maxLatitude;

/**
 *  Initialize with existing bounding box
 *
 *  @param boundingBox bounding box
 *
 *  @return new bounding box
 */
-(instancetype) initWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Build a Geometry Envelope from the bounding box
 *
 * @return geometry envelope
 */
-(WKBGeometryEnvelope *) buildEnvelope;

/**
 *  Determine if equal to the provided bounding box
 *
 *  @param boundingBox bounding box
 *
 *  @return true if equal, false if not
 */
-(BOOL) equals: (GPKGBoundingBox *) boundingBox;

/**
 *  Get a Map Rectangle representing the bounding box
 *
 *  @return map rectangle
 */
-(MKMapRect) getMapRect;

/**
 *  Get a Coordinate Region of the bounding box
 *
 *  @return Coordinate Region
 */
-(MKCoordinateRegion) getCoordinateRegion;

/**
 *  Get the Span of the bounding box
 *
 *  @return Span
 */
-(MKCoordinateSpan) getSpan;

/**
 *  Get the center of the bounding box
 *
 *  @return center location
 */
-(CLLocationCoordinate2D) getCenter;

/**
 *  Get with width and height of the bounding box in meters
 *
 *  @return bounding box size
 */
-(struct GPKGBoundingBoxSize) sizeInMeters;

@end
