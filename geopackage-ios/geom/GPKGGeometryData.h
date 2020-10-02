//
//  GPKGGeometryData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFGeometryEnvelope.h"
#import "SFGeometry.h"
#import "SFGeometryFilter.h"
#import "SFPProjectionTransform.h"

/**
 *  GeoPackage Geometry Data
 */
@interface GPKGGeometryData : NSObject

/**
 *  Byte data
 */
@property (nonatomic, strong) NSData *bytes;

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
@property (nonatomic, strong) NSNumber *srsId;

/**
 *  Geometry envelope
 */
@property (nonatomic, strong) SFGeometryEnvelope *envelope;

/**
 *  Well-Known Binary Geometry index of where the bytes start
 */
@property (nonatomic) int wkbGeometryIndex;

/**
 *  Geometry
 */
@property (nonatomic, strong) SFGeometry *geometry;

/**
 * Get geometry filter
 *
 * @return geometry filter
 */
+(NSObject<SFGeometryFilter> *) geometryFilter;

/**
 * Set the geometry filter
 *
 * @param filter
 *            geometry filter
 */
+(void) setGeometryFilter: (NSObject<SFGeometryFilter> *) filter;

/**
 * Get the default SRS id
 *
 * @return SRS id
 */
+(NSNumber *) defaultSrsId;

/**
 * Set the default SRS id
 *
 * @param srsId
 *            SRS id
 */
+(void) setDefaultSrsId: (NSNumber *) srsId;

/**
 * Get the default byte order
 *
 * @return byte order
 */
+(int) defaultByteOrder;

/**
 * Set the default byte order
 *
 * @param byteOrder
 *            byte order
 */
+(void) setDefaultByteOrder: (int) byteOrder;

/**
 * Create geometry data, default SRS Id of {@link #defaultSrsId}
 *
 * @return geometry data
 */
+(GPKGGeometryData *) create;

/**
 * Create geometry data, default SRS Id of {@link #defaultSrsId}
 *
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createWithGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data and build the envelope, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeWithGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data
 *
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId;

/**
 * Create geometry data
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data and build the envelope
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data and write the GeoPackage geometry bytes, default SRS
 * Id of {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteWithGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data, build the envelope, and write the GeoPackage
 * geometry bytes, default SRS Id of {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteWithGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data and write the GeoPackage geometry bytes
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry;

/**
 * Create geometry data, build the envelope, and write the GeoPackage
 * geometry bytes
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry;

/**
 * Create the geometry data from GeoPackage geometry bytes
 *
 * @param bytes
 *            GeoPackage geometry bytes
 * @return geometry data
 */
+(GPKGGeometryData *) createWithData: (NSData *) bytes;

/**
 * Create the geometry data, default SRS Id of {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @param envelope
 *            geometry envelope
 * @return geometry data
 */
+(GPKGGeometryData *) createWithGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Create the geometry data
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @param envelope
 *            geometry envelope
 * @return geometry data
 */
+(GPKGGeometryData *) createWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Copy the geometry data and create
 *
 * @param geometryData
 *            geometry data
 * @return geometry data
 */
+(GPKGGeometryData *) createWithGeometryData: (GPKGGeometryData *) geometryData;

/**
 * Create the geometry data from Well-Known Bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkb: (NSData *) bytes;

/**
 * Create the geometry data from Well-Known Bytes and build the envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) bytes;

/**
 * Create the geometry data from Well-Known Bytes
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes and build the envelope
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes and write the GeoPackage
 * geometry bytes, default SRS Id of {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) bytes;

/**
 * Create the geometry data from Well-Known Bytes, build the envelope, and
 * write the GeoPackage geometry bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) bytes;

/**
 * Create the geometry data from Well-Known Bytes and write the GeoPackage
 * geometry bytes
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes, build the envelope, and
 * write the GeoPackage geometry bytes
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * Create a geometry from Well-Known Bytes
 *
 * @param bytes
 *            well-known bytes
 * @return geometry
 */
