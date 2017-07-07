//
//  GPKGFeatureIndexResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/15/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"
#import "GPKGFeatureRow.h"

@interface GPKGFeatureIndexResults ()

/**
 *  Strong reference of enumerated feature rows to prevent garbage collection of enumerated items.
 */
@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic, strong) GPKGResultSet *results;

@end

@implementation GPKGFeatureIndexResults

-(instancetype) initWithResults: (GPKGResultSet *) results{
    self = [super init];
    if(self != nil){
        self.results = results;
    }
    return self;
}

-(GPKGResultSet *) getResults{
    return self.results;
}

-(int) count{
    return self.results.count;
}

-(void) close{
    [self.results close];
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
        if(![self.results moveToNext]){
            break;
        }
        
        GPKGFeatureRow * row = [self getFeatureRow];
        [self.rows addObject:row];
        stackbuf[count] = row;
        count += 1;
    }
    
    return count;
}

-(GPKGFeatureRow *) getFeatureRow{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
