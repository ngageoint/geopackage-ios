//
//  GPKGSpatialReferenceSystem.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "PROJProjection.h"
#import "SFPGeometryTransform.h"

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
@interface GPKGSpatialReferenceSystem : NSObject <NSMutableCopying>

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
 *  Well-known Text Representation of the Spatial Reference System
 */
@property (nonatomic, strong) NSString *definition;

/**
 *  Human readable description of this SRS
 */
@property (nonatomic, strong) NSString *theDescription;

/**
 *  Well-known Text extension Representation of the Spatial Reference System
 */
@property (nonatomic, strong) NSString *definition_12_063;

/**
 * Coordinate epoch
 */
@property (nonatomic, strong) NSDecimalNumber *epoch;

/**
 * Get the projection for the Spatial Reference System
 *
 * @return projection
 */
-(PROJProjection *) projection;

/**
 * Get the projection definition
 *
 * @return definition
 */
-(NSString *) projectionDefinition;

/**
 * Get the geometry transform from the provided projection to the Spatial
 * Reference System projection
 *
 * @param projection
 *            from projection
 * @return projection transform
 */
-(SFPGeometryTransform *) transformationFromProjection: (PROJProjection *) projection;

/**
 * Set the epoch value
 *
 * @param epoch
 *            epoch value
 */
-(void) setEpochValue: (double) epoch;

@end
