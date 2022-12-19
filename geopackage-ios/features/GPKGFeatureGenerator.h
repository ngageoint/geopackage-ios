//
//  GPKGFeatureGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"
#import "GPKGProgress.h"
#import "PROJProjections.h"

/**
 * Feature Generator
 */
@interface GPKGFeatureGenerator : NSObject

/**
 * Features bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *boundingBox;

/**
 * Bounding Box projection
 */
@property (nonatomic, strong) PROJProjection *boundingBoxProjection;

/**
 * Features projection
 */
@property (nonatomic, strong) PROJProjection *projection;

/**
 * Number of rows to save in a single transaction
 */
@property (nonatomic) int transactionLimit;

/**
 *  Progress callbacks
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

/**
 *  Get the EPSG WGS84 projection
 *
 *  @return projection
 */
+(PROJProjection *) epsgWGS84;

/**
 *  Initialize with number range
 *
 *  @param geoPackage GeoPackage
 *  @param tableName  table name
 *
 *  @return new feature generator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage
                          andTable: (NSString *) tableName;

/**
 * Get the GeoPackage
 *
 * @return GeoPackage
 */
-(GPKGGeoPackage *) geoPackage;

/**
 * Get the table name
 *
 * @return table name
 */
-(NSString *) tableName;

/**
 * Determine if the feature generator should remain active
 *
 * @return true if active
 */
-(BOOL) isActive;

/**
 * Get the geometry columns
 *
 * @return geometry columns
 */
-(GPKGGeometryColumns *) geometryColumns;

/**
 * Get the columns
 *
 * @return columns
 */
-(NSDictionary<NSString *, GPKGFeatureColumn *> *) columns;

/**
 * Get the Spatial Reference System
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) srs;

/**
 * Get the feature DAO
 *
 * @return feature DAO
 */
-(GPKGFeatureDao *) featureDao;

/**
 * Generate the features
 *
 * @return generated count
 */
-(int) generateFeatures;

/**
 * Create the feature
 *
 * @param geometry
 *            geometry
 * @param properties
 *            properties
 * @throws SQLException
 *             upon error
 */
-(void) createFeatureWithGeometry: (SFGeometry *) geometry andProperties: (NSDictionary<NSString *, NSObject *> *) properties;

/**
 * Create the Spatial Reference System
 *
 * @throws SQLException
 *             upon error
 */
-(void) createSrs;

/**
 * Get the projection for creating the Spatial Reference System
 *
 * @return projection
 */
-(PROJProjection *) srsProjection;

/**
 * Create the geometry data
 *
 * @param geometry
 *            geometry
 * @return geometry data
 */
-(GPKGGeometryData *) createGeometryData: (SFGeometry *) geometry;

/**
 * Add a projection
 *
 * @param projections
 *            projections
 * @param authority
 *            authority
 * @param code
 *            code
 */
-(void) addProjectionWithAuthority: (NSString *) authority andCode: (NSString *) code toProjections: (PROJProjections *) projections;

/**
 * Create a projection
 *
 * @param authority
 *            authority
 * @param code
 *            code
 * @return projection
 */
-(PROJProjection *) createProjectionWithAuthority: (NSString *) authority andCode: (NSString *) code;

@end
