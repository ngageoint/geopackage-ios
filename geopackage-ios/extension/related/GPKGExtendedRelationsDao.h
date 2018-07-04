//
//  GPKGExtendedRelationsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGExtendedRelation.h"

/**
 * Extended Relations Data Access Object
 */
@interface GPKGExtendedRelationsDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new tile scaling dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Get the extended relation for the current result in the result set
 *
 *  @param results result set
 *
 *  @return extended relation
 */
-(GPKGExtendedRelation *) relation: (GPKGResultSet *) results;

/**
 *  Get the first extended relation in the result set and close it
 *
 *  @param results result set
 *
 *  @return first extended relation
 */
-(GPKGExtendedRelation *) firstRelation: (GPKGResultSet *) results;

/**
 * Get all the base table names
 *
 * @return base table names
 */
-(NSArray<NSString *> *) baseTables;

/**
 * Get all the related table names
 *
 * @return related table names
 */
-(NSArray<NSString *> *) relatedTables;

/**
 * Get the relations to the base table
 *
 * @param baseTable
 *            base table
 * @return extended relations results
 */
-(GPKGResultSet *) relationsToBaseTable: (NSString *) baseTable;

/**
 * Get the relations to the related table
 *
 * @param relatedTable
 *            related table
 * @return extended relations results
 */
-(GPKGResultSet *) relationsToRelatedTable: (NSString *) relatedTable;

/**
 * Get the relations to the table, both base table and related table
 *
 * @param table
 *            table name
 * @return extended relations results
 */
-(GPKGResultSet *) relationsToTable: (NSString *) table;

@end
