//
//  GPKGSqlLiteQueryBuilder.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/13/15.
//
//

#import <Foundation/Foundation.h>

/**
 *  SQL Builder
 */
@interface GPKGSqlLiteQueryBuilder : NSObject

/**
 *  Build SQL query
 *
 *  @param distinct true if distinct
 *  @param tables   tables
 *  @param columns  columns
 *  @param where    where clause
 *  @param groupBy  group by
 *  @param having   having
 *  @param orderBy  order by
 *  @param limit    limit
 *
 *  @return query sql
 */
+(NSString *) buildQueryWithDistinct: (BOOL) distinct
                            andTables: (NSString *) tables
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

/**
 *  Append columns to the string
 *
 *  @param columns columns
 *  @param string  string
 */
+(void) appendColumnsToString: (NSArray *) columns toString: (NSMutableString *) string;

@end
