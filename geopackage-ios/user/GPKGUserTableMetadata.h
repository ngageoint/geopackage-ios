//
//  GPKGUserTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"

/**
 * Default ID column name
 */
extern NSString * const GPKG_UTM_DEFAULT_ID_COLUMN_NAME;

/**
 * User Table Metadata for defining table creation information
 */
@interface GPKGUserTableMetadata : NSObject

/**
 *  Table name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Data type
 */
@property (nonatomic, strong) NSString *dataType;

/**
 *  ID column name
 */
@property (nonatomic, strong) NSString *idColumnName;

/**
 * ID autoincrement flag
 */
@property (nonatomic) BOOL autoincrement;

/**
 * Additional table columns
 */
@property (nonatomic, strong) NSArray<GPKGUserColumn *> *additionalColumns;

/**
 * Table columns
 */
@property (nonatomic, strong) NSArray<GPKGUserColumn *> *columns;

/**
 *  Initialize
 *
 *  @return new user table metadata
 */
-(instancetype) init;

/**
 * Get the default data type
 *
 * @return default data type
 */
-(NSString *) defaultDataType;

/**
 * Build the table columns
 *
 * @return table columns
 */
-(NSArray<GPKGUserColumn *> *) buildColumns;

@end
