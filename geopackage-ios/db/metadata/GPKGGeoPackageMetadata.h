//
//  GPKGGeoPackageMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Table name
 */
extern NSString * const GPKG_GPM_TABLE_NAME;

/**
 *  Column names
 */
extern NSString * const GPKG_GPM_COLUMN_PK;
extern NSString * const GPKG_GPM_COLUMN_ID;
extern NSString * const GPKG_GPM_COLUMN_NAME;
extern NSString * const GPKG_GPM_COLUMN_PATH;

/**
 *  GeoPackage Metadata
 */
@interface GPKGGeoPackageMetadata : NSObject

/**
 *  GeoPackage id
 */
@property (nonatomic, strong) NSNumber *id;

/**
 *  GeoPackage name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  GeoPackage file path
 */
@property (nonatomic, strong) NSString *path;

@end