+(SFGeometry *) createGeometryFromWkb: (NSData *) bytes;

/**
 * Create the geometry data from Well-Known Text, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkt: (NSString *) text;

/**
 * Create the geometry data from Well-Known Text and build the envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkt: (NSString *) text;

/**
 * Create the geometry data from Well-Known Text
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Text and build the envelope
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Text and write the GeoPackage
 * geometry bytes, default SRS Id of {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkt: (NSString *) text;

/**
 * Create the geometry data from Well-Known Text, build the envelope, and
 * write the GeoPackage geometry bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkt: (NSString *) text;

/**
 * Create the geometry data from Well-Known Text and write the GeoPackage
 * geometry bytes
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Text, build the envelope, and
 * write the GeoPackage geometry bytes
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Create a geometry from Well-Known Text
 *
 * @param text
 *            well-known text
 * @return geometry
 */
+(SFGeometry *) createGeometryFromWkt: (NSString *) text;

/**
 * GeoPackage geometry bytes from the geometry, default SRS Id of
 * {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromGeometry: (SFGeometry *) geometry;

/**
 * GeoPackage geometry bytes from the geometry with built envelope, default
 * SRS Id of {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry;

/**
 * GeoPackage geometry bytes from the geometry
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from the geometry with built envelope
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromWkb: (NSData *) bytes;

/**
 * GeoPackage geometry bytes from Well-Known bytes with built envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param bytes
 *            well-known bytes
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) bytes;

/**
 * GeoPackage geometry bytes from Well-Known bytes
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known bytes with built envelope
 *
 * @param bytes
 *            well-known bytes
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) bytes withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known text, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromWkt: (NSString *) text;

/**
 * GeoPackage geometry bytes from Well-Known text with built envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text;

/**
 * GeoPackage geometry bytes from Well-Known text
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known text with built envelope
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry bytes
 */
+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Well-Known Bytes from the geometry data
 *
 * @param geometryData
 *            geometry data
 * @return well-known bytes
 */
+(NSData *) wkbFromGeometryData: (GPKGGeometryData *) geometryData;

/**
 * Well-Known Bytes from the geometry
 *
 * @param geometry
 *            geometry
 * @return well-known bytes
 */
+(NSData *) wkbFromGeometry: (SFGeometry *) geometry;

/**
 * Well-Known Bytes from GeoPackage geometry bytes
 *
 * @param bytes
 *            GeoPackage geometry bytes
 * @return well-known bytes
 */
+(NSData *) wkbFromData: (NSData *) bytes;

/**
 * Well-Known Bytes from Well-Known Text
 *
 * @param text
 *            well-known text
 * @return well-known bytes
 */
+(NSData *) wkbFromWkt: (NSString *) text;

/**
 * Well-Known Text from the geometry data
 *
 * @param geometryData
 *            geometry data
 * @return well-known text
 */
+(NSString *) wktFromGeometryData: (GPKGGeometryData *) geometryData;

/**
 * Well-Known Text from the geometry
 *
 * @param geometry
 *            geometry
 * @return well-known text
 */
+(NSString *) wktFromGeometry: (SFGeometry *) geometry;

/**
 * Well-Known Text from GeoPackage Geometry Bytes
 *
 * @param bytes
 *            GeoPackage geometry bytes
 * @return well-known text
 */
+(NSString *) wktFromData: (NSData *) bytes;

/**
 * Well-Known Text from Well-Known Bytes
 *
 * @param bytes
 *            well-known bytes
 * @return well-known text
 */
+(NSString *) wktFromWkb: (NSData *) bytes;

/**
 * Default Initialize, default SRS Id of {@link #defaultSrsId}
 *
 * @return new geometry data
 */
-(instancetype) init;

/**
 * Initialize, default SRS Id of {@link #defaultSrsId}
 *
 * @param geometry
 *            geometry
 *
 * @return new geometry data
 */
-(instancetype) initWithGeometry: (SFGeometry *) geometry;

