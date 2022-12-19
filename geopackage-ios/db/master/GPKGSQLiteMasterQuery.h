//
//  GPKGSQLiteMasterQuery.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGSQLiteMasterColumns.h"

/**
 * Query on the SQLiteMaster table
 */
@interface GPKGSQLiteMasterQuery : NSObject

/**
 * Add an equality query
 *
 * @param column
 *            column
 * @param value
 *            value
 */
-(void) addColumn: (enum GPKGSQLiteMasterColumn) column withValue: (NSString *) value;

/**
 * Add a query
 *
 * @param column
 *            column
 * @param operation
 *            operation
 * @param value
 *            value
 */
-(void) addColumn: (enum GPKGSQLiteMasterColumn) column withOperation: (NSString *) operation andValue: (NSString *) value;

/**
 * Add an is null query
 *
 * @param column
 *            column
 */
-(void) addIsNullColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Add an is not null query
 *
 * @param column
 *            column
 */
-(void) addIsNotNullColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Determine a query has been set
 *
 * @return true if has a query
 */
-(BOOL) has;

/**
 * Build the query SQL
 *
 * @return sql
 */
-(NSString *) buildSQL;

/**
 * Get the query arguments
 *
 * @return arguments
 */
-(NSArray<NSString *> *) arguments;

/**
 * Create an empty query that supports a single query
 *
 * @return query
 */
+(GPKGSQLiteMasterQuery *) create;

/**
 * Create a query with multiple queries combined by an OR
 *
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createOr;

/**
 * Create a query with multiple queries combined by an AND
 *
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createAnd;

/**
 * Create a single equality query
 *
 * @param column
 *            column
 * @param value
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createWithColumn: (enum GPKGSQLiteMasterColumn) column andValue: (NSString *) value;

/**
 * Create a single query
 *
 * @param column
 *            column
 * @param operation
 *            operation
 * @param value
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValue: (NSString *) value;

/**
 * Create an equality query with multiple values for a single column
 * combined with an OR
 *
 * @param column
 *            column
 * @param values
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createOrWithColumn: (enum GPKGSQLiteMasterColumn) column andValues: (NSArray<NSString *> *) values;

/**
 * Create a query with multiple values for a single column combined with an
 * OR
 *
 * @param column
 *            column
 * @param operation
 *            operation
 * @param values
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createOrWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValues: (NSArray<NSString *> *) values;

/**
 * Create an equality query with multiple values for a single column
 * combined with an AND
 *
 * @param column
 *            column
 * @param values
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createAndWithColumn: (enum GPKGSQLiteMasterColumn) column andValues: (NSArray<NSString *> *) values;

/**
 * Create a query with multiple values for a single column combined with an
 * AND
 *
 * @param column
 *            column
 * @param operation
 *            operation
 * @param values
 *            value
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createAndWithColumn: (enum GPKGSQLiteMasterColumn) column andOperation: (NSString *) operation andValues: (NSArray<NSString *> *) values;

/**
 * Create a query to find views in the sql column referring to the table
 *
 * @param tableName
 *            table name
 * @return query
 */
+(GPKGSQLiteMasterQuery *) createViewQueryWithTable: (NSString *) tableName;

@end
