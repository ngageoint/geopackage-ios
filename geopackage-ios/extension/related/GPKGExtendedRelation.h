//
//  GPKGExtendedRelation.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Extended Relation table constants
 */
extern NSString * const GPKG_ER_TABLE_NAME;
extern NSString * const GPKG_ER_COLUMN_PK;
extern NSString * const GPKG_ER_COLUMN_ID;
extern NSString * const GPKG_ER_COLUMN_BASE_TABLE_NAME;
extern NSString * const GPKG_ER_COLUMN_BASE_PRIMARY_COLUMN;
extern NSString * const GPKG_ER_COLUMN_RELATED_TABLE_NAME;
extern NSString * const GPKG_ER_COLUMN_RELATED_PRIMARY_COLUMN;
extern NSString * const GPKG_ER_COLUMN_RELATION_NAME;
extern NSString * const GPKG_ER_COLUMN_MAPPING_TABLE_NAME;

/**
 * Describes the relationships between a base table, a related data table, and a mapping table
 */
@interface GPKGExtendedRelation : NSObject <NSMutableCopying>

/**
 *  Extended Relations primary key
 */
@property (nonatomic, strong) NSNumber *id;

/**
 *  Name of the table containing the base data (e.g., features) to relate
 */
@property (nonatomic, strong) NSString *baseTableName;

/**
 * Name of the primary key column in base_table_name
 */
@property (nonatomic, strong) NSString *basePrimaryColumn;

/**
 *  Name of the table containing the related information
 */
@property (nonatomic, strong) NSString *relatedTableName;

/**
 * Name of the primary key column in related_table_name
 */
@property (nonatomic, strong) NSString *relatedPrimaryColumn;

/**
 * Name of the relation
 */
@property (nonatomic, strong) NSString *relationName;

/**
 * Name of a mapping table
 */
@property (nonatomic, strong) NSString *mappingTableName;

/**
 *  Initialize
 *
 *  @return new extended relation
 */
-(instancetype) init;

/**
 *  Reset the id so the row can be inserted as new
 */
-(void) resetId;

/**
 *  Get the relation type
 *
 *  @return relation type
 */
-(enum GPKGRelationType) relationType;

@end