/**
 * Initialize
 *
 * @param geometry
 *            geometry
 * @param buildEnvelope
 *            true to build and set the envelope
 *
 * @return new geometry data
 */
-(instancetype) initWithGeometry: (SFGeometry *) geometry andBuildEnvelope: (BOOL) buildEnvelope;

/**
 * Initialize
 *
 * @param srsId Spatial Reference System Id
 *
 * @return new geometry data
 */
-(instancetype) initWithSrsId: (NSNumber *) srsId;

/**
 * Initialize
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 *
 * @return new geometry data
 */
-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry;

/**
 * Initialize
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @param buildEnvelope
 *            true to build and set the envelope
 *
 * @return new geometry data
 */
-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andBuildEnvelope: (BOOL) buildEnvelope;

/**
 * Initialize, default SRS Id of {@link #defaultSrsId}
 *
 * @param geometry
 *            geometry
 * @param envelope
 *            geometry envelope
 *
 * @return new geometry data
 */
-(instancetype) initWithGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Initialize
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @param envelope
 *            geometry envelope
 *
 * @return new geometry data
 */
-(instancetype) initWithSrsId: (NSNumber *) srsId andGeometry: (SFGeometry *) geometry andEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Copy Initialize
 *
 * @param geometryData
 *            geometry data
 *
 * @return new geometry data
 */
-(instancetype) initWithGeometryData: (GPKGGeometryData *) geometryData;

/**
 * Initialize
 *
 * @param bytes byte data
 *
 * @return new geometry data
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
 * the extended flag. Following invoking this method and upon setting the
 * SRS id, call {@link #toData} to convert the geometry to bytes.
 * Alternatively call {@link #setGeometryToData(Geometry)} or
 * {@link #setGeometryAndBuildEnvelopeToData(Geometry)} to perform both
 * operations.
 *
 *  @param geometry geometry
 */
-(void) setGeometry:(SFGeometry *) geometry;

/**
 * Set the geometry and write to bytes
 *
 * @param geometry
 *            geometry
 * @return geometry bytes
 */
-(NSData *) setDataWithGeometry:(SFGeometry *) geometry;

/**
 * Set the geometry, build the envelope, and write to bytes
 *
 * @param geometry
 *            geometry
 * @return geometry bytes
 */
-(NSData *) setDataAndBuildEnvelopeWithGeometry: (SFGeometry *) geometry;

/**
 * Set the geometry from Well-Known bytes
 *
 * @param bytes
 *            well-known bytes
 */
-(void) setGeometryFromWkb: (NSData *) bytes;

/**
 * Set the geometry from Well-Known text
 *
 * @param text
 *            well-known text
 */
-(void) setGeometryFromWkt: (NSString *) text;

/**
 *  Get the GeoPackage header byte data
 *
 *  @return header byte data
 */
-(NSData *) headerData;

/**
 *  Get the Well-Known Binary Geometry byte data
 *
 *  @return wkb byte data
 */
-(NSData *) wkb;

/**
 * Get a Well-Known text string from the geometry
 *
 * @return well-known text string
 */
-(NSString *) wkt;

/**
 * Get the envelope if it exists or build, set, and retrieve it from the
 * geometry
 *
 * @return geometry envelope
 */
-(SFGeometryEnvelope *) envelope;

/**
 * Build, set, and retrieve the envelope from the geometry
 *
 * @return geometry envelope
 */
-(SFGeometryEnvelope *) buildEnvelope;

/**
 * Get the envelope flag indicator
 *
 * 1 for xy, 2 for xyz, 3 for xym, 4 for xyzm (null would be 0)
 *
 *  @param envelope geometry envelope
 *
 *  @return flag indicator
 */
+(int) indicatorWithEnvelope: (SFGeometryEnvelope *) envelope;

/**
 * Transform the geometry data using the provided projection transform
 *
 * @param transform
 *            projection transform
 * @return transformed geometry data
 */
-(GPKGGeometryData *) transform: (SFPProjectionTransform *) transform;

@end
