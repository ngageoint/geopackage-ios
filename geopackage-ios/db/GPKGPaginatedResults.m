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
 * Result Count
 */
@property (nonatomic) int count;

/**
 * SQL statement
 */
@property (nonatomic, strong) NSString *sql;

/**
 * SQL arguments
 */
@property (nonatomic, strong) NSArray *args;

/**
 *  Strong reference of the last enumerated rows to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray<NSObject *> *rows;

@end

@implementation GPKGPaginatedResults

+(BOOL) isPaginated: (GPKGResultSet *) resultSet{
    return [self pagination:resultSet] != nil;
}

+(GPKGPagination *) pagination: (GPKGResultSet *) resultSet{
    return [GPKGPagination findInSQL:resultSet.sql];
}

+(GPKGPaginatedResults *) create: (GPKGResultSet *) resultSet{
    return [[GPKGPaginatedResults alloc] initWithResultSet:resultSet];
}

-(instancetype) initWithResultSet: (GPKGResultSet *) resultSet{
    self = [super init];
    if(self != nil){
        _resultSet = resultSet;
        _count = resultSet.count;
        _sql = resultSet.sql;
        _args = resultSet.args;
        _pagination = [GPKGPaginatedResults pagination:resultSet];
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

-(int) count{
    return _count;
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
        if([_pagination hasLimit]){
            [_pagination incrementOffset];
            if(_pagination.offset != nil && [_pagination.offset intValue] < _count){
                GPKGUserColumns *columns = _resultSet.columns;
                NSString *query = [_pagination replaceSQL:_sql];
                _resultSet = [GPKGSqlUtils queryWithDatabase:connection andStatement:query andArgs:_args];
                _resultSet.columns = columns;
                hasNext = [_resultSet moveToNext];
                if(!hasNext){
                    [self close];
                }
            }
        }
    }
    return hasNext;
}

-(NSArray<NSObject *> *) rowValues{
    return [_resultSet rowValues];
}

-(GPKGRow *) row{
    return [_resultSet row];
}

-(NSNumber *) id{
    return [_resultSet id];
}

-(void) close{
    [_resultSet close];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len{
    self.rows = [NSMutableArray arrayWithCapacity:len];
    
    // First call
    if(state->state == 0){
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
    }
    
    state->itemsPtr = stackbuf;
    
    NSUInteger count = 0;
    while (count < len) {
        if(![self moveToNext]){
            break;
        }
        
        NSObject *value = nil;
        if(self.ids){
            value = [self id];
        }else{
            value = [self row];
        }
        [self.rows addObject:value];
        stackbuf[count] = value;
        count += 1;
    }
    
    return count;
}

@end
