//
//  GPKGSqlLiteQueryBuilder.h
//  Pods
//
//  Created by Brian Osborn on 5/13/15.
//
//

#import <Foundation/Foundation.h>

@interface GPKGSqlLiteQueryBuilder : NSObject

+(NSString *) buildQueryWithDistinct: (BOOL) distinct
                            andTables: (NSString *) tables
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

+(void) appendColumnsToString: (NSArray *) columns toString: (NSMutableString *) string;

@end
