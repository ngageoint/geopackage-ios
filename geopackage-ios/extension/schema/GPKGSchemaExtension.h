//
//  GPKGSchemaExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGDataColumnConstraintsDao.h"

extern NSString * const GPKG_SCHEMA_EXTENSION_NAME;

/**
 *  Schema extension
 * <p>
 * <a href="https://www.geopackage.org/spec/#extension_schema">https://www.geopackage.org/spec/#extension_schema</a>
 */
@interface GPKGSchemaExtension : GPKGBaseExtension

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension definition URL
 */
@property (nonatomic, strong) NSString *definition;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get or create the extensions
 *
 *  @return extensions
 */
-(NSArray<GPKGExtensions *> *) extensionCreate;

/**
 *  Determine if the GeoPackage has the extension
 *
 *  @return true if has extension
 */
-(BOOL) has;

/**
 * Remove all trace of the extension
 */
-(void) removeExtension;

/**
 * Get a Data Columns DAO
 *
 * @return Data Columns DAO
 */
-(GPKGDataColumnsDao *) dataColumnsDao;

/**
 * Get a Data Columns DAO
 *
 * @param geoPackage
 *            GeoPackage
 *
 * @return Data Columns DAO
 */
+(GPKGDataColumnsDao *) dataColumnsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Data Columns DAO
 *
 * @param database
 *            database connection
 *
 * @return Data Columns DAO
 */
+(GPKGDataColumnsDao *) dataColumnsDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Data Columns table if it does not already exist
 *
 * @return true if created
 */
-(BOOL) createDataColumnsTable;

/**
 * Get a Data Column Constraints DAO
 *
 * @return Data Column Constraints DAO
 */
-(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDao;

/**
 * Get a Data Column Constraints DAO
 *
 * @param geoPackage
 *            GeoPackage
 *
 * @return Data Column Constraints DAO
 */
+(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Data Column Constraints DAO
 *
 * @param database
 *            database connection
 *
 * @return Data Column Constraints DAO
 */
+(GPKGDataColumnConstraintsDao *) dataColumnConstraintsDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Data Column Constraints table if it does not already exist
 *
 * @return true if created
 */
-(BOOL) createDataColumnConstraintsTable;

@end
