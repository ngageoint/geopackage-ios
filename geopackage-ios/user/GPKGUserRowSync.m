//
//  GPKGUserRowSync.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/20/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGUserRowSync.h"

@interface GPKGRowCondition : NSObject 

/**
 * Wait and signal condition
 */
@property (nonatomic, strong) NSCondition *condition;

/**
 * User row
 */
@property (nonatomic, strong) GPKGUserRow *row;

@end

@implementation GPKGRowCondition

@end

@interface GPKGUserRowSync()

@property (nonatomic, strong) NSMutableDictionary *rows;

@end

@implementation GPKGUserRowSync

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.rows = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(GPKGUserRow *) getRowOrLockId: (int) id{
    return [self getRowOrLockNumber:[[NSNumber alloc] initWithInt:id]];
}

-(GPKGUserRow *) getRowOrLockNumber: (NSNumber *) id{
    
    GPKGUserRow *row = nil;
    
    @synchronized(self.rows){
        GPKGRowCondition *rowCondition = [self.rows objectForKey:id];
        if(rowCondition != nil){
            row = rowCondition.row;
            if(row == nil){
                // Another thread is currently retrieving the row, wait
                [rowCondition.condition lock];
                [rowCondition.condition wait];
                [rowCondition.condition unlock];
                
                // Row has now been retrieved
                row = rowCondition.row;
            }
        } else{
            // Set the row condition and the calling thread is now
            // responsible for retrieving the row
            rowCondition = [[GPKGRowCondition alloc] init];
            NSCondition *condition = [[NSCondition alloc] init];
            [rowCondition setCondition:condition];
            [self.rows setObject:rowCondition forKey:id];
        }
    }
    
    return row;
}

-(void) setRow: (GPKGUserRow *) row withId: (int) id{
    return [self setRow:row withNumber:[[NSNumber alloc] initWithInt:id]];
}

-(void) setRow: (GPKGUserRow *) row withNumber: (NSNumber *) id{
    
    @synchronized(self.rows){
        
        GPKGRowCondition *rowCondition = [self.rows objectForKey:id];
        if(rowCondition != nil){
            [self.rows removeObjectForKey:id];
            [rowCondition setRow:row];
            [rowCondition.condition broadcast];
        }
        
    }
    
}

@end
