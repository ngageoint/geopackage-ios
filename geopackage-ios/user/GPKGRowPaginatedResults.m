//
//  GPKGRowPaginatedResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGRowPaginatedResults.h"

@interface GPKGRowPaginatedResults ()

/**
 *  Strong reference of the last enumerated rows to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray<GPKGUserRow *> *rows;

@end

@implementation GPKGRowPaginatedResults

+(GPKGRowPaginatedResults *) createWithDao: (GPKGUserDao *) dao andResultSet: (GPKGResultSet *) resultSet{
    return [[GPKGRowPaginatedResults alloc] initWithDao:dao andResultSet:resultSet];
}

-(instancetype) initWithDao: (GPKGUserDao *) dao andResultSet: (GPKGResultSet *) resultSet{
    self = [super initWithDao:dao andResultSet:resultSet];
    return self;
}

-(GPKGUserDao *) dao{
    return (GPKGUserDao *) [super dao];
}

-(GPKGUserRow *) userRow{
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
    
    NSUInteger count = 0;
    while (count < len) {
        if(![self moveToNext]){
            break;
        }
        
        GPKGUserRow *row = [self userRow];
        [self.rows addObject:row];
        stackbuf[count] = row;
        count += 1;
    }
    
    return count;
}

@end
