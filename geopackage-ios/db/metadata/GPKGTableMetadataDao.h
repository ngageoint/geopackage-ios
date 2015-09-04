//
//  GPKGTableMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTableMetadata.h"

/**
 * Table Metadata Data Access Object
 */
@interface GPKGTableMetadataDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database conneciton
 *
 *  @return new table metadata
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete table metadata
 *
 *  @param metadata metadata
 *
 *  @return true if deleted
 */
-(BOOL) deleteMetadata: (GPKGTableMetadata *) metadata;

/**
 *  Delete table metadata by GeoPackage name
 *
 *  @param name GeoPackage name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageName: (NSString *) name;

/**
 *  Delete table metadata by GeoPackage id
 *
 *  @param geoPackageId GeoPackage id
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId;

/**
 *  Delete table metadata by GeoPackage name and table name
 *
 *  @param name      GeoPackage name
 *  @param tableName table name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

/**
 *  Delete table metadata by GeoPackage id and table name
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Update last indexed date of table metadata
 *
 *  @param lastIndexed date
 *  @param metadata    metadata
 *
 *  @return true if updated
 */
-(BOOL) updateLastIndexed: (NSDate *) lastIndexed inMetadata: (GPKGTableMetadata *) metadata;

/**
 *  Update last indexed of table metadata
 *
 *  @param lastIndexed date
 *  @param name        GeoPackage name
 *  @param tableName   table name
 *
 *  @return true if updated
 */
-(BOOL) updateLastIndexed: (NSDate *) lastIndexed withGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

/**
 *  Update last indexed of table metadata
 *
 *  @param lastIndexed  date
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return true if updated
 */
-(BOOL) updateLastIndexed: (NSDate *) lastIndexed withGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Get table metadata by GeoPackage name and table name
 *
 *  @param name      GeoPackage name
 *  @param tableName table name
 *
 *  @return table metadata
 */
-(GPKGTableMetadata *) getMetadataByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

/**
 *  Get table metadata by GeoPackage id and table name
 *
 *  @param geoPackageId GeoPackage id
 *  @param tableName    table name
 *
 *  @return table metadata
 */
-(GPKGTableMetadata *) getMetadataByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

/**
 *  Get or create table metadata by GeoPackage table and table name
 *
 *  @param name      GeoPackage name
 *  @param tableName table name
 *
 *  @return table metadata
 */
-(GPKGTableMetadata *) getOrCreateMetadataByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

/**
 *  Get GeoPackage Id for GeoPackage name
 *
 *  @param name GeoPackage name
 *
 *  @return GeoPackage id
 */
-(NSNumber *) getGeoPackageIdForGeoPackageName: (NSString *) name;

@end
