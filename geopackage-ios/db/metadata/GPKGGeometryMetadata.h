//
//  GPKGGeometryMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Table name
 */
extern NSString * const GPKG_GPGM_TABLE_NAME;

/**
 *  Column names
 */
extern NSString * const GPKG_GPGM_COLUMN_PK1;
extern NSString * const GPKG_GPGM_COLUMN_PK2;
extern NSString * const GPKG_GPGM_COLUMN_PK3;
extern NSString * const GPKG_GPGM_COLUMN_GEOPACKAGE_ID;
extern NSString * const GPKG_GPGM_COLUMN_TABLE_NAME;
extern NSString * const GPKG_GPGM_COLUMN_ID;
extern NSString * const GPKG_GPGM_COLUMN_MIN_X;
extern NSString * const GPKG_GPGM_COLUMN_MAX_X;
extern NSString * const GPKG_GPGM_COLUMN_MIN_Y;
extern NSString * const GPKG_GPGM_COLUMN_MAX_Y;
extern NSString * const GPKG_GPGM_COLUMN_MIN_Z;
extern NSString * const GPKG_GPGM_COLUMN_MAX_Z;
extern NSString * const GPKG_GPGM_COLUMN_MIN_M;
extern NSString * const GPKG_GPGM_COLUMN_MAX_M;

/**
 *  Geometry Metadata
 */
@interface GPKGGeometryMetadata : NSObject

/**
 *  GeoPackage id
 */
@property (nonatomic, strong) NSNumber *geoPackageId;

/**
 *  Table name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Geometry id
 */
@property (nonatomic, strong) NSNumber *id;

/**
 *  Min X
 */
@property (nonatomic, strong) NSDecimalNumber *minX;

/**
 *  Max X
 */
@property (nonatomic, strong) NSDecimalNumber *maxX;

/**
 *  Min Y
 */
@property (nonatomic, strong) NSDecimalNumber *minY;

/**
 *  Max Y
 */
@property (nonatomic, strong) NSDecimalNumber *maxY;

/**
 *  Min Z
 */
@property (nonatomic, strong) NSDecimalNumber *minZ;

/**
 *  Max Z
 */
@property (nonatomic, strong) NSDecimalNumber *maxZ;

/**
 *  Min M
 */
@property (nonatomic, strong) NSDecimalNumber *minM;

/**
 *  Max M
 */
@property (nonatomic, strong) NSDecimalNumber *maxM;

@end
