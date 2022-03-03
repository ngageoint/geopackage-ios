//
//  GPKGObjectPaginatedResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGObjectPaginatedResults.h"

@interface GPKGObjectPaginatedResults ()

/**
 * Base DAO
 */
@property (nonatomic, strong) GPKGBaseDao *dao;

/**
 *  Strong reference of the last enumerated objects to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray<NSObject *> *objects;

@end

@implementation GPKGObjectPaginatedResults

+(GPKGObjectPaginatedResults *) createWithDao: (GPKGBaseDao *) dao andResultSet: (GPKGResultSet *) resultSet{
    return [[GPKGObjectPaginatedResults alloc] initWithDao:dao andResultSet:resultSet];
}

-(instancetype) initWithDao: (GPKGBaseDao *) dao andResultSet: (GPKGResultSet *) resultSet{
    self = [super initWithResultSet:resultSet];
    if(self != nil){
        _dao = dao;
    }
    return self;
}

-(GPKGBaseDao *) dao{
    return _dao;
}

-(NSObject *) object{
    return [_dao object:[self resultSet]];
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
        
        NSObject *value = nil;
        if(self.ids){
            value = [self id];
        }else{
            value = [self object];
        }
        [self.objects addObject:value];
        stackbuf[count] = value;
        count += 1;
    }
    
    return count;
}

@end
