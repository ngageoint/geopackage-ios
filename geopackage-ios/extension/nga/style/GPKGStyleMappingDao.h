//
//  GPKGStyleMappingDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGUserMappingDao.h"
#import "GPKGStyleMappingRow.h"

/**
 * Style Mapping DAO for reading style mapping data tables
 */
@interface GPKGStyleMappingDao : GPKGUserMappingDao

/**
 *  Initialize
 *
 *  @param dao      user custom data access object
 *
 *  @return new style mapping dao
 */
-(instancetype) initWithDao: (GPKGUserCustomDao *) dao;

/**
 *  Get the style mapping table
 *
 *  @return style mapping table
 */
-(GPKGStyleMappingTable *) styleMappingTable;

/**
 *  Get the style mapping row for the current result in the result set
 *
 *  @param results result set
 *
 *  @return style mapping row
 */
-(GPKGStyleMappingRow *) row: (GPKGResultSet *) results;

/**
 *  Create a new style mapping row
 *
 *  @return style mapping row
 */
-(GPKGStyleMappingRow *) newRow;

/**
 * Query for style mappings by base id
 *
 * @param id base id, feature contents id or feature geometry id
 * @return style mappings rows
 */
-(NSArray<GPKGStyleMappingRow *> *) queryByBaseFeatureId: (int) id;

/**
 * Delete by base is and geometry type
 *
 * @param id           base id
 * @param geometryType geometry type
 * @return rows deleted
 */
-(int) deleteByBaseId: (int) id andGeometryType: (enum SFGeometryType) geometryType;

@end
