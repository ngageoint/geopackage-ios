//
//  GPKGUserMappingRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"
#import "GPKGUserMappingTable.h"

/**
 * User Mapping Row containing the values from a single result set row
 */
@interface GPKGUserMappingRow : GPKGUserCustomRow

/**
 *  Initialize
 *
 *  @param table       user mapping table
 *  @param columns   columns
 *  @param values      values
 *
 *  @return new user mapping row
 */
-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table user mapping table
 *
 *  @return new user mapping row
 */
-(instancetype) initWithUserMappingTable: (GPKGUserMappingTable *) table;

/**
 *  Get the user mapping table
 *
 *  @return user mapping table
 */
-(GPKGUserMappingTable *) table;

/**
 *  Get the base ID column index
 *
 *  @return base ID column index
 */
-(int) baseIdColumnIndex;

/**
 * Get the base ID column
 *
 * @return base ID column
 */
-(GPKGUserCustomColumn *) baseIdColumn;

/**
 * Get the base ID
 *
 * @return base ID
 */
-(int) baseId;

/**
 * Set the base ID
 *
 * @param baseId
 *            base ID
 */
-(void) setBaseId: (int) baseId;

/**
 *  Get the related ID column index
 *
 *  @return related ID column index
 */
-(int) relatedIdColumnIndex;

/**
 * Get the related ID column
 *
 * @return related ID column
 */
-(GPKGUserCustomColumn *) relatedIdColumn;

/**
 * Get the related ID
 *
 * @return related ID
 */
-(int) relatedId;

/**
 * Set the related ID
 *
 * @param relatedId
 *            related ID
 */
-(void) setRelatedId: (int) relatedId;

@end
