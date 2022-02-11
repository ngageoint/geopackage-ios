//
//  GPKGBoundingBox.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "SFGeometryEnvelope.h"
#import "SFPGeometryTransform.h"

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
@interface GPKGBoundingBox : NSObject <NSMutableCopying>

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
 *  Create a new WGS84 bounding box with world bounds (degrees)
 *
 *  @return new bounding box
 */
+(GPKGBoundingBox *) worldWGS84;

/**
 *  Create a new Web Mercator bounding box with world bounds (meters)
 *
 *  @return new bounding box
 */
+(GPKGBoundingBox *) worldWebMercator;

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
 *  @param minLatitude  minimum latitude
 *  @param maxLongitude maximum longitude
 *  @param maxLatitude  maximum latitude
 *
 *  @return new bounding box
 */
-(instancetype) initWithMinLongitude: (NSDecimalNumber *) minLongitude
                      andMinLatitude: (NSDecimalNumber *) minLatitude
                      andMaxLongitude: (NSDecimalNumber *) maxLongitude
                      andMaxLatitude: (NSDecimalNumber *) maxLatitude;

/**
 *  Initialize with double range
 *
 *  @param minLongitude minimum longitude
 *  @param minLatitude  minimum latitude
 *  @param maxLongitude maximum longitude
 *  @param maxLatitude  maximum latitude
 *
 *  @return new bounding box
 */
-(instancetype) initWithMinLongitudeDouble: (double) minLongitude
                      andMinLatitudeDouble: (double) minLatitude
                     andMaxLongitudeDouble: (double) maxLongitude
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
 *  Initialize with geometry envelope
 *
 *  @param envelope geometry envelope
 *
 *  @return new bounding box
 */
-(instancetype) initWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 *  Initialize with geometry
 *
 *  @param geometry geometry
 *
 *  @return new bounding box
 */
-(instancetype) initWithGeometry: (SFGeometry *) geometry;

/**
 * Get the longitude range
 *
 * @return longitude range
 */
-(NSDecimalNumber *) longitudeRange;

/**
 * Get the longitude range
 *
 * @return longitude range
 */
-(double) longitudeRangeValue;

/**
 * Get the latitude range
 *
 * @return latitude range
 */
 -(NSDecimalNumber *) latitudeRange;

/**
* Get the latitude range
*
* @return latitude range
*/
-(double) latitudeRangeValue;

/**
 * Get the bounding box centroid point
 *
 * @return centroid point
 */
-(SFPoint *) centroid;

/**
 * Get the bounding box centroid point
 *
 * @param boundingBox
 *            bounding box
 *
 * @return centroid point
 */
+(SFPoint *) centroidOfBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Get the centroid for the bounding box and projection
 *
 * @param projection
 *            projection of the bounding box
 * @return centroid point
 */
-(SFPoint *) centroidInProjection: (PROJProjection *) projection;

/**
 * Get the centroid for the bounding box and projection
 *
 * @param boundingBox
 *            bounding box
 * @param projection
 *            projection of the bounding box
 * @return centroid point
 */
+(SFPoint *) centroidOfBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection;

/**
 * Get the centroid for the bounding box in degrees
 *
 * @return centroid point
 */
-(SFPoint *) degreesCentroid;

/**
 * Get the centroid for a bounding box in degrees
 *
 * @param boundingBox
 *            bounding box in degrees
 * @return centroid point
 */
+(SFPoint *) degreesCentroidOfBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Build a Geometry Envelope from the bounding box
 *
 * @return geometry envelope
 */
-(SFGeometryEnvelope *) buildEnvelope;

/**
 * Build a Geometry Envelope from the bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return geometry envelope
 */
+(SFGeometryEnvelope *) buildEnvelopeFromBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 * Build a geometry representation of the bounding box
 *
 * @return geometry, polygon or point
 */
-(SFGeometry *) buildGeometry;

/**
 * Build a geometry representation of the bounding box
 *
 * @param boundingBox
 *            bounding box
 *
 * @return geometry, polygon or point
 */
+(SFGeometry *) buildGeometryFromBoundingBox: (GPKGBoundingBox *) boundingBox;

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
-(MKMapRect) mapRect;

/**
 *  Get a Coordinate Region of the bounding box
 *
 *  @return Coordinate Region
 */
-(MKCoordinateRegion) coordinateRegion;

/**
 *  Get the Span of the bounding box
 *
 *  @return Span
 */
-(MKCoordinateSpan) span;

/**
 *  Get the center of the bounding box
 *
 *  @return center location
 */
-(CLLocationCoordinate2D) center;

/**
 *  Get with width and height of the bounding box in meters
 *
 *  @return bounding box size
 */
