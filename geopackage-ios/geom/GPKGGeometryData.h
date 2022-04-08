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
#import "SFPGeometryTransform.h"
#import "GPKGBoundingBox.h"

/**
 *  GeoPackage Geometry Data
 */
@interface GPKGGeometryData : NSObject

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
 *  Geometry envelope
 */
@property (nonatomic, strong) SFGeometryEnvelope *envelope;

/**
 *  Spatial Reference System Id
 */
@property (nonatomic, strong) NSNumber *srsId;

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
 * @param data
 *            GeoPackage geometry byte data
 * @return geometry data
 */
+(GPKGGeometryData *) createWithData: (NSData *) data;

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
 * @param data
 *            well-known byte data
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkb: (NSData *) data;

/**
 * Create the geometry data from Well-Known Bytes and build the envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param data
 *            well-known byte data
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) data;

/**
 * Create the geometry data from Well-Known Bytes
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes and build the envelope
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndBuildEnvelopeFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes and write the GeoPackage
 * geometry bytes, default SRS Id of {@link #defaultSrsId}
 *
 * @param data
 *            well-known byte data
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) data;

/**
 * Create the geometry data from Well-Known Bytes, build the envelope, and
 * write the GeoPackage geometry bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param data
 *            well-known byte data
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) data;

/**
 * Create the geometry data from Well-Known Bytes and write the GeoPackage
 * geometry bytes
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createAndWriteFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * Create the geometry data from Well-Known Bytes, build the envelope, and
 * write the GeoPackage geometry bytes
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return geometry data
 */
+(GPKGGeometryData *) createBuildEnvelopeAndWriteFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * Create a geometry from Well-Known Bytes
 *
 * @param data
 *            well-known byte data
 * @return geometry
 */
+(SFGeometry *) createGeometryFromWkb: (NSData *) data;

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
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromGeometry: (SFGeometry *) geometry;

/**
 * GeoPackage geometry bytes from the geometry with built envelope, default
 * SRS Id of {@link #defaultSrsId()}
 *
 * @param geometry
 *            geometry
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry;

/**
 * GeoPackage geometry bytes from the geometry
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from the geometry with built envelope
 *
 * @param srsId
 *            SRS id
 * @param geometry
 *            geometry
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromGeometry: (SFGeometry *) geometry withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known bytes, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param data
 *            well-known byte data
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromWkb: (NSData *) data;

/**
 * GeoPackage geometry bytes from Well-Known bytes with built envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param data
 *            well-known byte data
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) data;

/**
 * GeoPackage geometry bytes from Well-Known bytes
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known bytes with built envelope
 *
 * @param data
 *            well-known byte data
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromWkb: (NSData *) data withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known text, default SRS Id of
 * {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromWkt: (NSString *) text;

/**
 * GeoPackage geometry bytes from Well-Known text with built envelope,
 * default SRS Id of {@link #defaultSrsId}
 *
 * @param text
 *            well-known text
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text;

/**
 * GeoPackage geometry bytes from Well-Known text
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * GeoPackage geometry bytes from Well-Known text with built envelope
 *
 * @param text
 *            well-known text
 * @param srsId
 *            SRS id
 * @return GeoPackage geometry byte data
 */
+(NSData *) dataAndBuildEnvelopeFromWkt: (NSString *) text withSrsId: (NSNumber *) srsId;

/**
 * Well-Known Bytes from the geometry data
 *
 * @param geometryData
 *            geometry data
 * @return well-known byte data
 */
+(NSData *) wkbFromGeometryData: (GPKGGeometryData *) geometryData;

/**
 * Well-Known Bytes from the geometry
 *
 * @param geometry
 *            geometry
 * @return well-known byte data
 */
+(NSData *) wkbFromGeometry: (SFGeometry *) geometry;

/**
 * Well-Known Bytes from GeoPackage geometry bytes
 *
 * @param data
 *            GeoPackage geometry byte data
 * @return well-known byte data
 */
+(NSData *) wkbFromData: (NSData *) data;

/**
 * Well-Known Bytes from Well-Known Text
 *
 * @param text
 *            well-known text
 * @return well-known byte data
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
 * @param data
 *            GeoPackage geometry byte data
 * @return well-known text
 */
+(NSString *) wktFromData: (NSData *) data;

/**
 * Well-Known Text from Well-Known Bytes
 *
 * @param data
 *            well-known byte data
 * @return well-known text
 */
+(NSString *) wktFromWkb: (NSData *) data;

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
 * @param data byte data
 *
 * @return new geometry data
 */
-(instancetype) initWithData: (NSData *) data;

/**
 *  Populate the geometry data from the byte data
 *
 *  @param data byte data
 */
-(void) fromData: (NSData *) data;

/**
 *  Write the geometry to byte data
 *
 *  @return byte data
 */
-(NSData *) toData;

/**
 * Get the bounding box of the geometry envelope
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) boundingBox;

/**
 * Get the geometry or read it from geometry bytes
 *
 * @return geometry
 */
-(SFGeometry *) getOrReadGeometry;

/**
 * Set the byte data
 *
 * @param data
 *            byte data
 */
-(void) setData: (NSData *) data;

/**
 * Set the byte data
 *
 * @param data
 *            byte data
 * @param wkbGeometryIndex
 *            well-known geometry byte data start index
 */
-(void) setData: (NSData *) data andGeometryIndex: (int) wkbGeometryIndex;

/**
 * Set the geometry header byte data
 *
 * @param headerData
 *            header byte data
 */
-(void) setHeaderData: (NSData *) headerData;

/**
 * Set the geometry byte data. Updates the empty flag. Extended flag should be
 * manually set with {@link #setExtended(boolean)} as needed.
 *
 * @param geometryData
 *            geometry byte data
 */
-(void) setGeometryData: (NSData *) geometryData;

/**
 * Set the geometry and write to bytes
 *
 * @param geometry
 *            geometry
 * @return geometry byte data
 */
-(NSData *) setDataWithGeometry:(SFGeometry *) geometry;

/**
 * Set the geometry, build the envelope, and write to bytes
 *
 * @param geometry
 *            geometry
 * @return geometry byte data
 */
-(NSData *) setDataAndBuildEnvelopeWithGeometry: (SFGeometry *) geometry;

/**
 * Set the geometry from Well-Known bytes
 *
 * @param data
 *            well-known byte data
 */
-(void) setGeometryFromWkb: (NSData *) data;

/**
 * Set the geometry from Well-Known text
 *
 * @param text
 *            well-known text
 */
-(void) setGeometryFromWkt: (NSString *) text;

/**
 * Clear the byte data
 */
-(void) clearData;

/**
 * Clear the header byte data and overall byte data
 */
-(void) clearHeaderData;

/**
 * Clear the geometry byte data and overall byte data
 */
-(void) clearGeometryData;

/**
 * Get the byte data of the entire GeoPackage geometry including GeoPackage
 * header and WKB bytes
 *
 * @return byte data
 */
-(NSData *) data;

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
-(SFGeometryEnvelope *) getOrBuildEnvelope;

/**
 * Build, set, and retrieve the envelope from the geometry
 *
 * @return geometry envelope
 */
-(SFGeometryEnvelope *) buildEnvelope;

/**
 * Get the bounding box of the geometry envelope if it exists or build, set
 * and retrieve it from the geometry
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) getOrBuildBoundingBox;

/**
 * Build, set, and retrieve the bounding box from the geometry
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) buildBoundingBox;

/**
 * Get the envelope flag indicator
 * <p>
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
 *            geometry transform
 * @return transformed geometry data
 */
-(GPKGGeometryData *) transform: (SFPGeometryTransform *) transform;

@end
