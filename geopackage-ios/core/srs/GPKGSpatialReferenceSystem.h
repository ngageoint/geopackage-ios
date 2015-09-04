//
//  GPKGSpatialReferenceSystem.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Spatial Reference System table constants
 */
extern NSString * const GPKG_SRS_TABLE_NAME;
extern NSString * const GPKG_SRS_COLUMN_PK;
extern NSString * const GPKG_SRS_COLUMN_SRS_NAME;
extern NSString * const GPKG_SRS_COLUMN_SRS_ID;
extern NSString * const GPKG_SRS_COLUMN_ORGANIZATION;
extern NSString * const GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID;
extern NSString * const GPKG_SRS_COLUMN_DEFINITION;
extern NSString * const GPKG_SRS_COLUMN_DESCRIPTION;

/**
 * Spatial Reference System object. The coordinate reference system definitions
 * it contains are referenced by the GeoPackage Contents and
 * GeometryColumns objects to relate the vector and tile data in user
 * tables to locations on the earth.
 */
@interface GPKGSpatialReferenceSystem : NSObject

/**
 *  Human readable name of this SRS
 */
@property (nonatomic, strong) NSString *srsName;

/**
 *  Unique identifier for each Spatial Reference System within a GeoPackage
 */
@property (nonatomic, strong) NSNumber *srsId;

/**
 *  Case-insensitive name of the defining organization e.g. EPSG or epsg
 */
@property (nonatomic, strong) NSString *organization;

/**
 *  Numeric ID of the Spatial Reference System assigned by the organization
 */
@property (nonatomic, strong) NSNumber *organizationCoordsysId;

/**
 *  Well-known Text [32] Representation of the Spatial Reference System
 */
@property (nonatomic, strong) NSString *definition;

/**
 *  Human readable description of this SRS
 */
@property (nonatomic, strong) NSString *theDescription;

@end
