//
//  GPKGFeatureIndexResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/15/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"

@interface GPKGFeatureIndexResults ()

/**
 *  Strong reference of the last enumerated feature rows result to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray *rowsResult;

@end

@implementation GPKGFeatureIndexResults

-(instancetype) init{
    self = [super init];
    return self;
}

-(int) count{
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

-(BOOL) moveToNext{
    [self doesNotRecognizeSelector:_cmd];
    return false;
}

-(GPKGFeatureRow *) getFeatureRow{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSNumber *) getFeatureId{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) close{
    
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len{
    self.rowsResult = [NSMutableArray arrayWithCapacity:len];
    
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
        
        GPKGFeatureRow * row = [self getFeatureRow];
        [self.rowsResult addObject:row];
        stackbuf[count] = row;
        count += 1;
    }
    
    return count;
}

@end
