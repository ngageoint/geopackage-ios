//
//  GPKGUserCustomTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGUserCustomColumn.h"
#import "GPKGUserCustomColumns.h"

/**
 * Represents a user custom table
 */
@interface GPKGUserCustomTable : GPKGUserTable

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param columns   columns
 *
 *  @return new user custom table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param columns   columns
 *  @param requiredColumns   required columns
 *
 *  @return new user custom table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns;

/**
 *  Initializer
 *
 *  @param columns user custom columns
 *
 *  @return new user custom table
 */
-(instancetype) initWithColumns: (GPKGUserCustomColumns *) columns;

/**
 * Initialize
 *
 * @param userCustomTable
 *            user custom table
 *
 *  @return new user custom table
 */
-(instancetype) initWithCustomTable: (GPKGUserCustomTable *) userCustomTable;

/**
 * Get the user custom columns
 *
 * @return columns
 */
-(GPKGUserCustomColumns *) userCustomColumns;

@end
