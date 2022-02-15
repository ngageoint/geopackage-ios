//
//  GPKGPagination.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Query pagination configuration
 */
@interface GPKGPagination : NSObject

/**
 * Find the pagination offset and limit from the SQL statement
 *
 * @param sql
 *            SQL statement
 * @return pagination or null if not found
 */
+(GPKGPagination *) findInSQL: (NSString *) sql;

/**
 * Replace the pagination limit and offset in the SQL statement
 *
 * @param sql
 *            SQL statement
 * @param pagination
 *            pagination settings
 * @return modified SQL statement
 */
+(NSString *) replaceSQL: (NSString *) sql withPagination: (GPKGPagination *) pagination;

/**
 * Limit
 */
@property (nonatomic) int limit;

/**
 * Offset
 */
@property (nonatomic, strong) NSNumber *offset;

/**
 * Initialize
 *
 * @param limit
 *            upper bound number of rows
 *
 * @return new pagination
 */
-(instancetype) initWithLimit: (int) limit;

/**
 * Initialize
 *
 * @param limit
 *            upper bound number of rows
 * @param offset
 *            row result starting offset
 *
 * @return new pagination
 */
-(instancetype) initWithLimit: (int) limit andOffsetInt: (int) offset;

/**
 * Initialize
 *
 * @param limit
 *            upper bound number of rows
 * @param offset
 *            row result starting offset
 *
 * @return new pagination
 */
-(instancetype) initWithLimit: (int) limit andOffset: (NSNumber *) offset;

/**
 * Is there positive limit
 *
 * @return true if limit above 0
 */
-(BOOL) hasLimit;

/**
 * Is there an offset
 *
 * @return true if has an offset
 */
-(BOOL) hasOffset;

/**
 * If the limit is positive, increment the offset
 */
-(void) incrementOffset;

/**
 * Increment the offset by the count
 *
 * @param count
 *            count to increment
 */
-(void) incrementOffsetByCount: (int) count;

/**
 * Replace the limit and offset in the SQL statement with the pagination
 * values
 *
 * @param sql
 *            SQL statement
 * @return modified SQL statement
 */
-(NSString *) replaceSQL: (NSString *) sql;

@end
