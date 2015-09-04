//
//  GPKGGeometryColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "WKBGeometryTypes.h"

/**
 *  Geometry Columns table constants
 */
extern NSString * const GPKG_GC_TABLE_NAME;
extern NSString * const GPKG_GC_COLUMN_PK1;
extern NSString * const GPKG_GC_COLUMN_PK2;
extern NSString * const GPKG_GC_COLUMN_TABLE_NAME;
extern NSString * const GPKG_GC_COLUMN_COLUMN_NAME;
extern NSString * const GPKG_GC_COLUMN_GEOMETRY_TYPE_NAME;
extern NSString * const GPKG_GC_COLUMN_SRS_ID;
extern NSString * const GPKG_GC_COLUMN_Z;
extern NSString * const GPKG_GC_COLUMN_M;

/**
 * Geometry Columns object. Identifies the geometry columns in tables that
 * contain user data representing features.
 */
@interface GPKGGeometryColumns : NSObject

/**
 *  Name of the table containing the geometry column
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Name of a column in the feature table that is a Geometry Column
 */
@property (nonatomic, strong) NSString *columnName;

/**
 * Name from Geometry Type Codes (Core) or Geometry Type Codes (Extension)
 * in Geometry Types (Normative)
 */
@property (nonatomic, strong) NSString *geometryTypeName;

/**
 *  Unique identifier for each Spatial Reference System within a GeoPackage
 */
@property (nonatomic, strong) NSNumber *srsId;

/**
 *  0: z values prohibited; 1: z values mandatory; 2: z values optional
 */
@property (nonatomic, strong) NSNumber *z;

/**
 *  0: m values prohibited; 1: m values mandatory; 2: m values optional
 */
@property (nonatomic, strong) NSNumber *m;

/**
 *  Get the geometry type
 *
 *  @return geometry type
 */
-(enum WKBGeometryType) getGeometryType;

/**
 *  Set the geometry type
 *
 *  @param geometryType geometry type
 */
-(void) setGeometryType: (enum WKBGeometryType) geometryType;

/**
 *  Set the z
 *
 *  @param z z
 */
-(void) setZ:(NSNumber *)z;

/**
 *  Set the m
 *
 *  @param m m
 */
-(void) setM:(NSNumber *)m;

/**
 *  Set the Contents
 *
 *  @param contents contents
 */
-(void) setContents: (GPKGContents *) contents;

/**
 *  Set the Spatial Reference System
 *
 *  @param srs srs
 */
-(void) setSrs: (GPKGSpatialReferenceSystem *) srs;

@end