-(struct GPKGBoundingBoxSize) sizeInMeters;

/**
 *  If the bounding box spans the Anti-Meridian, attempt to get a complementary bounding box using the max longitude of the unit projection
 *
 *  @param maxProjectionLongitude max longitude of the world for the current bounding box units
 *
 *  @return complementary bounding box or nil if none
 */
-(GPKGBoundingBox *) complementaryWithMaxLongitude: (double) maxProjectionLongitude;

/**
 *  If the bounding box spans the Anti-Meridian, attempt to get a complementary WGS84 bounding box
 *
 *  @return complementary bounding box or nil if none
 */
-(GPKGBoundingBox *) complementaryWgs84;

/**
 *  If the bounding box spans the Anti-Meridian, attempt to get a complementary Web Mercator bounding box
 *
 *  @return complementary bounding box or nil if none
 */
-(GPKGBoundingBox *) complementaryWebMercator;

/**
 * Bound the bounding box longitudes within the min and max possible
 * projection values. This may result in a max longitude numerically lower
 * than the min longitude.
 *
 * @param maxProjectionLongitude
 *            max longitude of the world for the current bounding box units
 * @return bounded bounding box
 */
-(GPKGBoundingBox *) boundCoordinatesWithMaxLongitude: (double) maxProjectionLongitude;

/**
 * Bound the bounding box coordinates within WGS84 range values
 *
 * @return bounded bounding box
 */
-(GPKGBoundingBox *) boundWgs84Coordinates;

/**
 * Bound the bounding box coordinates within Web Mercator range values
 *
 * @return bounded bounding box
 */
-(GPKGBoundingBox *) boundWebMercatorCoordinates;

/**
 * Expand the bounding box max longitude above the max possible projection
 * value if needed to create a bounding box where the max longitude is
 * numerically larger than the min longitude.
 *
 * @param maxProjectionLongitude
 *            max longitude of the world for the current bounding box units
 * @return expanded bounding box
 */
-(GPKGBoundingBox *) expandCoordinatesWithMaxLongitude: (double) maxProjectionLongitude;

/**
 * Expand the bounding box max longitude above the max WGS84 projection
 * value if needed to create a bounding box where the max longitude is
 * numerically larger than the min longitude.
 *
 * @return expanded bounding box
 */
-(GPKGBoundingBox *) expandWgs84Coordinates;

/**
 * Expand the bounding box max longitude above the max Web Mercator
 * projection value if needed to create a bounding box where the max
 * longitude is numerically larger than the min longitude.
 *
 * @return expanded bounding box
 */
-(GPKGBoundingBox *) expandWebMercatorCoordinates;

/**
 * Transform the bounding box using the provided projection transform
 *
 * @param transform
 *            geometry transform
 * @return transformed bounding box
 */
-(GPKGBoundingBox *) transform: (SFPGeometryTransform *) transform;

/**
 * Determine if intersects with the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return true if intersects
 */
-(BOOL) intersects: (GPKGBoundingBox *) boundingBox;

/**
 * Determine if intersects with the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @param allowEmpty
 *            allow empty ranges when determining intersection
 *
 * @return true if intersects
 */
-(BOOL) intersects: (GPKGBoundingBox *) boundingBox withAllowEmpty: (BOOL) allowEmpty;

/**
 * Get the overlapping bounding box with the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return bounding box
 */
-(GPKGBoundingBox *) overlap: (GPKGBoundingBox *) boundingBox;

/**
 * Get the overlapping bounding box with the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @param allowEmpty
 *            allow empty ranges when determining overlap
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) overlap: (GPKGBoundingBox *) boundingBox withAllowEmpty: (BOOL) allowEmpty;

/**
 * Get the union bounding box with the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return bounding box
 */
-(GPKGBoundingBox *) union: (GPKGBoundingBox *) boundingBox;

/**
 * Determine if inclusively contains the provided bounding box
 *
 * @param boundingBox
 *            bounding box
 * @return true if contains
 */
-(BOOL) contains: (GPKGBoundingBox *) boundingBox;

/**
 * Expand the bounding box to an equally sized width and height bounding box
 *
 * @return new square expanded bounding box
 */
-(GPKGBoundingBox *) squareExpand;

/**
 * Expand the bounding box to an equally sized width and height bounding box
 * with optional empty edge buffer
 *
 * @param bufferPercentage
 *            bounding box edge buffer percentage. A value of 0.1 adds a 10%
 *            buffer on each side of the squared bounding box.
 * @return new square expanded bounding box
 */
-(GPKGBoundingBox *) squareExpandWithBuffer: (double) bufferPercentage;

/**
 * Determine if the bounding box is of a single point
 *
 * @return true if a single point bounds
 */
-(BOOL) isPoint;

@end
