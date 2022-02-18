//
//  GPKGRowResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGRowResultSet.h"

@interface GPKGRowResultSet ()

/**
 *  Strong reference of the last enumerated rows to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray<GPKGUserRow *> *rows;

@end

@implementation GPKGRowResultSet

+(GPKGRowResultSet *) createWithDao: (GPKGUserDao *) dao andResults: (GPKGResultSet *) resultSet{
    return [[GPKGRowResultSet alloc] initWithDao:dao andResults:resultSet];
}

-(instancetype) initWithDao: (GPKGUserDao *) dao andResults: (GPKGResultSet *) resultSet{
    self = [super initWithDao:dao andResults:resultSet];
    return self;
}

-(GPKGUserDao *) dao{
    return (GPKGUserDao *) [super dao];
}

-(GPKGUserRow *) row{
    return [[self dao] row:[self resultSet]];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len{
    self.rows = [NSMutableArray arrayWithCapacity:len];
    
    // First call
    if(state->state == 0){
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
    }
    
    state->itemsPtr = stackbuf;
    
    GPKGResultSet *resultSet = [self resultSet];
    GPKGUserDao *dao = [self dao];
    
    NSUInteger count = 0;
    while (count < len) {
        if(![resultSet moveToNext]){
            break;
        }
        
        GPKGUserRow *row = [dao row:resultSet];
        [self.rows addObject:row];
        stackbuf[count] = row;
        count += 1;
    }
    
    return count;
}

@end
