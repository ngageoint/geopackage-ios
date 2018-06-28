//
//  GPKGUserMappingDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomDao.h"
#import "GPKGUserMappingTable.h"
#import "GPKGUserMappingRow.h"

/**
 * User Mapping DAO for reading user mapping data tables
 */
@interface GPKGUserMappingDao : GPKGUserCustomDao

/**
 *  Initialize
 *
 *  @param dao      user custom data access object
 *
 *  @return new user mapping dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 *  Get the user mapping table
 *
 *  @return user mapping table
 */
-(GPKGUserMappingTable *) table;

/**
 *  Get the user mapping row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return user mapping row
 */
-(GPKGUserMappingRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new user mapping row with the column types and values
 *
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return user mapping row as user row
 */
-(GPKGUserMappingRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Create a new user mapping row
 *
 *  @return user mapping row
 */
-(GPKGUserMappingRow *) newRow;

/**
 * Get a user mapping row from the user custom row
 *
 * @param row
 *            custom row
 * @return user mapping row
 */
-(GPKGUserMappingRow *) rowFromUserCustomRow: (GPKGUserCustomRow *) row;

/**
 * Query by base id
 *
 * @param userMappingRow
 *            user mapping row
 * @return result set
 */
-(GPKGResultSet *) queryByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Query by base id
 *
 * @param baseId
 *            base id
 * @return result set
 */
-(GPKGResultSet *) queryByBaseId: (int) baseId;

/**
 * Count by base id
 *
 * @param userMappingRow
 *            user mapping row
 * @return count
 */
-(int) countByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Count by base id
 *
 * @param baseId
 *            base id
 * @return count
 */
-(int) countByBaseId: (int) baseId;

/**
 * Query by related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return result set
 */
-(GPKGResultSet *) queryByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Query by related id
 *
 * @param relatedId
 *            related id
 * @return result set
 */
-(GPKGResultSet *) queryByRelatedId: (int) relatedId;

/**
 * Count by related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return count
 */
-(int) countByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Count by related id
 *
 * @param relatedId
 *            related id
 * @return count
 */
-(int) countByRelatedId: (int) relatedId;

/**
 * Query by both base id and related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return result set
 */
-(GPKGResultSet *) queryByIdsFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Query by both base id and related id
 *
 * @param baseId
 *            base id
 * @param relatedId
 *            related id
 * @return result set
 */
-(GPKGResultSet *) queryByBaseId: (int) baseId andRelatedId: (int) relatedId;

/**
 * Count by both base id and related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return count
 */
-(int) countByIdsFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Count by both base id and related id
 *
 * @param baseId
 *            base id
 * @param relatedId
 *            related id
 * @return count
 */
-(int) countByBaseId: (int) baseId andRelatedId: (int) relatedId;

/**
 * Delete user mappings by base id
 *
 * @param userMappingRow
 *            user mapping row
 * @return rows deleted
 */
-(int) deleteByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Delete user mappings by base id
 *
 * @param baseId
 *            base id
 * @return rows deleted
 */
-(int) deleteByBaseId: (int) baseId;

/**
 * Delete user mappings by related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return rows deleted
 */
-(int) deleteByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Delete user mappings by related id
 *
 * @param relatedId
 *            related id
 * @return rows deleted
 */
-(int) deleteByRelatedId: (int) relatedId;

/**
 * Delete user mappings by both base id and related id
 *
 * @param userMappingRow
 *            user mapping row
 * @return rows deleted
 */
-(int) deleteByIdsFromRow: (GPKGUserMappingRow *) userMappingRow;

/**
 * Delete user mappings by both base id and related id
 *
 * @param baseId
 *            base id
 * @param relatedId
 *            related id
 * @return rows deleted
 */
-(int) deleteByBaseId: (int) baseId andRelatedId: (int) relatedId;

@end
