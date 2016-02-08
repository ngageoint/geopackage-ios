//
//  GPKGFeatureTileLinkDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/3/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGFeatureTileLink.h"

@interface GPKGFeatureTileLinkDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new feature tile link dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Query by feature table name and tile table name for a link
 *
 *  @param featureTableName feature table name
 *  @param tileTableName tile table name
 *
 *  @return feature tile linke or nil
 */
-(GPKGFeatureTileLink *) queryForFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Query by feature table name
 *
 *  @param featureTableName feature table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForFeatureTableName: (NSString *) featureTable;

/**
 *  Query by tile table name
 *
 *  @param tileTableName tile table name
 *
 *  @return result set
 */
-(GPKGResultSet *) queryForTileTableName: (NSString *) tileTable;

/**
 *  Delete by feature table and tile table names
 *
 *  @param featureTableName feature table name
 *  @param tileTableName tile table name
 *
 *  @return rows deleted
 */
-(int) deleteByFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Delete by table name, either feature or tile table name
 *
 *  @param tableName table name
 *
 *  @return rows deleted
 */
-(int) deleteByTableName: (NSString *) tableName;

@end
