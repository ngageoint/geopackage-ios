//
//  GPKGSqlLiteQueryBuilder.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/13/15.
//
//

#import "GPKGSqlLiteQueryBuilder.h"
#import "GPKGSqlUtils.h"

@implementation GPKGSqlLiteQueryBuilder

+(NSString *) buildQueryWithDistinct: (BOOL) distinct
                           andTable: (NSString *) table
                          andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    return [self buildQueryWithDistinct:distinct andTables:[[NSArray alloc] initWithObjects:table, nil] andColumns:columns andWhere:where andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}


+(NSString *) buildQueryWithDistinct: (BOOL) distinct
                           andTables: (NSArray *) tables
                          andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    
    if([self isEmpty:groupBy] && ![self isEmpty:having]){
        [NSException raise:@"Illegal Arguments" format:@"having clauses require a groupBy clause"];
    }
    
    NSMutableString * query = [NSMutableString string];
    
    [query appendString:@"select "];
    if(distinct){
        [query appendString:@"distinct "];
    }
    if(columns != nil && [columns count] > 0){
        [self appendColumnsToString:columns toString:query];
    }else{
        [query appendString:@"* "];
    }
    
    [query appendString:@"from "];
    for (int i = 0; i < tables.count; i++) {
        NSString * table = [tables objectAtIndex:i];
        if (i > 0) {
            [query appendString:@", "];
        }
        [query appendString:[GPKGSqlUtils quoteWrapName:table]];
    }
    [self appendClauseToString:query withName:@" where " andClause:where];
    [self appendClauseToString:query withName:@" group by " andClause:groupBy];
    [self appendClauseToString:query withName:@" having " andClause:having];
    [self appendClauseToString:query withName:@" order by " andClause:orderBy];
    [self appendClauseToString:query withName:@" limit " andClause:limit];
    
    return query;
}

+(void) appendClauseToString: (NSMutableString *) string withName: (NSString *) name andClause: (NSString *) clause{
    if(![self isEmpty:clause]){
        [string appendString:name];
        [string appendString:clause];
    }
}

+(void) appendColumnsToString: (NSArray *) columns toString: (NSMutableString *) string{
    
    BOOL first = true;
    for(NSString * column in columns){
        
        if(column != nil){
            if(first){
                first = false;
            }else{
                [string appendString:@", "];
            }
        }
        [string appendString:[GPKGSqlUtils quoteWrapName:column]];
    }
    [string appendString:@" "];
}

+(BOOL) isEmpty: (NSString *) string{
    return string == nil || [string length] == 0;
}

@end
