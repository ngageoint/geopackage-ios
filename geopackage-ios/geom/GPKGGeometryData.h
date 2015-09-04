//
//  GPKGGeometryData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKBGeometryEnvelope.h"
#import "WKBGeometry.h"

/**
 *  GeoPackage Geometry Data
 */
@interface GPKGGeometryData : NSObject

/**
 *  Byte data
 */
@property (nonatomic, strong) NSData * bytes;

/**
 *  True if an extended geometry, false if standard
 */
@property (nonatomic) BOOL extended;

/**
 *  True if the geometry is empty
 */
@property (nonatomic) BOOL empty;

/**
 *  Byte ordering, big or little endian
 */
@property (nonatomic) CFByteOrder byteOrder;

/**
 *  Spatial Reference System Id
 */
@property (nonatomic, strong) NSNumber * srsId;

/**
 *  Geometry envelope
 */
@property (nonatomic, strong) WKBGeometryEnvelope * envelope;

/**
 *  Well-Known Binary Geometry index of where the bytes start
 */
@property (nonatomic) int wkbGeometryIndex;

/**
 *  Geometry
 */
@property (nonatomic, strong) WKBGeometry * geometry;

/**
 *  Initialize
 *
 *  @param srsId Spatial Reference System Id
 *
 *  @return new geometry data
 */
-(instancetype) initWithSrsId: (NSNumber *) srsId;

/**
 *  Initialize
 *
 *  @param bytes byte data
 *
 *  @return new geometry data
 */
-(instancetype) initWithData: (NSData *) bytes;

/**
 *  Populate the geometry data from the byte data
 *
 *  @param bytes byte data
 */
-(void) fromData: (NSData *) bytes;

/**
 *  Write the geometry to byte data
 *
 *  @return byte data
 */
-(NSData *) toData;

/**
 * Set the geometry. Updates the empty flag and if the geometry is not null,
 * the extended flag
 *
 *  @param geometry geometry
 */
-(void) setGeometry:(WKBGeometry *) geometry;

/**
 *  Get the GeoPackage header byte data
 *
 *  @return header byte data
 */
-(NSData *) getHeaderData;

/**
 *  Get the Well-Known Binary Geometry byte data
 *
 *  @return wkb byte data
 */
-(NSData *) getWkbData;

/**
 * Get the envelope flag indicator
 *
 * 1 for xy, 2 for xyz, 3 for xym, 4 for xyzm (null would be 0)
 *
 *  @param envelope geometry envelope
 *
 *  @return flag indicator
 */
+(int) getIndicatorWithEnvelope: (WKBGeometryEnvelope *) envelope;

@end
