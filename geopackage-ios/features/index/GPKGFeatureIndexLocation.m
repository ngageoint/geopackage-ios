//
//  GPKGFeatureIndexLocation.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/5/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureIndexLocation.h"

@interface GPKGFeatureIndexLocation ()

/**
 * Feature Index Manager
 */
@property (nonatomic, strong) GPKGFeatureIndexManager *manager;

/**
 * Feature index type query order
 */
@property (nonatomic, strong) NSArray *order;

/**
 * Feature index type query order index
 */
@property (nonatomic) int index;

/**
 *  Strong reference of the last enumerated index locations to prevent garbage collection
 */
@property (nonatomic, strong) NSMutableArray *indexLocations;

@end

@implementation GPKGFeatureIndexLocation

-(instancetype) initWithFeatureIndexManager: (GPKGFeatureIndexManager *) manager{
    self = [super self];
    if(self != nil){
        self.manager = manager;
        self.order = [manager indexLocationQueryOrder];
        self.index = 0;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len{
    self.indexLocations = [NSMutableArray arrayWithCapacity:len];
    
    // First call
    if(state->state == 0){
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
    }
    
    state->itemsPtr = stackbuf;
    
    NSUInteger count = 0;
    while (count < len) {
        
        enum GPKGFeatureIndexType type = GPKG_FIT_NONE;
        
        // Find the next indexed type
        while(self.index < self.order.count){
            NSString *nextTypeName = [self.order objectAtIndex:self.index++];
            enum GPKGFeatureIndexType nextType = [GPKGFeatureIndexTypes fromName:nextTypeName];
            if([self.manager isIndexedWithFeatureIndexType:nextType]){
                type = nextType;
                break;
            }
        }
        
        if(type == GPKG_FIT_NONE){
            break;
        }
        
        NSObject *value = [NSNumber numberWithInteger:type];
        [self.indexLocations addObject:value];
        stackbuf[count] = value;
        count += 1;
    }
    
    return count;
}

@end
