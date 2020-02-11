//
//  GPKGFeatureIndexerIdQuery.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/11/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Feature Indexer Id query with nested SQL and arguments
 */
@interface GPKGFeatureIndexerIdQuery : NSObject

/**
 *  Initialize
 */
-(instancetype) init;

/**
 * Add an id argument
 *
 * @param id id value
 */
-(void) addArgument: (NSNumber *) id;

/**
 * Add an id argument
 *
 * @param id id value
 */
-(void) addArgumentInt: (int) id;

/**
 * Get the number of ids
 *
 * @return count
 */
-(int) count;

/**
 * Get the set of ids
 *
 * @return ids
 */
-(NSSet<NSNumber *> *) ids;

/**
 * Check if the query has the id
 *
 * @param id id
 * @return true if has id
 */
-(BOOL) hasId: (NSNumber *) id;

/**
 * Check if the query has the id
 *
 * @param id id
 * @return true if has id
 */
-(BOOL) hasIdInt: (int) id;

/**
 * Check if the total number of query arguments is above the maximum allowed in a single query
 *
 * @return true if above the maximum allowed query arguments
 */
-(BOOL) aboveMaxArguments;

/**
 * Check if the total number of query arguments is above the maximum allowed in a single query
 *
 * @param additionalArgs additional arguments
 * @return true if above the maximum allowed query arguments
 */
-(BOOL) aboveMaxArgumentsWithAdditionalArgs: (NSArray *) additionalArgs;

/**
 * Check if the total number of query arguments is above the maximum allowed in a single query
 *
 * @param additionalArgs additional argument count
 * @return true if above the maximum allowed query arguments
 */
-(BOOL) aboveMaxArgumentsWithAdditionalArgsCount: (int) additionalArgs;

/**
 * Get the SQL statement
 *
 * @return SQL
 */
-(NSString *) sql;

/**
 * Get the arguments
 *
 * @return args
 */
-(NSArray *) args;

@end
