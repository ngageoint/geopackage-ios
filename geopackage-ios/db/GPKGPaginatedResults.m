//
//  GPKGPaginatedResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/14/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGPaginatedResults.h"
#import "GPKGSqlUtils.h"

@interface GPKGPaginatedResults ()

/**
 * Result Set
 */
@property (nonatomic, strong) GPKGResultSet *resultSet;

/**
 * SQL statement
 */
@property (nonatomic, strong) NSString *sql;

/**
 * SQL arguments
 */
@property (nonatomic, strong) NSArray *args;

@end

@implementation GPKGPaginatedResults

-(instancetype) initWithResultSet: (GPKGResultSet *) resultSet{
    self = [super init];
    if(self != nil){
        _resultSet = resultSet;
        _sql = resultSet.sql;
        _args = resultSet.args;
        _pagination = [GPKGPagination findInSQL:_sql];
        if(_pagination == nil){
            [NSException raise:@"Not Paginated" format:@"Results are not paginated. SQL: %@", _sql];
        }
    }
    return self;
}

-(GPKGDbConnection *) connection{
    return _resultSet.connection;
}

-(GPKGResultSet *) resultSet{
    return _resultSet;
}

-(NSString *) sql{
    return _sql;
}

-(NSArray *) args{
    return _args;
}

-(BOOL) moveToNext{
    BOOL hasNext = [_resultSet moveToNext];
    if(!hasNext){
        GPKGDbConnection *connection = _resultSet.connection;
        [self close];
        NSString *query = [_pagination replaceSQL:_sql];
        _resultSet = [GPKGSqlUtils queryWithDatabase:connection andStatement:query andArgs:_args];
        hasNext = [_resultSet moveToNext];
        if(!hasNext){
            [self close];
        }
    }
    return hasNext;
}

-(NSArray<NSObject *> *) row{
    return [_resultSet row];
}

-(void) close{
    [_resultSet close];
}

@end
