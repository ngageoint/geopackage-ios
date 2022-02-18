//
//  GPKGObjectResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGObjectResultSet.h"

@interface GPKGObjectResultSet ()

/**
 *  Base DAO
 */
@property (nonatomic, strong) GPKGBaseDao *dao;

/**
 *  Result Set
 */
@property (nonatomic, strong) GPKGResultSet *resultSet;

/**
 *  Strong reference of the last enumerated objects to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray<NSObject *> *objects;

@end

@implementation GPKGObjectResultSet

+(GPKGObjectResultSet *) createWithDao: (GPKGBaseDao *) dao andResults: (GPKGResultSet *) resultSet{
    return [[GPKGObjectResultSet alloc] initWithDao:dao andResults:resultSet];
}

-(instancetype) initWithDao: (GPKGBaseDao *) dao andResults: (GPKGResultSet *) resultSet{
    self = [super init];
    if(self != nil){
        _dao = dao;
        _resultSet = resultSet;
    }
    return self;
}

-(GPKGBaseDao *) dao{
    return _dao;
}

-(GPKGResultSet *) resultSet{
    return _resultSet;
}

-(int) count{
    return _resultSet.count;
}

-(NSObject *) object{
    return [_dao object:_resultSet];
}

-(BOOL) moveToNext{
    return [_resultSet moveToNext];
}

-(BOOL) moveToFirst{
    return [_resultSet moveToFirst];
}

-(BOOL) moveToPosition: (int) position{
    return [_resultSet moveToPosition:position];
}

-(void) close{
    [_resultSet close];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len{
    self.objects = [NSMutableArray arrayWithCapacity:len];
    
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
        
        NSObject *object = [self object];
        [self.objects addObject:object];
        stackbuf[count] = object;
        count += 1;
    }
    
    return count;
}

@end
