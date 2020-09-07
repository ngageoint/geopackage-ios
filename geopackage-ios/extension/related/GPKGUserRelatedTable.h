//
//  GPKGUserRelatedTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserCustomTable.h"
#import "GPKGContents.h"

/**
 * User Defined Related Table
 */
@interface GPKGUserRelatedTable : GPKGUserCustomTable

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param relationName   relation name
 *  @param dataType contents data type
 *  @param columns   columns
 *
 *  @return new user related table
 */
-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andDataType: (NSString *) dataType andColumns: (NSArray<GPKGUserCustomColumn *> *) columns;

/**
 *  Initializer
 *
 *  @param tableName table name
 *  @param relationName   relation name
 *  @param dataType contents data type
 *  @param columns   columns
 *  @param requiredColumns   required columns
 *
 *  @return new user related table
 */
-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andDataType: (NSString *) dataType andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns;

/**
 * Initialize
 *
 * @param relationName   relation name
 * @param dataType contents data type
 * @param userCustomTable user custom table
 *
 * @return new user related table
 */
-(instancetype) initWithRelation: (NSString *) relationName andDataType: (NSString *) dataType andCustomTable: (GPKGUserCustomTable *) userCustomTable;

/**
 * Get the relation name
 *
 * @return relation name
 */
-(NSString *) relationName;

@end
