//
//  GPKGGeometryMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GPKG_GPGM_TABLE_NAME;
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

@interface GPKGGeometryMetadata : NSObject

@property (nonatomic, strong) NSNumber *geoPackageId;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSDecimalNumber *minX;
@property (nonatomic, strong) NSDecimalNumber *maxX;
@property (nonatomic, strong) NSDecimalNumber *minY;
@property (nonatomic, strong) NSDecimalNumber *maxY;
@property (nonatomic, strong) NSDecimalNumber *minZ;
@property (nonatomic, strong) NSDecimalNumber *maxZ;
@property (nonatomic, strong) NSDecimalNumber *minM;
@property (nonatomic, strong) NSDecimalNumber *maxM;

@end
